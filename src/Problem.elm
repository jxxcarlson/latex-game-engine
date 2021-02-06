module Problem exposing (findById, Id)

import DocParser exposing(Problem)

type alias Id = Maybe (List Int)

findById : Id -> List Problem -> Maybe Problem
findById id probs =
    List.filter (\prob -> prob.id == id) probs |> List.head