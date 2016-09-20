library(shiny)
library(leaflet)
library(sp)
library(maptools)

shinyUI(
  navbarPage("MFI Webmap: Neighborhood Mixing in Southern California", id="nav",
  
  tabPanel("Mixing Clusters", div(class="outer",
        tags$head(includeCSS("styles.css")),   # custom, taken from Shiny's "superZIP"
        leafletOutput("clusterMap", width="100%", height="100%"),
        absolutePanel(id = "controls", class="panel panel-default", fixed = TRUE,
                          draggable=TRUE, top=110, left=10, right="auto", bottom="auto",
                          width=280, height="auto", 
                          p(strong(em("This application displays clusters of census tracts (2012 data) which exhibit statistically significant levels of mixing using entropy values."))),
                          h6("--- Please allow a minute for the app to load after first opening. It's a lot of data!"),
                          h6("-1- Begin by selecting a dimension of mixing using the radio buttons to the right."),
                          selectInput("variable", label=h6("-2- Choose a mixing type below for more information:"), selected=" ",
                                      choices=list(" ", "Age", "Race", "Income", "Education", "Dwelling Unit Type", "Housing Age", "Land Use (Overall)", "Jobs-Housing L.U.", "Local Services L.U.", "Nuisance Land Use", "Green Space L.U.")),
                          h6(textOutput("var_desc")),
                          h6("-- Groups of tracts are shown which stand out for their high levels of mixing (High-High Clusters), low levels of mixing (Low-Low Clusters), or by being significantly more or less mixed than neighboring tracts (High-Low or Low-High Outliers, respectively)."),
                          h6("-- See the ", a("full report here", href="http://mfi.soceco.uci.edu/category/quarterly-report/", target="_blank"), "for details.")
                          )
  )),
  
  tabPanel("Mixing Values", div(class="outer",
        tags$head(includeCSS("styles.css")),   # custom, taken from Shiny's "superZIP"                 
        leafletOutput("valuesMap", width="100%", height="100%"),
        absolutePanel(id = "controls", class = "panel panel-default", fixed = TRUE, draggable = TRUE, top = 60, left = "auto", 
                      right = 20, bottom = "auto",  width = 250, height = "auto",
                      p(strong(em("This application displays values of mixing (2012 data) and other socioeconomic conditions (year 2000)."))),
                      textInput("zip", label="Zoom to 5-digit ZIP Code:", value=90012),
                      actionButton("recenter", label="Re-center"),
                      br(),
                      p(strong("Select Topic of Analysis:")), 
                      selectInput("analysis", label="", choices=list("Mixing Type" = 1, "Socioeconomic Conditions (2000)" = 2), selected = 1),
                      conditionalPanel("input.analysis == 1",
                                       selectInput("mix", label=strong("Select Mixing Type:"), choices=list(" ", "Age", "Race", "Education", "Income", "Dwelling Unit Age", "Housing Type", "Land Use (Overall)"), selected=" "),
                                       actionButton("mixgo", label="Go/Refresh")),
                      conditionalPanel("input.analysis == 2",
                                       selectInput("soc", label=strong("Select Year 2000 Conditions:"), choices=list(" ", "Total Employment", "Median Household Income", "Average Home Value", "Percent Residential Space", "Percent Open Space", "Percent Black", "Percent Latino", "Percent < 20 yrs old", "Percent > 65 yrs old", "Percent Foreign Born", "Population Density (pop/acre)", "Unemployment Rate", "Percent Homeowners", "Percent Occupancy", "Average Length of Residence"), selected=" "),
                                       actionButton("socgo", label="Go/Refresh")),
                      h6(em("by the ", a("Metropolitan Futures Initiative", href="http://mfi.soceco.uci.edu", target="_blank"), "at UC-Irvine (2016). Webmap by ", a("Kevin Kane, PhD", href="http://www.kevinkane.org", target="_blank"), "and", a("UCI Data Science Initiative", href="http://datascience.uci.edu", target="_blank")))
                      ),
        
        absolutePanel(id = "controls", class="panel panel-default", fixed = TRUE, draggable=TRUE, top=110, left=10, right="auto",
                      bottom="auto", width=150, height="auto",
                      p(strong("Data Notes:")),
                      h6("-- Please be patient while map loads - it's a lot of data!"),
                      h6("-- Data are presented in census tracts (2010 boundaries)."),
                      h6("-- Legend splits tracts by quartiles (i.e. 25% of tracts in each color bin)."),
                      h6("-- Mixing values are entropy values. See the ", a("full report here", href="http://mfi.soceco.uci.edu/category/quarterly-report/", target="_blank"), "for details."),
                      h6("-- See 'Mixing Clusters' tab for a description of mixing types.")
                      )
  ))

))

