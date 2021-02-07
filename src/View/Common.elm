module View.Common exposing (..)



import Element exposing (..)
import Element.Input as Input
import Style exposing(..)
import Msg exposing(..)
import Model exposing(Model, AppMode(..))


showIf : Bool -> Element Msg -> Element Msg
showIf show element =
    if show then  element else Element.none



toggleAppMode : AppMode -> Element Msg
toggleAppMode appMode =
    let
        label = case appMode of
            StandardMode -> "Go to Editor"
            EditMode -> "Editor"
    in
    row [ ]
        [ Input.button buttonStyle
            { onPress = Just ToggleAppMode
            , label = el labelStyle (text label)
            }
        ]
