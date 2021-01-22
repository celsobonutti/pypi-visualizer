module Tests exposing (..)

import Expect
import Main exposing (Status(..))
import Test exposing (..)



-- Check out https://package.elm-lang.org/packages/elm-explorations/test/latest to learn more about testing in Elm!


librarySelection : Test
librarySelection =
    let
        ( { selectedLibrary, status }, _ ) =
            Main.update (Main.SelectLibrary "requests") Main.initialModel
    in
    describe "The model changes when a library is selected"
        [ test "Selected library changes" <|
            \_ ->
                Expect.equal selectedLibrary (Just "requests")
        , test "Status is set as Loading" <|
            \_ ->
                Expect.equal status Loading
        ]
