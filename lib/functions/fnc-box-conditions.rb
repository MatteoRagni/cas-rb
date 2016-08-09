#!//usr/bin/env ruby

module CAS
  #  ___           ___             _ _ _   _
  # | _ ) _____ __/ __|___ _ _  __| (_) |_(_)___ _ _
  # | _ \/ _ \ \ / (__/ _ \ ' \/ _` | |  _| / _ \ ' \
  # |___/\___/_\_\\___\___/_||_\__,_|_|\__|_\___/_||_|

  ##
  # BoxCondition class constructs a condition of the type:
  #
  # ```
  # L < f(x) < U
  # ```
  #
  # and this is a metaclass for different type of box conditions:
  #
  #  * open: `a < f(x) < b`
  #  * lower closed: `a ≤ f(x) < b`
  #  * upper closed: `a < f(x) ≤ b`
  #  * closed: `a ≤ f(x) ≤ b`
  class BoxCondition < CAS::Condition
    @@lower_cond  = @@upper_cond = "<"
    @@upper_latex = @lower_latex = "<"
    @@lower_str   = @@upper_str  = "<"

    attr_reader :x, :lower, :upper

    # Initializes a new box condition. A function is required as central term,
    # while the second and the third elements are lower and upper bounds
    # as `CAS::Constant`
    #
    # <- `CAS::Op` central term of the box condition
    # <- `CAS::Constant` lower bound
    # <- `CAS::Constant` upper bound
    # -> `CAS::BoxCondition` new instance
    def initialize(x, lower, upper)
      if lower.is_a? Numeric
        lower = CAS::const lower
      end
      if upper.is_a? Numeric
        upper = CAS::const upper
      end
      CAS::Help.assert(lower, CAS::Constant)
      CAS::Help.assert(upper, CAS::Constant)

      CAS::Help.assert(x, CAS::Op)
      CAS::Help.assert(type, Symbol)

      lower, upper = upper, lower if lower.x > upper.x

      @lower = lower
      @upper = upper
      @x = x
    end

    # Returns true if one the central function depends upon the expression included
    #
    # <- `CAS::Op` operator to check against for dependencies
    # -> `TrueClass` or `FalseClass`
    def depend?(v)
      @x.depend? v
    end

    # Simplify left and right term of the operator
    #
    # -> `CAS::BoxCondition`
    def simplify
      @x.simplify
      return self
    end

    # Substitute in the central element using a dictionary
    #
    # -> `Hash` of substitutions
    def subs(fd)
      @x = @x.subs(fd)
      return self
    end

    # Performs the derivative of the box condition. The derivative of
    # a box condition is a `CAS::Equal` object (the derivative of a constant
    # is zero):
    #
    # ```
    #   d
    #  -- [a < f(x) < b] = f'(x) == 0
    #  dx
    # ```
    #
    # since between the two there is a difference relation.
    #
    # <- `CAS::Op` to perform the derivative
    def diff(v)
      CAS::equal(@x.diff(v).simplify, CAS::Zero)
    end

    # Returns the dot graphviz representation of the code
    #
    # -> `String`
    def dot_graph
      cls = "#{self.class.to_s.gsub("CAS::", "")}_#{self.object_id}"
      " #{cls} -> #{@lower.dot_graph}\n #{cls} -> #{@x.dot_graph}\n #{cls} -> #{@upper.dot_graph}\n"
    end

    # Returns an array of variables of the central function
    #
    # -> `Array` of `CAS::Variable`
    def args
      @x.args
    end

    # Return true if two BoxConditions are equal, false if different
    #
    # <- `CAS::Op` operator to check against for equality
    # -> `TrueClass` or `FalseClass`
    def ==(cond)
      return false if not self.class != cond.class
      return (@x == cond.x and @lower == cond.lower and @upper == cond.upper)
    end

    # Function call will evaluate left and right functions to solve the
    # relation
    #
    # <- `Hash` with feed dictionary
    # -> `Trueclass` or `Falseclass`
    def call(_fd)
      raise CAS::CASError, "This is a virtual method"
    end

    # Inspector for the class. It is class specific
    #
    # -> `String`
    def inspect
      "(#{@lower.inspect} #{@@lower_cond} #{@x.inspect} #{@@upper_cond} #{@upper.inspect})"
    end

    # Returns a string that can be used for printing LaTeX version of the
    # box condition
    #
    # `String`
    def to_latex
      "#{@lower.to_latex} #{@@lower_latex} #{@x.to_latex} #{@@upper_latex} #{@upper.to_latex}"
    end

    # Returns a string that represents the object to be printed
    #
    # `String`
    def to_s
      "#{@lower} #{@@lower_str} #{@x} #{@@upper_str} #{@upper}"
    end

    # Return the code that performs a condition evaluation
    #
    # -> `String`
    def to_code
      "((#{@lower.to_code} #{@@lower_cond} (#{@x.to_code})) and ((#{@x.to_code}) #{@@upper_cond} #{@upper.to_code}))"
    end
  end # BoxCondition

  #  ___           ___             _ _ _   _          ___
  # | _ ) _____ __/ __|___ _ _  __| (_) |_(_)___ _ _ / _ \ _ __  ___ _ _
  # | _ \/ _ \ \ / (__/ _ \ ' \/ _` | |  _| / _ \ ' \ (_) | '_ \/ -_) ' \
  # |___/\___/_\_\\___\___/_||_\__,_|_|\__|_\___/_||_\___/| .__/\___|_||_|
  #                                                       |_|

  ##
  # Implements the box condition with both bounds are open
  #
  # ```
  # a < f(x) < b
  # ```
  class BoxConditionOpen < CAS::Condition
    @@lower_cond = @@upper_cond = @@upper_latex = @lower_latex = @@lower_str = @@upper_str = "<"

    def call(fd)
      x_call = @x.call(fd)
      return ((@lower.call(fd) < x_call) and (x_call < @upper))
    end
  end # BoxConditionOpen

  #  ___           ___             _ _ _   _          _                        ___ _                _
  # | _ ) _____ __/ __|___ _ _  __| (_) |_(_)___ _ _ | |   _____ __ _____ _ _ / __| |___ ___ ___ __| |
  # | _ \/ _ \ \ / (__/ _ \ ' \/ _` | |  _| / _ \ ' \| |__/ _ \ V  V / -_) '_| (__| / _ (_-</ -_) _` |
  # |___/\___/_\_\\___\___/_||_\__,_|_|\__|_\___/_||_|____\___/\_/\_/\___|_|  \___|_\___/__/\___\__,_|

  ##
  # Implements the box condition with lower bound closed and upper open
  #
  # ```
  # a ≤ f(x) < b
  # ```
  class BoxConditionLowerClosed < CAS::Condition
    @@lower_cond  = "<="
    @@lower_latex = "\\leq"
    @@lower_str   = "≤"
    @@upper_cond  = @@upper_latex = @@upper_str = "<"

    def call(fd)
      x_call = @x.call(fd)
      return ((@lower.call(fd) <= x_call) and (x_call < @upper))
    end
  end # BoxConditionLowerClosed

  #  ___           ___             _ _ _   _         _   _                     ___ _                _
  # | _ ) _____ __/ __|___ _ _  __| (_) |_(_)___ _ _| | | |_ __ _ __  ___ _ _ / __| |___ ___ ___ __| |
  # | _ \/ _ \ \ / (__/ _ \ ' \/ _` | |  _| / _ \ ' \ |_| | '_ \ '_ \/ -_) '_| (__| / _ (_-</ -_) _` |
  # |___/\___/_\_\\___\___/_||_\__,_|_|\__|_\___/_||_\___/| .__/ .__/\___|_|  \___|_\___/__/\___\__,_|
  #                                                       |_|  |_|

  ##
  # Implements the box condition with lower bound open and upper closed
  #
  # ```
  # a < f(x) ≤ b
  # ```
  class BoxConditionUpperClosed < CAS::Condition
    @@lower_cond  = @@lower_latex = @@lower_str = "<"
    @@upper_cond  = "<="
    @@upper_latex = "\\leq"
    @@upper_str   = "≤"

    def call(fd)
      x_call = @x.call(fd)
      return ((@lower.call(fd) < x_call) and (x_call <= @upper))
    end
  end # BoxConditionUpperClosed

  #  ___           ___             _ _ _   _          ___ _                _
  # | _ ) _____ __/ __|___ _ _  __| (_) |_(_)___ _ _ / __| |___ ___ ___ __| |
  # | _ \/ _ \ \ / (__/ _ \ ' \/ _` | |  _| / _ \ ' \ (__| / _ (_-</ -_) _` |
  # |___/\___/_\_\\___\___/_||_\__,_|_|\__|_\___/_||_\___|_\___/__/\___\__,_|

  ##
  # Implements the box condition with both bounds closed
  #
  # ```
  # a ≤ f(x) ≤ b
  # ```
  class BoxConditionClosed < CAS::Condition
    @@lower_cond  = @@upper_cond  = "<="
    @@lower_latex = @@upper_latex = "\\leq"
    @@lower_str   = @@upper_str   = "≤"

    def call(fd)
      x_call = @x.call(fd)
      return ((@lower.call(fd) <= x_call) and (x_call <= @upper))
    end
  end # BoxConditionUpperClosed

  # Shortcut for creating a new box condition. It requires four arguments:
  #
  # <- `CAS::Op` function for condition
  # <- `CAS::Constant` lower limit
  # <- `CAs::Constant` upper limit
  # <- `Symbol` of condition type it can be:
  #     - `:closed` for `CAs::BoxConditionClosed`
  #     - `:open` for `CAs::BoxConditionOpen`
  #     - `:upper_closed` for `CAs::BoxConditionUpperClosed`
  #     - `:lower_closed` for `CAs::BoxConditionLowerClosed`
  # -> `CAS::BoxCondition` new instance
  def self.box(x, a, b, type=:closed)
    case type
    when :closed
      return CAS::BoxConditionClosed.new(x, a, b)
    when :open
      return CAS::BoxConditionOpen.new(x, a, b)
    when :upper_closed
      return CAS::BoxConditionUpperClosed.new(x, a, b)
    when :lower_closed
      return CAS::BoxConditionLowerClosed.new(x, a, b)
    else
      raise CAS::CASError, "Unknown box condition type"
    end
  end

  class Op
    # Shortcut for creating a new box condition. It requires limits and type:
    #
    # <- `CAS::Constant` lower limit
    # <- `CAs::Constant` upper limit
    # <- `Symbol` of condition type it can be:
    #     - `:closed` for `CAs::BoxConditionClosed`
    #     - `:open` for `CAs::BoxConditionOpen`
    #     - `:upper_closed` for `CAs::BoxConditionUpperClosed`
    #     - `:lower_closed` for `CAs::BoxConditionLowerClosed`
    # -> `CAS::BoxCondition` new instance
    def limit(a, b, type=:closed)
      return CAS::box(self, a, b, type)
    end
  end # Op
end
