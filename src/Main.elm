module Main exposing (..)

import API
import Browser
import Config
import Html exposing (Html, div, fieldset, h1, input, label, legend, main_, p, section, text)
import Html.Attributes exposing (attribute, checked, class, id, name, type_, value)
import Html.Events exposing (onCheck, onClick)
import Http exposing (Error)
import Library exposing (Library)


notRequestedText : String
notRequestedText =
    """Welcome to the PyPi visualizer. To start check the information about a package, please select one of the
available ones in the buttons above.
"""



---- MODEL ----


type Status
    = NotRequested
    | Loading
    | Error Http.Error
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
                    ( { model | status = Error err }, Cmd.none )



---- VIEW ----


view : Model -> Html Msg
view model =
    main_ [ class "wrapper" ]
        [ viewLibraries model.selectedLibrary Config.libraries
        , section [ class "content" ] <| viewContent model
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


viewContent : Model -> List (Html Msg)
viewContent { status } =
    case status of
        NotRequested ->
            [ p [] [ text notRequestedText ] ]

        Data library ->
            Library.view library

        Loading ->
            [ viewLoading ]

        Error err ->
            viewError err


viewLoading : Html Msg
viewLoading =
    div [ class "loading-ring", attribute "aria-busy" "true", attribute "aria-live" "polite", attribute "aria-label" "loading" ]
        [ div [] []
        , div [] []
        , div [] []
        , div [] []
        ]


viewError : Http.Error -> List (Html Msg)
viewError error =
    let
        { title, content } =
            API.errorToMessage error
    in
    [ h1 [ class "error__title", attribute "aria-live" "assertive", attribute "role" "alert" ] [ text title ]
    , p [ class "error__description" ] [ text content ]
    ]



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
