module ParserTools exposing(many, sepBy, sepByWithEnd)

import Parser exposing(..)



-- intParser : Parser Int 
-- intParser = 
--   succeed identity 
--     |= int
--     |. spaces
--
-- > run (many intParser) "3 4 5"
-- Ok [3,4,5]
many : Parser a -> Parser (List a)
many p =
    loop [] (manyHelp p)


manyHelp : Parser a -> List a -> Parser (Step (List a) (List a))
manyHelp p vs =
    oneOf
        [ succeed (\v -> Loop (v :: vs))
            |= p
        , succeed ()
            |> map (\_ -> Done (List.reverse vs))
        ]


sepBy : Parser () -> Parser a -> Parser (List a)
sepBy sep p =
    loop [] (sepByHelp sep p)


sepByHelp : Parser () -> Parser a -> List a -> Parser (Step (List a) (List a))
sepByHelp sep p vs =
    oneOf
        [ succeed (\v -> Loop (v :: vs))
            |= p
            |. oneOf [ sep, succeed () ]
        , succeed ()
            |> map (\_ -> Done (List.reverse vs))
        ]


sepByWithEnd : Parser () -> Parser () -> Parser a -> Parser (List a)
sepByWithEnd sep end p =
    loop [] (sepByWithEndHelp sep end p)


sepByWithEndHelp : Parser () -> Parser () -> Parser a -> List a -> Parser (Step (List a) (List a))
sepByWithEndHelp sep end p vs =
    oneOf
        [ backtrackable <| succeed (\v -> Loop (v :: vs))
            |= p
            |. oneOf [ sep, succeed()]
        , succeed (\v -> Loop (v :: vs))
            |= p
            |. oneOf [ end, succeed()]
        , succeed ()
            |> map (\_ -> Done (List.reverse vs))
        ]
