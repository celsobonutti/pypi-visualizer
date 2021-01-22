module API exposing (..)


url : String
url =
    "https://pypi.org/pypi/"


getLibraryEndpoint : String -> String
getLibraryEndpoint libName =
    url ++ libName ++ "/json"
