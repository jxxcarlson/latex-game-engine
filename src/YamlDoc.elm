module YamlDoc exposing (..)

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

                "latex-solved" ->
                    Maybe.map Solved (fromString decoderSolvedProblems str |> Result.toMaybe)

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


decoderSolvedProblems : Decoder SolvedProblems
decoderSolvedProblems =
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


solved =
    """
---
format: latex-solved
header:
  title: Basic Algebra
  author: James Carlson
  contact: jxxcarlson@gmail.com
  date: February 23, 2021
  description: Basic Algebra
problems:
  - item:
      problem: "Solve $2x + 1 = 5$."
      solution: "$x = 2$"
  - item:
      problem: "Solve $x^2 + x - 6 = 0$."
      solution: "$x = -2, 3$"
  - item:
      problem: "Solve $x^2 + x - 7 = 0$."
      solution: "$x = \\frac{-1 \\pm \\sqrt{29}}{2}$"
  - item:
      problem: "Solve $2x + 3y = 1, x - 2y = 5$."
      solution: "$x = -9/7, y = 17/7$"

"""
