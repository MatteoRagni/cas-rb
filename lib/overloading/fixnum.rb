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
