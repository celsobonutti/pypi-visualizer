module API exposing (..)

import Http exposing (Error(..))


url : String
url =
    "https://pypi.org/pypi/"


getLibraryEndpoint : String -> String
getLibraryEndpoint libName =
    url ++ libName ++ "/json"


type alias ErrorMessage =
    { title : String
    , content : String
    }


errorToMessage : Error -> ErrorMessage
errorToMessage error =
    case error of
        Timeout ->
            { title = "Weird, this is taking too long."
            , content = "The server could be overloaded, or you could have a connection problem. Please, try again later."
            }

        NetworkError ->
            { title = "Oops, there is something wrong with your connection."
            , content = "Looks like you're having a network problem."
            }

        BadStatus 404 ->
            { title = "Package not found."
            , content = "The package you are looking for was not found."
            }

        BadStatus _ ->
            { title = "Server error."
            , content = "Looks like the PyPi server is having problems right now."
            }

        BadUrl _ ->
            { title = "Oops, looks like the API URL was malformed."
            , content = "This one is on our side, maybe somebody broke our application?"
            }

        BadBody reason ->
            { title = "Looks like there was a problem parsing the server's response."
            , content = reason
            }
