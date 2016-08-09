# CAS-RB

[![Gem Version](https://badge.fury.io/rb/ragni-cas.svg)](https://badge.fury.io/rb/ragni-cas)
[![Code Climate](https://codeclimate.com/github/MatteoRagni/cas-rb/badges/gpa.svg)](https://codeclimate.com/github/MatteoRagni/cas-rb)

## Introduction

An extremely simple graph, that handles only differentiation and simplification with one step ahead in the graph.

## Example

Given the function of Rosenbrock, find the optimum of such a function.

## Execution

### Installation

First of all is necessary to install and load the `ragni-cas` gem.
``` bash
gem install ragni-cas
```

``` ruby
require 'ragni-cas'
```

### Define a function

Now we can define the Rosenbrock function, that has two variable (`x` and `y`) and
two constants (`a` and `b`, with the default value on 1 and 100 in this case). The
variable `f` will contain our function:

``` ruby

x, y = CAS::vars :x, :y
a, b = CAS::const 1.0, 100.0

f = ((a - x) ** 2) + b * ((y - (x ** 2)) ** 2)

```

We can print this function as follows:

``` ruby
puts "f = #{f}"
# => ((1.0 - x)^2 + (100.0 * (y - x^2)^2))
```

### Derivatives

To find the minimum we need  to find the point in which the gradient of such a function is
equal to zero

The two derivatives are:

``` ruby
dfx = f.diff(x).simplify
dfy = f.diff(y).simplify

puts "df/dx = #{dfx}"
# => df/dx = ((((1 - x) * 2) * -1) + ((((y - x^2) * 2) * -(x * 2)) * 100.0))

puts "df/dy = #{dfy}"
# => df/dy = (((y - x^2) * 2) * 100.0)
```

### Substitutions

Now, from the second it is quite evident that

```
y = x^2 = g(x)
```
and thus we can perform on the first a substitution:

``` ruby
g = (x ** 2)
dfx = dfx.subs({y => g})

puts "df/dx = #{dfx}"
# => df/dx = (((1 - x) * 2) * -1)
```

### Meta-Programming (a Newton algorithm...)

That is something quite simple to solve (x = 1). Let's use this formulation for some meta-programming anyway! The stationary point is in the root of the function `dfx`, that depends
only on one variable:

``` ruby
puts "Arguments: #{dfx.args}"
```

We can write a Newton method. The solution is found iteratively solving the recursive equation:

```
x[k + 1] = x[k] - ( f(x[k]) / f'(x[k]) )
```

Let's write an algorithm that takes the symblic expression, and creates its own method
(e.g.: using `Proc` objects). Here an example with our function:

``` ruby
unused = (dfx/dfx.diff(x)).simplify
puts "unused(x) = #{unused}"
# => unused(x) = ((((1 - x) * 2) * -1)) / (((-1 * 2) * -1))

unused_proc = unused.as_proc
puts "unused(12.0) = #{unused.call({"x" => 12.0})}"
# => unused(12.0) = 11.0
```

First of all, let's write a function that contains the algorithm. We want to give as input
a symbolic function of one variable, it must reply with the value of the variable in which the function as value equal to zero:

``` ruby
def newton(f, init=3.0, tol=1E-8, kmax=100)
  k = 0

  x   = f.args[0]
  s   = {x.name => init}      # <-This is the solution dictionary

  fp  = f.as_proc             # <- This is a parsed object
  df  = f.diff(x).simplify    # <- This is still symbolic
  res = (f/df).as_proc        # <- This is a parsed object

  f0 = fp.call(s)
  k = 0

  loop do
    # Algorithm
    s[x.name] = s[x.name] - res.call(s)
    # Tolerance check
    f1        = fp.call(s)
    if (f1 - f0).abs < tol
      break
    else
      f0 = f1
    end

    # Iterations check
    k = k + 1
    break if k > kmax
  end
  puts "Solution after #{k} iterations: #{x} = #{s[x.name]}, f(#{x}) = #{f0}"
  return s[x.name]
end
```

**Transforming the symbolic function into a `Proc` makes the code more efficient.
It is not mandatory, but higlhy suggested in case of iterative algorithms**.

Let's call our new function, using as argument the derivative of the function
that we want to optimize:

``` ruby
x_opt = newton(dfx)
# => Solution after 1 iterations: x = 1.0, f(x) = -0.0
```

We can use the solution of `x`, to get the value of `y`:
``` ruby
puts "Optimum in #{x} = #{x_opt} and #{y} = #{g.call({x => x_opt})}"
# => Optimum in x = 1.0 and y = 1.0
```

## Disclaimer

This is a work in progress and mainly a proof of concept.
What really is missing is a ~~graph~~ a way to perform better simplifications.

## Full example code

``` ruby
require 'ragni-cas'

# Define the function
x, y = CAS::vars "x", "y"
a, b = CAS::const 1.0, 100.0

f = ((a - x) ** 2) + b * ((y - (x ** 2)) ** 2)

puts "f = #{f}"

# Derivate wrt variables
dfx = f.diff(x).simplify
dfy = f.diff(y).simplify

puts "df/dx = #{dfx}"
puts "df/dy = #{dfy}"

# Perform substitutions
g = (x ** 2)
dfx = dfx.subs({y => g}).simplify
puts "df/dx = #{dfx}"

# Arguments of a function
puts "Arguments: #{dfx.args}"

# Metaprogramming: Create a Proc from symbolic math
unused = (dfx/dfx.diff(x)).simplify
puts "unused(x) = #{unused}"
unused_proc = unused.as_proc

# Testing the Proc. The feed must have string as key to identify
# the variable
puts "unused(12.0) = #{unused.call({"x" => 12.0})}"

# We will not use this function, instead we will let the
# algorithm to create its own


# Newton algorthm on the fly, that creates its own formula!
def newton(f, init=3.0, tol=1E-8, kmax=100)
  k = 0

  x   = f.args[0]
  s   = {x.name => init}      # <-This is the solution dictionary

  fp  = f.as_proc             # <- This is a parsed object
  df  = f.diff(x).simplify    # <- This is still symbolic
  res = (f/df).as_proc        # <- This is a parsed object

  f0 = fp.call(s)
  k = 0

  loop do
    # Algorithm
    s[x.name] = s[x.name] - res.call(s)
    # Tolerance check
    f1        = fp.call(s)
    if (f1 - f0).abs < tol
      break
    else
      f0 = f1
    end

    # Iterations check
    k = k + 1
    break if k > kmax
  end
  puts "Solution after #{k} iterations: #{x} = #{s[x.name]}, f(#{x}) = #{f0}"
  return s[x.name]
end

# Let's call our shining algorithm:
x_opt = newton(dfx)

# Let's see the final result for both:
puts "Optimum in #{x} = #{x_opt} and #{y} = #{g.call({x => x_opt})}"
```
