module Config exposing (..)

paneHeight : Int
paneHeight = 150

appWidth = 900

appTitle = "LaTeX Challenge"

problemTitle = "Write LaTeX to imitate this:"

solutionTitle = "Your code, rendered:"

answerTitle = "Your code:"

initialDocumentText = """title: Welcome
---
author: James Carlson
---
date: 2 Feb 2021
---
description:
We assume that you have learned about
subscripts and superscripts.  In this
lesson you will learn how to write common
expressions in Calculus: derivatives,
integrals, etc.
---


title: Example
---
id: 1
---
target:
Pythagorean theorem: $a^2 + b^2 = c^2$
---
hint:
Use \\code{a^2} for $a^2$.
---
comment: This is for starters
---
===
"""

initialSolutionText = """
Pythagorean theorem: $a^2 + b^2 = c^2$
"""