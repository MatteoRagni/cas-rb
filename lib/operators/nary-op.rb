#!/usr/bin/env ruby

# Copyright (c) 2016 Matteo Ragni
#
# Permission is hereby granted, free of charge, to any person
# obtaining a copy of this software and associated documentation
# files (the "Software"), to deal in the Software without
# restriction, including without limitation the rights to use,
# copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following
# conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
# OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
# HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
# WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.

module CAS
  module Internals
    module NaryOp
      # Returns the dependencies of the operation. Require a `CAS::Variable`
      # and it is one of the recursive method (implicit tree resolution)
      #
      #  * **argument**: `CAS::Variable` instance
      #  * **returns**: `TrueClass` or `FalseClass`
      def depend?(v)
        CAS::Help.assert(v, CAS::Op)
        ret = false
        @x.each do |y|
          ret |= y.depend?(v)
        end
        return ret
      end

      # Return a list of derivative using the chain rule. The input is a
      # operation:
      #
      # ```
      #  f(x) = g(x) + h(x) + l(x) + m(x)
      #
      #  d f(x)
      #  ------ = g'(x) + h'(x) + l'(x) + m'(x)
      #    dx
      #
      #  d f(x)
      #  ------ = 1
      #  d g(x)
      # ```
      #  * **argument**: `CAS::Op` object of the derivative
      #  * **returns**: `CAS::NaryOp` of derivative
      def diff(v)
        CAS::Help.assert(v, CAS::Op)
        if self.depend?(v)
          return @x.map { |x| x.diff(v) }
        end
        return CAS::Zero
      end

      # Call resolves the operation tree in a `Numeric` (if `Fixnum`)
      # or `Float` depends upon promotions).
      # As input, it requires an hash with `CAS::Variable` or `CAS::Variable#name`
      # as keys, and a `Numeric` as a value
      #
      # ``` ruby
      # x, y = CAS::vars :x, :y
      # f = (x ** 2) + (y ** 2)
      # f.call({x => 1, y => 2})
      # # => 2
      # ```
      #  * **argument**: `Hash` with feed dictionary
      #  * **returns**: `Array` of `Numeric`
      def call(fd)
        CAS::Help.assert(fd, Hash)
        return @x.map { |x| x.call(fd) }
      end

      # Perform substitution of a part of the graph using a data table:
      #
      # ``` ruby
      # x, y = CAS::vars :x, :y
      # f = (x ** 2) + (y ** 2)
      # puts f
      # # => (x^2) + (y^2)
      # puts f.subs({x => CAS::ln(y)})
      # # => (ln(y)^2) + (y^2)
      # ```
      #
      #  * **argument**: `Hash` with substitution table
      #  * **returns**: `CAS::NaryOp` (`self`) with substitution performed
      def subs(dt)
        CAS::Help.assert(dt, Hash)
        @x = @x.map { |z| z.subs(dt) || z }
        @x.each_with_index do |x, k|
          sub = dt.keys.select { |e| e == x }[0]
          if sub
            if dt[sub].is_a? CAS::Op
              @x[k] = dt[sub]
            elsif dt[sub].is_a? Numeric
              @x[k] = CAS::const dt[sub]
            else
              raise CAS::CASError, "Impossible subs. Received a #{dt[sub].class} = #{dt[sub]}"
            end
          end
        end
        return self
      end

      # Convert expression to string
      #
      #  * **returns**: `String` to print on screen
      def to_s
        return "(#{@x.map(&:to_s).join(", ")})"
      end

      # Convert expression to code (internal, for `CAS::Op#to_proc` method)
      #
      #  * **returns**: `String` that represent Ruby code to be parsed in `CAS::Op#to_proc`
      def to_code
        return "(#{@x.map(&:to_code).join(", ")})"
      end

      # Simplification callback. It simplify the subgraph of each node
      # until all possible simplification are performed (thus the execution
      # time is not deterministic).
      #
      #  * **returns**: `CAS::Op` simplified
      def simplify
        hash = self.to_s
        @x = @x.map { |x| x.simplify }
        while self.to_s != hash
          hash = self.to_s
          @x = @x.map { |x| x.simplify }
        end
      end

      # Inspector for the current object
      #
      #  * **returns**: `String`
      def inspect
        "#{self.class}(#{@x.map(&:inspect).join(", ")})"
      end

      # Equality operator, the standard operator is overloaded
      # :warning: this operates on the graph, not on the math
      # See `CAS::equal`, etc.
      #
      #  * **argument**: `CAS::Op` to be tested against
      #  * **returns**: `TrueClass` if equal, `FalseClass` if differs
      def ==(op)
        # CAS::Help.assert(op, CAS::Op)
        if op.is_a? CAS::NaryOp
          return false if @x.size != op.x.size
          0.upto(@x.size - 1) do |i|
            return false if @x[i] != op.x[i]
          end
          return true
        end
        false
      end

      # Returns a list of all `CAS::Variable`s of the current tree
      #
      #  * **returns**: `Array` of `CAS::Variable`s
      def args
        r = []
        @x.each { |x| r += x.args }
        return r.uniq
      end

      # Reduce multeplicity will scan for elements that are equal in the definition
      # of the sum and will reduce their multeplicity. A block can be used to do something
      # different. For example in nary-product we use it like this:
      #
      # ``` ruby
      # @x = self.__reduce_multeplicity(@x) do |count, op|
      #   count > 1 ? (op ** count) : op
      # end
      # ```
      #
      # In general it works like that:
      #
      # ```
      #  a + a + b + c => 2 * a + b + c
      #  a * a * b * a => (a ** b) * b
      # ```
      # But operates only on Array level! This is an internal function
      # and should never be used
      #
      #  * **requires**: An `Array`
      #  * **returns**: An `Array` with multeplicity reduced
      #  * **block**: yields the count and the op. Get the value to insert in a new
      #    `Array` that is the returned `Array`
      def __reduce_multeplicity(xs)
        count = Hash.new(0)
        xs.each do |x|
          e = x
          count.keys.each { |d| e = d if x == d  }
          count[e] += 1
        end
        count.map do |k, v|
          if block_given?
            yield(k, v)
          else
            v > 1 ? CAS.const(v) * k : k
          end
        end
      end

      # Collects all the constants and tries to reduce them to a single constant.
      # Requires a block to understand what it should do with the constants
      #
      # * **requires**: input `Array` of `CAS::Op`
      # * **returns**: new `Array` of `CAS::Op`
      # * **block**: yields an `Array` of `CAS::Constant` and an `Array` of others `CAS::Op`,
      #   requires an `Array` back
      def __reduce_constants(xs)
        const = []
        xs.each { |x| const << x if x.is_a? CAS::Constant }
        if const.size > 0
          yield const, (xs - const)
        else
          xs
        end
      end
    end
  end

  # This is an attempt to build some sort of node in the graph that
  # has arbitrary number of childs node. It should help implement more easily
  # some sort of better simplifications engine
  #
  # This is an incredibly experimental feature.
  class NaryOp < CAS::Op
    # List of arguments of the operation
    attr_reader :x

    # Initialize a new empty N-elements operation container. This is
    # a virtual class, and other must inherit from this basical container
    #
    #  * **argument**: `Numeric` to be converted in `CAS::Constant` or `CAS::Op` child operations
    #  * **returns**: `CAS::NaryOp` instance
    def initialize(*xs)
      @x = []
      xs.flatten.each do |x|
        if x.is_a? Numeric
          x = Op.numeric_to_const x
        end
        CAS::Help.assert(x, CAS::Op)
        @x << x
      end
    end

    include CAS::Internals::NaryOp
  end # NaryOp
  CAS::NaryOp.init_simplify_dict
end
