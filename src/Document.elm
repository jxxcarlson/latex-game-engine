module Document exposing (..)


type Document
    = Simple SimpleProblems
    | Solved SolvedProblems
    | Commented CommentedProblems


type Problem
    = SimpleP String
    | SolvedP SolvedProblem
    | CommentedP CommentedProblem


fixLaTeX : Document -> Document
fixLaTeX doc =
    case doc of
        Simple probs ->
            Simple { probs | problems = List.map fixLaTeXInString probs.problems }

        Solved probs ->
            Solved { probs | problems = List.map fixLaTeXInSolvedProblem probs.problems }

        Commented probs ->
            Commented { probs | problems = List.map fixLaTeXInCommentedProblem probs.problems }


fixLaTeXInSolvedProblem : SolvedProblem -> SolvedProblem
fixLaTeXInSolvedProblem p =
    { p | problem = fixLaTeXInString p.problem, solution = fixLaTeXInString p.solution }


fixLaTeXInCommentedProblem : CommentedProblem -> CommentedProblem
fixLaTeXInCommentedProblem p =
    { p | target = fixLaTeXInString p.target, comment = fixLaTeXInString p.comment }



--case prob of
--     SimpleP str ->
--         SimpleP (fixLaTeXInString str)
--
--     SolvedP p ->
--         SolvedP { p | problem = fixLaTeXInString p.problem, solution = fixLaTeXInString p.solution }
--
--     CommentedP p ->
--         CommentedP { p | target = fixLaTeXInString p.target, comment = fixLaTeXInString p.comment }


fixLaTeXInString : String -> String
fixLaTeXInString str =
    String.replace "\\\\" "\\" str


header : Document -> Header
header doc_ =
    case doc_ of
        Simple doc ->
            doc.header

        Solved doc ->
            doc.header

        Commented doc ->
            doc.header


problems : Document -> List Problem
problems doc_ =
    case doc_ of
        Simple doc ->
            List.map SimpleP doc.problems

        Solved doc ->
            List.map SolvedP doc.problems

        Commented doc ->
            List.map CommentedP doc.problems


format : Document -> String
format doc_ =
    case doc_ of
        Simple doc ->
            doc.format

        Solved doc ->
            doc.format

        Commented doc ->
            doc.format


type alias SimpleProblems =
    { format : String
    , header : Header
    , problems : List String
    }


type alias SolvedProblems =
    { format : String
    , header : Header
    , problems : List SolvedProblem
    }


type alias CommentedProblems =
    { format : String
    , header : Header
    , problems : List CommentedProblem
    }



-- COMMON


type alias Header =
    { title : String
    , author : String
    , contact : String
    , date : String
    , description : String
    }


errorHeader : Header
errorHeader =
    { title = "Error"
    , author = "System"
    , contact = "None"
    , date = "Today"
    , description = "Sorry, I could not parse that docuemnt"
    }



-- ITEM


type alias SolvedProblem =
    { problem : String
    , solution : String
    }


type alias CommentedProblem =
    { title : String
    , id : String
    , target : String
    , comment : String
    }
