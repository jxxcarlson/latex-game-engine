module Editor exposing (..)

import DocParser exposing(Problem)
import Maybe.Extra
import File.Download as Download
import Problem


type alias EditorModel = {
          problemList : List Problem
        -- INPUT, HEADER
         , docTitle : String
        , author : String
        , date : String
        , description : String
        -- INPUT, PROBLEM
        , title : String
        , id : String
        , target : String
        , hint : String
        , comment : String
     }

init : ( EditorModel, Cmd EditorMsg )
init  = ( initModel, Cmd.none )

type EditorMsg =
    EditorNoOp
  | GoToStandarMode
  | AcceptTitle String
  | AcceptId String
  | AcceptTarget String
  | AcceptHint String
  | AcceptComment String
  | AddProblem
  | SaveProblems

initModel : EditorModel
initModel = {
       problemList = []
     -- INPUT, HEADER
     , docTitle = ""
     , author  = ""
     , date = ""
     , description = ""
     -- INPUT, PROBLEM
     , title  = ""
     , id = ""
     , target = ""
     , hint  = ""
     , comment = ""
     }

clearProblem model = { model |
       title  = ""
     , id = ""
     , target = ""
     , hint  = ""
     , comment = ""
     }

update : EditorMsg -> EditorModel -> ( EditorModel, Cmd EditorMsg )
update msg model =
    case msg of
        EditorNoOp -> (model, Cmd.none)
        GoToStandarMode -> (model, Cmd.none)
        AcceptTitle t -> ({model | title = t}, Cmd.none)
        AcceptId id -> ({model | id = id}, Cmd.none)
        AcceptTarget t -> ({model | target = t}, Cmd.none)
        AcceptHint h -> ({model | hint = h}, Cmd.none)
        AcceptComment c -> ({model | comment = c}, Cmd.none)
        AddProblem ->
            (
              clearProblem { model | problemList = makeProblem model :: model.problemList}, Cmd.none)
        SaveProblems -> (model, download (Problem.problemListToString (List.reverse model.problemList)))

download : String -> Cmd msg
download problemString =
  Download.string "problems.txt" "text/textl" problemString


makeProblem : EditorModel -> Problem
makeProblem model =
    {
       title  = model.title
     , id = Just (makeId model.id)
     , target = model.target
     , hint  = model.hint
     , comment = model.comment

    }

makeId : String -> List Int
makeId str =
  str
    |> String.split "."
    |> List.map (String.trim)
    |> List.map String.toInt
    |> Maybe.Extra.values