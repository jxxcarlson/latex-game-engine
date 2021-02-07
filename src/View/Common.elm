module View.Common exposing (..)



import Element exposing (..)
import Element.Input as Input
import Style exposing(..)
import Msg exposing(..)
import Model exposing(Model, AppMode(..))


toggleAppMode : AppMode -> Element Msg
toggleAppMode appMode =
    let
        label = case appMode of
            StandardMode -> "Standard"
            EditMode -> "Editor"
    in
    row [ ]
        [ Input.button buttonStyle
            { onPress = Just ToggleAppMode
            , label = el labelStyle (text label)
            }
        ]
