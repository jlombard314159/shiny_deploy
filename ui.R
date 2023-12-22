##TODO:
# filter to select current year
# filter to select previous years to compare to
# filter for a metric

navbarPage(title = "Colorado SNOWTEL data",
           lang = "en-US",

    tabPanel("Welcome",
             fluidRow(
                h1("Johns dashboard"),
                p("Lorem ipsum whatever."),
                 tags$br()
                 )
             ),

    tabPanel("Map",
                fluidRow(
                    sidebarPanel(width = 3
                    ),
                    mainPanel(width = 9,
                            leaflet::leafletOutput("map", height = "500px")
                    )
                )

    )       
)