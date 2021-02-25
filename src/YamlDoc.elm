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
