module Page.Paper.Paper_ exposing (..)

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

type alias Data = { membersAndAlumni : List Lab.Member, paper : Lab.Publication }
type alias RouteParams = { paper : String }
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
        , description = static.data.paper.short_description
        , locale = Nothing
        , title = static.data.paper.title
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
                BDBLab.papers
                    |> DataSource.andThen (\ms ->
                        case List.Extra.find (\p -> String.toLower p.slug == String.toLower routeParams.paper) ms of
                            Just p -> DataSource.succeed p
                            Nothing -> DataSource.fail "Unknown paper??")
                    |> (DataSource.map2 Data BDBLab.membersAndAlumni)
        }
        |> Page.buildWithLocalState
            { view = view
            , init = \_ _ staticPayload -> init ()
            , update = \_ _ _ _ -> update
            , subscriptions = \_ _ _ _-> Sub.none
            }

routes : DataSource (List RouteParams)
routes = DataSource.map (List.map toRoute) BDBLab.papers

toRoute : Lab.Publication -> RouteParams
toRoute p = RouteParams p.slug

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
        active = static.data.paper.authors |>
            List.filterMap (\a -> case List.filter (\m -> m.name == a) static.data.membersAndAlumni of
                [] -> Nothing
                (m :: _) -> Just m)
    in
        { title = static.data.paper.title
        , body = [showPaper static.data.paper static.data.membersAndAlumni model]
        , sidebar = Just <|
                Html.div []
                    [Html.h3 [] [Html.text "BDB-Lab members involved"]
                    ,Html.div [] (List.map makeBubble active)
                    ]
        }

showPaper :
    Lab.Publication
    -> List Lab.Member
    -> Model
    -> Html a
showPaper p members model =
    Grid.simpleRow
        [Grid.col []
            [Html.h1 [] [Html.text p.title]
            ,Html.div
                [HtmlAttr.style "width" "40%"
                ,HtmlAttr.style "float" "left"
                ,HtmlAttr.style "padding-right" "1em"
                ,HtmlAttr.style "margin-right" "1em"
                ,HtmlAttr.style "border-right" "solid 2px #7570b3"
                ,HtmlAttr.style "padding-bottom" "1em"
                ]
                [Html.img
                    [HtmlAttr.style "max-width" "100%"
                    ,HtmlAttr.src ("/images/papers/"++p.slug++".png")
                    ]
                    []
                ]
            ,Html.h3 []
                [Html.text p.title]
            ,Html.p []
                [Html.text "by "
                ,Html.cite []
                    (showAuthors p.authors members)
                ]
            ,Html.p [HtmlAttr.style "max-height" "160px"]
                [Html.span [HtmlAttr.class "__dimensions_badge_embed__"
                        ,HtmlAttr.attribute "data-doi" p.doi
                        ,HtmlAttr.attribute "data-legend" "always"
                        ] []]
            ,Html.h4 [] [Html.text "Abstract"]
            ,mdToHtml p.abstract
            ,Html.p []
                [Html.b
                    []
                    [Html.text "Full text: "]
                ,Html.a [HtmlAttr.href ("https://doi.org/"++p.doi)]
                    [Html.text ("https://doi.org/"++p.doi)]
                ]
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
                ,Html.text (if m.left /= Nothing then " (alumni)" else "")
                ]
            ]
        ]
