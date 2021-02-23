module Model exposing (..)

import Problem exposing(Id,  AugmentedProblem)
import DocParser exposing(Problem, DocumentDescription)
import Tree.Zipper exposing(Zipper)

type alias Model =
    { input : String
    , message : String
    , fileContents : Maybe String
    , documentDescription : Maybe DocumentDescription
    , documentDescriptionVisible : Bool
    , problems : Zipper AugmentedProblem
    , problemList : List AugmentedProblem
    , currentProblem : Maybe AugmentedProblem
    , solution: String
    , seed : Int
    , counter : Int
    , numberOfProblems : Int
    , numberOfProblemsCompleted : Int
    , url : String
    }
