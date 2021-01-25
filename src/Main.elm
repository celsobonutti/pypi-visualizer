module Main exposing (..)

import API
import Browser
import Config
import Html exposing (Html, div, fieldset, input, label, legend, main_, text)
import Html.Attributes exposing (checked, id, name, type_, value)
import Html.Events exposing (onCheck, onClick)
import Http exposing (Error)
import Library exposing (Library)



---- MODEL ----


type Status
    = NotRequested
    | Loading
    | Error
    | Data


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
    | GotLibrary (Result Http.Error Library.Raw)


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
                        | loadedLibrary = Just <| Library.fromRaw rawLibrary
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
        [ viewLibraries model.selectedLibrary Config.libraries
        , viewContent model
        ]


viewLibraries : Maybe String -> List String -> Html Msg
viewLibraries selectedLibrary libraries =
    fieldset []
        (legend [] [ text "Select a library:" ]
            :: List.map (viewLibraryOption selectedLibrary) libraries
        )


viewLibraryOption : Maybe String -> String -> Html Msg
viewLibraryOption selectedLibrary library =
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


viewContent : Model -> Html Msg
viewContent { status, selectedLibrary, loadedLibrary } =
    case ( status, loadedLibrary ) of
        ( Data, Just library ) ->
            Library.view (Maybe.withDefault "" selectedLibrary) library

        _ ->
            text ""



---- HTTP ----


fetchLibrary : String -> Cmd Msg
fetchLibrary library =
    Http.get
        { url = API.getLibraryEndpoint library
        , expect = Http.expectJson GotLibrary Library.decoder
        }



---- PROGRAM ----


main : Program () Model Msg
main =
    Browser.element
        { view = view
        , init = \_ -> init
        , update = update
        , subscriptions = always Sub.none
        }
