module Main exposing (..)

import API
import Browser
import Config
import Html exposing (Html, div, fieldset, input, label, legend, main_, section, text)
import Html.Attributes exposing (checked, class, id, name, type_, value)
import Html.Events exposing (onCheck, onClick)
import Http exposing (Error)
import Library exposing (Library)



---- MODEL ----


type Status
    = NotRequested
    | Loading
    | Error
    | Data Library


type alias Model =
    { selectedLibrary : Maybe String
    , status : Status
    }


initialModel : Model
initialModel =
    { selectedLibrary = Nothing
    , status = NotRequested
    }


init : ( Model, Cmd Msg )
init =
    ( initialModel, Cmd.none )



---- UPDATE ----


type Msg
    = SelectLibrary String
    | GotLibrary (Result Http.Error Library)


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
                Ok library ->
                    ( { model
                        | status = Data library
                      }
                    , Cmd.none
                    )

                -- TO-DO: handle errors in a better way
                Err err ->
                    ( { model | status = Error }, Cmd.none )



---- VIEW ----


view : Model -> Html Msg
view model =
    main_ [ class "wrapper" ]
        [ viewLibraries model.selectedLibrary Config.libraries
        , viewContent model
        ]


viewLibraries : Maybe String -> List String -> Html Msg
viewLibraries selectedLibrary libraries =
    fieldset [ class "selector" ]
        (legend [ class "selector__legend" ] [ text "Select a library:" ]
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
            , class "selector__item"
            ]
            []
        , label
            [ onClick <| SelectLibrary library, class "selector__item-label" ]
            [ text library ]
        ]


viewContent : Model -> Html Msg
viewContent { status, selectedLibrary } =
    case status of
        Data library ->
            section [ class "content" ] (Library.view library)

        _ ->
            div [] []



---- HTTP ----


fetchLibrary : String -> Cmd Msg
fetchLibrary library =
    Http.get
        { url = API.getLibraryEndpoint library
        , expect = Http.expectJson GotLibrary <| Library.decoder library
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
