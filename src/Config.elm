module Config exposing (..)

paneHeight : Int
paneHeight = 100
commentPaneHeight = 80

paneWidth = 540

appWidth = 900

appHeight = 750

appTitle = "LaTeX Challenge"

problemTitle = "Imitate what you see below"

solutionTitle = "This is what you wrote, rendered:"

answerTitle = "Write your LaTeX here:"

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
will write some LaTeX source text in the third
pane that recreates
what you see here.  The rendered result is displaye
above what you have written.  When you are satisfied with what you have
written, press **OK** to mark that problem
as completed. The app moves you on to the
next problem.

In this case the student has made a mistake,
or perhaps has simply mot completed it. *Correct
the proposed solution now by adding the text*
`\\int` *before* `x^n dx`.

**Status and Score.** The *status* of a
problem, as well as the current score,
 is displayed in the control panel,
the row of button **Load** **OK** etc.
Here is an example: *complete: NO* **1/2**.
One problem out of a total of two is complete,
but the current problem is not complete.

**Hints.** Notice the **Show hint**
button.  If you need help doing the problem,
press this button.

---


title: Indefinite integral
---
id: 1
---
target:$$
\\int x^n dx
$$
---
hint:
Use \\code{\\int} for the integral sign.
---
comment: Your first problem.  Give it a try!
Ask for a hint if you need to.
---


title: Definite integral
---
id: 2
---
target:$$
\\int_0^1 x^n dx
$$
---
hint:
---
comment: Remember that "_" is for subscripts and "^" is for
superscripts, e.g, "a_1^2 + a_2^2" produces $a_1^2 + a_2^2$.
---

"""

initialSolutionText = """$$
x^n dx
$$
"""