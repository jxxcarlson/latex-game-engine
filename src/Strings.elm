module Strings exposing (initialDocument)


initialDocument1 = """title:Simple formulas
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


initialDocument = """
---
format: latex-1
title: Problem set 1
author: James Carlson
date: February 23, 2021
description: Superscripts, subscripts, sums, and integrals
problems:
  - a^2 + b^2 = c^2
  - x^3 - 2x^2 + x + 1
  - 1 + x + x^2 + x^3 + \\cdots
  - \\sum x^n
  - \\sum_0^5 x^n
  - \\sum_{n=0}^5 x^n
  - \\sum_{n=1}^{10} x^n
  - \\sum_{n=1}^\\infty x^n
  - \\sum_{n=1}^\\infty 1/n = \\infty
  - x^2 + x^{-2}
  - 1 + x + x^{-1} + x^{-2} + x^{-3}
  - e^{-x}
  - \\int e^{-x} dx
  - \\int_0^a e^{-x} dx
  - \\int_0^\\infty e^{-x} dx = 1
"""