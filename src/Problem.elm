module Problem exposing (zip, AugmentedProblem, setCompleted,
   numberOfCompletedProblems, numberOfProblems, errorZipper, augment
   , Id, firstChild, forward, backward)

import HTree
import Tree exposing(Tree)
import Tree.Zipper as Zipper exposing(Zipper)
import Document

type alias Id = Maybe (List Int)

type alias AugmentedProblem = {id: String, prob : Document.Problem, completed: Bool}

zip : List Document.Problem -> Zipper AugmentedProblem
zip probs =
    case List.head probs of
        (Just (Document.CommentedP _)) ->
            probs
              |> List.map augment
              |> HTree.fromList (augment rootProblemCommented) (\p -> indexLevel p.id)
              |> Zipper.fromTree
        _ ->
            List.indexedMap (\k p -> {p | id = String.fromInt k}) (List.map augment probs)
              |> HTree.fromList rootProblemSimple (\q -> 1) |> Zipper.fromTree

errorZipper : Zipper AugmentedProblem
errorZipper = Tree.singleton (augmentProblemCommented rootProblemCommented_) |> Zipper.fromTree


augment : Document.Problem -> AugmentedProblem
augment prob =
    case prob of
        (Document.SimpleP _) -> {id = "0", prob = prob, completed = False }
        (Document.SolvedP _) -> {id = "0", prob = prob, completed = False }
        (Document.CommentedP p) -> {id = p.id, prob = prob, completed = False }

level : Document.Problem -> Int
level prob =
    case prob of
        (Document.SimpleP _) -> 0
        (Document.SolvedP _) -> 0
        (Document.CommentedP p) -> p.id |> String.split "." |> List.length

indexLevel str =
    str |> String.split "." |> List.length



augmentProblemCommented : Document.CommentedProblem -> AugmentedProblem
augmentProblemCommented p = {id = p.id, prob = Document.CommentedP p, completed = False }


rootProblemSimple : AugmentedProblem
rootProblemSimple = {id = "x", prob = Document.SimpleP "root", completed = False}

rootProblemSolved : AugmentedProblem
rootProblemSolved = {id = "x", prob = Document.SolvedP {problem = "root",solution = ""}, completed = False}


rootProblemCommented : Document.Problem
rootProblemCommented = Document.CommentedP {
      title = "root"
    , id = ""
    , target = ""
    , comment = ""
    }

rootProblemCommented_ = {
      title = "root"
    , id = ""
    , target = ""
    , comment = ""
    }

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