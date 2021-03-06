module Problem exposing (AugmentedProblem, setCompleted, Header,
   numberOfCompletedProblems, numberOfProblems,
    rootProblem
   , Id, toZipper, firstChild, forward, backward)

import DocParser exposing(Problem)
import HTree
import Tree exposing(Tree)
import Tree.Zipper as Zipper exposing(Zipper)

type alias Id = Maybe (List Int)

type alias AugmentedProblem = {
      title : String
    , id : Maybe (List Int)
    , target : String
    , comment : String
    , completed : Bool
    }

type alias Header = {
      docTitle : String
    , author : String
    , date : String
    , description : String
  }

augmentProblem : Problem -> AugmentedProblem
augmentProblem p = {
       title = p.title
     , id  = p.id
     , target  = p.target
     , comment  = p.comment
     , completed = False
     }

rootProblem = {
      title = "root"
    , id = Just []
    , target = ""
    , comment = ""
    , completed = False
    }

level : AugmentedProblem -> Int
level prob =
    case prob.id of
        Nothing -> -1
        Just id_ -> List.length id_

toZipper : List Problem -> Zipper AugmentedProblem
toZipper problems =
    problems
      |> List.filter (\p -> p.id /= Nothing)
      |> List.map augmentProblem
      |> HTree.fromList rootProblem level
      |> Zipper.fromTree
      |> firstChild


firstChild : Zipper a -> Zipper a
firstChild z =
    case Zipper.firstChild z of
        Nothing -> z
        Just z_ -> z_

forward : Zipper a -> Zipper a
forward z =
    case Zipper.forward z of
        Nothing -> z
        Just z_ -> z_

backward : Zipper a -> Zipper a
backward z =
    case Zipper.backward z of
        Nothing -> z
        Just z_ -> z_

setCompleted : Bool -> AugmentedProblem -> Zipper  AugmentedProblem ->  Zipper  AugmentedProblem
setCompleted bit prob zipper =
    Zipper.replaceLabel { prob | completed = bit } zipper


numberOfProblems : Zipper AugmentedProblem -> Int
numberOfProblems zipper =
    (List.length (Tree.flatten (Zipper.toTree zipper))) - 1

numberOfCompletedProblems : Zipper AugmentedProblem -> Int
numberOfCompletedProblems zipper =
    List.length (Tree.flatten (Zipper.toTree zipper) |> List.filter (\p -> p.completed == True))