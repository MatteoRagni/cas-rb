#!/usr/bin/env ruby

##
# Overloading operators for Fixnum. Operations that are
# oveloaded are:
#
# * `overloaded_plus` for `+`
# * `overloaded_minus` for `-`
# * `overloaded_mul` for `*`
# * `overloaded_div` for `/`
# * `overloaded_pow` for `**`
class Fixnum
  # Setting aliases
  alias :overloaded_plus  :+
  alias :overloaded_minus :-
  alias :overloaded_mul   :*
  alias :overloaded_div   :/
  alias :overloaded_pow   :**
  alias :dot_graph :to_s

  ##
  # If `a` is a `CAS::Op` transform self in a `CAS::Const`
  # and return a symbolic operation.
  # If
  def +(a)
    return (CAS::const(self) + a) if a.is_a? CAS::Op
    self.overloaded_plus a
  end

  ##
  # If `a` is a `CAS::Op` transform self in a `CAS::Const`
  # and return a symbolic operation
  def -(a)
    return (CAS::const(self) - a) if a.is_a? CAS::Op
    self.overloaded_minus a
  end

  ##
  # If `a` is a `CAS::Op` transform self in a `CAS::Const`
  # and return a symbolic operation
  def *(a)
    return (CAS::const(self) * a) if a.is_a? CAS::Op
    self.overloaded_mul a
  end

  ##
  # If `a` is a `CAS::Op` transform self in a `CAS::Const`
  # and return a symbolic operation
  def /(a)
    return (CAS::const(self) / a) if a.is_a? CAS::Op
    self.overloaded_div a
  end

  ##
  # If `a` is a `CAS::Op` transform self in a `CAS::Const`
  # and return a symbolic operation
  def **(a)
    return (CAS::const(self) ** a) if a.is_a? CAS::Op
    self.overloaded_pow a
  end
end
