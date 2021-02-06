module Config exposing (..)

paneHeight : Int
paneHeight = 150

appWidth = 900

appTitle = "LaTeX Challenge"

problemTitle = "Challenge"

solutionTitle = "Does this match?"

answerTitle = "Type your answer:"

initialProblemText = """title: Integration
---
id: 1.1.1
---
next: 1.1.2
---
@target
Pythagorean theorem: $a^2 + b^2 = c^2$
+++
Use \\code{a^2} for $a^2$.
---
comment: This is for starters
---
===
"""

initialSolutionText = """
Pythagorean theorem: $a^2 + b^2 = c^2$
"""