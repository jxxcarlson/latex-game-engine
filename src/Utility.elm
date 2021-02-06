module Utility exposing (maybeValueF, removeComments)

maybeValue : String -> Maybe String  -> String
maybeValue default mstring  =
    case mstring of
        Nothing -> default
        Just str -> str

maybeValueF : (a -> String) -> Maybe a -> String -> String
maybeValueF f ma default =
  Maybe.map f ma |> maybeValue default

removeComments : String -> String
removeComments str =
   str
     |> String.lines
     |> List.filter (\l -> String.left 1 l /= "#")
     |> String.join "\n"
