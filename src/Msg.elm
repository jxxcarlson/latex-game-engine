module Msg exposing (..)

import File exposing (File)
import Http
import Markdown.Render
import MiniLatex.EditSimple


type Msg
    = InputText String
    | LaTeXMsg MiniLatex.EditSimple.LaTeXMsg
    | MarkdownMsg Markdown.Render.MarkdownMsg
    | NewSeed Int
    | AcceptUrl String
    | GetLesson
    | GotLesson (Result Http.Error String)
    | GetSolution String
    | NextProblem
    | PrevProblem
    | SolutionIsOK
    | ShowMe
