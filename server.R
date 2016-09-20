library(shiny)
library(leaflet)
library(sp)
library(maptools)

age <- readShapePoly("diss_LISA_AGE")
dfage <- data.frame(age)
race <- readShapePoly("diss_LISA_RACE")
dfrace <- data.frame(race)
educ <- readShapePoly("diss_LISA_EDUC")
dfeduc <- data.frame(educ)
inc <- readShapePoly("diss_LISA_INC")
dfinc <- data.frame(inc)
resage <- readShapePoly("diss_LISA_RESAGE")
dfresage <- data.frame(resage)
ht <- readShapePoly("diss_LISA_HT")
dfht <- data.frame(ht)
lu <- readShapePoly("diss_LISA_LU")
dflu <- data.frame(lu)
jhbal <- readShapePoly("diss_LISA_JHBAL")
dfjhbal <- data.frame(jhbal)
local <- readShapePoly("diss_LISA_LOCAL")
dflocal <- data.frame(local)
nuis <- readShapePoly("diss_LISA_NUIS")
dfnuis <- data.frame(nuis)
green <- readShapePoly("diss_LISA_GREEN")
dfgreen <- data.frame(green)
zips <- read.csv("ZIP_centroids.csv")
ch <- readShapePoly("SoCal_tracts_inUAs_ESRI2014")
dfch <- data.frame(ch)

descr = data.frame(c("Age", "Race", "Income", "Education", "Dwelling Unit Type", "Housing Age", "Land Use (Overall)", "Jobs-Housing L.U.", "Local Services L.U.", "Nuisance Land Use", "Green Space L.U."),
                   c("mixing is derived from four categories from the US Census: 0-19, 20-34, 35-64, and 65+ years.",
                     "mixing is derived from five categories from the US Census: white, black, hispanic, asian, and other/mixed/undefined.",
                     "mixing is from five categories of household median annual income from the US Census: <$15k, $15k-$35k, $35k-$75k, $75k-$150k, >$150k",
                     "mixing is derived from 5 categories of education levels for people above 25 from the US Census: no high school diploma, high school diploma, some college, Bachelor's degree, graduate degree.",
                     "mixing, from the US Census, represents single-family attached, single-family detached, multifamily, and mobile homes",
                     "mixing is derived from the US Census' measure of housing age: built before 1939, 1940-1959, 1960-1979, 1980-1999, and built after 1999.",
                     "mixing is from the Southern California Association of Governments (SCAG): single-family residential, multifamily residential, commercial, industrial, and vacant/open space.",
                     "mixing analyzes the mixing between residential land use and commercial/industrial land use in a tract to roughly gauge the level of mixing between homes and 'job-producing' land use.",
                     "mixing compares mixing between residential land use and retail/public facilities (schools, hospitals, etc.) to gauge areas that stand out for even blends of homes and local services.",
                     "mixing compares mixing in a tract between residential land use and industrial and transportation infrastructure land uses to gauge the level of 'nuisance' they may pose to nearby homes.",
                     "mixing compares the mixing between residential land use and green or open spaces to gauge the prevelance of this positive externality."))
colnames(descr) = c("var", "explain")

