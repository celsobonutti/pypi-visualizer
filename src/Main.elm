module Main exposing (..)

import API
import Browser
import Config
import Dict exposing (Dict)
import Html exposing (Html, div, fieldset, input, label, main_, text)
import Html.Attributes exposing (checked, id, name, type_, value)
import Html.Events exposing (onCheck, onClick)
import Http exposing (Error)
import Json.Decode as Decode exposing (Decoder, at, dict, list, string)



---- MODEL ----


type Status
    = NotRequested
    | Loading
    | Error
    | Data


type alias Library =
    { relatedLinks : Dict String String
    , dependencies : List String
    , versions : List String
    }


type alias Model =
    { selectedLibrary : Maybe String
    , loadedLibrary : Maybe Library
    , status : Status
    }


initialModel : Model
initialModel =
    { selectedLibrary = Nothing
    , loadedLibrary = Nothing
    , status = NotRequested
    }


init : ( Model, Cmd Msg )
init =
    ( initialModel, Cmd.none )



---- UPDATE ----


type Msg
    = SelectLibrary String
    | GotLibrary (Result Http.Error RawLibrary)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SelectLibrary library ->
            ( { model
                | selectedLibrary = Just library
                , status = Loading
              }
            , fetchLibrary library
            )

        GotLibrary result ->
            case result of
                Ok rawLibrary ->
                    ( { model
                        | loadedLibrary = Just <| formatLibrary rawLibrary
                        , status = Data
                      }
                    , Cmd.none
                    )

                -- TO-DO: handle errors in a better way
                Err err ->
                    ( { model | status = Error }, Cmd.none )



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
        , label
            [ onClick <| SelectLibrary library ]
            [ text library ]
        ]



---- HTTP ----


type alias RawLibrary =
    { relatedLinks : Dict String String
    , dependencies : List String
    , versions : Dict String Decode.Value
    }


formatLibrary : RawLibrary -> Library
formatLibrary rawLibrary =
    let
        versions =
            Dict.keys rawLibrary.versions
    in
    { versions = versions
    , dependencies = rawLibrary.dependencies
    , relatedLinks = rawLibrary.relatedLinks
    }


fetchLibrary : String -> Cmd Msg
fetchLibrary library =
    Http.get
        { url = API.getLibraryEndpoint library
        , expect = Http.expectJson GotLibrary libraryDecoder
        }


libraryDecoder : Decoder RawLibrary
libraryDecoder =
    Decode.map3 RawLibrary
        (at [ "info", "project_urls" ] (dict string))
        (at [ "info", "requires_dist" ] (list string))
        (at [ "releases" ] (dict Decode.value))



---- PROGRAM ----


main : Program () Model Msg
main =
    Browser.element
        { view = view
        , init = \_ -> init
        , update = update
        , subscriptions = always Sub.none
        }
