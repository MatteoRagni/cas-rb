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
three = CAS::const(3.0)

# A simple function if defined:
#   __________________________
# \/  x² + 2 sin(x) + 3 exp(x)
f = CAS.sqrt(CAS.pow(x, two) +  CAS.sin(x) * 2.0 + CAS.exp(x) * 3.0)

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

# => (((((x^(2 - 1) * 2) * 1) + ((1 * cos(x)) * 2.0)) + ((1 * exp(x)) * 3.0))) / ((2.0 * √(((x^2 + (sin(x) * 2.0)) + (exp(x) * 3.0))))) = 1.70643662864123

# This equation is really messed up. We can try to simplify it
f_diff.simplify
puts "#{f_diff} = #{f_diff.call({x => 1.0})}"

# => ((((x * 2) + (cos(x) * 2.0)) + (exp(x) * 3.0))) / ((2.0 * √(((x^2 + (sin(x) * 2.0)) + (exp(x) * 3.0))))) = 1.70643662864123

```

## Disclaimer

This is a working in progress and only a proof of concept.
What really is missing is a graph to perform simplifications.
