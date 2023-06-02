module Data.Invoices exposing (..)

import Date exposing (Date)
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
