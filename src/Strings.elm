module Strings exposing (initialDocument)


initialDocument =
    """
---
format: latex-simple
header:
  title: Problem set 1
  author: James Carlson
  contact: jxxcarlson@gmail.com
  date: February 23, 2021
  description: Superscripts, subscripts, sums, and integrals
problems:
  - a^2 + b^2 = c^2
  - x^3 - 2x^2 + x + 1
  - 1 + x + x^2 + x^3 + \\cdots
  - \\sum x^n
"""
