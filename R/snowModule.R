# UI function for snow module
snowUI <- function(id) {
  ns <- NS(id)
  # Use absolutePanel for both map and controls to allow full-page map
  tagList(
    # Add a div with specific CSS
    tags$style(HTML("
        #map, #snow-snow_map {
          height: calc(100vh - 90px) !important;
          width: 100% !important;
          position: absolute;
          top: 60px;
          left: 0;
          right: 0;
          bottom: 30px
          z-index: 1;
        }
      .floating-panel {
        background-color: #ffffff;
        padding: 20px;
        border-radius: 5px;
        box-shadow:
          0 0 0 rgba(0,0,0,0),        /* Top shadow - no offset, no blur, transparent */
          0 2px 15px rgba(0,0,0,0.2),  /* Bottom shadow */
          2px 0 15px rgba(0,0,0,0.1),  /* Right shadow */
          -2px 0 15px rgba(0,0,0,0.1); /* Left shadow */
        max-width: 300px;
        z-index: 2;
      }
      .leaflet-control-zoom {
        position: fixed !important;
        bottom: 80px !important;
        left: 10px !important;
        top: auto !important;
        z-index: 1000 !important;
      }
      .last-updated-control{
        bottom:3px !important;
      }
    ")),

    # Map output
    leafletOutput(ns("snow_map"), height = "100%"),

    # Floating control panel
    absolutePanel(
      id = ns("snow_controls"),
      class = "floating-panel",
      fixed = TRUE,
      draggable = TRUE,
      top = 70,
      left = 20,

      # year selection - label will be updated via JavaScript when language changes
      # selectInput(ns("snow_year"), "Select Year:", choices = NULL),
      uiOutput(ns("year_selector")),
       # added by MA July 2025 - french - uiOutput for snow_controls_content (created in server)
      uiOutput(ns("snow_controls_content"))
    ),

    create_info_panel_UI(ns)
    )
}

# Server function for snow module - french - add language to server fun
snowServer <- function(id, first_visits, language, preloaded_data, show_welcome_trigger) {
  moduleServer(id, function(input, output, session) {

    # Trigger welcome modal on first visit
    observe({
      req(first_visits$snow)
      show_welcome_trigger(TRUE)  # This will trigger the modal in main server
      first_visits$snow <- FALSE
    })

    # for info panel / welcome modal keep info
    setup_info_panel_server(input, output, session, language)

    # DATA LOADING
    # load shapefiles
    if (!is.null(preloaded_data()$mackenzie_basin)) {
      mackenzie_basin <- preloaded_data()$mackenzie_basin
      slave <- preloaded_data()$slave
      peel <- preloaded_data()$peel
      hay <- preloaded_data()$hay
      liard <- preloaded_data()$liard
    } else {
      mackenzie_basin <- readRDS("data/MackenzieRiverBasin_FDA.rds")
      slave <- readRDS("data/07NC005_DrainageBasin_BassinDeDrainage.rds")
      peel <- readRDS("data/10MC002_DrainageBasin_BassinDeDrainage.rds")
      hay <- readRDS("data/07OB001_DrainageBasin_BassinDeDrainage.rds")
      liard <- readRDS("data/10ED002_DrainageBasin_BassinDeDrainage.rds")
    }

    # load df and update site names if preload fails
    if (!is.null(preloaded_data()$md_3)) {
      md_3 <- preloaded_data()$md_3
    } else {
      md_3 <- readRDS("data/md_3.rds")
      md_3 <- update_site_names(md_3)
    }
    max_snow_date <- format(max(md_3$date_time, na.rm = TRUE), "%Y-%m-%d")
    available_years <- sort(unique(md_3$year), decreasing = TRUE)

    #

    # REACTIVE EXPRESSIONS
    map_text <- reactive({
      #print(paste("map_text() RUNNING - language:", language(), "snow_year:", input$snow_year, "at", Sys.time()))
      req(language())
      if(language() == "fr") {
        list(
          last_updated = paste0(
            "<strong>Dernière mise à jour:</strong> ",
            '<span title="Cette date indique quand les données ont été ajoutées pour la dernière fois à l\'application, et non la dernière fois que l\'application elle-même a été mise à jour." style="cursor: help; text-decoration: underline; text-decoration-style: dotted;">',
            max_snow_date,
            '</span>'
          ),
          basins = list(
            mackenzie = "Bassin du Mackenzie",
            slave = "Bassin de la rivière des Esclaves",
            peel = "Bassin de la rivière Peel",
            hay = "Bassin de la rivière au Foin",
            liard = "Bassin de la rivière Liard"
          ),
          base_maps = list(
            cartodb = "Carte Simple",
            esri = "Carte Satellite"
          ),
          legend = list(
            title = paste0("Équivalent en eau de la neige <br> (% de la moyenne) <br> Printemps (", input$snow_year, ")")
          ),
          popup = list(
            percent_avg = "Pourcentage de la moyenne (%)",
            swe = "EEN (mm)",
            snow_depth = "Épaisseur de neige (cm)",
            years_record = "Nombre d'années avec données"
          )
        )
      } else {
        list(
          last_updated = paste0(
            "<strong>Last updated:</strong> ",
            '<span title="This date indicates when data was last added to the application, not when the application itself was last updated." style="cursor: help; text-decoration: underline; text-decoration-style: dotted;">',
            max_snow_date,
            '</span>'
          ),
          basins = list(
            mackenzie = "Mackenzie Basin",
            slave = "Slave Basin",
            peel = "Peel Basin",
            hay = "Hay Basin",
            liard = "Liard Basin"
          ),
          base_maps = list(
            cartodb = "Simple Map",
            esri = "Satellite Map"
          ),
          legend = list(
            title = paste0("Snow Water Equivalent <br> (% of Average) <br> Spring (", input$snow_year, ")")
          ),
          popup = list(
            percent_avg = "Percent of Average (%)",
            swe = "SWE (mm)",
            snow_depth = "Snow Depth (cm)",
            years_record = "Years of Record"
          )
        )
      }
    })

    output$snow_controls_content <- renderUI({
      current_lang <- isolate(language())  # Use isolate to prevent re-running
      tagList(
        uiOutput(session$ns("year_warning")),
        actionButton(session$ns("refresh"),
                     if(current_lang == "fr") "Actualiser" else "Refresh Data")
      )
    })

    # make year warning text dynamic - for years where no snow surveys were conducted
    output$year_warning <- renderUI({
      req(input$snow_year)
        current_lang <- isolate(language())
      if(input$snow_year %in% c(1976, 1977)) {
        tags$div(
          style = "color: #d32f2f; font-size: 12px; margin-top: 5px; padding: 8px; background-color: #ffebee; border-radius: 4px;",
          HTML(paste0(
            "<strong>",
            if(language() == "fr") "Aucune donnée disponible pour" else "No data available for",
            " ", input$snow_year, "</strong><br>",
            if(language() == "fr") {
              paste0("Les relevés nivométriques n'ont pas été effectués en ", input$snow_year, ".")
            } else {
              paste0("Snow surveys were not conducted in ", input$snow_year, ".")
            }
          ))
        )
      } else {
        NULL
      }
    })

    # Render year selector, reactive to langauge and preserves selected year
    output$year_selector <- renderUI({
      req(language())
      req(available_years)

      # Preserve current selection if it exists
      current_selected <- isolate(input$snow_year)
      if(is.null(current_selected)) {
        current_selected <- max(available_years)
      }

      selectInput(
        session$ns("snow_year"),
        label = if(language() == "fr") "Année:" else "Select Year:",
        choices = available_years,
        selected = current_selected
      )
    })

    # Added by MA - May 15, 2025
    # Create reactive expression for data processing
    snow_data <- reactive({
      #print(paste("snow_data() RUNNING - year:", input$snow_year, "language:", isolate(language()), "at", Sys.time()))

      req(input$snow_year)
      year <- input$snow_year

      # Added by MA - Jul 17, 2025 - return empty df if select year is 1976-77
      if(year %in% c(1976, 1977)) {
        df <- data.frame(
          Region = character(),
          Site = character(),
          Length_Total = numeric(),
          Length_Trimmed = numeric(),
          Mean_SWE_mm = numeric(),
          Current_Depth = numeric(),
          Current_SWE = numeric(),
          Percent_Normal = numeric(),
          Long = numeric(),
          Lat = numeric(),
          Date = as.Date(character()),
          Jurisdiction = character(),
          Percent_Normal_Bin = factor()
        )
        return(df)
      }

      NT_Data <- SWEsummary_shiny(data = md_3,
                                  surface="upland",
                                  minyear=2000,
                                  maxyear=2021,
                                  curmaxyear=year,
                                  flags = c("Y", "HS"),
                                  act="A",
                                  hdensity_sd  = 3,
                                  ldensity_sd  = 2,
                                  ldensity_limit  = 0.1,
                                  write = FALSE) %>%
        mutate(Jurisdiction = "NT") %>%
        rename("Region"="region", "Site"="site", "Length_Total"="yrs", "Length_Trimmed"="yrs2",
               "Mean_SWE_mm"="meanSWE01_cur", "Current_Depth"="meandepth_cur",
               "Current_SWE"="meanSWE_cur", "Percent_Normal"="pernorm")

      df <- NT_Data

      df <- df[!is.na(df$Percent_Normal), ]

      # Convert to sf object
      proj <- '+proj=longlat +datum=WGS84'

      df$Percent_Normal_Bin <- cut(df$Percent_Normal,
                                   c(0, 50, 70, 90, 110, 130, 150, 500),
                                   include.lowest = T,
                                   labels = c("< 50%", "51 - 70%", "71 - 90%", "91 - 110%",
                                              "111 - 130%", "131 - 150%", "> 151%"))

      PerCol <- leaflet::colorFactor(palette = "RdYlBu", df$Percent_Normal_Bin)
      colours <- colorRampPalette(c("red", "yellow", "blue"))(n = 8)

      return(df)
    })

    # MAP RENDERING - only render basemap once vs each time a year is selected
    output$snow_map <- renderLeaflet({
      #print(paste("output$snow_map RENDERING - snow_data rows:", nrow(snow_data()), "map_text language:", isolate(language()), "at", Sys.time()))
      req(snow_data())
      req(map_text())
      map_text <- isolate(map_text()) # isolate to evaluate once per render and prevent duplicate rendering
      df <- snow_data()

      PerCol <- leaflet::colorFactor(palette = "RdYlBu", df$Percent_Normal_Bin)

      # Return empty map for years with no data
      if(nrow(df) == 0) {
        leaflet() %>%
          addTiles() %>%
          setView(lng = -125, lat = 63, zoom = 4) %>%
          addProviderTiles(providers$CartoDB.Positron, group = map_text()$base_maps$cartodb) %>%
          addProviderTiles(providers$Esri.WorldImagery, group = map_text()$base_maps$esri) %>%
          addPolylines(data = mackenzie_basin, weight = 2, color = "black", opacity = 0.8, group = map_text()$basins$mackenzie) %>%
          addPolylines(data = slave, weight = 2, color = "black", opacity = 0.8, group = map_text()$basins$slave) %>%
          addPolylines(data = peel, weight = 2, color = "black", opacity = 0.8, group = map_text()$basins$peel) %>%
          addPolylines(data = hay, weight = 2, color = "black", opacity = 0.8, group = map_text()$basins$hay) %>%
          addPolylines(data = liard, weight = 2, color = "black", opacity = 0.8, group = map_text()$basins$liard) %>%
          addLayersControl(
            overlayGroups = c(map_text()$basins$mackenzie, map_text()$basins$slave, map_text()$basins$liard, map_text()$basins$peel, map_text()$basins$hay),
            baseGroups = c(map_text()$base_maps$cartodb, map_text()$base_maps$esri),
            options = layersControlOptions(collapsed = TRUE)
          ) %>%
          addControl(
            html = paste("<div style='padding: 0.5px; background-color: white; opacity: 0.6; border-radius: 0.5px; font-size: 10px;'>", map_text()$last_updated, "</div>"),
            position = "bottomleft",
            className = "last-updated-control"
          )
      } else {
        leaflet() %>%
          addTiles() %>%
          setView(lng = -125, lat = 63, zoom = 4) %>%
          addProviderTiles(providers$CartoDB.Positron, group = map_text()$base_maps$cartodb) %>%
          addProviderTiles(providers$Esri.WorldImagery, group = map_text()$base_maps$esri) %>%
          addPolylines(data = mackenzie_basin, weight = 2, color = "black", opacity = 0.8, group = map_text()$basins$mackenzie) %>%
          addPolylines(data = slave, weight = 2, color = "black", opacity = 0.8, group = map_text()$basins$slave) %>%
          addPolylines(data = peel, weight = 2, color = "black", opacity = 0.8, group = map_text()$basins$peel) %>%
          addPolylines(data = hay, weight = 2, color = "black", opacity = 0.8, group = map_text()$basins$hay) %>%
          addPolylines(data = liard, weight = 2, color = "black", opacity = 0.8, group = map_text()$basins$liard) %>%
          addCircleMarkers(
            data = df,
            color = "black",
            fillColor = ~PerCol(Percent_Normal_Bin),
            lat = ~Lat, lng = ~Long,
            radius = 7, label = ~Site,
            weight = 1, opacity = 0.8, fillOpacity = 0.8,
            popup = ~paste0(
              map_text()$popup$percent_avg, ": ", round(Percent_Normal, 1), "<br>",
              map_text()$popup$swe, ": ", round(Current_SWE, 1), "<br>",
              map_text()$popup$snow_depth, ": ", round(Current_Depth, 1), "<br>",
              map_text()$popup$years_record, ": ", Length_Total
            )
          ) %>%
          addLayersControl(
            overlayGroups = c(map_text()$basins$mackenzie, map_text()$basins$slave, map_text()$basins$liard, map_text()$basins$peel, map_text()$basins$hay),
            baseGroups = c(map_text()$base_maps$cartodb, map_text()$base_maps$esri),
            options = layersControlOptions(collapsed = TRUE)
          ) %>%
          addLegend(
            'bottomright',
            pal = PerCol,
            values = df$Percent_Normal_Bin,
            title = map_text()$legend$title,
            opacity = 1
          ) %>%
          addControl(
            html = paste("<div style='padding: 0.5px; background-color: white; opacity: 0.6; border-radius: 0.5px; font-size: 10px;'>", map_text()$last_updated, "</div>"),
            position = "bottomleft",
            className = "last-updated-control"
          )
      }
    })

  })
}
