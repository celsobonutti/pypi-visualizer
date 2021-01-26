module Tests exposing (..)

import Expect
import Html exposing (section)
import Json.Decode as Decode
import JsonLibrary
import Library
import Main exposing (Status(..), viewLibraryOption)
import Test exposing (..)
import Test.Html.Event as Event
import Test.Html.Query as Query
import Test.Html.Selector as Selector



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
        , test "Event is fired correctly" <|
            \_ ->
                viewLibraryOption Nothing "requests"
                    |> Query.fromHtml
                    |> Query.find [ Selector.class "selector__item-label" ]
                    |> Event.simulate Event.click
                    |> Event.expect (Main.SelectLibrary "requests")
        ]


libraryModule : Test
libraryModule =
    let
        validLibrary =
            Decode.decodeString (Library.decoder "requests") JsonLibrary.valid

        emptyDepsLibrary =
            Decode.decodeString (Library.decoder "requests") JsonLibrary.validWithoutDependencies

        invalidLibrary =
            Decode.decodeString (Library.decoder "requests") JsonLibrary.invalid
    in
    describe "Tests the Library module"
        [ test "Decodes correctly when the JSON is correct" <|
            \_ ->
                case validLibrary of
                    Ok _ ->
                        Expect.pass

                    Err _ ->
                        Expect.fail "Decoding should be successful"
        , test "Decodes correctly even if dependencies are empty" <|
            \_ ->
                case emptyDepsLibrary of
                    Ok _ ->
                        Expect.pass

                    Err _ ->
                        Expect.fail "Decoding should be successful"
        , test "Decoding fails when JSON doesn't match" <|
            \_ ->
                case invalidLibrary of
                    Err _ ->
                        Expect.pass

                    Ok _ ->
                        Expect.fail "Decoding should fail"
        , test "Shows libraries correctly" <|
            \_ ->
                case validLibrary of
                    Ok library ->
                        section [] (Library.view library)
                            |> Query.fromHtml
                            |> Expect.all
                                [ Query.find [ Selector.tag "h1" ]
                                    >> Query.has [ Selector.text "requests" ]
                                , Query.findAll [ Selector.tag "h2" ]
                                    >> Query.count (Expect.equal 3)
                                ]

                    Err _ ->
                        Expect.fail "Decoding should be successful"
        ]
