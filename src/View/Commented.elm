module View.Commented exposing (view)

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


view : Model -> Element Msg
view model =
    column [ centerX ]
        [ row [ spacing 20 ] [ lhs model, rhs model ]
        ]


getProblem : AugmentedProblem -> Document.CommentedProblem
getProblem augp =
    case augp.prob of
        Document.CommentedP p ->
            p

        _ ->
            fakeProblem


fakeProblem : Document.CommentedProblem
fakeProblem =
    { title = "Undefind"
    , id = "0"
    , target = "null target"
    , comment = "null comment"
    }


lhs : Model -> Element Msg
lhs model =
    column mainColumnStyle
        [ column [ spacing 4 ]
            [ mainTitle
            , problemTitle model.currentProblem
            , heading1 Config.problemTitle
            , viewProblem model.counter model.currentProblem
            , heading Config.solutionTitle
            , viewSolution model.counter model.solution
            , heading Config.answerTitle
            , viewEditor model
            , row [ spacing 18, paddingXY 0 12, width (px Config.paneWidth) ]
                [ row [ spacing 6 ]
                    [ prevButton
                    , nextButton
                    ]
                , el [ centerX ] okButton
                , el [ alignRight ] (showScore model)
                ]
            , viewComment model.seed model.currentProblem
            , row [ spacing 12 ] [ loadButton, urlInput model ]
            , el [ moveRight 72, Font.size 12, Font.italic, paddingEach { top = 8, left = 0, right = 0, bottom = 0 } ]
                (text "Use the load button for more lessons. Lessons are on Github: user/repo/tag/lesson-name")
            ]
        ]


wellDone : Model -> Element Msg
wellDone model =
    if model.numberOfProblemsCompleted == model.numberOfProblems then
        el [ Font.size 24, Font.bold, Font.color (Element.rgb 0.7 0 0) ] (text "Well done!")

    else
        Element.none


showScore : Model -> Element Msg
showScore model =
    let
        completed =
            model.numberOfProblemsCompleted

        all =
            model.numberOfProblems

        ratio =
            String.fromInt completed ++ "/" ++ String.fromInt all

        pc_ =
            toFloat completed / toFloat all |> round |> String.fromInt

        pc =
            " (" ++ pc_ ++ "%)"
    in
    el [ Font.underline, Font.size 14, Font.color (Element.rgb 0.2 0.2 1) ] (text <| "Score: " ++ ratio ++ pc)


mainTitle : Element Msg
mainTitle =
    el [ Font.size 24, paddingEach { top = 0, bottom = 8, left = 0, right = 0 } ] (text "LaTeX Tutor")


problemTitle : Maybe AugmentedProblem -> Element Msg
problemTitle mprob =
    case mprob of
        Nothing ->
            Element.none

        Just prob ->
            el [ Font.bold, Font.size 18, paddingXY 0 8 ] (text <| prob.id ++ " " ++ (getProblem prob).title)


rhs : Model -> Element Msg
rhs model =
    column rhsColumnStyle
        [ column [ spacing 10 ]
            [ column [ spacing 4 ]
                [ el [ Font.bold, Font.size 24 ] (text model.documentHeader.title)
                , el [ Font.size 14 ] (text model.documentHeader.author)
                , el [ Font.size 14 ] (text model.documentHeader.date)
                ]
            , renderedSource model.counter (Document.fixLaTeXInString model.documentHeader.description)
            , column [ spacing 8, height (px 360), width (px 320), scrollbarY ]
                (List.map (summary model.currentProblem) model.problemList)
            ]
        , wellDone model
        , row [ moveDown 5, alignBottom, Font.size 12, Font.italic ] [ el [ alignBottom ] (outputDisplay model) ]
        ]


summary : Maybe AugmentedProblem -> AugmentedProblem -> Element Msg
summary mproblem problem =
    let
        fontColor =
            if mproblem == Just problem then
                Element.rgb 0.7 0 0

            else
                Element.rgb 0 0 0

        title =
            if problem.completed then
                String.fromChar '✓' ++ " " ++ (getProblem problem).title

            else
                (getProblem problem).title
    in
    row [ spacing 12 ]
        [ el [ Font.size 12, Font.color fontColor, Font.bold, width (px 30) ] (el [ alignLeft ] (text problem.id))
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


viewComment : Int -> Maybe AugmentedProblem -> Element Msg
viewComment seed mprob =
    case mprob of
        Nothing ->
            Element.none

        Just prob_ ->
            let
                prob =
                    getProblem prob_
            in
            if String.length prob.comment < 3 then
                Element.none

            else
                column [ paddingEach { top = 8, bottom = 32, left = 0, right = 0 } ]
                    [ column [ Background.color (Style.gray 255), Font.size 13, paddingXY 18 0, width (px (Config.paneWidth + 15)), height (px Config.commentPaneHeight), scrollbarY ]
                        [ renderMath seed (commentStyle (Config.paneWidth - 20) Config.commentPaneHeight) prob.comment ]
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
viewSolution seed solution =
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
            renderProblem seed problem



-- RENDER


renderProblem : Int -> AugmentedProblem -> Element Msg
renderProblem seed problem =
    column problemStyle
        [ renderMath seed [] (getProblem problem).target ]


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


heading1 : String -> Element msg
heading1 str =
    row [ Font.size 16, Font.italic ] [ text str ]


outputDisplay : Model -> Element msg
outputDisplay model =
    row [ spacing 12 ]
        [ text model.message ]



-- BUTTONS & FIELDS


urlInput : Model -> Element Msg
urlInput model =
    Input.text [ width (px 482), Font.size 14 ]
        { onChange = AcceptUrl
        , text = model.url
        , placeholder = Nothing
        , label = Input.labelHidden "Enter Github URL"
        }


loadButton : Element Msg
loadButton =
    row []
        [ Input.button buttonStyle
            { onPress = Just GetLesson
            , label = el labelStyle (text "Load")
            }
        ]


okButton : Element Msg
okButton =
    row []
        [ Input.button buttonStyle
            { onPress = Just SolutionIsOK
            , label = el labelStyle (text "I think it is correct")
            }
        ]


prevButton : Element Msg
prevButton =
    row []
        [ Input.button buttonStyle
            { onPress = Just PrevProblem
            , label = el labelStyle (text <| String.fromChar '◀')
            }
        ]


nextButton : Element Msg
nextButton =
    row []
        [ Input.button buttonStyle
            { onPress = Just NextProblem
            , label = el labelStyle (text <| String.fromChar '▶')
            }
        ]
