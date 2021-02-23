module Strings exposing (..)


initialDocument = """title:Simple formulas
---
author:James Carlson
---
date:22 Feb 2021
---
description:Use this document as a template for producing LaTeX lessons.
More information at [this GitHub repo](https://github.com/jxxcarlson/latex-lessons/).

$$ \\frac{\\sqrt{2 + \\sqrt 3}}{\\sqrt{ 2 + \\sqrt 5}} $$
---

title:Trigonometry
---
id:1
---
target: The sum of interior angles: $\\alpha + \\beta + \\gamma = \\pi$
---
comment: Write source code for the formula above, in the \\blue{blue box}. Enclose it in dollar
signs: \\dollar MATH HERE \\dollar. Use \\bs{alpha} for $\\alpha$, and so on.
---

title:Polynomials
---
id:2
---
target: $p(x) = ax^3 + bx^2 + cx + d$
---
comment: Use a caret (^) for superscripts, e.g., \\code{a^5} for $a^5$.
---

title:Negative exponents
---
id:3
---
target: $R(x) = x^2 + x + x^{-1} + x^{-2} + x^{-3}$
---
comment: Enclose an exponent like \\code{-1} in curly braces: \\code{x^{-1}} for $x^{-1}$.
---
"""


old = """title:Basics
---
author:James Carlson
---
date:7 Feb 2021
---
description:Do these exercises to learn to derivatives, integrals, series and sums etc.  Soon you will be writing beautiful formulas like this:

$$
\\int_{-\\infty}^{+\\infty} e^{-x^2} dx = \\sqrt{\\pi}
$$
---

title:Symbols
---
id:1
---
target: $\\alpha + \\beta + \\gamma = \\pi$
---
hint:
---
comment: Write source text for the formula above. Enclose it in dollar signs: \\dollar MATH HERE \\dollar. Use \\bs{alpha} for $\\alpha$, and so on.

\\blue{When your solution matches the given formula, press OK to go on to the next problem.}
---

title:Integrals
---
id:1.1
---
target: $$\\int x dx$$
---
hint:
---
comment: Now write code for the integral above. You will need \\code{\\bs{int}} for $\\int$.  Snippets of LaTeX code like \\code{\\bs{int}}  are called \\italic{macros}.

This time, put your LaTeX code between double dollar signs: \\dollar\\dollar MATH HERE \\dollar\\dollar.  This is \\italic{display math mode}.
---

title:Spacing
---
id:1.2
---
target: $$\\int x\\ dx$$
---
hint:
---
comment: Sometimes you need to adjust the spacing.  If you put \\code{\\bs{space}}
between the \\code{x} and the \\code{dx}, the formula will look better. You can also put a backslash followed by a space.
---

title:Superscripts
---
id:2
---
target:Pythagoras said that $ a^2 + b^2 = c^2 $
---
hint:
---
comment:Use \\code{^} for superscripts, e.g, \\code{x^2} for $x^2$. Notice the form: ordinary text, with the mathematics between dollar signs. This is \\italic{inline math mode} once again.
---

title:Superscripts and Integrals
---
id:2.1
---
target:$$
\\int x^2 dx
$$
---
hint:
---
comment:You know what to do here!  Combine what you know about symbols
with what you know about superscripts. This is \\italic{display math mode} once again.
---


title:Fractions
---
id:2.2
---
target:$$
\\int x^2 dx = \\frac{x^3}{3} + C
$$
---
hint:
---
comment: You will need to use the \\code{\\bs{frac}} macro.  It works
like this: \\code{\\bs{frac}\\texarg{numerator}\\texarg{denomianator}}. If
you don't like the looks of the result, try putting the macro \\code{\\bs{small}} just before the \\code{\\bs{frac}}.
---

title:Derivatives
---
id:2.3
---
target:$$
\\frac{dy}{dx} = y
$$
---
hint:
---
comment: You can use fractions to make derivatives.
---

title: Second derivatives
---
id:2.3
---
target:$$
\\frac{d^2y}{d^2x} = -k y
$$
---
hint:
---
comment: You can use fractions and superscripts to make second derivatives.
---

title: Partial derivatives
---
id:2.4
---
target:$$
\\frac{\\partial u}{\\partial t} = \\frac{\\partial u}{\\partial x} 
$$
---
hint:
---
comment: Here you need to know that \\code{\\bs{partial}} makes this: $\\partial$.
---


title: The wave equation
---
id:2.4
---
target:$$
\\frac{\\partial^2 u}{\\partial t^2} = \\frac{\\partial^2 u}{\\partial x^2} 
$$
---
hint:
---
comment: You can do it!
---



title:Subscripts
---
id:3
---
target:$$
a_1, a_2, a_3
$$
---
hint:Use \\code{_} for subscripts, e.g., \\code{a_1} for $a_1$.
---
comment:Use \\code{_} for subscripts, e.g., \\code{a_1} for $a_1$. 
---

title:On and on
---
id:3.1
---
target:$$
a_1, a_2, a_3, \\ldots
$$
---
hint:Use \\code{_} for subscripts, e.g., \\code{a_1} for $a_1$.
---
comment:The macro \\code{\\ldots} puts three dots along the baseline. A
related macro is \\code{\\bs{cdots}}, which puts dots centere in the line, above the baseline.
---

title:Combining subscripts and superscripts
---
id:4
---
target:$$
a_1^2 + a_2^2 + a_3^2 + \\ldots
$$
---
hint:The previous two problems gave you what you need to do this one.
---
comment:  Now you can combine subscripts and superscripts.
---

title:Complex subscirpts
---
id:4.1
---
target:$$
a_{10}^2 + a_{11}^2 + a_{12}^2 + \\ldots
$$
---
hint:The previous two problems gave you what you need to do this one.
---
comment:When the subscript consists of more than a single character or entity, enclose it in curly braces, like this: \\code{x_\\texarg{abc}} for $x_{abc}$.
---

title: Subscripts of subscirpts
---
id:4.2
---
target:$$
a_{i_1} + a_{i_2} + a_{1_3} + \\ldots
$$
---
hint:The previous two problems gave you what you need to do this one.
---
comment: Curly braces will help!
---

title: Subscripts in superscripts
---
id:4.3
---
target:$$
a^{n_1} + a^{n_2} + a^{n_3} + \\ldots
$$
---
hint:The previous two problems gave you what you need to do this one.
---
comment: Curly braces will help here also.
---

title:Sums
---
id:5
---
target:$$
\\sum_{i=0}^6 a_i
$$
---
hint:Use curly braces to group the parts of the subscript, like this
\\code{\\texarg{i=0}}.
---
comment:Sums follow the same pattern as integrals, except that you use
\\code{\\bs{sum}} in place of \\code{\\bs{int}}. Oh ... remember what we said earlier about complex subscripts.
---

title:An infinite sum
---
id:5.1
---
target:$$
\\sum_{i=1}^\\infty a_i
$$
---
hint:
---
comment:Use \\code{\\bs{infty}} for $\\infty$.
---



title:Harmonic series
---
id:5.2
---
target:$$
\\sum_{n=1}^\\infty \\small\\frac{1}{n} = \\infty
$$
---
hint:
---
comment:You know everything you need for this one!
---
"""