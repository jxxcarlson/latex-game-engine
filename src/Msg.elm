module Msg exposing (..)

import MiniLatex.EditSimple
import Markdown.Render
import File exposing(File)
import Editor


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
    | ToggleAppMode
    | E Editor.EditorMsg
