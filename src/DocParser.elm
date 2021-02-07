module DocParser exposing(..)

import Parser exposing(..)
import ParserTools as PT

type alias Problem = {
      title : String
    , id : Maybe (List Int)
    , target : String
    , hint : String
    , comment : String
    }

type alias DocumentDescription = {
       title : String
     , author : String
     , date : String
     , description :String
  }

errorDescription : DocumentDescription
errorDescription = {
    title = "Error"
  , author = "Nobody"
  , date = ""
  , description = "There is an error in Config.initialDocument"
  }

runWithErrorReporter : Parser a -> String -> Result String a
runWithErrorReporter parser input  =
    case run parser input of
        Ok result -> Ok result
        Err err -> Err (List.map (errorReport input) err |> String.join "\n\n")


errorReport : String ->  { a | row : Int, col : Int, problem : Parser.Problem } -> String
errorReport input err  =
    "at " ++ String.fromInt err.row
     ++ ", " ++ String.fromInt err.col
     ++ ": " ++ reportProblem err.problem
     ++ "\n" ++ getLinesAround err.row input


getLinesAround : Int -> String -> String
getLinesAround line input =
    input
      |> String.lines
      |> List.indexedMap (\k l -> String.fromInt k ++ ": " ++ l)
      |> slice (line - 2) (line + 3)
      |> String.join "\n"

slice : Int -> Int -> List a -> List a
slice from to list =
    list
      |> List.take to
      |> List.drop from

reportProblem : Parser.Problem -> String
reportProblem p =
    case p of
        Expecting e -> "expecting: " ++ e
        ExpectingSymbol s -> "expecting symbol: " ++ s
        _ -> "Unknown error type"

type alias KVRecord = List KV

type alias KV = {key: String, value: Value}

type Value = S String | L (List String)

documentDescriptionParser : Parser DocumentDescription
documentDescriptionParser =
    succeed DocumentDescription
      |= kvSParser_ "title"
      |= kvSParser_ "author"
      |= kvSParser_ "date"
      |= kvSParser_ "description"

problems input =
   case run problemListParser input of
       Ok ps -> ps
       Err _ -> []


parseDocument : String -> Result String (DocumentDescription, List Problem)
parseDocument input =
    runWithErrorReporter documentParser input |> Debug.log "PARSE"

documentParser : Parser (DocumentDescription, List Problem)
documentParser =
    succeed (\h l -> (h, l))
      |=  documentDescriptionParser
      |=  problemListParser

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
    |= kvSParser_ "target"
    |= kvSParser_ "hint"
    |= kvSParser_ "comment"

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


-- > run (kvSParser_ "title") "title: W. Shakespeare\n"
-- Ok (" W. Shakespeare")
kvSParser_ : String -> Parser String
kvSParser_ key = 
 succeed identity
   |. symbol (key ++ ":")
   |= getChompedString (chompUntil "---")
   |. symbol "---"
   |. spaces


-- FOR TESTING


doc = head ++ "\n\n" ++ probs

head = """title:Calculus
---
author: James Carlson
---
date: 2 Feb 2021
---
description:
We assume that you have learned about
subscripts and superscripts.  In this
lesson you will learn how to write common
expressions in Calculus: derivaties,
integrals, etc.
---
"""

prob = """title: Integration
---
id: 1.1.1
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

"""

prob2 = """title: Integration
---
id: 1.1.1
---
target:
$$
\\int x^n dx
$$
---
hint:
Use '\\int' for the integral sign
---
comment: This is for starters
--

"""

prob3 = """
title:Symbols
---
id:1
---
target: $\\alpha + \\beta + \\gamma = \\pi$
hint:
---
comment: Enclose your formula with dollar signs: \\dollar ... \\dollar.
Use \\bs{alpha} for $\\alpha$, and so on.
---
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
