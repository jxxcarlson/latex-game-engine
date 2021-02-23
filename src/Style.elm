module Style exposing (..)


import Element exposing (..)
import Element.Background as Background
import Element.Font as Font
import Html.Attributes as HA
import Html exposing (Html)
import Config

-- STYLE

gray g = rgb255 g g g

labelStyle = [ centerX, centerY, Font.size 14]

mainColumnStyle =
    let
      g = 200
    in
    [ centerX
    , centerY
    , Background.color (rgb255 g g g)
    , paddingXY 20 20
    , width (px 600)
    , height (px Config.appHeight)
    ]

rhsColumnStyle =
    [ centerX
    , centerY
    , Background.color (gray 200)
    , paddingXY 20 20
    , width (px 400)
    , height (px Config.appHeight)
    ]

buttonStyle =
    [ Background.color (rgb255 40 40 40)
    , Font.color (rgb255 255 255 255)
    , paddingXY 15 8
    , Element.mouseDown  [Background.color (rgb255 180 0 0)]
    ]


selectedButtonStyle =
    [ Background.color (rgb255 160 40 40)
    , Font.color (rgb255 255 255 255)
    , paddingXY 15 8
    ]

hintStyle = [  HA.style "background-color" "white"
             , HA.style "width" "540px"
             , HA.style "margin-left" "-8px"
             , HA.style "padding-top" "1px"
             , HA.style "padding-bottom" "1px"
             , HA.style "padding-left" "9px"
             , HA.style "padding-right" "8px"
             ]

commentStyle w h = [  HA.style "background-color" "white"
             , HA.style "width" (String.fromInt w ++ "px")
             , HA.style "height" (String.fromInt h ++ "px")
            --  , HA.style "margin-top" "0px"
            --  , HA.style "margin-left" "-8px"
            --  , HA.style "padding-top" "2px"
            --  , HA.style "padding-bottom" "2px"
             --, HA.style "padding-left" "10x"
             --, HA.style "padding-right" "10px"
             , HA.style "white-space" "pre-wrap"
             , HA.style "line-height" "1.35"
             ]


commentStyle1 w h = [  HA.style "background-color" "white"
             , HA.style "width" (String.fromInt w ++ "px")
             , HA.style "height" (String.fromInt h ++ "px")
             , HA.style "margin-top" "0px"
             , HA.style "margin-left" "-8px"
             , HA.style "padding-top" "2px"
             , HA.style "padding-bottom" "2px"
             , HA.style "padding-left" "21x"
             , HA.style "padding-right" "21px"
             , HA.style "white-space" "pre-wrap"
             , HA.style "line-height" "1.35"
             ]


renderedSourceStyle : List (Html.Attribute msg)
renderedSourceStyle =
    textStyle "300px" "170px" "#fff"


textStyle : String -> String -> String -> List (Html.Attribute msg)
textStyle width height color =
    [ HA.style "width" width
    , HA.style "height" height
    , HA.style "margin-top" "18px"
    , HA.style "margin-bottom" "18px"
    , HA.style "background-color" color
    , HA.style "margin-right" "20px"
    , HA.style "white-space" "pre-wrap"
    , HA.style "padding-left" "10px"
    , HA.style "padding-right" "10px"
    , HA.style "overflow" "scroll"
    , HA.style "float" "left"
    , HA.style "border-width" "1px"
    , HA.style "font-size" "14px"
    , HA.style "line-height" "1.5"
    ]
