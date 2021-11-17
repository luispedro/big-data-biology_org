module Page.People exposing (Model, Msg, Data, page)

import Html.Extra
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Col as Col
import Bootstrap.Grid.Row as Row
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

import Html
import Html.Attributes exposing (class, src, href, style)
import Html.Events exposing (..)

import SiteMarkdown
import Lab.Lab as Lab
import Lab.BDBLab as BDBLab

type alias Model = ()
type alias Msg = Never

type alias RouteParams =
    { }

type alias Data = List Lab.Member

page : Page RouteParams Data
page =
    Page.prerender
        { head = head
        , routes = DataSource.succeed [{}]
        , data = data
        }
        |> Page.buildNoState { view = view }



data : RouteParams -> DataSource Data
data routeParams = BDBLab.membersAndAlumni

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
        , description = "The members of BDB-Lab, including alumni"
        , locale = Nothing
        , title = "BDB-Lab Members"
        }
        |> Seo.website


splitMembers :
    List Lab.Member
    ->
        { pi : List Lab.Member
        , postdocs : List Lab.Member
        , students : List Lab.Member
        , visitors : List Lab.Member
        , other : List Lab.Member
        , alumni : List Lab.Member
        }
splitMembers =
    let
        add1 k sofar =
            if k.left /= Nothing
            then { sofar | alumni = k :: sofar.alumni }
            else if k.title == "Principal Investigator"
            then { sofar | pi = k :: sofar.pi }
            else if k.title == "Postdoctoral researcher"
            then { sofar | postdocs = k :: sofar.postdocs }
            else if k.title == "Graduate student"
            then { sofar | students = k :: sofar.students }
            else if k.title == "Visitor"
            then { sofar | visitors = k :: sofar.pi }
            else { sofar | other = k :: sofar.other }
    in
        List.foldr add1 { pi = [], postdocs = [], students = [] ,visitors = [], other = [], alumni = []}

view :
    Maybe PageUrl
    -> Shared.Model
    -> StaticPayload Data RouteParams
    -> View Msg
view maybeUrl sharedModel static =
    let
        cat = splitMembers static.data
        showMembers name mems =
            Html.Extra.viewIf
                (not <| List.isEmpty mems)
                <| Html.div []
                    [Html.h3 [] [Html.text name]
                    ,Html.div [] (List.map showMember mems)]
    in { title = "BDB-Lab Members"
        , body =
                [Html.h1 [] [Html.text "BDB-Lab Members"]
                ,showMembers "Principal Investigator" cat.pi
                ,showMembers "Postdoctoral researchers" cat.postdocs
                ,showMembers "Graduate students" cat.students
                ,showMembers "Other members" cat.other
                ,showMembers "Visitors" cat.visitors
                ,showMembers "Alumni" cat.alumni
                ]
        , sidebar = Nothing
        }

showMember m =
    Grid.simpleRow
        [Grid.col []
            [Html.h4 [] [Html.text m.name]
            ,case m.left of
                Just ell_date ->
                    Html.p []
                        [Html.i []
                            [Html.text "Member from "
                            ,Html.text m.joined
                            ,Html.text " to "
                            ,Html.text ell_date
                            ,Html.text " ("
                            ,Html.text m.title
                            ,Html.text ")."
                            ]
                        ]
                Nothing -> Html.div [] []
            ,SiteMarkdown.mdToHtml m.short_bio
            ,Html.p [] [Html.text "More about "
                       ,Html.a [href <| "/person/"++m.slug] [Html.text m.name]
                       ,Html.text "..."]
            ]
        ,Grid.col
            [Col.xs4]
            [Html.img [src ("/images/people/"++m.slug++".jpeg")
                    , style "max-height" "120px"
                    , style "border-radius" "50%"
                    ]
                []]
        ]

