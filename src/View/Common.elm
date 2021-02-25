module View.Common exposing (bottomRowRHS, controls, loader, showIf, showScore, wellDone)

import Config
import Element exposing (..)
import Element.Font as Font
import Element.Input as Input
import Model exposing (Model)
import Msg exposing (..)
import Style exposing (..)


showIf : Bool -> Element Msg -> Element Msg
showIf bit element =
    if bit then
        element

    else
        Element.none


loader model =
    column [ spacing 8 ]
        [ row [ spacing 12 ] [ loadButton, urlInput model ]
        , el [ moveRight 72, Font.size 12, Font.italic, paddingEach { top = 8, left = 0, right = 0, bottom = 0 } ]
            (text "Use the load button for more lessons. Lessons are on Github: user/repo/tag/lesson-name")
        ]


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


controls model =
    row [ spacing 18, paddingXY 0 12, width (px Config.paneWidth) ]
        [ row [ spacing 6 ]
            [ prevButton
            , nextButton
            ]
        , row [ spacing 12, centerX ] [ okButton, showMeButton ]
        , el [ alignRight ] (showScore model)
        ]


bottomRowRHS model =
    row [ moveDown 5, alignBottom, Font.size 12, Font.italic, spacing 12 ]
        [ el [] (text model.format), el [ alignBottom ] (outputDisplay model) ]


outputDisplay : Model -> Element msg
outputDisplay model =
    row [ spacing 12 ]
        [ text model.message ]


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
            100 * (toFloat completed / toFloat all) |> round |> String.fromInt

        pc =
            " (" ++ pc_ ++ "%)"
    in
    el [ Font.underline, Font.size 14, Font.color (Element.rgb 0.2 0.2 1) ] (text <| "Score: " ++ ratio ++ pc)



-- BUTTONS


okButton : Element Msg
okButton =
    row []
        [ Input.button buttonStyle
            { onPress = Just SolutionIsOK
            , label = el labelStyle (text "I think it is correct")
            }
        ]


showMeButton : Element Msg
showMeButton =
    row []
        [ Input.button buttonStyle
            { onPress = Just ShowMe
            , label = el labelStyle (text "Show me")
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
