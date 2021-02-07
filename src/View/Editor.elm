module View.Editor exposing (view)

import Element exposing (..)
import Element.Font as Font
import Element.Input as Input
import DocParser exposing(Problem, DocumentDescription)
import Config
import Style exposing(..)
import Markdown.Option exposing (MarkdownOption(..), OutputOption(..))
import Markdown.Render
import Editor exposing(EditorModel, EditorMsg(..), EditorMode(..))

view : EditorModel -> Element EditorMsg
view model =
  column [centerX] [
      row [  spacing 20 ] [lhs model, rhs model ]
    ]

lhs : EditorModel -> Element EditorMsg
lhs model =
    case model.editorMode of
        ProblemMode -> lhsProblem model
        HeaderMode -> lhsHeader model

lhsHeader : EditorModel -> Element EditorMsg
lhsHeader model =
    column mainColumnStyle
        [ column [  spacing 18 ]
        [ inputDocTitle model
        , inputAuthor model
        , inputDate model
        , inputDescription model
        , row [spacing 12] [problemMode model, headerMode model]

        ]
        ]


lhsProblem : EditorModel -> Element EditorMsg
lhsProblem model =
    column mainColumnStyle
        [ column [  spacing 18 ]
            [
               inputTitle model
             , inputId model
             , inputTarget model
             , inputHint model
             , inputComment model
             , row [spacing 36] [
                  row [spacing 12] [problemMode model, headerMode model]
                , showIf (model.editorMode == ProblemMode) addProblem]

            ]
        ]

showIf : Bool -> Element EditorMsg -> Element EditorMsg
showIf show element =
    if show then  element else Element.none


rhs : EditorModel -> Element EditorMsg
rhs model =
    column rhsColumnStyle
        [ column [  spacing 6 ]
            [
              text model.docTitle
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
            , label = el labelStyle (text "Add Problem")
            }

problemMode : EditorModel -> Element EditorMsg
problemMode  model =
    let
      style = if model.editorMode == ProblemMode then
                selectedButtonStyle
              else
                buttonStyle
    in
    Input.button style
            { onPress = Just (SetMode ProblemMode)
            , label = el labelStyle (text "Problems")
            }

headerMode : EditorModel -> Element EditorMsg
headerMode  model =
    let
      style = if model.editorMode == HeaderMode then
                selectedButtonStyle
              else
                buttonStyle
    in
    Input.button style
            { onPress = Just (SetMode HeaderMode)
            , label = el labelStyle (text "Header")
            }


-- INPUT, HEADER

inputDocTitle : EditorModel -> Element EditorMsg
inputDocTitle model =
    el [moveLeft 5]
        (Input.text textFieldStyle
            { onChange = AcceptDocTitle
            , text = model.docTitle
            , placeholder = Nothing
            , label = Input.labelAbove [] <| el [] (text "title")
            })

inputAuthor : EditorModel -> Element EditorMsg
inputAuthor model =
    el [moveLeft 5]
        (Input.text textFieldStyle
            { onChange = AcceptAuthor
            , text = model.author
            , placeholder = Nothing
            , label = Input.labelAbove [] <| el [] (text "author")
            })


inputDate : EditorModel -> Element EditorMsg
inputDate model =
    el [moveLeft 5]
        (Input.text textFieldStyle
            { onChange = AcceptDate
            , text = model.date
            , placeholder = Nothing
            , label = Input.labelAbove [] <| el [] (text "date")
            })

inputDescription : EditorModel -> Element EditorMsg
inputDescription model =
    el [moveLeft 5]
        (Input.multiline textAreaStyle
            { onChange = AcceptDescription
            , text = model.description
            , placeholder = Nothing
            , label = Input.labelAbove [] <| el [] (text "description")
            , spellcheck = False
            })


-- INPUT, PROBLEMS

inputTitle : EditorModel -> Element EditorMsg
inputTitle model =
    el [moveLeft 5]
        (Input.text textFieldStyle
            { onChange = AcceptTitle
            , text = model.title
            , placeholder = Nothing
            , label = Input.labelAbove [] <| el [] (text "title")
            })

textFieldStyle = [ width (px 500), Font.size 16]
textAreaStyle = [ width (px 500), height (px 120), Font.size 16]

inputId : EditorModel -> Element EditorMsg
inputId model =
    el [moveLeft 5]
        (Input.text textFieldStyle
            { onChange = AcceptId
            , text = model.id
            , placeholder = Nothing
            , label = Input.labelAbove [] <| el [] (text "id")
            })


inputTarget : EditorModel -> Element EditorMsg
inputTarget model =
    el [moveLeft 5]
        (Input.multiline textAreaStyle
            { onChange = AcceptTarget
            , text = model.target
            , placeholder = Nothing
            , label = Input.labelAbove [] <| el [] (text "target")
            , spellcheck = False
            })

inputHint : EditorModel -> Element EditorMsg
inputHint model =
   el [moveLeft 5]
     (Input.text textAreaStyle
         { onChange = AcceptHint
         , text = model.hint
         , placeholder = Nothing
         , label = Input.labelAbove [] <| el [] (text "hint")
         })

inputComment : EditorModel -> Element EditorMsg
inputComment model =
   el [moveLeft 5]
     (Input.text textAreaStyle
         { onChange = AcceptComment
         , text = model.comment
         , placeholder = Nothing
         , label = Input.labelAbove [] <| el [] (text "comment")
         })