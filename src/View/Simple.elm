module View.Simple exposing (view)

import Html exposing (Html)
import Html.Keyed as Keyed
import Element exposing (..)
import Element.Background as Background
import Element.Font as Font
import Element.Input as Input
import Problem exposing(Id, AugmentedProblem)
import MiniLatex.EditSimple
import Config
import Style exposing(..)
import Markdown.Option exposing (MarkdownOption(..), OutputOption(..))
import Markdown.Render
import Msg exposing(..)
import Model exposing(Model)


view : Model -> Element Msg
view model =
  column [centerX] [
      row [  spacing 20 ] [lhs model, rhs model ]
    ]


lhs : Model -> Element Msg
lhs model = el [] (text "LHS")

rhs : Model -> Element Msg
rhs model = el [] (text "RHS")