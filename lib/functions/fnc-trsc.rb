#!/usr/bin/env ruby

# Copyright (c)  Matteo Ragni
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
  #  ___                            _
  # | __|_ ___ __  ___ _ _  ___ _ _| |_
  # | _|\ \ / '_ \/ _ \ ' \/ -_) ' \  _|
  # |___/_\_\ .__/\___/_||_\___|_||_\__|
  #         |_|

  ##
  # Representation for the `e^x` function. It is implemented
  # as a `CAS::Op`
  class Exp < CAS::Op
    # Return the derivative of the `sin(x)` function using the chain
    # rule. The input is a `CAS::Op` because it can handle derivatives
    # with respect to functions.
    #
    # ```
    #  d
    # -- exp(f(x)) = f'(x) exp(f(x))
    # dx
    # ```
    #
    #  * **argument**: `CAS::Op` object of the derivative
    #  * **returns**: `CAS::Op` a derivated object, or `CAS::Zero` for constants
    def diff(v)
      if @x.depend? v
        return @x.diff(v) * CAS.exp(@x)
      else
        return CAS::Zero
      end
    end

    # Call resolves the operation tree in a `Numeric` (if `Fixnum`)
    # or `Float` (depends upon promotions).
    # As input, it requires an hash with `CAS::Variable` or `CAS::Variable#name`
    # as keys, and a `Numeric` as a value
    #
    #  * **argument**: `Hash` with feed dictionary
    #  * **returns**: `Numeric`
    def call(f)
      CAS::Help.assert(f, Hash)
      Math::exp(@x.call(f))
    end

    # Convert expression to string
    #
    #  * **returns**: `String` to print on screen
    def to_s
      "exp(#{@x})"
    end

    # Simplification callback. It simplify the subgraph of each node
    # until all possible simplification are performed (thus the execution
    # time is not deterministic).
    #
    #  * **returns**: `CAS::Op` simplified version
    def simplify
      super
      return @x.x if @x.is_a? CAS::Ln
      return self.simplify_dictionary
    end

    def self.init_simplify_dict
      @simplify_dict = {
        CAS::Zero => CAS::One,
        CAS::One => CAS::E,
        CAS::Infinity => CAS::Infinity
      }
    end

    # Convert expression to code (internal, for `CAS::Op#to_proc` method)
    #
    #  * **returns**: `String` that represent Ruby code to be parsed in `CAS::Op#to_proc`
    def to_code
      "Math::exp(#{@x.to_code})"
    end

    # Returns the latex representation of the current Op.
    #
    #  * **returns**: `String`
    def to_latex
      "e^{#{@x.to_latex}}"
    end
  end # Exp
  CAS::Exp.init_simplify_dict

  # Shortcut for `CAS::Exp#new`
  #
  #  * **argument**: `CAS::Op` argument of the function
  #  * **returns**: `CAS::Exp` operation
  def self.exp(x)
    CAS::Exp.new x
  end

  #  _                       _ _   _
  # | |   ___  __ _ __ _ _ _(_) |_| |_  _ __
  # | |__/ _ \/ _` / _` | '_| |  _| ' \| '  \
  # |____\___/\__, \__,_|_| |_|\__|_||_|_|_|_|
  #           |___/

  ##
  # Representation for the `log(x)` function. It is implemented
  # as a `CAS::Op`
  class Ln < CAS::Op
    # Return the derivative of the `log(x)` function using the chain
    # rule. The input is a `CAS::Op` because it can handle derivatives
    # with respect to functions.
    #
    # ```
    #  d              f'(x)
    # -- log(f(x)) = -------
    # dx               f(x)
    # ```
    #
    #  * **argument**: `CAS::Op` object of the derivative
    #  * **returns**: `CAS::Op` a derivated object, or `CAS::Zero` for constants
    def diff(v)
      if @x.depend? v
        return CAS::One / @x
      else
        return CAS::Zero
      end
    end

    # Call resolves the operation tree in a `Numeric` (if `Fixnum`)
    # or `Float` (depends upon promotions).
    # As input, it requires an hash with `CAS::Variable` or `CAS::Variable#name`
    # as keys, and a `Numeric` as a value
    #
    #  * **argument**: `Hash` with feed dictionary
    #  * **returns**: `Numeric`
    def call(f)
      # I'm leaving to Math the honor
      # of handling negative values...
      CAS::Help.assert(f, Hash)
      Math::log(@x.call(f))
    end

    # Convert expression to string
    #
    #  * **returns**: `String` to print on screen
    def to_s
      "log(#{@x})"
    end

    # Simplification callback. It simplify the subgraph of each node
    # until all possible simplification are performed (thus the execution
    # time is not deterministic).
    #
    #  * **returns**: `CAS::Op` simplified version
    def simplify
      super
      return @x.x if @x.is_a? CAS::Exp
      return self.simplify_dictionary
    end

    def self.init_simplify_dict
      @simplify_dict = {
        CAS::Zero => CAS.invert(CAS::Infinity),
        CAS::One => CAS::Zero,
        CAS::E => CAS::One
      }
    end

    # Convert expression to code (internal, for `CAS::Op#to_proc` method)
    #
    #  * **returns**: `String` that represent Ruby code to be parsed in `CAS::Op#to_proc`
    def to_code
      "Math::log(#{@x.to_code})"
    end

    # Returns the latex representation of the current Op.
    #
    #  * **returns**: `String`
    def to_latex
      "\\log\\left( #{@x.to_latex} \\right)"
    end
  end # Ln
  CAS::Ln.init_simplify_dict

  class << self
    # Shortcut for `CAS::Ln#new`
    #
    #  * **argument**: `CAS::Op` argument of the function
    #  * **returns**: `CAS::Ln` operation
    def ln(x)
      CAS::Ln.new x
    end
    alias :log :ln
  end
end
