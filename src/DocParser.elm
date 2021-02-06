module DocParser exposing(..)

import Parser exposing(..)
import ParserTools as PT

type alias Problem = {
      title : String
    , id : Maybe (List Int)
    , next : Maybe (List Int)
    , target : String
    , hint : String
    , comment : String
    }

type alias KVRecord = List KV

type alias KV = {key: String, value: Value}

type Value = S String | L (List String)


prob = """title: Integration
---
id: 1.1.1
---
next: 1.1.2
---
@target
$$
\\int x^n dx
$$
---
@hint
Use '\\int' for the integral sign
---
comment: This is for starters
---
===
"""

probs = """title: Integration
---
id: 1.1.1
---
next: 1.1.2
---
@target
$$
\\int x^n dx
$$
---
@hint
Use '\\int' for the integral sign
---
comment: This is for starters
---
===
title: Integration
---
id: 1.1.2
---
next: 1.1.3
---
@target
$$
\\int_0^1 x^n dx
$$
---
@hint
You know all you need to know for this one!
---
comment: You are getting better!
---
===
"""

problems input =
   case run problemListParser input of
       Ok ps -> ps
       Err _ -> []

-- > run problemListParser probs
-- Ok [{ comment = " This is for starters", id = Just [1,1,1], next = Just [1,1,2], target = ["$$\n\\int x^n dx\n$$","Use '\\int' for the integral sign"], title = " Integration" },{ comment = " You are getting better!", id = Just [1,1,2], next = Just [1,1,3], target = ["$$\n\\int_0^1 x^n dx\n$$","You know all you need to know for this one!"], title = " Integration" }]
--     : Result (List DeadEnd) (List Problem)
problemListParser : Parser (List Problem)
problemListParser =
  PT.sepBy spaces problemParser

problemParser : Parser Problem
problemParser = 
  succeed Problem
    |= kvSParser_ "title"
    |= (kvSParser_ "id" |> map parseId)
    |= (kvSParser_ "next" |> map parseId)
    |= kvSParser_ "target"
    |= kvSParser_ "hint"
    |= kvSParser_ "comment"
    |. symbol "===\n"
    |. spaces

parseId : String -> Maybe (List Int)
parseId input = 
  case run (PT.sepBy (symbol ":") int) (String.replace "." ":" (String.trim input)) of 
    Ok list -> Just list 
    Err _ -> Nothing

int_ : Parser (Maybe Int) 
int_ =
  getChompedString 
   (chompWhile (\c -> List.member c ['0', '1', '2', '3','4', '5', '6', '7','8', '9']))
   |> map String.toInt


{- 

FILE FORMAT

key: value
---
key: value
---
@key # with one multi-line value
...
...
--- # record separator
@key # with several multi-line value
...
...
+++ # value separator
...
...
---
key: value
=== # End of record
-}


rec0 = """title: integrals
---
@content
$$
\\int_0^1 x^n dx
$$
+++
Use \\int for the integral sign.
---
"""

rec = """title: integrals
---
@content
$$
\\int_0^1 x^n dx
$$
+++
Use \\int for the integral sign.
---
===
"""

recs = """title: integrals
---
@content
$$
\\int_0^1 x^n dx
$$
+++
Use \\int for the integral sign.
---
===
title: integrals2
---
@content
$$
\\int_0^\\infty e^{-x} dx
$$
+++
Use \\int for the integral sign.
---
===
"""

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

-- > run (kvSParser_ "title") "title: W. Shakespeare\n"
-- Ok (" W. Shakespeare")
kvSParser_ : String -> Parser String
kvSParser_ key = 
 succeed identity
   |. symbol (key ++ ":")
   |= getChompedString (chompUntil "---")
   |. symbol "---"
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