module Search.Query exposing
    ( SearchConditions
    , SortOrder(..)
    , encodeToJSValue
    , fromQueryParams
    , toQueryParams
    )

import Dict
import Json.Encode
import List.Extra


type alias SearchConditions fieldType =
    { filters : List ( fieldType, String )
    , sortBy : List ( fieldType, SortOrder )
    , pageNo : Int
    }


type SortOrder
    = Ascending
    | Descending


fromQueryParams :
    (String -> Maybe field)
    -> Dict.Dict String (List String)
    -> SearchConditions field
fromQueryParams toFieldName queryParams =
    { filters =
        queryParams
            |> Dict.toList
            |> List.filterMap
                (\( key, value ) ->
                    toFieldName key
                        |> Maybe.andThen
                            (\validField ->
                                List.Extra.last value
                                    |> Maybe.andThen
                                        (\vv ->
                                            if vv |> String.trim |> String.isEmpty then
                                                Nothing

                                            else
                                                Just ( validField, vv )
                                        )
                            )
                )
    , sortBy =
        queryParams
            |> Dict.filter (\k _ -> k == "_sort-by")
            |> Dict.toList
            |> List.filterMap
                (\( _, field ) ->
                    List.Extra.last field
                        |> Maybe.andThen
                            (\fieldKey ->
                                toFieldName fieldKey
                                    |> Maybe.map
                                        (\valF ->
                                            ( valF
                                            , queryParams
                                                |> Dict.get "_sort-order"
                                                |> Maybe.map fromSortOrderList
                                                |> Maybe.withDefault Ascending
                                            )
                                        )
                            )
                )
    , pageNo =
        queryParams
            |> Dict.get "_page"
            |> Maybe.andThen
                (List.Extra.last >> Maybe.andThen String.toInt)
            |> Maybe.withDefault 1
    }


toQueryParams : (fieldType -> String) -> SearchConditions fieldType -> Dict.Dict String String
toQueryParams fieldTypeToString searchConditions =
    let
        filters =
            searchConditions.filters
                |> List.map (\( field, searchValue ) -> ( field |> fieldTypeToString, searchValue ))

        sortBy =
            case List.head searchConditions.sortBy of
                Just ( sortField, sortOrder ) ->
                    [ ( "_sort-by", sortField |> fieldTypeToString )
                    , ( "_sort-order", toSortOrder sortOrder )
                    ]

                Nothing ->
                    []

        pageNo =
            [ ( "_page", searchConditions.pageNo |> String.fromInt ) ]
    in
    [ filters
    , sortBy
    , pageNo
    ]
        |> List.concat
        |> Dict.fromList
        |> Dict.map (\_ v -> v)


encodeToJSValue : (fieldType -> String) -> SearchConditions fieldType -> Json.Encode.Value
encodeToJSValue fieldTypeToString searchConditions =
    toQueryParams fieldTypeToString searchConditions
        |> Json.Encode.dict
            Basics.identity
            Json.Encode.string


fromSortOrderList : List String -> SortOrder
fromSortOrderList str =
    case List.Extra.last str of
        Just "asc" ->
            Ascending

        Just "desc" ->
            Descending

        _ ->
            Ascending


toSortOrder : SortOrder -> String
toSortOrder order_ =
    case order_ of
        Ascending ->
            "asc"

        Descending ->
            "desc"


fromSortOrder : String -> Maybe SortOrder
fromSortOrder order_ =
    case order_ of
        "asc" ->
            Just Ascending

        "desc" ->
            Just Descending

        _ ->
            Nothing
