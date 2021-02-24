module YamlDoc exposing (..)

-- (parseDocument, solved, simple, commented, firstLine)

import Document exposing (..)
import Parser as P exposing ((|.), (|=))
import Yaml.Decode exposing (..)


parseDocument : String -> Maybe Document
parseDocument str =
    case firstLine str of
        Nothing ->
            Nothing

        Just format ->
            case format of
                "latex-simple" ->
                    Maybe.map Simple (fromString decoderSimpleProblems str |> Result.toMaybe)

                "latex-qa" ->
                    Maybe.map Solved (fromString decoderQuestionAnswer str |> Result.toMaybe)

                "latex-commented" ->
                    Maybe.map Commented (fromString decoderCommentedProblems str |> Result.toMaybe)

                _ ->
                    Nothing


test str =
    fromString decoderCommentedProblems str


firstLine : String -> Maybe String
firstLine str =
    case P.run lineParser str of
        Err _ ->
            Nothing

        Ok s ->
            Just s


lineParser : P.Parser String
lineParser =
    P.succeed identity
        |. P.spaces
        |. P.symbol "---\n"
        |. P.symbol "format:"
        |. P.spaces
        |= (P.chompUntil "\n" |> P.getChompedString)


decoderSimpleProblems : Decoder SimpleProblems
decoderSimpleProblems =
    map3 SimpleProblems
        (field "format" string)
        (field "header" decodeHeader)
        (field "problems" (list string))


decoderQuestionAnswer : Decoder SolvedProblems
decoderQuestionAnswer =
    map3 SolvedProblems
        (field "format" string)
        (field "header" decodeHeader)
        (field "problems" (list (field "item" decodeSolvedProblem)))


decoderCommentedProblems : Decoder CommentedProblems
decoderCommentedProblems =
    map3 CommentedProblems
        (field "format" string)
        (field "header" decodeHeader)
        (field "problems" (list (field "item" decodeCommentedProblem)))


decodeSolvedProblem : Decoder SolvedProblem
decodeSolvedProblem =
    map2 SolvedProblem
        (field "problem" string)
        (field "solution" string)


decodeCommentedProblem : Decoder CommentedProblem
decodeCommentedProblem =
    map4 CommentedProblem
        (field "title" string)
        (field "id" string)
        (field "target" string)
        (field "comment" string)


decodeHeader : Decoder Header
decodeHeader =
    map5 Header
        (field "title" string)
        (field "author" string)
        (field "contact" string)
        (field "date" string)
        (field "description" string)


simple =
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


solved =
    """
---
format: latex-qa
header:
  title: Problem set 1
  author: James Carlson
  contact: jxxcarlson@gmail.com
  date: February 23, 2021
  description: Superscripts, subscripts, sums, and integrals
problems:
  - item:
      problem: Solve $2x + 1 = 5$.
      solution: $x = 4$
  - item:
      problem: Solve $x^2 + x - 6 = 0$.
      solution: $x = -2, 3$
"""


prob =
    """title: Second derivatives
id: "8"
target: $$ \\frac{d^2y}{d^2x} = -k y$$
comment: See if you can do this one: combine superscripts and \\code{\\bs{frac}}.
"""


prob2 =
    """title: Second derivatives
id: "8"
target: $$ \\frac{d^2y}{d^2x} = -k y$$
comment: > "See if you can do this one:
            combine superscripts and \\code{\\bs{frac}}."
"""


commented =
    """
---
format: latex-commented
header:
  title: Problem set 1
  author: James Carlson
  contact: jxxcarlson@gmail.com
  date: February 23, 2021
  description: In this lesson, you will learn how to do simple math formulas.
problems:
  - item:
      title: Sum of the interior angles
      id: "1"
      target: "The sum of interior angles: $\\alpha + \\beta + \\gamma = \\pi$"
      comment: "Write source code for the formula above. Enclose it in dollar signs: \\dollar MATH HERE \\dollar. Use \\bs{alpha} for $\\alpha$, and so on."
  - item:
      title: Trigonometric polynomial
      id: "1.1"
      target: "$$ f(\\theta) = \\sin \\theta + \\sin 2\\theta + \\sin 3\\theta $$"
      comment: "Use \\code{\\bs{sin}} for the sine function"
  - item:
      title: Addition formula
      id: "1.2"
      target: "$$ \\sin(\\theta + \\phi) = \\sin\\theta \\cos\\phi + \\cos\\theta\\sin\\phi $$"
      comment: "Can you guess how to write the cosine function?"
  - item:
      title: Polynomials
      id: "2"
      target: "$p(x) = ax^3 + bx^2 + cx + d$"
      comment: "Use a caret (^) for superscripts, e.g., \\code{a^5} for $a^5$."
  - item:
      title: Negative exponents
      id: "3"
      target: "$R(x) = x^2 + x + x^{-1} + x^{-2} + x^{-3}$"
      comment: "Enclose an exponent like \\code{-1} in curly braces: \\code{x^{-1}} for $x^{-1}$."
  - item:
      title: Square roots
      id: "4"
      target: "This is radical: $1 + \\sqrt 3 + \\sqrt 5$"
      comment: "Use \\code{\\bs{sqrt}} for square roots, e.g., \\bs{sqrt} 2 for $\\sqrt 2$."
  - item:
      title: More complex radical expressions
      id: "5"
      target: "$$ \\sqrt{2 + \\sqrt 3} $$"
      comment: "You will need to group things in curly braces for this one, like you did with negative exponents.This time we use \\italic{display math mode}: double dollar signs instead of single ones: \\dollar\\dollar MATH STUFF \\dollar\\dollar."
  - item:
      title: Fractions
      id: "6"
      target: "$$ \\frac{1}{3} + \\frac{3}{5} + \\frac{5}{7} $$"
      comment: "Use \\code{\\bs{frac}\\texarg{1}\\texarg{3}} for $\\frac{1}{3}$."
  - item:
      title: Derivatives!
      id: "7"
      target: "$$ \\frac{dy}{dx} = y $$"
      comment: "Another use for \\code{\\bs{frac}}: make derivatives."
  - item:
      title: Second derivatives
      id: "8"
      target: "$$ \\frac{d^2y}{d^2x} = -k y$$"
      comment: "See if you can do this one: combine superscripts and \\code{\\bs{frac}}."
  - item:
      title: Partial derivatives
      id: "9"
      target: "$$ \\frac{\\partial u}{\\partial t} = \\frac{\\partial u}{\\partial x} $$"
      comment: "Here you need to know that \\code{\\bs{partial}} makes this: $\\partial$."
  - item:
      title: Poisson's equation
      id: "10"
      target: "$$\\nabla^2 u = \\rho$$"
      comment: "Use \\code{\\bs{nabla}} for this one."
 """
