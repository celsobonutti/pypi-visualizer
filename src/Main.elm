module Main exposing (..)

import Browser
import Config
import Html exposing (Html, div, fieldset, input, label, main_, text)
import Html.Attributes exposing (checked, id, name, type_, value)
import Html.Events exposing (onCheck)



---- MODEL ----


type alias Model =
    { selectedLibrary : Maybe String
    }


initialModel : Model
initialModel =
    { selectedLibrary = Nothing }


init : ( Model, Cmd Msg )
init =
    ( initialModel, Cmd.none )



---- UPDATE ----


type Msg
    = SelectLibrary String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SelectLibrary library ->
            ( { model | selectedLibrary = Just library }, Cmd.none )



---- VIEW ----


view : Model -> Html Msg
view model =
    main_ []
        [ viewLibraries model.selectedLibrary Config.libraries ]


viewLibraries : Maybe String -> List String -> Html Msg
viewLibraries selectedLibrary libraries =
    fieldset []
        (List.map (viewLibrary selectedLibrary) libraries)


viewLibrary : Maybe String -> String -> Html Msg
viewLibrary selectedLibrary library =
    div []
        [ input
            [ type_ "radio"
            , name "library-name"
            , id library
            , value library
            , onCheck (\_ -> SelectLibrary library)
            , checked (Just library == selectedLibrary)
            ]
            []
        , label [] [ text library ]
        ]



---- PROGRAM ----


main : Program () Model Msg
main =
    Browser.element
        { view = view
        , init = \_ -> init
        , update = update
        , subscriptions = always Sub.none
        }
