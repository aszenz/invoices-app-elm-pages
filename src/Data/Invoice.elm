module Data.Invoice exposing (..)

import BackendTask
import BackendTask.Custom
import Date
import Dict
import FatalError
import Json.Decode
import Json.Encode
import Search.Query


type alias Invoice =
    { number : String
    , company : String
    , date : Date.Date
    , items : List InvoiceItem
    }


type alias InvoiceItem =
    { product : String
    , quantity : Int
    , price : Float
    }


invoiceDecoder : Json.Decode.Decoder Invoice
invoiceDecoder =
    Json.Decode.map4
        (\number company date items ->
            { number = number
            , company = company
            , items = items
            , date = date
            }
        )
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
    -> BackendTask.BackendTask { fatal : FatalError.FatalError, recoverable : BackendTask.Custom.Error } (List Invoice)
getInvoices filters =
    let
        _ =
            Debug.log "filters" filters
    in
    BackendTask.Custom.run "getInvoices"
        (filters
            |> Search.Query.fromQueryParams
                (\key -> Just key)
            |> Search.Query.encodeToJSValue Basics.identity
        )
        (Json.Decode.list invoiceDecoder)


getInvoice : String -> BackendTask.BackendTask { fatal : FatalError.FatalError, recoverable : BackendTask.Custom.Error } (Maybe Invoice)
getInvoice invoiceNumber =
    BackendTask.Custom.run "getInvoice"
        (Json.Encode.object [ ( "invoiceNumber", invoiceNumber |> Json.Encode.string ) ])
        (Json.Decode.nullable invoiceDecoder)



-- createInvoice : Invoice -> BackendTask.BackendTask { fatal : FatalError.FatalError, recoverable : BackendTask.Custom.Error } (Maybe Invoice)
-- createInvoice invoice =
--     BackendTask.Custom.run "createInvoice"
--         (Json.Encode.object [ ( "invoiceNumber", invoiceNumber |> Json.Encode.string ) ])
--         (Json.Decode.nullable invoiceDecoder)


updateInvoice : Invoice -> BackendTask.BackendTask { fatal : FatalError.FatalError, recoverable : BackendTask.Custom.Error } Invoice
updateInvoice invoice =
    BackendTask.Custom.run "updateInvoice"
        (Json.Encode.object
            [ ( "invoiceNumber", invoice.number |> Json.Encode.string )
            , ( "newData"
              , Json.Encode.object
                    [ ( "company", invoice.company |> Json.Encode.string )
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
