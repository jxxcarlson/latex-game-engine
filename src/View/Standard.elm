module View.Standard exposing (view)

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
import Model exposing(Model, AppMode(..))
import View.Common


view : Model -> Element Msg
view model =
  column [centerX] [
      row [  spacing 20 ] [lhs model, rhs model ]
    ]


lhs : Model -> Element Msg
lhs model =
    column mainColumnStyle
        [ column [  spacing 6 ]
            [
              problemTitle model.currentProblem
            , heading1 Config.problemTitle
            , viewProblem model.counter model.currentProblem
            , heading Config.solutionTitle
            , viewSolution model.counter model.solution
            , heading Config.answerTitle
            , viewEditor model
            , row [spacing 12, paddingXY 0 12] [
                 loadButton
               , okButton
               , nextButton
               , prevButton
               ,el [] (toggleInfo model.showInfo)
               , showStatus model.currentProblem
               , showScore model

               ]
             , showComment model.seed model.currentProblem

            , View.Common.showIf model.showInfo <| showHint model.seed model.currentProblem
            ]
        ]

showScore : Model -> Element Msg
showScore model =
    let
        completed = String.fromInt model.numberOfProblemsCompleted
        all = String.fromInt model.numberOfProblems
    in
     el [Font.size 18, Font.bold ](text <| completed ++ "/" ++ all)

showStatus : Maybe AugmentedProblem -> Element Msg
showStatus mprob =
    case mprob of
        Nothing -> Element.none
        Just prob ->
            let
               msg =  if prob.completed then "YES" else "NO"
            in
              el [Font.size 14] (text ("Complete: " ++ msg))




problemTitle : Maybe AugmentedProblem -> Element Msg
problemTitle mprob =
    case mprob of
        Nothing -> Element.none
        Just prob ->
            let
                id = prob.id
                  |> Maybe.withDefault []
                  |> List.map String.fromInt
                  |> String.join "."
            in
             el [Font.bold, Font.size 18] (text <| id ++ " " ++ prob.title)

rhs : Model -> Element Msg
rhs model =
    column rhsColumnStyle
        [ column [  spacing 10 ]
            [
                el [Font.bold, Font.size 24] (text (Maybe.map .title model.documentDescription |> Maybe.withDefault "Exercises"))
               , el [Font.bold, Font.size 14] (text (Maybe.map .author model.documentDescription |> Maybe.withDefault "Exercises"))
               , el [Font.bold, Font.size 14] (text (Maybe.map .date model.documentDescription |> Maybe.withDefault "Exercises"))
               , View.Common.showIf model.documentDescriptionVisible
                  (renderedSource model.counter (Maybe.map .description model.documentDescription |>  Maybe.withDefault "Exercises"))

            ]
            , row [alignBottom, spacing 18] [el [alignBottom] (View.Common.toggleAppMode model.appMode)
                  , el [Font.size 12, Font.italic, alignBottom ](outputDisplay model)
                  ]
        ]

renderedSource : Int -> String -> Element Msg
renderedSource counter sourceText =
    (Keyed.node "div"
        renderedSourceStyle
        [ ( String.fromInt counter, Markdown.Render.toHtml ExtendedMath sourceText |> Html.map MarkdownMsg ) ]
        ) |> Element.html




showHint : Int -> Maybe AugmentedProblem -> Element Msg
showHint seed mprob =
    case mprob of
        Nothing -> Element.none
        Just prob -> column[width (px 600) ] [
              column [Font.size 13, width (px 580), padding 10] [renderMath seed hintStyle prob.hint]
             ]

showComment : Int -> Maybe AugmentedProblem -> Element Msg
showComment seed mprob =
    case mprob of
        Nothing -> Element.none
        Just prob ->
            if String.length prob.comment < 3  then Element.none
            else
                column[ ] [
                       el [Font.size 14, Font.bold, moveRight 8] (text "Comment")
                     , column [Font.size 13, padding 10] [renderMath seed (commentStyle Config.panelWidth) prob.comment]
                     ]



viewEditor : Model -> Element Msg
viewEditor model =
    Input.multiline [width (px 560), height (px Config.paneHeight), Font.size 16]
      { onChange = GetSolution
      , text = model.solution
      , placeholder = Nothing
      , spellcheck = False
      , label = Input.labelHidden "LaTeX input field"
      }

viewSolution : Int -> String -> Element Msg
viewSolution  seed solution =
  column  problemStyle
     [renderMath seed [] solution]

viewProblem : Int -> Maybe AugmentedProblem -> Element Msg
viewProblem seed mproblem =
    case mproblem of
        Nothing -> el [] (text "No problem loaded")
        Just problem -> renderProblem seed problem



-- RENDER

renderProblem : Int -> AugmentedProblem -> Element Msg
renderProblem seed problem =
   column problemStyle
     [renderMath  seed  [] problem.target]


problemStyle : List (Attribute Msg)
problemStyle = [height (px Config.paneHeight), width (px 560), paddingXY 18 0,  Font.size 16, Background.color (rgb 255 255 255)]

renderMath : Int -> List (Html.Attribute Msg) -> String -> Element Msg
renderMath seed attr str =
   str
     |> MiniLatex.EditSimple.renderWithVersion seed
     |> List.map (Html.map LaTeXMsg)
     |> Html.div  attr
     |> mathNode seed

mathNode : Int -> Html Msg -> Element Msg
mathNode k element =
    (Keyed.node "div" [] [(String.fromInt k, element)]) |> Element.html



-- UI

title : String -> Element msg
title str =
    row [  width (px Config.appWidth), Font.size 24, Font.color (gray 240), paddingXY 0 8 ] [ text str ]

heading : String -> Element msg
heading str =
    row [  Font.size 16, Font.italic, paddingEach {top = 12, bottom = 0, left = 0, right = 0} ] [ text str ]

heading1 : String -> Element msg
heading1 str =
    row [  Font.size 16, Font.italic ] [ text str ]


outputDisplay : Model -> Element msg
outputDisplay model =
    row [ spacing 12]
        [ text model.message]


inputText : Model -> Element Msg
inputText model =
    el [moveLeft 5]
        (Input.text []
            { onChange = InputText
            , text = model.input
            , placeholder = Nothing
            , label = Input.labelLeft [] <| el [] (text "")
            })

-- BUTTONS

toggleInfo : Bool -> Element Msg
toggleInfo showInfo =
    let
        label = if showInfo then "Hide hint" else "Show hint"
    in
    row [ ]
        [ Input.button buttonStyle
            { onPress = Just ToggleInfo
            , label = el labelStyle (text label)
            }
        ]


loadButton : Element Msg
loadButton =
    row [ ]
        [ Input.button buttonStyle
            { onPress = Just ProblemsRequested
            , label = el labelStyle (text "Load")
            }
        ]
okButton : Element Msg
okButton =
    row [ ]
        [ Input.button buttonStyle
            { onPress = Just OK
            , label = el labelStyle(text "OK")
            }
        ]


prevButton : Element Msg
prevButton =
    row [ ]
        [ Input.button buttonStyle
            { onPress = Just PrevProblem
            , label = el labelStyle (text "Prev")
            }
        ]

nextButton : Element Msg
nextButton =
    row [ ]
        [ Input.button buttonStyle
            { onPress = Just NextProblem
            , label = el labelStyle (text "Next")
            }
        ]

