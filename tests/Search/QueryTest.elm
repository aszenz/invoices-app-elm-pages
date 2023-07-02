module Search.QueryTest exposing (suite)

import Dict
import Expect
import Fuzz
import Search.Query
import Test


suite : Test.Test
suite =
    Test.describe "Test.Query"
        [ Test.test "Simple test" <|
            \_ ->
                equalSearchParams
                    searchQuery
                    (searchQuery
                        |> Search.Query.fromQueryParams (\v -> Just v)
                        |> Search.Query.toQueryParams Basics.identity
                    )
        , Test.fuzz searchQueryFuzzer "test fuzz" <|
            \fuzzDict ->
                equalSearchParams
                    fuzzDict
                    (fuzzDict
                        |> Search.Query.fromQueryParams (\v -> Just v)
                        |> Search.Query.toQueryParams Basics.identity
                    )
        ]


searchQueryFuzzer : Fuzz.Fuzzer (Dict.Dict String (List String))
searchQueryFuzzer =
    Fuzz.list (Fuzz.pair (Fuzz.stringOfLength 4) (Fuzz.listOfLength 1 (Fuzz.stringOfLength 4)))
        |> Fuzz.map Dict.fromList


equalSearchParams : Dict.Dict String b -> Dict.Dict String b -> Expect.Expectation
equalSearchParams expected actual =
    Expect.equalDicts
        (expected |> Dict.filter (\k _ -> String.trim k == "" || String.startsWith "_" k |> not))
        (actual |> Dict.filter (\k _ -> String.trim k == "" || String.startsWith "_" k |> not))


searchQuery : Dict.Dict String (List String)
searchQuery =
    Dict.fromList
        [ ( "name", [ "rel" ] )
        , ( "qty", [ "50" ] )
        , ( "_page", [ "1" ] )
        ]
