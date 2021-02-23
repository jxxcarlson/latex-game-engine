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
