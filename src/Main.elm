module Main exposing (main)

{- This is a starter app which presents a text label, text field, and a button.
   What you enter in the text field is echoed in the label.  When you press the
   button, the text in the label is reverse.
   This is the Elements version.  It uses uses `mdgriffith/elm-ui` for the view functions.
-}

import Browser
import Html exposing (Html)
import Html.Attributes as HA
import Element exposing (..)
import Element.Background as Background
import Element.Font as Font
import Element.Input as Input
import File exposing (File)
import File.Select as Select
import Task
import DocParser exposing(Problem)
import Json.Encode
import MiniLatex.EditSimple
import MiniLatex.Edit


main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


type alias Model =
    { input : String
    , output : String
    , fileContents : Maybe String
    , problems : List Problem
    , currentProblem : Maybe Problem
    }


type Msg
    = NoOp
    | InputText String
    | ReverseText
    | ProblemsRequested
    | ProblemsSelected File
    | ProblemsLoaded String
    | LaTeXMsg MiniLatex.EditSimple.LaTeXMsg


type alias Flags =
    {}


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( { input = "App started"
      , output = "App started"
      , fileContents = Nothing
      , problems = []
      , currentProblem = Nothing
      }
    , Cmd.none
    )


subscriptions model =
    Sub.none


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        LaTeXMsg _ -> ( model, Cmd.none )

        InputText str ->
            ( { model | input = str, output = str }, Cmd.none )

        ReverseText ->
            ( { model | output = model.output |> String.reverse |> String.toLower }, Cmd.none )

        ProblemsRequested ->
              ( model
              , Select.file ["text/text"] ProblemsSelected
              )

        ProblemsSelected file ->
          ( model
          , Task.perform ProblemsLoaded (File.toString file)
          )

        ProblemsLoaded content ->
          let
              problems = Debug.log "PROBLEMS" <| DocParser.problems content
          in
          ( { model | fileContents = Just content
               , problems = problems
               , currentProblem = List.head problems
               , output =  fileStatus (Just content)}
          , Cmd.none
          )

fileStatus : Maybe String -> String
fileStatus mstr =
    case mstr of
        Nothing -> "No file contents loaded"
        Just stuff -> String.fromInt (String.length stuff) ++ " chars added"

--
-- VIEW
--


view : Model -> Html Msg
view model =
    Element.layoutWith { options = [focusStyle noFocus]}
       [Background.color (rgb255 40 40 40)]
       (mainView model)

noFocus : Element.FocusStyle
noFocus =
    { borderColor = Nothing
    , backgroundColor = Nothing
    , shadow = Nothing
    }

mainView : Model -> Element Msg
mainView model =
    column mainColumnStyle
        [ column [  spacing 20 ]
            [ title "The LaTeX Game"
            , viewProblem model.currentProblem
            , inputText model
            , appButton
            , outputDisplay model
            ]
        ]

viewProblem : Maybe Problem -> Element Msg
viewProblem mproblem =
    case mproblem of
        Nothing -> el [] (text "No problem loaded")
        Just problem -> renderMath problem


renderMath_ : String -> List (Html Msg)
renderMath_ str =
   str
     |> MiniLatex.EditSimple.render
     |> List.map (Html.map LaTeXMsg)

renderMath problem =
    case List.head problem.target of
        Nothing -> Element.none
        Just sourceText ->
           column [height (px 220), width (px 560), padding 24,  Background.color (rgb 255 255 255)]
             (List.map Element.html (renderMath_ sourceText))


mathText : String -> Html msg
mathText content =
    Html.node "math-text"
        [ HA.class "mm-math", HA.property "content" (Json.Encode.string content) ]
        []

-- renderLaTeX : String -> Element Msg
renderLaTeX str =
   row [ ](MiniLatex.EditSimple.render str |> List.map (Element.html))

title : String -> Element msg
title str =
    row [  Font.size 36 ] [ text str ]


outputDisplay : Model -> Element msg
outputDisplay model =
    row [ spacing 12]
        [ text model.output, text <| "Problems loaded: " ++ String.fromInt (List.length model.problems) ]


inputText : Model -> Element Msg
inputText model =
    el [moveLeft 5]
        (Input.text []
            { onChange = InputText
            , text = model.input
            , placeholder = Nothing
            , label = Input.labelLeft [] <| el [] (text "")
            })


appButton : Element Msg
appButton =
    row [ ]
        [ Input.button buttonStyle
            { onPress = Just ProblemsRequested
            , label = el [ centerX, centerY ] (text "Load")
            }
        ]



--
-- STYLE
--


mainColumnStyle =
    let
      g = 200
    in
    [ centerX
    , centerY
    , Background.color (rgb255 g g g)
    , paddingXY 20 20
    , width (px 600)
    , height fill
    ]


buttonStyle =
    [ Background.color (rgb255 40 40 40)
    , Font.color (rgb255 255 255 255)
    , paddingXY 15 8
    ]
