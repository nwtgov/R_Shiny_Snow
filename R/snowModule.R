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

      .info-panel {
        background-color: white;
        padding: 15px;
        border-radius: 5px;
        box-shadow: 0 0 15px rgba(0,0,0,0.2);
        max-width: 300px;
        max-height: 200px;
        overflow-y: auto;
        z-index: 2;
        font-size: 12px;
        display: none;  /* Hidden by default */
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

      # year selection
      selectInput(ns("snow_year"), "Select Year:", choices = NULL),

       # added by MA July 2025 - french - uiOutput for snow_controls_content (created in server)
      uiOutput(ns("snow_controls_content"))

    ),

    absolutePanel(
      id = ns("info_panel"),
      class = "info-panel",
      fixed = TRUE,
      draggable = TRUE,
      bottom = 20,
      left = 20,

# added - french - use uiOutput for ino_panel_content (created in server)
uiOutput(ns("info_panel_content"))
      )
    )
}

# Server function for snow module - french - add language to server fun
snowServer <- function(id, first_visits, language, preloaded_data) {
  moduleServer(id, function(input, output, session) {

    create_info_content <- function(lang) {
      if(lang == "fr") {
        HTML("<div style='font-weight: bold; font-size: 14px; margin-bottom: 10px;'>
          Les relevés nivométriques sont collectées à partir de diverses stations de surveillance dans les TNO.
        </div>
           <div style='font-size: 13px; font-weight: bold; margin-bottom: 8px;'>Interprétation des données:</div>
             <ul style='padding-left: 15px; margin-top: 5px;'>
          <li><strong>Couleurs des stations:</strong> Indiquent l'équivalent en eau de la neige (EEN) en pourcentage de la normale:
            <ul style='padding-left: 15px; margin-top: 5px;'>
              <li><strong>Bleu:</strong> Supérieure à la normale</li>
              <li><strong>Jaune:</strong> Près de la normale</li>
              <li><strong>Rouge:</strong> Inférieur à la normale</li>
            </ul>
          </li>
          <li><strong>Cliquez sur les stations</strong> pour voir des informations détaillées sur:
            <ul style='padding-left: 15px; margin-top: 5px;'>
              <li>Équivalent en eau de la neige (EEN)</li>
              <li>Épaisseur de neige (NaN = aucune mesure)</li>
              <li>Pourcentage de la normale</li>
            </ul>
          </li>
        </ul>
      ")
      } else {
        HTML("<div style='font-weight: bold; font-size: 14px; margin-bottom: 10px;'>
          Snow data are collected from various monitoring stations across the NWT.
        </div>
           <div style='font-size: 13px; font-weight: bold; margin-bottom: 8px;'>Data interpretation:</div>
             <ul style='padding-left: 15px; margin-top: 5px;'>
          <li><strong>Station Colors:</strong> Indicate snow water equivalent (SWE) as a percentage of normal:
            <ul style='padding-left: 15px; margin-top: 5px;'>
              <li><strong>Blue:</strong> Above normal</li>
              <li><strong>Yellow:</strong> Near normal</li>
              <li><strong>Red:</strong> Below normal</li>
            </ul>
          </li>
          <li><strong>Click stations</strong> to see detailed information about:
            <ul style='padding-left: 15px; margin-top: 5px;'>
              <li>Snow Water Equivalent (SWE)</li>
              <li>Snow Depth (NaN = no measurements)</li>
              <li>Percent of Normal</li>
            </ul>
          </li>
        </ul>
      ")
      }
    }

    # REACTIVE EXPRESSIONS
    map_text <- reactive({
      req(language())
      if(language() == "fr") {
        list(
          last_updated = paste0("<strong>Dernière mise à jour:</strong> ", max_snow_date),
          basins = list(
            mackenzie = "Bassin du Mackenzie",
            slave = "Bassin de la rivière des Esclaves",
            peel = "Bassin de la rivière Peel",
            hay = "Bassin de la rivière au Foin",
            liard = "Bassin de la rivière Liard"
          ),
          base_maps = list(
            cartodb = "CartoDB Positron",
            esri = "ESRI World"
          ),
          legend = list(
            title = paste0("Équivalent en eau de la neige <br> Printemps (", input$snow_year, ") <br> EEN (mm)")
          ),
          popup = list(
            percent_avg = "Pourcentage de la normale (%)",
            swe = "EEN (mm)",
            snow_depth = "Épaisseur de neige (cm)",
            years_record = "Nombre d'années avec données"
          )
        )
      } else {
        list(
          last_updated = paste0("<strong>Last updated:</strong> ", max_snow_date),
          basins = list(
            mackenzie = "Mackenzie Basin",
            slave = "Slave Basin",
            peel = "Peel Basin",
            hay = "Hay Basin",
            liard = "Liard Basin"
          ),
          base_maps = list(
            cartodb = "CartoDB Positron",
            esri = "ESRI World"
          ),
          legend = list(
            title = paste0("Snow Water Equivalent <br> Spring (", input$snow_year, ") <br> SWE (mm)")
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


    # MODAL LOGIC
    observe({
      req(first_visits$snow)
      modal_title <- if(language() == "fr") "Information sur les données nivométriques" else "Snow Data Information"
      showModal(modalDialog(
        title = modal_title,
        create_info_content(language()),  # Use the helper function
        easyClose = TRUE,
        footer = tagList(
          modalButton(if(language() == "fr") "Compris!" else "Got it!"),
          actionButton(session$ns("keep_info"),
                       if(language() == "fr") "Garder l'info visible" else "Keep info visible")
        )
      ))
      first_visits$snow <- FALSE
    })

    # trigger map to start rendering even while modal and info pop up is open
    observe({
      req(language())
    })


    # OUTPUTS AND UI
    output$info_panel_content <- renderUI({
      req(language())
      create_info_content(language())
    })

    # Handle the keep info button
    observeEvent(input$keep_info, {
      removeModal()
      # Get the ID with proper namespacing
      info_panel_id <- paste0("#", session$ns("info_panel"))
      # Use JavaScript to show the panel
      shinyjs::runjs(sprintf("document.querySelector('%s').style.display = 'block';", info_panel_id))
    })

    observe({
      req(language())
      updateSelectInput(session, "snow_year",
                        label = if(language() == "fr") "Année:" else "Select Year:")
    })

    # controls content - warnings and refresh button
    output$snow_controls_content <- renderUI({
      req(language())  # Wait for language selection
      tagList(
        uiOutput(session$ns("year_warning")),

        actionButton(session$ns("refresh"),
                     if(language() == "fr") "Actualiser" else "Refresh Data")
      )
    })

    # make year warning text dynamic - for years where no snow surveys were conducted
    output$year_warning <- renderUI({
      req(input$snow_year)

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

    # DATA LOADING - moved this up and out of reactive contexts
    mackenzie_basin <- readRDS("data/MackenzieRiverBasin_FDA.rds")

    slave <- readRDS("data/07NC005_DrainageBasin_BassinDeDrainage.rds")

    peel <- readRDS("data/10MC002_DrainageBasin_BassinDeDrainage.rds")

    hay <- readRDS("data/07OB001_DrainageBasin_BassinDeDrainage.rds")

    liard <- readRDS("data/10ED002_DrainageBasin_BassinDeDrainage.rds")

    #md_3 <- readRDS("data/md_3.rds")
    md_3 <- preloaded_data()$md_3
    max_snow_date <- format(max(md_3$date_time, na.rm = TRUE), "%Y-%m-%d")

    # Get available years from md_3
    available_years <- sort(unique(md_3$year), decreasing = TRUE)

    # Update year choices
    observe({
      updateSelectInput(session, "snow_year",
                        choices = available_years,
                        selected = max(available_years))
  })

    # Added by MA - May 15, 2025
    # Create reactive expression for data processing
    snow_data <- reactive({
      req(input$snow_year)
      year <- input$snow_year

      #year <- if(is.null(input$snow_year)) max(available_years) else input$snow_year

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
                            flags = c("Y", "HS"), # note - open report removed "Y" data flags
                            act="A",
                            hdensity_sd  = 3,  # standard deviations for upper bound - should be 3
                            ldensity_sd  = 2,  #  standard deviations for lower bound - should be 2
                            ldensity_limit  = 0.1,  # should be 0.1
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
      req(snow_data())
      req(map_text())
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
            options = layersControlOptions(collapsed = FALSE)
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
            options = layersControlOptions(collapsed = FALSE)
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


