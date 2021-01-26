module Library exposing (Library, decoder, view)

import Dict exposing (Dict)
import Html exposing (Html, a, button, div, h1, h2, li, small, span, text, ul)
import Html.Attributes exposing (attribute, class, href, tabindex, target, type_)
import Json.Decode as Decode exposing (Decoder, at, dict, field, list, null, oneOf, string)


type alias Fields =
    { relatedLinks : Dict String String
    , dependencies : List String
    , versions : List String
    }


type alias Name =
    String


type Library
    = Library Name Fields


decoder : String -> Decoder Library
decoder library =
    Decode.map3 Fields
        (at [ "info", "project_urls" ] (dict string))
        (at [ "info", "requires_dist" ] (oneOf [ list string, null [] ]))
        (field "releases" (dict Decode.value) |> Decode.map Dict.keys)
        |> Decode.map (Library library)


view : Library -> List (Html msg)
view (Library name { versions, relatedLinks, dependencies }) =
    [ h1 [ class "library__heading" ] [ text name ]
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
    div [ class "library__version-button", type_ "button", tabindex 1, attribute "role" "button" ]
        [ text "See the library versions"
        , ul [ class "library__versions library__info-list", attribute "role" "listbox", tabindex -1 ] (List.map viewVersion versions)
        ]


viewVersion : String -> Html msg
viewVersion version =
    li [ attribute "role" "option", tabindex 1, class "library__version-item" ] [ text version ]


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
