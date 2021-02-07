module Main exposing (main)

{- This is a starter app which presents a text label, text field, and a button.
   What you enter in the text field is echoed in the label.  When you press the
   button, the text in the label is reverse.
   This is the Elements version.  It uses uses `mdgriffith/elm-ui` for the view functions.
-}

import Browser
import Html exposing (Html)
import Html.Keyed as Keyed
import Element exposing (..)
import Element.Background as Background
import Element.Font as Font
import Element.Input as Input
import File exposing (File)
import File.Select as Select
import Problem exposing(Id, Op(..), AugmentedProblem)
import Task
import DocParser exposing(Problem, DocumentDescription)
import MiniLatex.EditSimple
import Config
import Random
import Style exposing(..)
import Utility
import Tree.Zipper as Zipper exposing(Zipper)
import Markdown.Option exposing (MarkdownOption(..), OutputOption(..))
import Markdown.Render

main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


-- MODEL

type alias Model =
    { input : String
    , output : String
    , fileContents : Maybe String
    , documentDescription : Maybe DocumentDescription
    , problems : Zipper AugmentedProblem
    , currentProblem : Maybe AugmentedProblem
    , solution: String
    , seed : Int
    , counter : Int
    , showInfo : Bool
    , numberOfProblems : Int
    , numberOfProblemsCompleted : Int
    }




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


type alias Flags =
    { seed : Int
    , width : Int
    , height : Int
    }


load : String -> (Maybe DocumentDescription, Zipper AugmentedProblem)
load input =
    let
          (documentDescription, problems_) =
             case DocParser.parseDocument input of
                Nothing -> (Nothing, [])
                Just (desc, probs) -> (Just desc, probs)

          zipper = Problem.toZipper problems_
    in
      (documentDescription, zipper)

init : Flags -> ( Model, Cmd Msg )
init flags =
    let
      (documentDescription, zipper) = load Config.initialDocumentText |> Debug.log "INIT"

      foo = zipper
    in
    ( { input = "App started"
      , output = "App started"
      , fileContents = Nothing
      , documentDescription = documentDescription
      , problems = zipper
      , currentProblem =  Just (Zipper.label zipper)
      , solution = Config.initialSolutionText
      , seed = flags.seed
      , counter = 0
      , showInfo = False
      , numberOfProblems  = Problem.numberOfProblems zipper
      , numberOfProblemsCompleted = 0
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

        MarkdownMsg _ -> ( model, Cmd.none )

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
            case load (Utility.removeComments content) of
                (Nothing, _) -> (model, Cmd.none)
                (documentDescription, zipper) ->
                      ( { model | fileContents = Just content
                           , documentDescription = documentDescription
                           , problems = zipper
                           , currentProblem = Just <| Zipper.label zipper
                           , output =  fileStatus (Just content)
                           , solution =  "nothing yet"
                           , counter = model.counter + 1
                           , numberOfProblems = Problem.numberOfProblems zipper
                           , numberOfProblemsCompleted = 0
                        }
                      , Cmd.none
                      )

        NewSeed newSeed ->
             ( { model | seed = newSeed }, Cmd.none )

        GetSolution s ->
           ({model | solution = s, counter = Debug.log "N" (model.counter + 1)}, Random.generate NewSeed (Random.int 1 10000))


        NextProblem ->
            let
                zipper = Problem.forward model.problems
            in
            ({model | problems = zipper
                    , solution = ""
                    , counter = model.counter + 1
                    , showInfo = False
                    , currentProblem = Just <| Zipper.label zipper}
                    , Cmd.none)

        PrevProblem ->
            let
                zipper = Problem.backward model.problems
            in
            ({model | problems = zipper
                    , solution = ""
                    , counter = model.counter + 1
                    , showInfo = False
                    , currentProblem = Just <| Zipper.label zipper}, Cmd.none)

        OK ->
            case model.currentProblem of
                Nothing -> (model, Cmd.none)
                Just prob ->
                    let
                        zipper1 = Problem.setCompleted True prob model.problems
                        zipper2 = Problem.forward zipper1
                    in
                        ({model | problems = zipper2
                                , showInfo = False
                                , counter = model.counter + 1
                                , currentProblem =  Just (Zipper.label zipper2)
                                , numberOfProblemsCompleted = Problem.numberOfCompletedProblems zipper2
                             }
                            , Cmd.none)

        ToggleInfo -> ({model | showInfo = not model.showInfo}, Cmd.none)

fileStatus : Maybe String -> String
fileStatus mstr =
    case mstr of
        Nothing -> "No file contents loaded"
        Just stuff -> String.fromInt (String.length stuff) ++ " bytes read"

--
-- VIEW
--



view : Model -> Html Msg
view model =
    Element.layoutWith { options = [focusStyle noFocus]}
       [Background.color (gray 60)]
       (mainView model)

noFocus : Element.FocusStyle
noFocus =
    { borderColor = Nothing
    , backgroundColor = Nothing
    , shadow = Nothing
    }

mainView : Model -> Element Msg
mainView model =
  column [centerX] [
      -- row [width (px Config.appWidth), centerX, paddingXY 0 12] [ title Config.appTitle ]
      row [  spacing 20 ] [ lhs model, rhs model ]
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

            , showIf model.showInfo <| showHint model.seed model.currentProblem
            , el [Font.size 12, Font.italic, alignBottom ](outputDisplay model)
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
               , renderedSource model.counter (Maybe.map .description model.documentDescription |>  Maybe.withDefault "Exercises")
               , showComment model.seed model.currentProblem

            ]
        ]

renderedSource : Int -> String -> Element Msg
renderedSource counter sourceText =
    (Keyed.node "div"
        renderedSourceStyle
        [ ( String.fromInt counter, Markdown.Render.toHtml ExtendedMath sourceText |> Html.map MarkdownMsg ) ]
        ) |> Element.html



showIf : Bool -> Element Msg -> Element Msg
showIf show element =
    if show then  element else Element.none

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
                column[width (px 380) ] [
                       el [Font.size 14, Font.bold, moveRight 8] (text "Comment")
                     , column [Font.size 13, width (px 380), padding 10] [renderMath seed commentStyle prob.comment]
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
        [ text model.output, text <| "Problems loaded"] -- ++ String.fromInt (List.length model.problems) ]


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

