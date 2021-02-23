module Msg exposing (..)

import MiniLatex.EditSimple
import Markdown.Render
import File exposing(File)
import Http


type Msg
    = NoOp
    | InputText String
    | ReverseText
    | ProblemsRequested
    | ProblemsSelected File
    | ProblemsLoaded String
    | LaTeXMsg MiniLatex.EditSimple.LaTeXMsg
    | MarkdownMsg Markdown.Render.MarkdownMsg
    | NewSeed Int
    | GetSolution String
    | NextProblem
    | PrevProblem
    | OK
    | ToggleInfo
    | GotLesson (Result Http.Error String)
    | GetLesson
    | AcceptUrl String
