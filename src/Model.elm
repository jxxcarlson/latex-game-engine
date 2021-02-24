module Model exposing (..)

import Document
import Problem exposing (AugmentedProblem, Id)
import Tree.Zipper exposing (Zipper)


type alias Model =
    { input : String
    , message : String
    , fileContents : Maybe String
    , format : String
    , documentHeader : Document.Header
    , documentHeaderVisible : Bool
    , problems : Zipper AugmentedProblem
    , problemList : List AugmentedProblem
    , currentProblem : Maybe AugmentedProblem
    , solution : String
    , seed : Int
    , counter : Int
    , numberOfProblems : Int
    , numberOfProblemsCompleted : Int
    , url : String
    }
