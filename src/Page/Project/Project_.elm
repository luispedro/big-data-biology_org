module Page.Project.Project_ exposing (..)

import Bootstrap.Grid as Grid
import Bootstrap.Grid.Col as Col
import Bootstrap.Grid.Row as Row
import List.Extra

import DataSource exposing (DataSource)
import Head
import Head.Seo as Seo
import Page exposing (Page, PageWithState, StaticPayload)
import Pages.PageUrl exposing (PageUrl)
import Pages.Url
import Shared
import View exposing (View)
import DataSource.File
import OptimizedDecoder as Decode exposing (Decoder)


import Html exposing (Html)
import Html.Attributes as HtmlAttr
import Html.Events

import SiteMarkdown exposing (mdToHtml)
import Lab.Utils exposing (showAuthors)
import Lab.Lab as Lab
import Lab.BDBLab as BDBLab

type alias Data = { members : List Lab.Member, project : Lab.Project }
type alias RouteParams = { project : String }
type alias Model = { }
type Msg =
        NoOp

head :
    StaticPayload Data RouteParams
    -> List Head.Tag
head static =
    Seo.summary
        { canonicalUrlOverride = Nothing
        , siteName = "BDB-Lab"
        , image =
            { url = Pages.Url.external "TODO"
            , alt = "elm-pages logo"
            , dimensions = Nothing
            , mimeType = Nothing
            }
        , description = static.data.project.short_description
        , locale = Nothing
        , title = static.data.project.title
        }
        |> Seo.website

init : () -> ( Model, Cmd Msg )
init () =
    ( {}
    , Cmd.none
    )

page = Page.prerender
        { head = head
        , routes = routes
        , data = \routeParams ->
                BDBLab.projects
                    |> DataSource.andThen (\ms ->
                        case List.Extra.find (\p -> toRoute p == routeParams) ms of
                            Just p -> DataSource.succeed p
                            Nothing -> DataSource.fail "Unknown project??")
                    |> (DataSource.map2 Data BDBLab.members)
        }
        |> Page.buildWithLocalState
            { view = view
            , init = \_ _ staticPayload -> init ()
            , update = \_ _ _ _ -> update
            , subscriptions = \_ _ _ _-> Sub.none
            }

toRoute : Lab.Project -> RouteParams
toRoute p = { project = p.slug }

routes : DataSource (List RouteParams)
routes = DataSource.map (List.map toRoute) BDBLab.projects

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model = (model, Cmd.none)

view :
    Maybe PageUrl
    -> Shared.Model
    -> Model
    -> StaticPayload Data RouteParams
    -> View Msg
view maybeUrl shared model static =
    let
        active = List.filter (\m -> List.member static.data.project m.projects) static.data.members
    in
        { title = static.data.project.title
        , body = [showProject static.data.project model]
        , sidebar = Just <|
                Html.div []
                    [Html.h3 [] [Html.text "BDB-Lab members involved"]
                    ,Html.div [] (List.map makeBubble active)
                    ]
        }

showProject p model =
    Grid.simpleRow
        [Grid.col []
            [Html.h1 [] [Html.text p.title]
            ,mdToHtml p.long_description
            ]
        ]

makeBubble m =
    Html.div
        [HtmlAttr.style "width" "280px"
        ,HtmlAttr.style "height" "280px"
        ,HtmlAttr.style "text-align" "center"
        ,HtmlAttr.style "float" "left"
        ]
        [Html.p
            []
            [Html.a
                [HtmlAttr.href ("/person/"++m.slug)]
                [Html.img
                    [HtmlAttr.src ("/images/people/"++m.slug++".jpeg")
                    ,HtmlAttr.style "width" "220px"
                    ,HtmlAttr.style "height" "220px"
                    ,HtmlAttr.style "border-radius" "50%"
                    ]
                    []
                ,Html.br [] []
                ,Html.text m.name
                ]
            ]
        ]
