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
  #  ___ _
  # / __(_)_ _
  # \__ \ | ' \
  # |___/_|_||_|

  ##
  # Representation for the `sin(x)` function. It is implemented
  # as a `CAS::Op`
  class Sin < CAS::Op
    # Return the derivative of the `sin(x)` function using the chain
    # rule. The input is a `CAS::Op` because it can handle derivatives
    # with respect to functions.
    #
    # ```
    #  d
    # -- sin(f(x)) = f'(x) cos(fx)
    # dx
    # ```
    #
    #  * **argument**: `CAS::Op` object of the derivative
    #  * **returns**: `CAS::Op` a derivated object, or `CAS::Zero` for constants
    def diff(v)
      if @x.depend? v
        return @x.diff(v) * CAS.cos(@x)
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
      Math::sin(@x.call(f))
    end

    # Convert expression to string
    #
    #  * **returns**: `String` to print on screen
    def to_s
      "sin(#{@x})"
    end

    # Simplification callback. It simplify the subgraph of each node
    # until all possible simplification are performed (thus the execution
    # time is not deterministic).
    #
    #  * **returns**: `CAS::Op` simplified version
    def simplify
      super
      return @x.x if @x.is_a? CAS::Asin
      return self.simplify_dictionary
    end

    def self.init_simplify_dict
      @simplify_dict = {
        CAS::Zero => CAS::Zero,
        CAS::Pi => CAS::Zero,
        CAS::Pi/2 => CAS::One
      }
    end

    # Convert expression to code (internal, for `CAS::Op#to_proc` method)
    #
    #  * **returns**: `String` that represent Ruby code to be parsed in `CAS::Op#to_proc`
    def to_code
      "Math::sin(#{@x.to_code})"
    end
  end # Sin
  CAS::Sin.init_simplify_dict

  # Shortcut for `CAS::Sin#new`
  #
  #  * **argument**: `CAS::Op` argument of the function
  #  * **returns**: `CAS::Sin` operation
  def self.sin(x)
    CAS::Sin.new x
  end

  #    _       _
  #   /_\   __(_)_ _
  #  / _ \ (_-< | ' \
  # /_/ \_\/__/_|_||_|

  ##
  # Representation for the `arcsin(x)` function. It is implemented
  # as a `CAS::Op`. It is the inverse of the `sin(x)` function
  class Asin < CAS::Op
    # Return the derivative of the `arcsin(x)` function using the chain
    # rule. The input is a `CAS::Op`
    #
    #  * **argument**: `CAS::Op` object of the derivative
    #  * **returns**: `CAS::Op` a derivated object, or `CAS::Zero` for constants
    def diff(v)
      if @x.depend? v
        return @x.diff(v) / CAS.sqrt(CAS::One - CAS.pow(@x, CAS::Two))
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
      Math::acos(@x.call(f))
    end

    # Convert expression to string
    #
    #  * **returns**: `String` to print on screen
    def to_s
      "asin(#{@x})"
    end

    # Simplification callback. It simplify the subgraph of each node
    # until all possible simplification are performed (thus the execution
    # time is not deterministic).
    #
    #  * **returns**: `CAS::Op` simplified version
    def simplify
      super
      return @x.x if @x.is_a? CAS::Sin
      return self.simplify_dictionary
    end

    def self.init_simplify_dict
      @simplify_dict = {
        CAS::Zero => CAS::Zero,
        CAS::One => (CAS::Pi / 2)
      }
    end

    # Convert expression to code (internal, for `CAS::Op#to_proc` method)
    #
    #  * **returns**: `String` that represent Ruby code to be parsed in `CAS::Op#to_proc`
    def to_code
      "Math::asin(#{@x.to_code})"
    end
  end
  CAS::Asin.init_simplify_dict

  class << self
    # Shortcuts for `CAS::Asin#new`
    #
    #  * **argument**: `CAS::Op` argument of the function
    #  * **returns**: `CAS::Asin` operation
    def asin(x)
      CAS::Asin.new x
    end
    alias :arcsin :asin
  end

  #   ___
  #  / __|___ ___
  # | (__/ _ (_-<
  #  \___\___/__/

  ##
  # Representation for the `cos(x)` function. It is implemented
  # as a `CAS::Op`.
  class Cos < CAS::Op
    # Return the derivative of the `cos(x)` function using the chain
    # rule. The input is a `CAS::Op` because it can handle derivatives
    # with respect to functions.
    #
    # ```
    #  d
    # -- cos(f(x)) = -f'(x) sin(fx)
    # dx
    # ```
    #
    #  * **argument**: `CAS::Op` object of the derivative
    #  * **returns**: `CAS::Op` a derivated object, or `CAS::Zero` for constants
    def diff(v)
      if @x.depend? v
        return CAS.invert(@x.diff(v) * CAS.sin(@x))
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
      Math::cos(@x.call(f))
    end

    # Convert expression to string
    #
    #  * **returns**: `String` to print on screen
    def to_s
      "cos(#{@x})"
    end

    # Simplification callback. It simplify the subgraph of each node
    # until all possible simplification are performed (thus the execution
    # time is not deterministic).
    #
    #  * **returns**: `CAS::Op` simplified version
    def simplify
      super
      return @x.x if @x.is_a? CAS::Acos
      return self.simplify_dictionary
    end

    def self.init_simplify_dict
      @simplify_dict = {
        CAS::Zero => CAS::One,
        CAS::Pi => CAS::One,
        CAS::Pi/2 => CAS::Zero
      }
    end

    # Convert expression to code (internal, for `CAS::Op#to_proc` method)
    #
    #  * **returns**: `String` that represent Ruby code to be parsed in `CAS::Op#to_proc`
    def to_code
      "Math::cos(#{@x.to_code})"
    end
  end
  CAS::Cos.init_simplify_dict

  # Shortcut for `CAS::Cos#new`
  #
  #  * **argument**: `CAS::Op` argument of the function
  #  * **returns**: `CAS::Cos` operation
  def self.cos(x)
    CAS::Cos.new x
  end

  #    _
  #   /_\  __ ___ ___
  #  / _ \/ _/ _ (_-<
  # /_/ \_\__\___/__/

  ##
  # Representation for the `arccos(x)` function. It is implemented
  # as a `CAS::Op`. It is the inverse of the `cos(x)` function
  class Acos < CAS::Op
    def diff(v)
      if @x.depend? v
        return CAS.invert(@x.diff(v)/CAS.sqrt(CAS::One - CAS.pow(@x, CAS::Two)))
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
      return Math::acos(@x.call(f))
    end

    # Convert expression to string
    #
    #  * **returns**: `String` to print on screen
    def to_s
      "acos(#{@x})"
    end

    # Simplification callback. It simplify the subgraph of each node
    # until all possible simplification are performed (thus the execution
    # time is not deterministic).
    #
    #  * **returns**: `CAS::Op` simplified version
    def simplify
      super
      return @x.x if @x.is_a? CAS::Cos
      return self.simplify_dictionary
    end

    def self.init_simplify_dict
      @simplify_dict = {
        CAS::Zero => (CAS::Pi / 2),
        CAS::One => CAS::Zero
      }
    end

    # Convert expression to code (internal, for `CAS::Op#to_proc` method)
    #
    #  * **returns**: `String` that represent Ruby code to be parsed in `CAS::Op#to_proc`
    def to_code
      "Math::acos(#{@x.to_code})"
    end
  end
  CAS::Acos.init_simplify_dict

  class << self
    # Shortcut for `CAS::Acos#new`
    #
    #  * **argument**: `CAS::Op` argument of the function
    #  * **returns**: `CAS::Acos` operation
    def acos(x)
      CAS::Acos.new x
    end
    alias :arccos :acos
  end

  #  _____
  # |_   _|_ _ _ _
  #   | |/ _` | ' \
  #   |_|\__,_|_||_|

  ##
  # Representation for the `tan(x)` function. It is implemented
  # as a `CAS::Op`.
  class Tan < CAS::Op
    # Return the derivative of the `tan(x)` function using the chain
    # rule. The input is a `CAS::Op` because it can handle derivatives
    # with respect to functions. E.g.:
    #
    # ```
    #  d              f'(x)
    # -- sin(f(x)) = -------
    # dx             cos²(x)
    # ```
    #
    #  * **argument**: `CAS::Op` object of the derivative
    #  * **returns**: `CAS::Op` a derivated object, or `CAS::Zero` for constants
    def diff(v)
      if @x.depend? v
        return @x.diff(v) * CAS.pow(CAS::One/CAS.cos(@x), CAS::Two)
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
      Math::tan(@x.call(f))
    end

    # Convert expression to string
    #
    #  * **returns**: `String` to print on screen
    def to_s
      "tan(#{@x})"
    end

    # Simplification callback. It simplify the subgraph of each node
    # until all possible simplification are performed (thus the execution
    # time is not deterministic).
    #
    #  * **returns**: `CAS::Op` simplified version
    def simplify
      super
      return @x.x if @x.is_a? CAS::Atan
      return self.simplify_dictionary
    end

    def self.init_simplify_dict
      @simplify_dict = {
        CAS::Zero => CAS::Zero,
        CAS::Pi => CAS::Zero,
        CAS::Pi/2 => CAS::Infinity
      }
    end

    # Convert expression to code (internal, for `CAS::Op#to_proc` method)
    #
    #  * **returns**: `String` that represent Ruby code to be parsed in `CAS::Op#to_proc`
    def to_code
      "Math::tan(#{@x.to_code})"
    end
  end
  CAS::Tan.init_simplify_dict

  # Shortcut for `CAS::Tan#new`
  #
  #  * **argument**: `CAS::Op` argument of the function
  #  * **returns**: `CAS::Tan` operation
  def self.tan(x)
    CAS::Tan.new x
  end

  #    _  _
  #   /_\| |_ __ _ _ _
  #  / _ \  _/ _` | ' \
  # /_/ \_\__\__,_|_||_|

  ##
  # Representation for the `arctan(x)` function. It is implemented
  # as a `CAS::Op`. It is the inverse of the `tan(x)` function
  class Atan < CAS::Op
    # Return the derivative of the `arctan(x)` function using the chain
    # rule. The input is a `CAS::Op` because it can handle derivatives
    # with respect to functions.
    #
    #  * **argument**: `CAS::Op` object of the derivative
    #  * **returns**: `CAS::Op` a derivated object, or `CAS::Zero` for constants
    def diff(v)
      if @x.depend? v
        return (@x.diff(v) / (CAS.pow(@x, CAS::Two) + CAS::One))
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
      Math::atan(@x.call(f))
    end

    # Convert expression to string
    #
    #  * **returns**: `String` to print on screen
    def to_s
      "atan(#{@x})"
    end

    # Simplification callback. It simplify the subgraph of each node
    # until all possible simplification are performed (thus the execution
    # time is not deterministic).
    #
    #  * **returns**: `CAS::Op` simplified version
    def simplify
      super
      return @x.x if @x.is_a? CAS::Tan
      return self.simplify_dictionary
    end

    def self.init_simplify_dict
      @simplify_dict = {
        CAS::Zero => CAS::Zero,
        CAS::One => (CAS::Pi/4),
        CAS::Infinity => (CAS::Pi/2)
      }
    end

    # Convert expression to code (internal, for `CAS::Op#to_proc` method)
    #
    #  * **returns**: `String` that represent Ruby code to be parsed in `CAS::Op#to_proc`
    def to_code
      "Math::atan(#{@x.to_code})"
    end
  end
  CAS::Atan.init_simplify_dict

  class << self
    # Shortcut for `CAS::Atan#new`
    #
    #  * **argument**: `CAS::Op` argument of the function
    #  * **returns**: `CAS::Atan` operation
    def atan(x)
      CAS::Atan.new x
    end
    alias :arctan :atan
  end
end
