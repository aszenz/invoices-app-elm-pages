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
import Form
import Form.Invoice
import Head
import Html
import Html.Attributes
import Pages.Form
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
    let
        searchForm viewWrap =
            Pages.Form.renderHtml []
                (Form.options "searchInvoices"
                    |> Form.withGetMethod
                )
                app
                (Form.Invoice.searchInvoicesForm viewWrap)
    in
    { title = "Invoices"
    , body =
        [ Html.h2 []
            [ Html.text "Invoices"
            ]
        , Html.nav []
            [ Html.button [ Html.Attributes.type_ "submit", Html.Attributes.form "searchInvoices" ] [ Html.text "Search" ]
            ]
        , searchForm
            (\inputs ->
                [ Html.table []
                    [ Html.thead []
                        [ Html.tr []
                            (inputs
                                |> List.map (\input -> Html.th [] [ input ])
                            )
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
            )
        ]
    }
