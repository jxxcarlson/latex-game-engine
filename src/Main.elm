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
import Tree.Zipper as Zipper
import Tree
import Problem

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
      data = case load Config.initialDocumentText of
          Ok data_ -> data_
          Err _ -> {desc = DocParser.errorDescription, problems = [], zipper = Zipper.fromTree (Tree.singleton Problem.rootProblem)}
    in
    ( { input = "App started"
      , message = "App started"
      , fileContents = Nothing
      , documentDescription = Just data.desc
      , documentDescriptionVisible = True
      , problems = data.zipper
      , currentProblem =  Just (Zipper.label data.zipper)
      , solution = Config.initialSolutionText
      , seed = flags.seed
      , counter = 0
      , showInfo = False
      , numberOfProblems  = Problem.numberOfProblems data.zipper
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
            ( { model | input = str, message = str }, Cmd.none )

        ReverseText ->
            ( { model | message = model.message |> String.reverse |> String.toLower }, Cmd.none )

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
                Err message -> ({model | message = message}, Cmd.none)
                Ok data ->
                    let
                      oldEditorModel = model.editorModel
                      newEditorModel =
                         {oldEditorModel | problemList = List.reverse data.problems}
                           |> addDocumentDescription (Just data.desc)
                    in
                      ( { model | fileContents = Just content
                           , documentDescription = Just data.desc
                           , documentDescriptionVisible = True
                           , problems = data.zipper
                           , currentProblem = Just <| Zipper.label data.zipper
                           , message =  fileStatus (Just content)
                           , solution =  "nothing yet"
                           , counter = model.counter + 1
                           , numberOfProblems = Problem.numberOfProblems data.zipper
                           , numberOfProblemsCompleted = 0
                           , editorModel = newEditorModel
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
                                , solution = ""
                                , counter = model.counter + 1
                                , showInfo = False
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


load : String -> Result String { desc: DocumentDescription, problems: List Problem, zipper: Zipper AugmentedProblem}
load input =
    case DocParser.parseDocument input of
        Ok (documentDescription, problems_) ->
            Ok { desc = documentDescription, problems = problems_, zipper = Problem.toZipper problems_}
        Err err -> Err ("Errors: " ++ err)


addDocumentDescription : Maybe DocumentDescription -> EditorModel -> EditorModel
addDocumentDescription mdesc editorModel =
  case mdesc of
      Nothing -> editorModel
      Just desc ->
         {editorModel | docTitle = desc.title
                      , date = desc.date
                      , author = desc.author
                      , description = desc.description
        }