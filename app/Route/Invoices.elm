module Route.Invoices exposing (Model, Msg, RouteParams, route, Data, ActionData)

{-|

@docs Model, Msg, RouteParams, route, Data, ActionData

-}

import BackendTask
import Data.Invoices
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
init app shared =
    ( {}, Effect.none )


update :
    RouteBuilder.App Data ActionData RouteParams
    -> Shared.Model
    -> Msg
    -> Model
    -> ( Model, Effect.Effect Msg )
update app shared msg model =
    case msg of
        NoOp ->
            ( model, Effect.none )


subscriptions : RouteParams -> UrlPath.UrlPath -> Shared.Model -> Model -> Sub Msg
subscriptions routeParams path shared model =
    Sub.none


type alias Data =
    {}


type alias ActionData =
    {}


data :
    RouteParams
    -> Server.Request.Request
    -> BackendTask.BackendTask FatalError.FatalError (Server.Response.Response Data ErrorPage.ErrorPage)
data routeParams request =
    BackendTask.succeed (Server.Response.render {})


head : RouteBuilder.App Data ActionData RouteParams -> List Head.Tag
head app =
    []


view :
    RouteBuilder.App Data ActionData RouteParams
    -> Shared.Model
    -> Model
    -> View.View (PagesMsg.PagesMsg Msg)
view app shared model =
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
            , Data.Invoices.exampleInvoices
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
action routeParams request =
    BackendTask.succeed (Server.Response.render {})
