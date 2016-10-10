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



    # Initializes a new function. It requires a name and a series of arguments
    # that will be the functions on which it depends.
    #
    #  * **argument**: `String` or `Symbol` name of the variable
    #  * **argument**: `Array` of `CAS::Variable` that are argument of the function
    #  * **returns**: `CAS::Function`
    def initialize(name, *xs)
      CAS::Help.assert_name name
      raise ArgumentError
      xs.each do |x|
        CAS::Help.assert x, CAS::Variable
      end
      raise CASError, "Function #{name} already exists" if CAS::Function.exist? name

      @xs = xs
      @name = name
      @@container[@name] = self
    end

    # Overrides new method. This will return an existing function if in the function container
    #
    #  * **requires**: `String` or `Symbol` that is the name of the function
    #  * **requires**: `Array` of `CAS::Variable`
    #  * **returns**: a new `CAS::Function` or the old one
    def Function.new(name, *xs)
      if @@container[name]
        return @@container[name] if (@@container[name].args == xs or xs.size == 0)
        raise CASError, "Function #{name} already defined with different arguments!"
      end
      super
    end

    # Returns an array containing `CAS::Variable`s argument of the function
    #
    #  * **returns**: `Array` containing `CAs:;Variable`
    def args
      @xs
    end


  end # Function

  class << self
    # This shortcut allows to declare a new function
    #
    #  * **requires**: `String` or `Symbol` that is the name of the function
    #  * **requires**: `Array` of `CAS::Variable`
    #  * **returns**: a new `CAS::Function` or the old one
    def declare(name, *xs)
      CAS::Function.new name, xs
    end
  end
end
