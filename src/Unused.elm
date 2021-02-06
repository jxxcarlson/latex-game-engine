module Unused exposing (..)

import Parser exposing(..)
import ParserTools as PT



-- > run (many kvRecordParser) recs
-- Ok [[{ key = "title", value = S (" integrals") },{ key = "content", value = L ["$$\n\\int_0^1 x^n dx\n$$","Use \\int for the integral sign.\n"] }],[{ key = "title", value = S (" integrals2") },{ key = "content", value = L ["$$\n\\int_0^\\infty e^{-x} dx\n$$","Use \\int for the integral sign.\n"] }]]
kvRecordListParser : Parser (List KVRecord)
kvRecordListParser =
  PT.sepBy spaces kvRecordParser

-- > run kvRecordParser "@foo\nbar\nbaz\n---\nfoo: bar\n===\n"
-- Ok [{ key = "foo", value = L ["bar\nbaz\n"] },{ key = "foo", value = S (" bar") }]
kvRecordParser : Parser KVRecord
kvRecordParser =
   succeed identity
     |= PT.sepBy (symbol "---\n") kvParser
     |. symbol "===\n"
     |. spaces



{-|
> run kvParser "foo: bar\n"
Ok { key = "foo", value = S (" bar") }

> run kvParser "@target\n$$\n\\int_0^2 x^n dx\n$$\n+++\nUse \\int for the integral sign\n---\n\n"
Ok { key = "target", value = L ["$$\n\\int_0^2 x^n dx\n$$","Use \\int for the integral sign\n"] }
    : Result (List Parser.DeadEnd) KV
-}
kvParser = oneOf [ kvLParser, kvSParser]


kvSParser : Parser KV
kvSParser =
 succeed (\k v -> {key = k, value = S v})
   |= getChompedString (chompWhile (\c -> Char.isAlphaNum c))
   |. symbol ":"
   |= getChompedString (chompWhile (\c -> c /= '\n'))
   |. spaces



kvLParser : Parser KV
kvLParser =
 succeed (\k v -> {key = k, value = L (String.split "\n+++\n" v)})
   |. symbol "@"
   |= getChompedString (chompWhile (\c -> Char.isAlphaNum c))
   |. symbol "\n"
   |= getChompedString (chompUntil "---")
   |. spaces

-- > run (kvLParser_ "target") "@target\n$$\n\\int_0^1 x^n dx\n$$\n+++\nUse '\\int' for the integral sign\n---\n"
-- Ok ["$$\n\\int_0^1 x^n dx\n$$","Use '\\int' for the integral sign\n"]kvLParser_ : String -> Parser (List String)

kvLParser_ : String -> Parser String
kvLParser_ key =
 succeed identity
   |. symbol (key ++ ":\n")
   |= getChompedString (chompUntil "---")
   |. symbol "---"
   |. spaces

