module Main exposing (main)


import Browser
import Html exposing (Html)
import Element exposing (..)
import Element.Background as Background
import Problem exposing(Id, AugmentedProblem)
import DocParser exposing(Problem, DocumentDescription)
import Random
import Style exposing(..)
import Tree.Zipper as Zipper exposing(Zipper)
import Msg exposing(..)
import View
import Model exposing(Model)
import Http
import Tree.Zipper as Zipper
import Tree
import Problem
import Strings

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
      data : { desc : DocumentDescription, problems : List Problem, zipper : Zipper AugmentedProblem }
      data = case load Strings.initialDocument of
          Ok data_ -> data_
          Err _ -> {desc = DocParser.errorDescription, problems = [], zipper = Zipper.fromTree (Tree.singleton Problem.rootProblem)}
    in
    ( { input = "App started"
      , message = "App started"
      , fileContents = Just Strings.initialDocument
      , documentDescription = Just data.desc
      , documentDescriptionVisible = True
      , problems = data.zipper
      , problemList = data.zipper |> Zipper.toTree |> Tree.flatten |> List.drop 1
      , currentProblem =  Just (Zipper.label data.zipper)
      , solution = ""
      , seed = flags.seed
      , counter = 0
      , numberOfProblems  = Problem.numberOfProblems data.zipper
      , numberOfProblemsCompleted = 0
      , url = "jxxcarlson/latex-lessons/master/lesson1"
      }
    , Cmd.none
    )


subscriptions model =
    Sub.none


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LaTeXMsg _ -> ( model, Cmd.none )

        MarkdownMsg _ -> ( model, Cmd.none )

        AcceptUrl url ->
          ({ model | url = url}, Cmd.none)

        GetLesson ->
          (model, getLesson model.url)

        GotLesson result ->
          case result of
           Ok content -> loadLesson model content

           Err _ -> (model, Cmd.none)

        InputText str ->
            ( { model | input = str, message = str }, Cmd.none )

        NewSeed newSeed ->
             ( { model | seed = newSeed }, Cmd.none )

        GetSolution s ->
           ({model | solution = s, counter = model.counter + 1}, Random.generate NewSeed (Random.int 1 10000))


        NextProblem ->
            let
                zipper = Problem.forward model.problems
            in
            ({model | problems = zipper
                    , solution = ""
                    , counter = model.counter + 1
                    , documentDescriptionVisible = False
                    , currentProblem = Just <| Zipper.label zipper}
                    , Cmd.none)

        PrevProblem ->
            let
                zipper = Problem.backward model.problems
            in
            ({model | problems = zipper
                    , solution = ""
                    , counter = model.counter + 1
                    , currentProblem = Just <| Zipper.label zipper}, Cmd.none)

        SolutionIsOK ->
            case model.currentProblem of
                Nothing -> (model , Cmd.none)
                Just prob ->
                    let
                        zipper1 = Problem.setCompleted True prob model.problems
                        zipper2 = Problem.forward zipper1
                    in
                        ({model | problems = zipper2
                                , solution = ""
                                , counter = model.counter + 1
                                , currentProblem =  Just (Zipper.label zipper2)
                                , numberOfProblemsCompleted = Problem.numberOfCompletedProblems zipper2
                             }
                            , Cmd.none)



view : Model -> Html Msg
view model =
    Element.layoutWith { options = [focusStyle noFocus]}
       [Background.color (gray 60)]
       (mainView model)

mainView model =
    View.view model


-- HELPERS

loadLesson model content =
    case load (removeComments content) of
        Err message -> ({model | message = message}, Cmd.none)
        Ok data ->
                ( { model | fileContents = Just content
                    , documentDescription = Just data.desc
                    , problems = data.zipper
                    , currentProblem = Just <| Zipper.label data.zipper
                    , problemList = data.zipper |> Zipper.toTree |> Tree.flatten |> List.drop 1
                    , message =  fileStatus (Just content)
                    , solution =  ""
                    , counter = model.counter + 1
                    , numberOfProblems = Problem.numberOfProblems data.zipper
                    , numberOfProblemsCompleted = 0
                }
                , Cmd.none
                )

removeComments : String -> String
removeComments str =
   str
     |> String.lines
     |> List.filter (\l -> String.left 1 l /= "#")
     |> String.join "\n"

getLesson: String -> Cmd Msg
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
        Nothing -> "No file contents loaded"
        Just stuff -> String.fromInt (String.length stuff) ++ " bytes read"


load : String -> Result String { desc: DocumentDescription, problems: List Problem, zipper: Zipper AugmentedProblem}
load input =
    case DocParser.parseDocument input of
        Ok (documentDescription, problems_) ->
            Ok { desc = documentDescription, problems = problems_, zipper = Problem.toZipper problems_}
        Err err -> Err ("Errors: " ++ err)

