module Main exposing (main)

import Browser
import Document
import Element exposing (..)
import Element.Background as Background
import Html exposing (Html)
import Http
import Model exposing (Model)
import Msg exposing (..)
import Problem exposing (AugmentedProblem, Id)
import Random
import Strings
import Style exposing (..)
import Tree
import Tree.Zipper as Zipper exposing (Zipper)
import View.Commented
import View.Simple
import View.Solved
import YamlDoc


main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


type alias Flags =
    { seed : Int
    , width : Int
    , height : Int
    }


init : Flags -> ( Model, Cmd Msg )
init flags =
    let
        data : Data
        data =
            case load YamlDoc.solved of
                Just data_ ->
                    data_

                Nothing ->
                    { format = "latex-commented", desc = Document.errorHeader, problems = [], zipper = Problem.errorZipper }
    in
    ( { input = "App started"
      , format = data.format
      , message = "App started"
      , fileContents = Just YamlDoc.solved
      , documentHeader = data.desc
      , documentHeaderVisible = True
      , problems = data.zipper
      , problemList = data.problems
      , currentProblem = Just (Zipper.label data.zipper)
      , solution = ""
      , showSolution = False
      , seed = flags.seed
      , counter = 0
      , numberOfProblems = List.length data.problems
      , numberOfProblemsCompleted = 0
      , url = "jxxcarlson/latex-lessons/master/latex-simple.yaml"
      }
    , Cmd.none
    )


type alias Data =
    { format : String
    , desc : Document.Header
    , problems : List AugmentedProblem
    , zipper : Zipper AugmentedProblem
    }


subscriptions model =
    Sub.none


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LaTeXMsg _ ->
            ( model, Cmd.none )

        MarkdownMsg _ ->
            ( model, Cmd.none )

        AcceptUrl url ->
            ( { model | url = url }, Cmd.none )

        GetLesson ->
            ( model, getLesson model.url )

        GotLesson result ->
            case result of
                Ok content ->
                    loadLesson model content

                Err _ ->
                    ( model, Cmd.none )

        InputText str ->
            ( { model | input = str, message = str }, Cmd.none )

        NewSeed newSeed ->
            ( { model | seed = newSeed }, Cmd.none )

        GetSolution s ->
            ( { model | solution = s, counter = model.counter + 1 }, Random.generate NewSeed (Random.int 1 10000) )

        NextProblem ->
            let
                zipper =
                    Problem.forward model.problems
            in
            ( { model
                | problems = zipper
                , solution = ""
                , showSolution = False
                , counter = model.counter + 1
                , documentHeaderVisible = False
                , currentProblem = Just <| Zipper.label zipper
              }
            , Cmd.none
            )

        PrevProblem ->
            let
                zipper =
                    Problem.backward model.problems
            in
            ( { model
                | problems = zipper
                , solution = ""
                , showSolution = False
                , counter = model.counter + 1
                , currentProblem = Just <| Zipper.label zipper
              }
            , Cmd.none
            )

        SolutionIsOK ->
            handleSolutionIsOK model

        ShowMe ->
            case model.showSolution of
                False ->
                    ( { model | showSolution = True }, Cmd.none )

                True ->
                    handleShowMe model


handleSolutionIsOK model =
    case model.currentProblem of
        Nothing ->
            ( model, Cmd.none )

        Just prob ->
            let
                zipper1 =
                    Problem.setCompleted True prob model.problems

                zipper2 =
                    Problem.forward zipper1
            in
            ( { model
                | problems = zipper2
                , problemList = zipper2 |> Zipper.toTree |> Tree.flatten |> List.drop 1
                , solution = ""
                , showSolution = False
                , counter = model.counter + 1
                , currentProblem = Just (Zipper.label zipper2)
                , numberOfProblemsCompleted = Problem.numberOfCompletedProblems zipper2
              }
            , Cmd.none
            )


handleShowMe model =
    case model.currentProblem of
        Nothing ->
            ( model, Cmd.none )

        Just prob ->
            let
                showSolution =
                    if model.format == "latex-solved" then
                        not model.showSolution

                    else
                        False

                zipper =
                    if model.format == "latex-solved" then
                        model.problems

                    else
                        Problem.forward model.problems
            in
            ( { model
                | problems = zipper
                , showSolution = showSolution
                , counter = model.counter + 1
                , currentProblem = Just (Zipper.label zipper)
              }
            , Cmd.none
            )


view : Model -> Html Msg
view model =
    Element.layoutWith { options = [ focusStyle noFocus ] }
        [ Background.color (gray 60) ]
        (mainView model)


mainView model =
    case model.format of
        "latex-commented" ->
            View.Commented.view model

        "latex-simple" ->
            View.Simple.view model

        "latex-solved" ->
            View.Solved.view model

        _ ->
            View.Simple.view model



-- HELPERS


loadLesson : Model -> String -> ( Model, Cmd msg )
loadLesson model content =
    case load content of
        Nothing ->
            ( { model | message = "Could not load document" }, Cmd.none )

        Just data ->
            ( { model
                | fileContents = Just content
                , format = data.format
                , documentHeader = data.desc
                , problems = data.zipper
                , currentProblem = Just <| Zipper.label data.zipper
                , problemList = data.zipper |> Zipper.toTree |> Tree.flatten |> List.drop 1
                , message = fileStatus (Just content)
                , solution = ""
                , counter = model.counter + 1
                , numberOfProblems = Problem.numberOfProblems data.zipper
                , numberOfProblemsCompleted = 0
              }
            , Cmd.none
            )


getLesson : String -> Cmd Msg
getLesson url =
    Http.get
        { url = "https://raw.githubusercontent.com/" ++ url -- dev: https://raw.githack.com/, prod: rawcdn.githack.com
        , expect = Http.expectString GotLesson
        }


noFocus : Element.FocusStyle
noFocus =
    { borderColor = Nothing
    , backgroundColor = Nothing
    , shadow = Nothing
    }


fileStatus : Maybe String -> String
fileStatus mstr =
    case mstr of
        Nothing ->
            "No file contents loaded"

        Just stuff ->
            String.fromInt (String.length stuff) ++ " bytes read"


load : String -> Maybe Data
load input =
    case YamlDoc.parseDocument input of
        Just document_ ->
            let
                document =
                    Document.fixLaTeX document_

                problems =
                    Document.problems document
            in
            Just
                { format = Document.format document
                , desc = Document.header document
                , problems = Problem.augmentList problems
                , zipper = Problem.zip problems |> Problem.firstChild
                }

        Nothing ->
            Nothing