shinyServer(function(input, output) {

  # Grab ZIP code input
  center <- reactiveValues(xcoord=-118.239, ycoord=34.06583)
  observeEvent(input$recenter, {
    center$xcoord = zips$x_centr[zips$CODE==input$zip]
    center$ycoord = zips$y_centr[zips$CODE==input$zip]
  })
  
  ########### CLUSTERS MAP ###########
  
  finalMap <- reactive ({
    withProgress(message='Please Wait: Map Loading', {
    # Create map 
    m = leaflet() %>%  setView(lng=center$xcoord, lat=center$ycoord , zoom=10) %>% addTiles() %>%
    addPolygons(data=age, stroke=T, weight=.7, color="black", fillOpacity=0.4, opacity=1, group="Age Mixing Clusters",
                fillColor = ~colorFactor("RdYlBu", dfage$LISA_AGE)(dfage$LISA_AGE), popup=~LISA_AGE) %>%
    addPolygons(data=race, stroke=T, weight=.7, color="black", fillOpacity=0.4, opacity=1, group="Race Mixing Clusters",
                fillColor = ~colorFactor("RdYlBu", dfrace$LISA_RACE)(dfrace$LISA_RACE), popup=~LISA_RACE) %>%
    addPolygons(data=educ, stroke=T, weight=.7, color="black", fillOpacity=0.4, opacity=1, group="Education Mixing Clusters",
                fillColor = ~colorFactor("RdYlBu", dfeduc$LISA_EDUC)(dfeduc$LISA_EDUC), popup=~LISA_EDUC) %>%
    addPolygons(data=inc, stroke=T, weight=.7, color="black", fillOpacity=0.4, opacity=1, group="Income Mixing Clusters",
                  fillColor = ~colorFactor("RdYlBu", dfinc$LISA_INC)(dfinc$LISA_INC), popup=~LISA_INC) %>%  
    addPolygons(data=resage, stroke=T, weight=.7, color="black", fillOpacity=0.4, opacity=1, group="Housing Age Mixing Clusters",
                  fillColor = ~colorFactor("RdYlBu", dfresage$LISARESAGE)(dfresage$LISARESAGE), popup=~LISARESAGE) %>%
    addPolygons(data=ht, stroke=T, weight=.7, color="black", fillOpacity=0.4, opacity=1, group="Dwelling Unit Type Mixing Clusters",
                  fillColor = ~colorFactor("RdYlBu", dfht$LISA)(dfht$LISA_HT), popup=~LISA_HT) %>%
    addPolygons(data=lu, stroke=T, weight=.7, color="black", fillOpacity=0.4, opacity=1, group="Land Use Mixing (Overall) Clusters",
                  fillColor = ~colorFactor("RdYlBu", dflu$LISA_LU)(dflu$LISA_LU), popup=~LISA_LU) %>%
    addPolygons(data=jhbal, stroke=T, weight=.7, color="black", fillOpacity=0.4, opacity=1, group="Jobs-Housing L.U. Mixing Clusters",
                  fillColor = ~colorFactor("RdYlBu", dfjhbal$LISA_JHBAL)(dfjhbal$LISA_JHBAL), popup=~LISA_JHBAL) %>%
    addPolygons(data=local, stroke=T, weight=.7, color="black", fillOpacity=0.4, opacity=1, group="Local Services L.U. Mixing Clusters",
                  fillColor = ~colorFactor("RdYlBu", dflocal$LISA_LOCAL)(dflocal$LISA_LOCAL), popup=~LISA_LOCAL) %>%
    addPolygons(data=nuis, stroke=T, weight=.7, color="black", fillOpacity=0.4, opacity=1, group="Nuisance Land Use Mixing Clusters",
                  fillColor = ~colorFactor("RdYlBu", dfnuis$LISA_NUIS)(dfnuis$LISA_NUIS), popup=~LISA_NUIS) %>%
    addPolygons(data=green, stroke=T, weight=.7, color="black", fillOpacity=0.4, opacity=1, group="Green Space L.U. Mixing Clusters",
                  fillColor = ~colorFactor("RdYlBu", dfgreen$LISA_GREEN)(dfgreen$LISA_GREEN), popup=~LISA_GREEN) %>%

    addLegend("bottomright", pal=colorFactor("RdYlBu", dfage$LISA), values=dfage$LISA, opacity=0.75, title="Significant Cluster Types:") %>%
      
    addLayersControl(
      baseGroups = c("Age Mixing Clusters", "Race Mixing Clusters", "Education Mixing Clusters", "Income Mixing Clusters", "Housing Age Mixing Clusters", 
                     "Land Use Mixing (Overall) Clusters", "Jobs-Housing L.U. Mixing Clusters", "Local Services L.U. Mixing Clusters",
                     "Nuisance Land Use Mixing Clusters", "Green Space L.U. Mixing Clusters", "Dwelling Unit Type Mixing Clusters"),
      options = layersControlOptions(collapsed = FALSE))
    })
  })
  
  # Generate Map Output
  output$clusterMap = renderLeaflet(finalMap())
  
  
  
  
  ########## VALUES MAP #################
  # Grab Inputs - ALL
  options = reactiveValues(choose="Shape_Area") #Shape_Area chosen as a placeholder since it's numeric 
  observeEvent(input$mixgo, {
    mixlink = switch(input$mix, "Age"="age_k4", "Race"="race_k5", "Education"="educ_k5", "Income"="inc_k5", "Dwelling Unit Age"="resage_", "Land Use (Overall)"="LU_k5", "Housing Type"="ht_k4")
    options$choose = paste(mixlink, "ent", sep="")
  })
  observeEvent(input$socgo, {
    soclink = switch(input$soc, "Total Employment"="totemp", "Median Household Income"="medhhinc", "Average Home Value"="avgval", "Percent Residential Space"="tpctres", "Percent Open Space"="tpctopen", "Percent Black"="tblack", "Percent Latino"="tlatino", "Percent < 20 yrs old"="tpctund20_", "Percent > 65 yrs old"="tpctovr65", "Percent Foreign Born"="timm", "Population Density (pop/acre)"="tpden", "Unemployment Rate"="tunemp", "Percent Homeowners"="towner", "Percent Occupancy"="tocc", "Average Length of Residence"="thowlng")
    options$choose = soclink
  })
    # Create a reactive color palette
  colorpal <- reactive({
    datause <- dfch[,grep(options$choose, colnames(dfch))]
    if(input$analysis==1){pal <- colorBin("Blues", datause, bins=quantile(datause), na.color="#B0171F")}
    else {pal <- colorBin("Greens", datause, bins=quantile(datause), na.color="#B0171F")}
  })
    # Generate the basemap
  output$valuesMap <- renderLeaflet({
    leaflet(ch) %>% setView(lng=center$xcoord, lat=center$ycoord , zoom=10) %>% addTiles()
  })
    # Observe function to add polygons and legend to basemap based on color palette 
  observe({
    withProgress(message='Please Wait: Map Loading', {
    pal <- colorpal()
    datause <- dfch[,grep(options$choose, colnames(dfch))]
    lab <- switch(options$choose, 'age_k4ent'='Age Mixing', 'race_k5ent'='Race Mixing', 'educ_k5ent'='Education Mixing', 'inc_k5ent'='Income Mixing', 'resage_ent'='Dwelling Age Mixing', 'LU_k5ent'='Land Use Mixing', 'ht_k4ent'='Housing Type Mixing', 'totemp'='Total Employment', 'medhhinc'='Median Household Income', 'avgval'='Average Home Value', 'tpctres'='Percent Residential Space', 'tpctopen'='Percent Open Space', 'tblack'='Percent Black', 'tlatino'='Percent Latino', 'tpctund20_'='Percent < 20 yrs old', 'tpctovr65'='Percent > 65 yrs old', 'timm'='Percent Foreign Born', 'tpden'='Population Density (pop/acre)', 'tunemp'='Unemployment Rate', 'towner'='Percent Homeowners', 'tocc'='Percent Occupancy', 'thowlng'='Average Length of Residence')
    leafletProxy("valuesMap") %>% clearControls() %>% clearShapes() %>% 
      addPolygons(data=ch, stroke=T, weight=1, fillColor = ~pal(datause), color="black",
                  fillOpacity=0.6, opacity=1, popup=~NAME10) %>%
      addLegend("bottomleft", pal=pal, values=datause, opacity=0.75, title=lab)
    })
  })  
  
  
  
  
  
  # Add Variable Descriptions
  output$var_desc <- renderText({
    data_link = switch(input$variable,
                       "Age" = descr$explain[descr$var=="Age"],
                       "Race"= descr$explain[descr$var=="Race"],
                       "Income"= descr$explain[descr$var=="Income"],
                       "Education"= descr$explain[descr$var=="Education"],
                       "Dwelling Unit Type"= descr$explain[descr$var=="Dwelling Unit Type"],
                       "Housing Age"= descr$explain[descr$var=="Housing Age"],
                       "Land Use (Overall)"= descr$explain[descr$var=="Land Use (Overall)"],
                       "Jobs-Housing L.U." = descr$explain[descr$var=="Jobs-Housing L.U."],
                       "Local Services L.U." = descr$explain[descr$var=="Local Services L.U."],
                       "Nuisance Land Use" = descr$explain[descr$var=="Nuisance Land Use"],
                       "Green Space L.U." = descr$explain[descr$var=="Green Space L.U."])
    paste("--", input$variable, data_link)
  })
  
})

