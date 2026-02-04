# metadata module for snow app

# UI function for metadata module
metadataUI <- function(id) {
  ns <- NS(id)
  tagList(
    # Add a div with specific CSS
    tags$style(HTML("
  #map, #metadata-metadata_map {
    height: calc(100vh - 90px) !important;
    width: 100% !important;
    position: absolute;
    top: 60px;
    left: 0;
    right: 0;
    bottom: 30px;
    z-index: 1;
  }
  /* Only apply to metadata map popups - using class added by JavaScript */
  .metadata-popup .leaflet-popup-content-wrapper {
    font-size: 16px !important;
    width: fit-content !important;
    min-width: 600px !important;
    max-width: 800px !important;
  }
  .metadata-popup .leaflet-popup-content {
    font-size: 16px !important;
    line-height: 1.5 !important;
    margin: 12px 16px !important;
    width: 100% !important;
    box-sizing: border-box !important;
  }
  .metadata-popup .leaflet-popup-tip{
  display: none !important;
  }
  .metadata-popup .metadata-table {
    width: 100%;
    border-collapse: collapse;
    margin-top: 6px;
  }
  .metadata-popup .metadata-table td {
    padding: 6px 10px 6px 0;
    vertical-align: top;
  }
  .metadata-popup .metadata-table td:first-child {
    font-weight: bold;
    color: #333;
    width: 30%;
  }
  .metadata-popup .metadata-table td:last-child {
    padding-left: 0;
    color: #555;
    word-wrap: break-word;
    white-space: normal;
  }
  .metadata-popup .metadata-table tr {
    border-bottom: 1px solid #eee;
  }
  .metadata-popup .metadata-table tr:last-child {
    border-bottom: none;
  }
  .metadata-popup .metadata-header {
    font-weight: bold;
    margin-bottom: 8px;
    font-size: 18px;
    border-bottom: 2px solid #2699D5;
    padding-bottom: 4px;
    color: #0066cc;
  }
  .leaflet-control-zoom {
    position: fixed !important;
    bottom: 80px !important;
    left: 10px !important;
    top: auto !important;
    z-index: 1000 !important;
  }
")),

    # Map output
    leafletOutput(ns("metadata_map"), height = "100%"),

    # panel for year selector
    absolutePanel(
      id = ns("metadata_controls"),
      class = "floating-panel",
      fixed = TRUE,
      draggable = TRUE,
      top = 70,
      left = 20,

      # Year selection type
      uiOutput(ns("year_selection_label")),
      radioButtons(
        ns("year_selection_type"),
        label = NULL,
        choices = list("All Sites" = "all", "Single Year" = "single", "Year Range" = "range"),
        selected = "all"
      ),
      # Conditional UI for year selection
      uiOutput(ns("year_selector_ui"))
    ),
    create_info_panel_UI(ns)
  )
}

# Server function for metadata module - french - add language to server fun
metadataServer <- function(id, language, preloaded_data) {
  moduleServer(id, function(input, output, session) {

    # for info panel / welcome modal keep info
    setup_info_panel_server(input, output, session, language)

    # DATA LOADING
    # load shapefiles
    if (!is.null(preloaded_data()$mackenzie_basin)) {
      nwt_boundary <- preloaded_data()$nwt_boundary
      mackenzie_basin <- preloaded_data()$mackenzie_basin
      slave <- preloaded_data()$slave
      snare <- preloaded_data()$snare
      YKriver <- preloaded_data()$YKriver
      peel <- preloaded_data()$peel
      hay <- preloaded_data()$hay
      liard <- preloaded_data()$liard
    } else {
      nwt_boundary <- load_github_rdsshp("NWT_ENR_BND_FND.rds")
      mackenzie_basin <- load_github_rdsshp("MackenzieRiverBasin_FDA.rds")
      slave <- load_github_rdsshp("07NC005_DrainageBasin_BassinDeDrainage.rds")
      snare <- load_github_rdsshp("07SA001_DrainageBasin_BassinDeDrainage.rds")
      YKriver <- load_github_rdsshp("07SB002_DrainageBasin_BassinDeDrainage.rds")
      peel <- load_github_rdsshp("10MC002_DrainageBasin_BassinDeDrainage.rds")
      hay <- load_github_rdsshp("07OB001_DrainageBasin_BassinDeDrainage.rds")
      liard <- load_github_rdsshp("10ED002_DrainageBasin_BassinDeDrainage.rds")
    }
    # load data and update site names if preload fails
    if (!is.null(preloaded_data()$md_3)) {
      md_3 <- preloaded_data()$md_3
    } else {
      md_3 <- readRDS("data/snow_data.rds")
    }
    data <- md_3

    # site year summary - for mapping surveyed sites given selected year(s)
    site_year_summary <- md_3 %>%
      group_by(site, year) %>%
      summarise(
        has_swe = any(!is.na(swe_cm)),
        has_depth = any(!is.na(snow_depth_cm)),
        # add metadata columns
        latitude = first(na.omit(latitude)),
        longitude = first(na.omit(longitude)),
        elevation = first(na.omit(elevation)),
        region = first(na.omit(region)),
        catchment = first(na.omit(catchment)),
        catchment_reference = first(na.omit(catchment_reference)),
        ecological_region = first(na.omit(ecological_region)),
        activity = first(na.omit(activity)),
        site_notes = first(na.omit(site_notes)),
        .groups = 'drop'
      ) %>%
      mutate(
        variables_measured = case_when(
          has_swe & has_depth ~ "SWE and Snow depth",
          has_swe ~ "SWE",
          has_depth ~ "Snow depth",
          TRUE ~ "NA"
        )
      ) %>%
      arrange(site, year)

     available_years <- sort(unique(site_year_summary$year[site_year_summary$has_swe == TRUE | site_year_summary$has_depth == TRUE]), decreasing = TRUE)

    # site metadata
    site_metadata <- site_year_summary %>%
      filter(has_swe == TRUE | has_depth == TRUE) %>%
      group_by(site) %>%
      summarise(
        # metadata cols
        latitude = first(na.omit(latitude)),
        longitude = first(na.omit(longitude)),
        elevation = first(na.omit(elevation)),
        region = first(na.omit(region)),
        catchment = first(na.omit(catchment)),
        catchment_reference = first(na.omit(catchment_reference)),
        ecological_region = first(na.omit(ecological_region)),
        activity = first(na.omit(activity)),
        # variables measured
        has_swe_ever = any(has_swe),
        has_depth_ever = any(has_depth),
        # computed fields
        record_length = n(),
        min_year = min(year),
        max_year = max(year),
        .groups = 'drop'
      ) %>%
      mutate(
        date_range = ifelse(min_year == max_year, min_year,
                            paste0(min_year, "-", max_year)),
        variables_measured = case_when(
          has_swe_ever & has_depth_ever ~ "SWE and Snow depth",
          has_swe_ever ~ "SWE",
          has_depth_ever ~ "Snow depth",
          TRUE ~ "NA"
        )
      )

    sites <- site_metadata

    # REACTIVE EXPRESSIONS
filtered_sites <- reactive({
  req(input$year_selection_type) #single, range or all

  if(input$year_selection_type == "all") {
    sites$has_data_in_selection <- TRUE
    return(sites)
  }

  if(input$year_selection_type == "single") {
    req(input$selected_year)
    selected_years <- input$selected_year
  } else if(input$year_selection_type == "range") {
    req(input$start_year, input$end_year)
    selected_years <- input$start_year:input$end_year
  }

  #use site year summ df (pre-computed)
  sites_with_data <- site_year_summary %>%
    filter(year %in% selected_years, (has_swe == TRUE | has_depth == TRUE)) %>%
    distinct(site) %>%
    pull(site)

  sites$has_data_in_selection <- sites$site %in% sites_with_data

  # get variables measured for selected year(s)
  if(input$year_selection_type == "single") {
    # get variables for single year selection
    selected_variables <- site_year_summary %>%
      filter(site %in% sites_with_data, year %in% selected_years) %>%
      distinct(site, .keep_all = TRUE) %>%
      select(site, variables_measured)
  } else {
    # get variables for year range
    selected_variables <- site_year_summary %>%
      filter(site %in% sites_with_data, year %in% selected_years) %>%
      group_by(site) %>%
      summarise(
        variables_measured = case_when(
          any(variables_measured == "SWE and Snow depth") ~ "SWE and Snow depth", # if both are anywhere
          n_distinct(variables_measured) == 1 ~ first(variables_measured),  # if values are all uniform
          any(variables_measured == "SWE") & any(variables_measured == "Snow depth") ~ "SWE and Snow depth",  # Both appear
          any(variables_measured == "SWE") ~ "SWE", #fallback - if only one is present
          any(variables_measured == "Snow depth") ~ "Snow depth", # fallback - if only snow depth is present
          TRUE ~ "NA"
        ),
        .groups = 'drop'
      )
  }

  # Merge variables_measured back to sites
  sites <- sites %>%
    left_join(selected_variables, by = "site") %>%
    mutate(variables_measured = coalesce(variables_measured.y, variables_measured.x)) %>%
    select(-variables_measured.x, -variables_measured.y)


  return(sites)
})

    map_text <- reactive({
      req(language())
      if(language() == "fr") {
        list(
          basins = list(
            nwt_boundary = "Frontière des TNO",
            mackenzie = "Bassin du Mackenzie",
            slave = "Bassin de la rivière des Esclaves",
            snare = "Bassin de la rivière Snare",
            YKriver = "Bassin de la rivière Yellowknife",
            peel = "Bassin de la rivière Peel",
            hay = "Bassin de la rivière au Foin",
            liard = "Bassin de la rivière Liard"
          ),
          base_maps = list(
            cartodb = "Carte Simple",
            esri = "Carte Satellite"
          ),
          popup = list(
            site = "Nom du site",
            record_length = "Longeur d'enregistrement",
            date_range = "Plage de dates",
            variables_measured = "Variables mesurées",
            elevation = "Élévation",
            longitude = "Longitude",
            latitude = "Latitude",
            nwt_region = "Région des TNO",
            catchment = "Bassin versant",
            ecological_region = "Région écologique"
          ),
          year_selection = list(
            label = "Filtrer par:",
            choices = list(
              "Toutes les sites" = "all",
              "Année unique" = "single",
              "Plage d'années" = "range"
            )
          ),
          legend = list(
            title = "Légende",
            surveyed = "Relevés",
            not_surveyed = "Non relevés"
          ),
          year_range_note = "Note : Les sites indiqués comme relevés (en bleu) ont des données pour au moins une année de la plage sélectionnée "
        )
      } else {
        list(
          basins = list(
            nwt_boundary = "NWT boundary",
            mackenzie = "Mackenzie Basin",
            slave = "Slave Basin",
            snare = "Snare Basin",
            YKriver = "Yellowknife River Basin",
            peel = "Peel Basin",
            hay = "Hay Basin",
            liard = "Liard Basin"
          ),
          base_maps = list(
            cartodb = "Simple Map",
            esri = "Satellite Map"
          ),
          popup = list(
            site = "Site Name",
            record_length = "Record Length",
            date_range = "Date range",
            variables_measured = "Variables measured",
            elevation = "Elevation",
            longitude = "Longitude",
            latitude = "Latitude",
            nwt_region = "NWT Region",
            catchment = "Catchment",
            ecological_region = "Ecological Region"
          ),
          year_selection = list(
            label = "Filter By:",
            choices = list(
              "All Sites" = "all",
              "Single Year" = "single",
              "Year Range" = "range"
            )
          ),
          legend = list(
            title = "Legend",
            surveyed = "Surveyed",
            not_surveyed = "Not surveyed"
          ),
          year_range_note = "Note: Sites marked as surveyed (in blue) have data from at least one year in the selected range "
        )
      }
    })

    output$year_selection_label <- renderUI({
      req(map_text())
      tags$strong(
        style = "display: block; margin-bottom: 10px;",
        map_text()$year_selection$label
      )
    })

    # radioButtons when language changes
    observe({
      req(map_text())
      req(input$year_selection_type)

      updateRadioButtons(
        session,
        "year_selection_type",
        label = NULL,
        choices = map_text()$year_selection$choices,
        selected = isolate(input$year_selection_type)
      )
    })

    # legend when year selection changes
    observe({
      req(input$year_selection_type)
      req(map_text())

      leafletProxy(session$ns("metadata_map"), session) %>%
        clearControls()

      if(input$year_selection_type %in% c("single", "range")) {
        legend_html <- paste0(
          "<div style='background: white; padding: 10px; border-radius: 5px; font-size: 14px;'>",
          "<strong>", map_text()$legend$title, "</strong><br/>",
          "<div style='margin-top: 8px;'>",
          "<span style='display: inline-block; width: 12px; height: 12px; border-radius: 50%; background-color: #3388ff; border: 1px solid black; margin-right: 8px;'></span>",
          map_text()$legend$surveyed, "<br/>",
          "<span style='display: inline-block; width: 12px; height: 12px; border-radius: 50%; background-color: #666666; border: 1px solid black; margin-right: 8px; margin-top: 5px;'></span>",
          map_text()$legend$not_surveyed,
          "</div>",
          "</div>"
        )

        leafletProxy(session$ns("metadata_map"), session) %>%
          addControl(
            html = legend_html,
            position = "bottomright"
          )
      }
    })

    # year selector ui
    output$year_selector_ui <- renderUI({
      req(input$year_selection_type)
      req(language())
      req(map_text())

      if(input$year_selection_type == "all") {
        return(NULL)
      }

      if(input$year_selection_type == "single") {
        selectInput(
          session$ns("selected_year"),
          label = if(language() == "fr") "Année:" else "Select Year:",
          choices = available_years,
          selected = max(available_years)
        )
      } else if(input$year_selection_type == "range") {
        tagList(
          selectInput(
            session$ns("start_year"),
            label = if(language() == "fr") "Année de début:" else "Start Year:",
            choices = available_years,
            selected = min(available_years)
          ),
          selectInput(
            session$ns("end_year"),
            label = if(language() == "fr") "Année de fin:" else "End Year:",
            choices = available_years,
            selected = max(available_years)
          ),
          tags$div(
            style = "font-size: 12px; colour: #6b7280; font-style: italic; margin-top 6px; line-height: 1.3;",
            map_text()$year_range_note
          )
        )
      }
    })

    # MAP RENDERING - only render basemap once vs each time a year is selected
    output$metadata_map <- renderLeaflet({
      req(map_text())
      req(filtered_sites())
      map_text <- isolate(map_text()) # isolate to evaluate once per render and prevent duplicate rendering
      meta_df <- filtered_sites()
      # Create popup content
      popup_content <- paste0(
        "<div style='font-family: Arial, sans-serif;'>",
        "<div class='metadata-header'>", meta_df$site, "</div>",
        "<table class='metadata-table'>",
        #"<tr><td>", map_text()$popup$activity, ":</td><td>", ifelse(meta_df$activity %in% names(activity_labels), activity_labels[meta_df$activity], meta_df$activity), "</td></tr>",
        "<tr><td>", map_text()$popup$record_length, ":</td><td>",
        #ifelse(is.na(meta_df$record_length), "0", meta_df$record_length), " years</td></tr>",
        ifelse(is.na(meta_df$record_length),
               "0",
               paste0(meta_df$record_length, ifelse(meta_df$record_length == 1, " year", " years"))),
        "</td></tr>",

        "<tr><td>", map_text()$popup$date_range, ":</td><td>",
        ifelse(is.na(meta_df$date_range), "No data", meta_df$date_range), "</td></tr>",
        "<tr><td>", map_text()$popup$variables_measured, ":</td><td>",
        ifelse(is.na(meta_df$variables_measured), "NA", meta_df$variables_measured), "</td></tr>",
        "<tr><td>", map_text()$popup$longitude, ":</td><td>", round(meta_df$longitude, 4), "</td></tr>",
        "<tr><td>", map_text()$popup$latitude, ":</td><td>", round(meta_df$latitude, 4), "</td></tr>",
        "<tr><td>", map_text()$popup$elevation, ":</td><td>", round(meta_df$elevation, 1), " m</td></tr>",
        "<tr><td>", map_text()$popup$nwt_region, ":</td><td>", meta_df$region, "</td></tr>",
        "<tr><td>", map_text()$popup$catchment, ":</td><td>", meta_df$catchment, "</td></tr>",
        "<tr><td>", map_text()$popup$ecological_region, ":</td><td>", meta_df$ecological_region, "</td></tr>",
        "</table>",
        "</div>"
      )

      map <- leaflet() %>%
          addTiles() %>%
          setView(lng = -123, lat = 63.7, zoom = 4.5) %>%
          addProviderTiles(providers$CartoDB.Positron, group = map_text()$base_maps$cartodb) %>%
          addProviderTiles(providers$Esri.WorldImagery, group = map_text()$base_maps$esri) %>%
          addPolylines(data = nwt_boundary, weight = 2, color = "#000000", opacity = 0.8, group = map_text()$basins$nwt_boundary) %>%
          addPolylines(data = mackenzie_basin, weight = 2, color = "#888888", opacity = 0.8, group = map_text()$basins$mackenzie) %>%
          addPolylines(data = slave, weight = 2, color = "#999999", opacity = 0.8, group = map_text()$basins$slave) %>%
          addPolylines(data = snare, weight = 2, color = "#999999", opacity = 0.8, group = map_text()$basins$snare) %>%
          addPolylines(data = YKriver, weight = 2, color = "#999999", opacity = 0.8, group = map_text()$basins$YKriver) %>%
          addPolylines(data = peel, weight = 2, color = "#999999", opacity = 0.8, group = map_text()$basins$peel) %>%
          addPolylines(data = hay, weight = 2, color = "#999999", opacity = 0.8, group = map_text()$basins$hay) %>%
          addPolylines(data = liard, weight = 2, color = "#999999", opacity = 0.8, group = map_text()$basins$liard) %>%
          addCircleMarkers(
            data = meta_df,
            color = "black",
            fillColor = ifelse(meta_df$has_data_in_selection, "#3388ff", "#666666"),
            lat = ~latitude, lng = ~longitude,
            radius = 7, label = ~site,
            weight = 1,
            opacity = ifelse(meta_df$has_data_in_selection, 0.8, 0.4),
            fillOpacity = ifelse(meta_df$has_data_in_selection, 0.8, 0.4),
            popup = popup_content,
            popupOptions = popupOptions(autoPan = TRUE)
            )%>%
          addLayersControl(
            overlayGroups = c(map_text()$basins$nwt_boundary,map_text()$basins$mackenzie, map_text()$basins$slave, map_text()$basins$snare, map_text()$basins$YKriver,map_text()$basins$liard, map_text()$basins$peel, map_text()$basins$hay),
            baseGroups = c(map_text()$base_maps$cartodb, map_text()$base_maps$esri),
            options = layersControlOptions(collapsed = TRUE)
          )
        # Add legend only for single year or year range
        if(input$year_selection_type %in% c("single", "range")) {
          legend_html <- paste0(
            "<div style='background: white; padding: 10px; border-radius: 5px; font-size: 14px;'>",
            "<strong>", map_text()$legend$title, "</strong><br/>",
            "<div style='margin-top: 8px;'>",
            "<span style='display: inline-block; width: 12px; height: 12px; border-radius: 50%; background-color: #3388ff; border: 1px solid black; margin-right: 8px;'></span>",
            map_text()$legend$surveyed, "<br/>",
            "<span style='display: inline-block; width: 12px; height: 12px; border-radius: 50%; background-color: #666666; border: 1px solid black; margin-right: 8px; margin-top: 5px;'></span>",
            map_text()$legend$not_surveyed,
            "</div>",
            "</div>"
          )

          map <- map %>%
            addControl(
              html = legend_html,
              position = "bottomright"
            )
        }

        map %>%
          htmlwidgets::onRender("
  function(el, x) {
    var map = this;
    map.on('popupopen', function(e) {
      var popup = e.popup.getElement();
      if (popup) {
        // Add class to the popup element itself
        popup.classList.add('metadata-popup');
        // Also add to the wrapper for CSS targeting
        var wrapper = popup.querySelector('.leaflet-popup-content-wrapper');
        if (wrapper) {
          wrapper.classList.add('metadata-popup-wrapper');
        }
      }
    });
  }
")
    })
    # sub-basins toggled off by default
    observe({
      # Trigger when map is ready OR when year changes (map re-renders)
      req(map_text())
      # isolate (to prevent infinite loops)
      isolate({
        map_text <- map_text()
        # Small delay to ensure map is fully rendered
        Sys.sleep(0.1)
        leafletProxy(session$ns("metadata_map"), session) %>%
          hideGroup(c(
            map_text()$basins$slave,
            map_text()$basins$snare,
            map_text()$basins$YKriver,
            map_text()$basins$liard,
            map_text()$basins$peel,
            map_text()$basins$hay
          ))
      })
    })

  })
}




