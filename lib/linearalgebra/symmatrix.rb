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

  module LinearAlgebra

    #  ___            __  __      _       _
    # / __|_  _ _ __ |  \/  |__ _| |_ _ _(_)_ __
    # \__ \ || | '  \| |\/| / _` |  _| '_| \ \ /
    # |___/\_, |_|_|_|_|  |_\__,_|\__|_| |_/_\_\
    #      |__/

    # Symbolic Matrix class. This particular class handles the property
    # of a matrix or a block matrix in order to perform some algebraic
    # operations.
    class SymMatrix < CAS::LinearAlgebra::Op
      # Contains all defined `CAS::SymMatrix` in a unique place. The container is
      #  a simple `Hash` with the name of the matrix as a key that points
      # to the actual object with that name.
      @@container = {}

      # Returns the `Hash` that contains all defined `CAS::SymMatrix`
      #
      # **returns**: `Hash`
      def self.list; @@container; end

      # Return `true` if a matrix was already defined
      #
      #  * **argument**: name of the matrix to be checked
      def self.exist?(name)
        CAS::Help.assert_name name
        (@@container[name] ? true : false)
      end

      # Initialize a new `CAS::SymMatrix`
      def initialize(name, *attributes)
        attributes.flatten!
        CAS::Help.assert_name name
        @name = name

        @properties = []

        yield(self)
      end

      # Helpers function to be used during the specification
      # of a new symbolical matrix. This is due to the fact we
      # may need to do some reasoning upon the different properties
      # of the matrix

      def is_

    end # SymMatrix

  end # LinearAlgebra
end
