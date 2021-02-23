module Model exposing (..)

import Problem exposing(Id, Op(..), AugmentedProblem)
import DocParser exposing(Problem, DocumentDescription)
import Tree.Zipper as Zipper exposing(Zipper)

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
    , showInfo : Bool
    , numberOfProblems : Int
    , numberOfProblemsCompleted : Int
    , url : String
    }
