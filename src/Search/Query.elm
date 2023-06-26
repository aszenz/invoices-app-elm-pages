module Search.Query exposing
    ( SearchConditions
    , SortOrder(..)
    , encodeToJSValue
    , fromQueryParams
    )

import Dict
import Json.Encode
import List.Extra


type alias SearchConditions fieldType =
    { filters : List ( fieldType, String )
    , sortBy :
        Maybe
            { field : fieldType
            , order : SortOrder
            }
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
            |> Dict.get "_sort-by"
            |> Maybe.andThen
                (\field ->
                    List.Extra.last field
                        |> Maybe.andThen
                            (\fieldKey ->
                                toFieldName fieldKey
                                    |> Maybe.map
                                        (\valF ->
                                            { field = valF
                                            , order =
                                                queryParams
                                                    |> Dict.get "_sort-order"
                                                    |> Maybe.map fromSortOrder
                                                    |> Maybe.withDefault Ascending
                                            }
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


encodeToJSValue : SearchConditions fieldType -> (fieldType -> String) -> Json.Encode.Value
encodeToJSValue searchConditions fieldTypeToString =
    Debug.todo ""


fromSortOrder : List String -> SortOrder
fromSortOrder str =
    case List.Extra.last str of
        Just "asc" ->
            Ascending

        Just "desc" ->
            Descending

        _ ->
            Ascending
