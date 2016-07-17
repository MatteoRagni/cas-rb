# CAS-RB

## Introduction

An extremely simple graph, that handles only differentiation.

## Example

``` ruby
# Loading CAS library
require './lib/cas.rb'

# Create a new variable called x
x = CAS::Variable.new("x")

# There are some constants defined
# MINUS_ONE, One, Two, E, PI, INFINITY
two = CAS::Two

# A simple function if defined:
#     _________________
#    /   2
# /\/  x   +  2 x + 2
f = CAS::sqrt(CAS::pow(x, two) + two * x + two)

# f_diff will contain the symbolic derivative of the previous
# function
f_diff = f.diff(x)

# To evaluate what a CAS::Op contains variable value is mapped with
# an Hash with variables as keys
f_diff_value = f_diff.call({
    x => 1.0
  })

# Printing the result
puts "#{f_diff} = #{f_diff_value}"

# => (((((x^2 * 2) * 1)) / (x) + (1 * 2))) / ((2.0 * √(((x^2 + (2 * x)) + 2)))) = 0.8944271909999159

```

## Disclaimer

This is a working in progress and only a proof of concept.
What really is missing is a graph to perform simplifications.
