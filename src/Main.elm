module Main exposing (main)

{- This is a starter app which presents a text label, text field, and a button.
   What you enter in the text field is echoed in the label.  When you press the
   button, the text in the label is reverse.
   This is the Elements version.  It uses uses `mdgriffith/elm-ui` for the view functions.
-}

import Browser
import Html exposing (Html)
import Html.Attributes as HA
import Html.Keyed as Keyed
import Element exposing (..)
import Element.Background as Background
import Element.Font as Font
import Element.Input as Input
import File exposing (File)
import File.Select as Select
import Task
import DocParser exposing(Problem)
import MiniLatex.EditSimple
import Config
import Random


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
    , solution: String
    , seed : Int
    , counter : Int
    }




type Msg
    = NoOp
    | InputText String
    | ReverseText
    | ProblemsRequested
    | ProblemsSelected File
    | ProblemsLoaded String
    | LaTeXMsg MiniLatex.EditSimple.LaTeXMsg
    | NewSeed Int
    | GetSolution String


type alias Flags =
    { seed : Int
    , width : Int
    , height : Int
    }


init : Flags -> ( Model, Cmd Msg )
init flags =
    let
        initialProblemList : List Problem
        initialProblemList = DocParser.problems Config.initialProblemText
        initialSolution = Config.initialSolutionText
    in
    ( { input = "App started"
      , output = "App started"
      , fileContents = Nothing
      , problems = initialProblemList
      , currentProblem = List.head initialProblemList
      , solution = initialSolution
      , seed = flags.seed
      , counter = 0
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
              problems =  DocParser.problems content
          in
          ( { model | fileContents = Just content
               , problems = problems
               , currentProblem = List.head problems
               , output =  fileStatus (Just content)
               , solution =  "nothing yet"
            }
          , Cmd.none
          )

        NewSeed newSeed ->
             ( { model | seed = newSeed }, Cmd.none )

        GetSolution s ->
           ({model | solution = s, counter = Debug.log "N" (model.counter + 1)}, Random.generate NewSeed (Random.int 1 10000))

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
  column [] [
       row [width (px Config.appWidth), centerX, paddingXY 0 12] [ title Config.appTitle ]
     , row [  spacing 20 ] [ lhs model, rhs model ]
    ]


lhs : Model -> Element Msg
lhs model =
    column mainColumnStyle
        [ column [  spacing 10 ]
            [ heading Config.problemTitle
            , viewProblem model.counter model.currentProblem
            , heading Config.solutionTitle
            , viewSolution model.counter model.solution
            , heading Config.answerTitle
            , viewEditor model
            ]
        ]


rhs : Model -> Element Msg
rhs model =
    column mainColumnStyle
        [ column [  spacing 10 ]
            [ title "Controls"
            , inputText model
            , appButton
            , outputDisplay model
            ]
        ]

viewEditor : Model -> Element Msg
viewEditor model =
    Input.multiline [width (px 560), height (px Config.paneHeight)]
      { onChange = GetSolution
      , text = model.solution
      , placeholder = Nothing
      , spellcheck = False
      , label = Input.labelHidden "LaTeX input field"


      }

viewSolution : Int -> String -> Element Msg
viewSolution  seed solution =
  column [height (px Config.paneHeight), width (px 560), paddingXY 18 0,  Font.size 16, Background.color (rgb 255 255 255)]
     [renderMath seed solution]

viewProblem : Int -> Maybe Problem -> Element Msg
viewProblem seed mproblem =
    case mproblem of
        Nothing -> el [] (text "No problem loaded")
        Just problem -> renderProblem seed problem



-- RENDER

renderProblem : Int -> Problem -> Element Msg
renderProblem seed problem =
    case List.head problem.target of
        Nothing -> Element.none
        Just sourceText ->
           column [height (px Config.paneHeight), width (px 560), paddingXY 18 0,  Font.size 16, Background.color (rgb 255 255 255)]
             [renderMath seed sourceText]


renderMath : Int -> String -> Element Msg
renderMath seed str =
   str
     |> MiniLatex.EditSimple.renderWithVersion seed
     |> List.map (Html.map LaTeXMsg)
     |> Html.div  []
     |> mathNode seed

mathNode : Int -> Html Msg -> Element Msg
mathNode k element =
    (Keyed.node "div" [] [(String.fromInt k, element)]) |> Element.html



-- UI

title : String -> Element msg
title str =
    row [  width (px Config.appWidth), Font.size 36, Font.color (rgb255 240 240 240) ] [ text str ]

heading : String -> Element msg
heading str =
    row [  Font.size 18, paddingEach {top = 12, bottom = 0, left = 0, right = 0} ] [ text str ]

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
