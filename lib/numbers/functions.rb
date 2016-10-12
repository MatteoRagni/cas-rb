#!/usr/bin/env ruby

module CAS
  #  ___             _   _
  # | __|  _ _ _  __| |_(_)___ _ _
  # | _| || | ' \/ _|  _| / _ \ ' \
  # |_| \_,_|_||_\__|\__|_\___/_||_|

  # Unknown function class. Will allow to make symbolic differentiation and
  # so on.
  class Function < CAS::NaryOp
    # Contains all defined functions. Container is a `Hash` with name of the
    # function as key and the function as the value
    @@container = {}

    # Return the `Hash` of the functions
    #
    #  * **returns**: `Hash`
    def self.list; @@container; end

    # Return `true` if a function was already defined
    #
    #  * **argument**: name of the function to be checked
    def self.exist?(name)
      CAS::Help.assert_name name
      (@@container[name] ? true : false)
    end

    # Return the number of functions defined
    #
    #  * **returns**: `Fixnum`
    def self.size; @@container.keys.size; end

    # Returns a function given its name
    #
    #  * **argument**: `Object` name of the function
    #  * **returns**: `CAS::Function` instance if exists, raises a `CAS::CASError`
    #    if not
    def self.[](s)
      return @@container[s] if self.exist? s
      raise CASError, "Function #{s} not found"
    end

    # Returns `true` if a function exists in container
    #
    #  * **argument**: `String` or `Symbol` that represent the functions
    #  * **returns**: `TrueClass` if variable exists, `FalseClass` if not
    def self.exist?(name); @@container.keys.include?(name); end

    # The attribute `name` identifies the current function. A function with the
    # same name of an existing function connot be defined
    attr_reader :name

    # Initializes a new function. It requires a name and a series of arguments
    # that will be the functions on which it depends.
    #
    #  * **argument**: `String` or `Symbol` name of the variable
    #  * **argument**: `Array` of `CAS::Variable` that are argument of the function
    #  * **returns**: `CAS::Function`
    def initialize(name, *xs)
      xs.flatten!
      CAS::Help.assert_name name
      xs.each do |x|
        CAS::Help.assert x, CAS::Variable
      end
      raise CASError, "Function #{name} already exists" if CAS::Function.exist? name

      @x = xs.uniq
      @name = name
      @@container[@name] = self
    end

    # Overrides new method. This will return an existing function if in the function container
    #
    #  * **requires**: `String` or `Symbol` that is the name of the function
    #  * **requires**: `Array` of `CAS::Variable`
    #  * **returns**: a new `CAS::Function` or the old one
    def Function.new(name, *xs)
      xs.flatten!
      if @@container[name]
        return @@container[name] if (@@container[name].args - xs.uniq == [] or xs.size == 0)
        raise CASError, "Function #{name} already defined with different arguments!"
      end
      super
    end

    # Returns an array containing `CAS::Variable`s argument of the function
    #
    #  * **returns**: `Array` containing `CAs:;Variable`
    def args
      @x
    end

    # Simplifications cannot be performed on anonymous function, thus it will always return
    # the `self` `CAS::Function` object
    #
    #  * **returns**: `CAS::Function` self instance
    def simplify; self; end

    # Tries to convert an anonymous function into Ruby code will always raise a `CASError` because it
    # is not possible to generate code for such a fuction
    #
    #  * **raises**: `CAS::CASError`: Ruby code for CAs::Function cannot be generated
    def to_code
      raise CASError, "Ruby code for #{self.class} cannot be generated"
    end

    # Substitutions in which a function is involved directly generates a CAS::Error unless the substitution will
    # involve another variable. Example:
    #
    # ``` ruby
    # (CAS.declare :f [x, y, z]).subs { x => x ** 2 } # this raises CASError
    # (CAS.declare :f [x, y, z]).subs { x => y } # this returns f(y, z)
    # ```
    #
    #  * **requires**: a substitution `Hash`
    #  * **returns**: a `CAS::Function` with modified argument list
    #  * **raises**: `CASError` if something different with resppect to a `CAS::Variable` is a active substitution
    def subs(s)
      s.each do |k, v|
        next unless self.depend? k
        if v.is_a? CAS::Variable
          (@x.collect! { |e| (e == k) ? v : e }).uniq!
          next
        end
        raise CASError, "Cannot perform a substitution in #{self.class}"
      end
      self
    end

    # Performs the derivative with respect to one of the variable. The new function
    # has a name with respect to a schema that for now is fixed (TODO: make it variable and user defined).
    #
    #  * **requires**: a `CAS::Variable` for derivative
    #  * **returns**: the `CAS::Variable` derivated function
    def diff(v)
      if self.depend? v
        return CAS.declare :"d#{@name}[#{v}]", @x
      else
        return CAS::Zero
      end
    end

    # Trying to call a `CAS::Function` will always return a `CAS::Error`
    #
    #  * **raises**: `CAS::CASError`
    def call(_v)
      raise CASError, "Cannot call a #{self.class}"
    end

    # Returns the inspect string of the function, that is similar to `CAS::Function#to_s`
    #
    #  * **returns**: inspection `String`
    def inspect; self.to_s; end

    # Returns a description `String` for the `CAS::Function`
    #
    #  * **returns**: `String`
    def to_s
      "#{@name}(#{@x.map(&:to_s).join(", ")})"
    end

    # Checks if two functions can be considered equal (same name, same args)
    #
    #  * **requires**: another op to be checked against
    #  * **returns**: `TrueClass` if functions are equal, `FalseClass` if not equal
    def ==(op)
      return false if not self.class == op.class
      return false if not (@name == op.name and @x == op.args)
      true
    end
  end # Function

  class << self
    # This shortcut allows to declare a new function
    #
    #  * **requires**: `String` or `Symbol` that is the name of the function
    #  * **requires**: `Array` of `CAS::Variable`
    #  * **returns**: a new `CAS::Function` or the old one
    def declare(name, *xs)
      xs.flatten!
      CAS::Function.new(name, xs)
    end
  end
end
