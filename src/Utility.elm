module Utility exposing (maybeValueF)

maybeValue : String -> Maybe String  -> String
maybeValue default mstring  =
    case mstring of
        Nothing -> default
        Just str -> str

maybeValueF : (a -> String) -> Maybe a -> String -> String
maybeValueF f ma default =
  Maybe.map f ma |> maybeValue default