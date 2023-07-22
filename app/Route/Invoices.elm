module Route.Invoices exposing
    ( ActionData
    , Data
    , Model
    , Msg
    , RouteParams
    , route
    )

import BackendTask
import Data.Invoice
import Date
import ErrorPage
import FatalError
import Head
import Html
import Html.Attributes
import PagesMsg
import Route
import RouteBuilder
import Server.Request
import Server.Response
import Shared
import View


type alias Model =
    {}


type alias Msg =
    ()


type alias RouteParams =
    {}


type alias Data =
    { invoices : List Data.Invoice.SavedInvoice }


type alias ActionData =
    Never


route : RouteBuilder.StatelessRoute RouteParams Data ActionData
route =
    RouteBuilder.serverRender
        { data = data
        , head = head
        , action = action
        }
        |> RouteBuilder.buildNoState
            { view = view
            }


data :
    RouteParams
    -> Server.Request.Request
    -> BackendTask.BackendTask FatalError.FatalError (Server.Response.Response Data ErrorPage.ErrorPage)
data _ request =
    Data.Invoice.getInvoices (Server.Request.queryParams request)
        |> BackendTask.allowFatal
        |> BackendTask.map
            (\invoices ->
                Server.Response.render
                    { invoices = invoices
                    }
            )


head : RouteBuilder.App Data ActionData RouteParams -> List Head.Tag
head _ =
    []


action :
    RouteParams
    -> Server.Request.Request
    -> BackendTask.BackendTask FatalError.FatalError (Server.Response.Response ActionData ErrorPage.ErrorPage)
action _ _ =
    BackendTask.succeed
        (Server.Response.plainText "Not supported")


view :
    RouteBuilder.App Data ActionData RouteParams
    -> Shared.Model
    -> View.View (PagesMsg.PagesMsg ())
view app _ =
    { title = "Invoices"
    , body =
        [ Html.h2 []
            [ Html.text "Invoices"
            ]
        , Html.form [ Html.Attributes.method "GET", Html.Attributes.id "search-invoices-form" ]
            [ Html.button [ Html.Attributes.type_ "submit" ] [ Html.text "Search" ]
            ]
        , Html.table []
            [ Html.thead []
                [ Html.tr []
                    [ Html.th []
                        [ Html.div []
                            [ Html.text "Number"
                            , Html.input
                                [ Html.Attributes.name "number"
                                , Html.Attributes.type_ "text"
                                , Html.Attributes.form "search-invoices-form"
                                ]
                                []
                            ]
                        ]
                    , Html.th []
                        [ Html.div []
                            [ Html.text "Company"
                            , Html.input
                                [ Html.Attributes.name "company"
                                , Html.Attributes.type_ "text"
                                , Html.Attributes.form "search-invoices-form"
                                ]
                                []
                            ]
                        ]
                    , Html.th []
                        [ Html.div []
                            [ Html.text "Date"
                            , Html.input
                                [ Html.Attributes.name "date"
                                , Html.Attributes.type_ "text"
                                , Html.Attributes.form "search-invoices-form"
                                ]
                                []
                            ]
                        ]
                    , Html.th []
                        [ Html.div []
                            [ Html.text "Item count"
                            , Html.input
                                [ Html.Attributes.name "item_count"
                                , Html.Attributes.type_ "text"
                                , Html.Attributes.form "search-invoices-form"
                                ]
                                []
                            ]
                        ]
                    ]
                ]
            , app.data.invoices
                |> List.map
                    (\invoice ->
                        Html.tr []
                            [ Html.td []
                                [ Route.Invoices__Id_ { id = invoice.id }
                                    |> Route.link []
                                        [ Html.text invoice.number
                                        ]
                                ]
                            , Html.td [] [ Html.text invoice.company ]
                            , Html.td [] [ invoice.date |> Date.format "d-MM-Y" |> Html.text ]
                            , Html.td [] [ List.length invoice.items |> String.fromInt |> Html.text ]
                            ]
                    )
                |> Html.tbody []
            ]
        ]
    }
