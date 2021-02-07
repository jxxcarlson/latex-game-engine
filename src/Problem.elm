module Problem exposing (AugmentedProblem, findById, Id, Op(..), toZipper, firstChild, forward, backward)

import DocParser exposing(Problem)
import HTree
import Tree exposing(Tree)
import Tree.Zipper as Zipper exposing(Zipper)

type alias Id = Maybe (List Int)

type alias AugmentedProblem = {
      title : String
    , id : Maybe (List Int)
    , target : String
    , hint : String
    , comment : String
    , completed : Bool
    }


augmentProblem : Problem -> AugmentedProblem
augmentProblem p = {
       title = p.title
     , id  = p.id
     , target  = p.target
     , hint  = p.hint
     , comment  = p.comment
     , completed = False
     }



rootProblem = {
      title = "root"
    , id = Just []
    , target = ""
    , hint  = ""
    , comment = ""
    , completed = True
    }

type Op = Next | Prev

findById : Id -> List Problem -> Maybe Problem
findById id probs =
    List.filter (\prob -> prob.id == id) probs |> List.head

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