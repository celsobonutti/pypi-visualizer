module Tests exposing (..)

import Expect
import Main
import Test exposing (..)



-- Check out https://package.elm-lang.org/packages/elm-explorations/test/latest to learn more about testing in Elm!


librarySelection : Test
librarySelection =
    describe "The model changes when a library is selected"
        [ test "When it was empty" <|
            \_ ->
                let
                    ( { selectedLibrary }, _ ) =
                        Main.update (Main.SelectLibrary "requests") Main.initialModel
                in
                Expect.equal selectedLibrary (Just "requests")
        ]
