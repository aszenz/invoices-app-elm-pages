module Data.Invoice exposing (..)

import BackendTask
import BackendTask.Custom
import Date
import Dict
import FatalError
import Json.Decode
import Json.Encode
import Search.Query


type alias FormInvoice =
    { number : String
    , company : String
    , date : Date.Date
    , items : List InvoiceItem
    }


type alias SavedInvoice =
    { id : String
    , number : String
    , company : String
    , date : Date.Date
    , items : List InvoiceItem
    }


type alias InvoiceItem =
    { product : String
    , quantity : Int
    , price : Float
    }


invoiceDecoder : Json.Decode.Decoder SavedInvoice
invoiceDecoder =
    Json.Decode.map5
        (\id number company date items ->
            { id = id
            , number = number
            , company = company
            , items = items
            , date = date
            }
        )
        (Json.Decode.field "id" Json.Decode.int |> Json.Decode.map String.fromInt)
        (Json.Decode.field "number" Json.Decode.string)
        (Json.Decode.field "company" Json.Decode.string)
        (Json.Decode.field "date" BackendTask.Custom.dateDecoder)
        (Json.Decode.field "items"
            (Json.Decode.list
                (Json.Decode.map3
                    (\price product qty ->
                        { price = price
                        , product = product
                        , quantity = qty |> Basics.round
                        }
                    )
                    (Json.Decode.field "price" Json.Decode.float)
                    (Json.Decode.field "product" Json.Decode.string)
                    (Json.Decode.field "quantity" Json.Decode.float)
                )
            )
        )


getInvoices :
    Dict.Dict String (List String)
    -> BackendTask.BackendTask { fatal : FatalError.FatalError, recoverable : BackendTask.Custom.Error } (List SavedInvoice)
getInvoices filters =
    BackendTask.Custom.run "getInvoices"
        (filters
            |> Search.Query.fromQueryParams
                (\key -> Just key)
            |> Search.Query.encodeToJSValue Basics.identity
        )
        (Json.Decode.list invoiceDecoder)


getInvoice : String -> BackendTask.BackendTask { fatal : FatalError.FatalError, recoverable : BackendTask.Custom.Error } (Maybe SavedInvoice)
getInvoice id =
    BackendTask.Custom.run "getInvoice"
        (Json.Encode.object [ ( "id", id |> Json.Encode.string ) ])
        (Json.Decode.nullable invoiceDecoder)


createInvoice : FormInvoice -> BackendTask.BackendTask { fatal : FatalError.FatalError, recoverable : BackendTask.Custom.Error } SavedInvoice
createInvoice invoice =
    BackendTask.Custom.run "createInvoice"
        (Json.Encode.object
            [ ( "number", invoice.number |> Json.Encode.string )
            , ( "company", invoice.company |> Json.Encode.string )
            , ( "date", invoice.date |> Date.toIsoString |> Json.Encode.string )
            , ( "items", Json.Encode.object [] )
            ]
        )
        invoiceDecoder


deleteInvoice : String -> BackendTask.BackendTask { fatal : FatalError.FatalError, recoverable : BackendTask.Custom.Error } ()
deleteInvoice id =
    BackendTask.Custom.run "deleteInvoice"
        (Json.Encode.object [ ( "id", id |> Json.Encode.string ) ])
        (Json.Decode.succeed ())


updateInvoice : SavedInvoice -> BackendTask.BackendTask { fatal : FatalError.FatalError, recoverable : BackendTask.Custom.Error } SavedInvoice
updateInvoice invoice =
    BackendTask.Custom.run "updateInvoice"
        (Json.Encode.object
            [ ( "id", invoice.id |> Json.Encode.string )
            , ( "newData"
              , Json.Encode.object
                    [ ( "number", invoice.number |> Json.Encode.string )
                    , ( "company", invoice.company |> Json.Encode.string )
                    , ( "date", invoice.date |> Date.toIsoString |> Json.Encode.string )
                    ]
              )
            ]
        )
        invoiceDecoder


invoiceNoExists : String -> BackendTask.BackendTask { fatal : FatalError.FatalError, recoverable : BackendTask.Custom.Error } Bool
invoiceNoExists invoiceNo =
    BackendTask.Custom.run "invoiceNoExists"
        (Json.Encode.object [ ( "invoiceNumber", invoiceNo |> Json.Encode.string ) ])
        Json.Decode.bool
