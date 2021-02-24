module Document exposing (..)

type Document = Simple SimpleProblems
              | Solved SolvedProblems
              | Commented CommentedProblems


type Problem = SimpleP String
              | SolvedP SolvedProblem
              | CommentedP CommentedProblem



header : Document -> Header
header doc_ =
    case doc_ of
        Simple doc -> doc.header
        Solved doc -> doc.header
        Commented doc -> doc.header

problems : Document -> List Problem
problems doc_ =
    case doc_ of
        Simple doc -> List.map SimpleP doc.problems
        Solved doc -> List.map SolvedP doc.problems
        Commented doc -> List.map CommentedP doc.problems

format : Document -> String
format doc_ =
    case doc_ of
        Simple doc -> doc.format
        Solved doc -> doc.format
        Commented doc -> doc.format


type alias SimpleProblems = {
     format: String
   , header : Header
   , problems: List String
  }

type alias SolvedProblems = {
     format: String
   , header : Header
   , problems: List SolvedProblem
  }

type alias CommentedProblems = {
     format: String
   , header : Header
   , problems: List CommentedProblem
  }

-- COMMON

type alias Header = {
       title: String
     , author: String
     , contact: String
     , date: String
     , description : String
  }


errorHeader : Header
errorHeader = {
     title = "Error"
   , author = "System"
   , contact = "None"
   , date ="Today"
   , description  = "Sorry, I could not parse that docuemnt"
  }
-- ITEM

type alias SolvedProblem = {
    problem : String
  , solution : String
  }

type alias CommentedProblem = {
    title : String
  , id : String
  , target : String
  , comment : String
  }


