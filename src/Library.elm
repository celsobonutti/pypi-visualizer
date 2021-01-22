module Library exposing (Library, Raw, decoder, fromRaw)

import Dict exposing (Dict)
import Json.Decode as Decode exposing (Decoder, at, dict, list, string)


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
        (at [ "info", "requires_dist" ] (list string))
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
