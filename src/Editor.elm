module Editor exposing (..)

import DocParser exposing(Problem)
import Maybe.Extra
import File.Download as Download
import Problem exposing(Header)


type alias EditorModel = {
          editorMode : EditorMode
          , problemList : List Problem
        -- INPUT, HEADER
         , docTitle : String
        , author : String
        , date : String
        , description : String
        -- INPUT, PROBLEM
        , title : String
        , id : String
        , target : String
        , comment : String
     }

type EditorMode = ProblemMode | HeaderMode

init : ( EditorModel, Cmd EditorMsg )
init  = ( initModel, Cmd.none )

type EditorMsg =
    EditorNoOp
  | GoToStandarMode
  | AcceptTitle String
  | AcceptId String
  | AcceptTarget String
  | AcceptComment String
  | AcceptDocTitle String
  | AcceptAuthor String
  | AcceptDate String
  | AcceptDescription String
  | AddProblem
  | SaveProblems
  | SetMode EditorMode

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
     , comment = ""
     , editorMode = ProblemMode
     }

clearProblem model = { model |
       title  = ""
     , id = ""
     , target = ""
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
        AcceptComment c -> ({model | comment = c}, Cmd.none)
        AcceptDocTitle t -> ({model | docTitle = t}, Cmd.none)
        AcceptAuthor a -> ({model | author = a}, Cmd.none)
        AcceptDate d -> ({model | date = d}, Cmd.none)
        AcceptDescription d -> ({model | description = d}, Cmd.none)
        AddProblem ->
            (
              clearProblem { model | problemList = makeProblem model :: model.problemList}, Cmd.none)
        SaveProblems -> (model, download (Problem.problemListToString (getHeader model) (List.reverse model.problemList)))
        SetMode editorMode ->
            ({ model | editorMode = editorMode}, Cmd.none)

getHeader : EditorModel -> Header
getHeader model =
    {
      docTitle = model.docTitle
    , author = model.author
    , date = model.date
    , description = model.description

    }

download : String -> Cmd msg
download problemString =
  Download.string "problems.txt" "text/textl" problemString


makeProblem : EditorModel -> Problem
makeProblem model =
    {
       title  = model.title
     , id = Just (makeId model.id)
     , target = model.target
     , comment = model.comment

    }

makeId : String -> List Int
makeId str =
  str
    |> String.split "."
    |> List.map (String.trim)
    |> List.map String.toInt
    |> Maybe.Extra.values