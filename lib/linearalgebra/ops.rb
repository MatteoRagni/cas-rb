#!/usr/vin/env ruby

# Copyright (c) 2017 Matteo Ragni
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
  #  _    _                    _   _          _
  # | |  (_)_ _  ___ __ _ _ _ /_\ | |__ _ ___| |__ _ _ __ _
  # | |__| | ' \/ -_) _` | '_/ _ \| / _` / -_) '_ \ '_/ _` |
  # |____|_|_||_\___\__,_|_|/_/ \_\_\__, \___|_.__/_| \__,_|
  #                                 |___/
  module LinearAlgebra
    #  _      _   _ _ ___
    # | |    /_\ (_|_) _ \ _ __
    # | |__ / _ \ _ | (_) | '_ \
    # |____/_/ \_(_|_)___/| .__/
    #                     |_|
    class Op < CAS::Op
      def initialize(x)
        CAS::Help.assert(x, CAS::LinearAlgebra::Op)
        @x = x
      end

      def +(op)
        CAS::LinearAlgebra::Sum.new(self, op)
      end

      def -(op)
        CAS::LinearAlgebra::Diff.new(self, op)
      end

      def *(op)
        if op.is_a? CAS::LinearAlgebra::Op
          CAS::LinearAlgebra::Prod.new(self, op)
        else
          CAS::LinearAlgebra::Scale.new(self, op)
        end
      end

      def /(op)
        raise RuntimeError, "Not implemented yet!"
      end

      def **(op)
        CAS::LinearAlgebra::Pow.new(self, op)
      end

      def -@
        CAS::LinearAlgebra::Invert.new(self)
      end
    end # Op
    CAS::LinearAlgebra::Op.init_simplify_dict

    #  _      _   _ _ ___ _                     ___
    # | |    /_\ (_|_) _ |_)_ _  __ _ _ _ _  _ / _ \ _ __
    # | |__ / _ \ _ _| _ \ | ' \/ _` | '_| || | (_) | '_ \
    # |____/_/ \_(_|_)___/_|_||_\__,_|_|  \_, |\___/| .__/
    #                                     |__/      |_|
    class BinaryOp < CAS::LinearAlgebra::Op
      def initialize(x, y)
        CAS::Help.assert(x, CAS::LinearAlgebra::Op)
        CAS::Help.assert(y, CAS::LinearAlgebra::Op)
        @x, @y = x, y
      end

      prepend CAS::Internals::BinaryOp
    end # BinaryOp
    CAS::LinearAlgebra::BinaryOp.init_simplify_dict

    #  _      _   _ _ _  _                ___
    # | |    /_\ (_|_) \| |__ _ _ _ _  _ / _ \ _ __
    # | |__ / _ \ _ _| .` / _` | '_| || | (_) | '_ \
    # |____/_/ \_(_|_)_|\_\__,_|_|  \_, |\___/| .__/
    #                               |__/      |_|
    class NaryOp < CAS::LinearAlgebra::Op
      def initialize(*xs)
        @x = []
        xs.flatten.each do |x|
          CAS::Help.assert(x, CAS::LinearAlgebra::Op)
          @x << x
        end
      end

      prepend CAS::Internals::NaryOp
    end
    CAs::LinearAlgebra::NaryOp.init_simplify_dict

    #  _      _   _ _ ___
    # | |    /_\ (_|_) __|_  _ _ __
    # | |__ / _ \ _ _\__ \ || | '  \
    # |____/_/ \_(_|_)___/\_,_|_|_|_|
    class Sum < CAS::LinearAlgebra::NaryOp
      def +(op)
        CAS::Help.assert(op, CAS::LinearAlgebra::Op)
        @x << op
        self
      end

      def to_s
        "(#{@x.map(&:to_s).join(" + ")})"
      end

      def simplify
        super
        return @x[0] if @x.size == 1

        @x = @x - [CAS::LinearAlgebra::Zero]
        return CAS::LinearAlgebra::Zero if @x.size == 0
        # Reduce constants
        @x = self.__reduce_constants(@x) do |cs, xs|
          xs + [cs.inject { |t, c| t += c.call({}) }]
        end
        # Multeplicity and associativity executed
        return self.reduce_associativity
      end

      def reduce_associativity
        pos, neg = [], []

        @x.each do |x_el|
          case x_el
          when CAS::LinearAlgebra::Invert
            neg << x_el.x
          when CAS::LinearAlgebra::Diff
            pos << x_el.x
            neg << x_el.y
          else
            pos << x_el
          end
        end

        pos, neg = self.reduce_associativity_array pos, neg
        pos = self.__reduce_multeplicity(pos)
        neg = self.__reduce_multeplicity(neg)

        # TODO : Add rules for simplifications
        left, right = nil, nil
        left  = CAS::LinearAlgebra::Sum.new(pos) if pos.size > 1
        left  = pos[0]                           if pos.size == 1
        right = CAS::Sum.new(neg)                if neg.size > 1
        right = neg[0]                           if neg.size == 1

        return  CAS::LinearAlgebra::Zero unless left || right
        return  left unless right
        return  -right unless left
        return left - right
      end
    end
    CAS::LinearAlgebra::Sum.init_simplify_dict
  end # LinearAlgebra
end # CAS
