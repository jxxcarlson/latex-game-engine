module Msg exposing (..)

import MiniLatex.EditSimple
import Markdown.Render
import File exposing(File)
import Http


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

