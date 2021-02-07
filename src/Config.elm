module Config exposing (..)

paneHeight : Int
paneHeight = 150

appWidth = 900

appTitle = "LaTeX Challenge"

problemTitle = "Write LaTeX to imitate this:"

solutionTitle = "Your code, rendered:"

answerTitle = "Your code:"

initialDocumentText = """title: Welcome!
---
author: James Carlson
---
date: 2 Feb 2021
---
description:
On the left you will see three "window panes,"
In the top pane is some rendered LaTeX. The
idea is that you
will write some LaTeX source text that recreates
what you see here.  You write this in the bottom
pane, with the rendered result displayed in the
middle.  When you are satisfied that your code
produces rendered LaTeX that matches that of the
top pane, press **OK** to mark that problem
as completed and move to the
next problem.

In this case the student has made a mistake,
or perhaps has simply mot completed it.
Correct the proposed solution now, by adding the text
`\\int` before `x^n dx`.

**Hints.** Notice the **Show hint**
button.  If you need help doing the problem,
press this button.

---


title: Indefinite integral
---
id: 1
---
target:
$$
\\int x^n dx
$$
---
hint:
Use \\code{\\int} for the integral sign.
---
comment:
---


title: Definite integral
---
id: 2
---
target:
$$
\\int_0^1 x^n dx
$$
---
hint:
Remember that "_" is for subscripts and "^" is for
superscripts, e.g, "a_1^2 + a_2^2" produces $a_1^2 + a_2^2$.
---
comment:
---

"""

initialSolutionText = """
$$
x^n dx
$$
"""