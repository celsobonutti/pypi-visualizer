module Library exposing (Library, Raw, decoder, fromRaw, view)

import Dict exposing (Dict)
import Html exposing (Html, a, button, div, h1, h2, li, section, small, span, text, ul)
import Html.Attributes exposing (attribute, class, href, tabindex, target, type_)
import Json.Decode as Decode exposing (Decoder, at, dict, list, null, oneOf, string)


type alias Raw =
    { relatedLinks : Dict String String
    , dependencies : List String
    , versions : Dict String Decode.Value
    }


type alias Fields =
    { relatedLinks : Dict String String
    , dependencies : List String
    , versions : List String
    }


type Library
    = Library Fields


decoder : Decoder Raw
decoder =
    Decode.map3 Raw
        (at [ "info", "project_urls" ] (dict string))
        (at [ "info", "requires_dist" ] (oneOf [ list string, null [] ]))
        (at [ "releases" ] (dict Decode.value))


fromRaw : Raw -> Library
fromRaw rawLibrary =
    let
        versions =
            Dict.keys rawLibrary.versions
    in
    Library
        { versions = versions
        , dependencies = rawLibrary.dependencies
        , relatedLinks = rawLibrary.relatedLinks
        }


view : String -> Library -> Html msg
view name (Library { versions, relatedLinks, dependencies }) =
    section [ class "library" ]
        [ h1 [ class "library__heading " ] [ text name ]
        , div [ class "library__grid" ]
            [ div [ class "library__info-section" ]
                [ h2
                    [ class "library__subheading" ]
                    [ text "Versions" ]
                , viewVersionList versions
                ]
            , div [ class "library__info-section" ]
                [ h2
                    [ class "library__subheading" ]
                    [ text "Related Links" ]
                , ul [ class "library__info-list" ]
                    (relatedLinks
                        |> Dict.toList
                        |> List.map viewRelatedLink
                    )
                ]
            , div [ class "library__info-section" ]
                [ h2
                    [ class "library__subheading" ]
                    [ text "Dependencies" ]
                , ul [ class "library__info-list" ]
                    (List.map viewDependency dependencies)
                ]
            ]
        ]


viewVersionList : List String -> Html msg
viewVersionList versions =
    button [ class "library__version-button", type_ "button" ]
        [ text "See the library versions"
        , ul [ class "library__versions library__info-list", attribute "aria-role" "listbox", tabindex -1 ] (List.map viewVersion versions)
        ]


viewVersion : String -> Html msg
viewVersion version =
    li [ attribute "aria-role" "option", tabindex 1, class "library__version-item" ] [ text version ]


viewRelatedLink : ( String, String ) -> Html msg
viewRelatedLink ( title, url ) =
    li [] [ a [ href url, target "_blank", class "library__related-link" ] [ span [] [ text title ] ] ]


viewDependency : String -> Html msg
viewDependency dependency =
    case String.words dependency of
        name :: splitInfo ->
            li [ class "library__dependency" ] [ text name, small [ class "library__dependency-detail" ] [ text (String.join " " splitInfo) ] ]

        [] ->
            li [ class "library__dependency" ] [ text dependency ]
