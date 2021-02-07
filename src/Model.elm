module Model exposing (..)

import Problem exposing(Id, Op(..), AugmentedProblem)
import DocParser exposing(Problem, DocumentDescription)
import Tree.Zipper as Zipper exposing(Zipper)
import Editor exposing(EditorModel)


type alias Model =
    { input : String
    , message : String
    , fileContents : Maybe String
    , documentDescription : Maybe DocumentDescription
    , documentDescriptionVisible : Bool
    , problems : Zipper AugmentedProblem
    , currentProblem : Maybe AugmentedProblem
    , solution: String
    , seed : Int
    , counter : Int
    , showInfo : Bool
    , numberOfProblems : Int
    , numberOfProblemsCompleted : Int
    , appMode : AppMode
    , editorModel : EditorModel
    }

type AppMode = StandardMode | EditMode