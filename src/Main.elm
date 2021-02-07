module Main exposing (main)


import Browser
import Html exposing (Html)
import Element exposing (..)
import Element.Background as Background
import File exposing (File)
import File.Select as Select
import Problem exposing(Id, Op(..), AugmentedProblem)
import Task
import DocParser exposing(Problem, DocumentDescription)
import Config
import Random
import Style exposing(..)
import Utility
import Tree.Zipper as Zipper exposing(Zipper)
import Msg exposing(..)
import View.Standard as Standard
import View.Editor as Editor
import Model exposing(Model, AppMode(..))
import Editor exposing(EditorModel, EditorMsg(..))

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
      (documentDescription, zipper) = load Config.initialDocumentText |> Debug.log "INIT"
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
      , appMode = StandardMode
      , editorModel = Editor.initModel
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

        ToggleAppMode ->
            let
              newMode = case model.appMode of
                  StandardMode -> EditMode
                  EditMode -> StandardMode
            in
              ({ model | appMode = newMode}, Cmd.none)

        E editorMsg ->
          case editorMsg of
            GoToStandarMode ->
               ({ model | appMode = StandardMode}, Cmd.none)
            _ -> let
                   (newEditorModel, cmd) = Editor.update editorMsg model.editorModel
                 in
                   ({model | editorModel = newEditorModel}, cmd |> Cmd.map E)


view : Model -> Html Msg
view model =
    Element.layoutWith { options = [focusStyle noFocus]}
       [Background.color (gray 60)]
       (mainView model)

mainView model =
    case model.appMode of
        StandardMode -> Standard.view model
        EditMode -> Editor.view model.editorModel |> Element.map E


-- HELPERS

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
