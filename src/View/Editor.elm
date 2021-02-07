module View.Editor exposing (view)


import Html exposing (Html)
import Html.Keyed as Keyed
import Element exposing (..)
import Element.Background as Background
import Element.Font as Font
import Element.Input as Input
import Problem exposing(Id, Op(..), AugmentedProblem)
import DocParser exposing(Problem, DocumentDescription)
import MiniLatex.EditSimple
import Config
import Style exposing(..)
import Markdown.Option exposing (MarkdownOption(..), OutputOption(..))
import Markdown.Render
import Msg exposing(..)
import Model exposing(AppMode(..))
import Editor exposing(EditorModel, EditorMsg(..))
import View.Common

view : EditorModel -> Element EditorMsg
view model =
  column [centerX] [
      row [  spacing 20 ] [lhs model, rhs model ]
    ]


lhs : EditorModel -> Element EditorMsg
lhs model =
    column mainColumnStyle
        [ column [  spacing 18 ]
            [
               inputTitle model
             , inputId model
             , inputTarget model
             , inputHint model
             , inputComment model
             , addProblem

            ]
        ]

rhs : EditorModel -> Element EditorMsg
rhs model =
    column rhsColumnStyle
        [ column [  spacing 6 ]
            [
              text "RHS"
              , el [Font.size 14] (text <| "Problems: " ++ (String.fromInt (List.length model.problemList)))
              , column [spacing 8] (List.map summary model.problemList)

            ]
           , row [alignBottom, spacing 12] [saveProblems, goToStandardView]
        ]

summary : Problem -> Element EditorMsg
summary problem =
    el [Font.size 14] (text problem.title)


-- BUTTONS

saveProblems : Element EditorMsg
saveProblems  =
    Input.button buttonStyle
            { onPress = Just SaveProblems
            , label = el labelStyle (text "Save")
            }

goToStandardView : Element EditorMsg
goToStandardView  =
    Input.button buttonStyle
            { onPress = Just GoToStandarMode
            , label = el labelStyle (text "Return")
            }

addProblem : Element EditorMsg
addProblem  =
    Input.button buttonStyle
            { onPress = Just AddProblem
            , label = el labelStyle (text "Add")
            }

-- INPUT, PROBLEMS

inputTitle : EditorModel -> Element EditorMsg
inputTitle model =
    el [moveLeft 5]
        (Input.text []
            { onChange = AcceptTitle
            , text = model.title
            , placeholder = Nothing
            , label = Input.labelAbove [] <| el [] (text "title")
            })

inputId : EditorModel -> Element EditorMsg
inputId model =
    el [moveLeft 5]
        (Input.text []
            { onChange = AcceptId
            , text = model.id
            , placeholder = Nothing
            , label = Input.labelAbove [] <| el [] (text "id")
            })


inputTarget : EditorModel -> Element EditorMsg
inputTarget model =
    el [moveLeft 5]
        (Input.text []
            { onChange = AcceptTarget
            , text = model.target
            , placeholder = Nothing
            , label = Input.labelAbove [] <| el [] (text "target")
            })

inputHint : EditorModel -> Element EditorMsg
inputHint model =
   el [moveLeft 5]
     (Input.text []
         { onChange = AcceptHint
         , text = model.hint
         , placeholder = Nothing
         , label = Input.labelAbove [] <| el [] (text "hint")
         })

inputComment : EditorModel -> Element EditorMsg
inputComment model =
   el [moveLeft 5]
     (Input.text []
         { onChange = AcceptComment
         , text = model.comment
         , placeholder = Nothing
         , label = Input.labelAbove [] <| el [] (text "comment")
         })