module Problem exposing (findById, Id, Op(..))

import DocParser exposing(Problem)
import HTree
import Tree exposing(Tree)
import Tree.Zipper as Zipper exposing(Zipper)

type alias Id = Maybe (List Int)

rootProblem = {
      title = "root"
    , id = Just []
    , target = ""
    , hint  = ""
    , comment = ""
    }

type Op = Next | Prev

findById : Id -> List Problem -> Maybe Problem
findById id probs =
    List.filter (\prob -> prob.id == id) probs |> List.head

level : Problem -> Int
level prob =
    case prob.id of
        Nothing -> -1
        Just id_ -> List.length id_

toZipper : List Problem -> Zipper Problem
toZipper problems =
    problems
      |> List.filter (\p -> p.id /= Nothing)
      |> HTree.fromList rootProblem level
      |> Zipper.fromTree
      |> firstChild_


firstChild_ : Zipper a -> Zipper a
firstChild_ z =
    case Zipper.firstChild z of
        Nothing -> z
        Just z_ -> z_
