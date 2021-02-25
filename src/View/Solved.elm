module View.Solved exposing (view)

import Config
import Document
import Element exposing (..)
import Element.Background as Background
import Element.Font as Font
import Element.Input as Input
import Html exposing (Html)
import Html.Keyed as Keyed
import Markdown.Option exposing (MarkdownOption(..), OutputOption(..))
import Markdown.Render
import MiniLatex.EditSimple
import Model exposing (Model)
import Msg exposing (..)
import Problem exposing (AugmentedProblem, Id)
import Style exposing (..)
import View.Common


view : Model -> Element Msg
view model =
    column [ centerX ]
        [ row [ spacing 20 ] [ lhs model, rhs model ]
        ]


lhs : Model -> Element Msg
lhs model =
    column mainColumnStyle
        [ column [ spacing 12 ]
            [ mainTitle
            , heading1 "Problem"
            , viewProblem model.counter model.currentProblem
            , heading "Your solution, rendered"
            , viewSolution model.counter model.solution
            , solutionHeading model
            , View.Common.showIf (not model.showSolution) (viewEditor model)
            , View.Common.showIf model.showSolution (viewComment model.showSolution model.seed model.currentProblem)
            , View.Common.controls model
            , View.Common.loader model
            ]
        ]


solutionHeading model =
    if model.showSolution then
        headingBlue "Our solution"

    else
        heading "Your solution"


mainTitle : Element Msg
mainTitle =
    el [ Font.size 24, paddingEach { top = 0, bottom = 8, left = 0, right = 0 } ] (text "LaTeX Tutor")


rhs : Model -> Element Msg
rhs model =
    column rhsColumnStyle
        [ column [ spacing 10 ]
            [ column [ spacing 4 ]
                [ el [ Font.bold, Font.size 24 ] (text model.documentHeader.title)
                , el [ Font.size 14 ] (text model.documentHeader.author)
                , el [ Font.size 14 ] (text model.documentHeader.date)
                ]
            , renderedSource model.counter model.documentHeader.description
            , column [ spacing 8, height (px 360), width (px 320), scrollbarY ]
                (List.map (summary model.currentProblem) model.problemList)
            ]
        , View.Common.wellDone model
        , View.Common.bottomRowRHS model
        ]


getProblem : AugmentedProblem -> Document.SolvedProblem
getProblem augp =
    case augp.prob of
        Document.SolvedP p ->
            p

        _ ->
            fakeProblem


fakeProblem : Document.SolvedProblem
fakeProblem =
    { problem = "null target"
    , solution = "null comment"
    }


summary : Maybe AugmentedProblem -> AugmentedProblem -> Element Msg
summary mproblem problem =
    let
        fontColor =
            if mproblem == Just problem then
                Element.rgb 0.7 0 0

            else
                Element.rgb 0 0 0

        check =
            if problem.completed then
                String.fromChar '✓'

            else
                ""

        title =
            (getProblem problem).problem
    in
    row [ spacing 12 ]
        [ el [ Font.size 12, Font.color fontColor, Font.bold, width (px 15) ] (el [ alignLeft ] (text problem.id))
        , el [ Font.size 12, Font.color fontColor, Font.bold, width (px 8) ] (el [ alignLeft ] (text check))
        , el [ Font.size 14, Font.color fontColor ] (text title)
        ]


idToString : Maybe (List Int) -> String
idToString mis =
    case mis of
        Nothing ->
            ""

        Just is ->
            is |> List.map String.fromInt |> String.join "."


renderedSource : Int -> String -> Element Msg
renderedSource counter sourceText =
    Keyed.node "div"
        renderedSourceStyle
        [ ( String.fromInt counter, Markdown.Render.toHtml ExtendedMath sourceText |> Html.map MarkdownMsg ) ]
        |> Element.html


viewComment : Bool -> Int -> Maybe AugmentedProblem -> Element Msg
viewComment showMe seed mprob =
    case mprob of
        Nothing ->
            Element.none

        Just prob_ ->
            let
                prob =
                    getProblem prob_
            in
            column []
                [ column
                    [ Background.color (Style.gray 255)
                    , Font.size 16
                    , paddingXY 18 0
                    , width (px (Config.paneWidth + 15))
                    , height (px Config.paneHeight)
                    , scrollbarY
                    ]
                    [ renderMath seed [] prob.solution ]
                ]


viewEditor : Model -> Element Msg
viewEditor model =
    let
        bgColor =
            Background.color (Element.rgb 0.9 0.89 1.0)
    in
    Input.multiline [ width (px 560), height (px Config.paneHeight), Font.size 16, bgColor ]
        { onChange = GetSolution
        , text = model.solution
        , placeholder = Nothing
        , spellcheck = False
        , label = Input.labelHidden "LaTeX input field"
        }


viewSolution : Int -> String -> Element Msg
viewSolution seed solution_ =
    let
        solution =
            if solution_ == "" then
                "$$\n??\n$$"

            else
                "$$\n" ++ solution_ ++ "\n$$"
    in
    column solutionStyle
        [ renderMath seed [] solution ]


solutionStyle : List (Attribute Msg)
solutionStyle =
    [ height (px Config.paneHeight)
    , width (px 560)
    , paddingXY 18 0
    , Font.size 16
    , Background.color (rgb 255 255 255)
    ]


viewProblem : Int -> Maybe AugmentedProblem -> Element Msg
viewProblem seed mproblem =
    case mproblem of
        Nothing ->
            el [] (text "No problem loaded")

        Just problem ->
            renderProblem seed (getProblem problem).problem



-- RENDER


renderProblem : Int -> String -> Element Msg
renderProblem seed str =
    column problemStyle
        [ renderMath seed [] str ]


problemStyle : List (Attribute Msg)
problemStyle =
    [ height (px Config.paneHeight)
    , width (px 560)
    , paddingXY 18 0
    , Font.size 16
    , Background.color (rgb 255 255 255)
    ]


renderMath : Int -> List (Html.Attribute Msg) -> String -> Element Msg
renderMath seed attr str =
    str
        |> MiniLatex.EditSimple.renderWithVersion seed
        |> List.map (Html.map LaTeXMsg)
        |> Html.div attr
        |> mathNode seed


mathNode : Int -> Html Msg -> Element Msg
mathNode k element =
    Keyed.node "div" [] [ ( String.fromInt k, element ) ] |> Element.html



-- UI


heading : String -> Element msg
heading str =
    row [ Font.size 16, Font.italic, paddingEach { top = 12, bottom = 0, left = 0, right = 0 } ] [ text str ]


headingBlue : String -> Element msg
headingBlue str =
    row
        [ Font.size 16
        , Font.italic
        , Font.bold
        , Font.color (Element.rgb 0.2 0.2 1.0)
        , paddingEach { top = 12, bottom = 0, left = 0, right = 0 }
        ]
        [ text str ]


heading1 : String -> Element msg
heading1 str =
    row [ Font.size 16, Font.italic ] [ text str ]
