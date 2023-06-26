module Data.Invoice exposing (..)

import BackendTask
import BackendTask.Custom
import Date
import Dict
import FatalError
import Json.Decode
import Json.Encode
import Search.Search
import Time


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


exampleInvoices : List Invoice
exampleInvoices =
    [ { number = "1"
      , company = "BarCorp"
      , date = Date.fromCalendarDate 2023 Time.Apr 13
      , items =
            [ { product = "Biscuits"
              , quantity = 2
              , price = 200.0
              }
            ]
      }
    , { number = "2"
      , company = "FooCorp"
      , date = Date.fromCalendarDate 2022 Time.Mar 13
      , items =
            [ { product = "Chips"
              , quantity = 1
              , price = 250.0
              }
            ]
      }
    , { number = "3"
      , company = "ZCorp"
      , date = Date.fromCalendarDate 2023 Time.Jun 13
      , items =
            [ { product = "Chocolates"
              , quantity = 2
              , price = 400.0
              }
            ]
      }
    , { number = "4"
      , company = "NS"
      , date = Date.fromCalendarDate 2024 Time.Dec 13
      , items =
            [ { product = "Snacks"
              , quantity = 2
              , price = 1250.0
              }
            ]
      }
    ]


invoiceDecoder : Json.Decode.Decoder Invoice
invoiceDecoder =
    Json.Decode.map3
        (\number company items ->
            { number = number
            , company = company
            , items = items
            , date = Date.fromCalendarDate 1 Time.Apr 2022
            }
        )
        (Json.Decode.field "number" Json.Decode.string)
        (Json.Decode.field "company" Json.Decode.string)
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
            |> Search.Query.encodeToJs
        )
        (Json.Decode.list invoiceDecoder)


getInvoice : String -> BackendTask.BackendTask { fatal : FatalError.FatalError, recoverable : BackendTask.Custom.Error } (Maybe Invoice)
getInvoice invoiceNumber =
    BackendTask.Custom.run "getInvoice"
        (Json.Encode.object [ ( "invoiceNumber", invoiceNumber |> Json.Encode.string ) ])
        (Json.Decode.nullable invoiceDecoder)
