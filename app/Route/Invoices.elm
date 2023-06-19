module Route.Invoices exposing (Model, Msg, RouteParams, route, Data, ActionData)

{-|

@docs Model, Msg, RouteParams, route, Data, ActionData

-}

import BackendTask
import Data.Invoice
import Date
import Effect
import ErrorPage
import FatalError
import Head
import Html
import PagesMsg
import Route
import RouteBuilder
import Server.Request
import Server.Response
import Shared
import UrlPath
import View


type alias Model =
    {}


type Msg
    = NoOp


type alias RouteParams =
    {}


route : RouteBuilder.StatefulRoute RouteParams Data ActionData Model Msg
route =
    RouteBuilder.serverRender { data = data, action = action, head = head }
        |> RouteBuilder.buildWithLocalState
            { view = view
            , init = init
            , update = update
            , subscriptions = subscriptions
            }


init :
    RouteBuilder.App Data ActionData RouteParams
    -> Shared.Model
    -> ( Model, Effect.Effect Msg )
init _ _ =
    ( {}, Effect.none )


update :
    RouteBuilder.App Data ActionData RouteParams
    -> Shared.Model
    -> Msg
    -> Model
    -> ( Model, Effect.Effect Msg )
update _ _ msg model =
    case msg of
        NoOp ->
            ( model, Effect.none )


subscriptions : RouteParams -> UrlPath.UrlPath -> Shared.Model -> Model -> Sub Msg
subscriptions _ _ _ _ =
    Sub.none


type alias Data =
    { invoices : List Data.Invoice.Invoice }


type alias ActionData =
    {}


data :
    RouteParams
    -> Server.Request.Request
    -> BackendTask.BackendTask FatalError.FatalError (Server.Response.Response Data ErrorPage.ErrorPage)
data _ _ =
    Data.Invoice.getInvoices
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


view :
    RouteBuilder.App Data ActionData RouteParams
    -> Shared.Model
    -> Model
    -> View.View (PagesMsg.PagesMsg Msg)
view app _ _ =
    { title = "Invoices"
    , body =
        [ Html.h2 []
            [ Html.text "Invoices"
            ]
        , Html.table []
            [ Html.thead []
                [ Html.tr []
                    [ Html.th [] [ Html.text "Number" ]
                    , Html.th [] [ Html.text "Company" ]
                    , Html.th [] [ Html.text "Date" ]
                    , Html.th [] [ Html.text "Item count" ]
                    ]
                ]
            , app.data.invoices
                |> List.map
                    (\invoice ->
                        Html.tr []
                            [ Html.td []
                                [ Route.Invoices__Id_ { id = invoice.number }
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


action :
    RouteParams
    -> Server.Request.Request
    -> BackendTask.BackendTask FatalError.FatalError (Server.Response.Response ActionData ErrorPage.ErrorPage)
action _ _ =
    BackendTask.succeed (Server.Response.render {})
