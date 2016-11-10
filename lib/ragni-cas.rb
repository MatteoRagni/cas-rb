#!/usr/bin/env ruby

##
# ragni-cas
# A very simple CAS engine with encapsuled graph
# representation. This will make impossible to
# perform complex high level simplifications, but
# it is powerful enough to define simple algorithm
# in a symbolic way.
#
# Mathematically, this is an implementation of the
# forward chain rule for automatic differentiaition.
# Each function is a container of function and the
# derivation is in the form:
#
# ```
#   d(f(g(x))
#   --------- = g'(x) * f'(g(x))
#      dx
# ```
#
# Author:: Matteo Ragni (mailto:info@ragni.me)
# Copyright:: Copyright (c) 2016 Matteo Ragni
# License:: Distributed under MIT license terms
module CAS

  # Support functions are in this separate Helper class
  module Help
    # Check input `obj.class` against a `type` class
    # raises an `ArgumentError` if check fails
    #
    #  * **argument**: object to be cecked
    #  * **argument**: type to be checked against
    #  * **returns**: `TrueClass`, or raises an `ArgumentError`
    def self.assert(obj, type)
      raise ArgumentError, "required #{type}, received #{obj.class}" unless obj.is_a? type
      return true
    end

    # Check if input object is feasible to be a name of a `CAS::Variable` or a `CAS::Function`
    # raise an `ArgumentError` if the check fails. To be feasible the object must be a `String`
    # instance or `Symbol` instance
    #
    #  * **argument**: object to be checked
    #  * **returns**: `TrueClass` or raises `ArgumentError`
    def self.assert_name(obj)
      raise ArgumentError, "Input name must be a String/Symbol" unless [Symbol, String].include? obj.class
      return true
    end
  end
end

#  ___               _
# | _ \___ __ _ _  _(_)_ _ ___ ___
# |   / -_) _` | || | | '_/ -_|_-<
# |_|_\___\__, |\_,_|_|_| \___/__/
#            |_|

%w|operators/op.rb operators/bary-op.rb operators/nary-op.rb
   numbers/constants.rb numbers/variables.rb numbers/functions.rb
   functions/fnc-sum.rb functions/fnc-prod.rb
   functions/fnc-base.rb functions/fnc-trig.rb functions/fnc-trsc.rb
   functions/fnc-conditions.rb functions/fnc-box-conditions.rb functions/fnc-piecewise.rb
   overloading/fixnum.rb overloading/float.rb
   version.rb|.each do |r|
  require File.expand_path(r, File.dirname(__FILE__))
end

module CAS
  CAS::NumericToConst[-Math::PI] = (-CAS::Pi)
  CAS::NumericToConst[-Math::E] = (-CAS::E)
  CAS::NumericToConst[(-1.0/0.0)]  = (CAS::NegInfinity)
end
