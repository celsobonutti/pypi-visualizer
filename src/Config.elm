module Config exposing (..)


libraries : List String
libraries =
    [ "requests"
    , "Pendulum"
    , "xhtml2pdf"
    ]


apiUrl : String
apiUrl =
    "https://pypi.org/pypi/"


libEndpointUrl : String -> String
libEndpointUrl libName =
    apiUrl ++ libName ++ "/json"
