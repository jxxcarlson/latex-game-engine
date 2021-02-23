module Problem exposing (AugmentedProblem, setCompleted, Header,
   numberOfCompletedProblems, numberOfProblems, deAugment,
   problemListToString, findById, rootProblem
   , Id, Op(..), toZipper, firstChild, forward, backward)

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
deAugment : AugmentedProblem -> Problem
deAugment p = {
       title = p.title
     , id  = p.id
     , target  = p.target
     , comment  = p.comment
     }




rootProblem = {
      title = "root"
    , id = Just []
    , target = ""
    , comment = ""
    , completed = False
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


problemListToString : Header -> List Problem -> String
problemListToString header problems =
   headerToString header
   ++ "\n\n"
   ++ (List.map problemToString problems |> String.join "\n\n")


headerToString : Header -> String
headerToString header =
    [ fieldToString "title" header.docTitle
   , fieldToString "author" header.author
   , fieldToString "date" header.date
   , fieldToString "description" header.description
   ] |> String.join "\n"


problemToString : Problem -> String
problemToString problem =
    [ fieldToString "title" problem.title
   , idToString problem.id
   , fieldToString "target" problem.target
   , fieldToString "comment" problem.comment] |> String.join "\n"
idToString :Maybe (List Int) -> String
idToString mis =
    case mis of
        Nothing -> fieldToString "id" ""
        Just is ->  fieldToString "id" (String.join "." (List.map String.fromInt is))

fieldToString : String -> String -> String
fieldToString name value =
    name ++ ":" ++ String.trim value ++ "\n---"

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