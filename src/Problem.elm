module Problem exposing (findById, Id, Op(..))

import DocParser exposing(Problem)

type alias Id = Maybe (List Int)

type Op = Next | Prev

findById : Id -> List Problem -> Maybe Problem
findById id probs =
    List.filter (\prob -> prob.id == id) probs |> List.head