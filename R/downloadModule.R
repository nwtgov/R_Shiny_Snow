# UI function for download module
downloadUI <- function(id) {
  ns <- NS(id)

  fluidPage(
    # Add some padding and styling
    tags$head(
      tags$style(HTML("
        .download-container {
          padding: 20px;
          max-width: 800px;
          margin: 0 auto;
        }
        .download-controls-section {
          background-color: #f8f9fa;
          padding: 20px;
          border-radius: 5px;
          border-left: 4px solid #0066cc;
          margin-bottom: 20px;
          margin-top: 20px;
          box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        .disclaimer-section {
          background-color: transparent;
          padding: 20px 0;
          border-radius: 0;
          border-left: none;
          margin-bottom: 20px;
          font-size: 14px;
        }
          .modal-dialog.modal-lg {
            max-height: 90vh;
            margin: 1.75rem auto;
          }
          .modal-content {
            max-height: 90vh;
            display: flex;
            flex-direction: column;
          }
          .modal-body {
            max-height: calc(90vh - 120px);
            overflow-y: auto;
            overflow-x: hidden;
          }
          .modal-header {
            flex-shrink: 0;
          }
        .flag-table {
          width: 100%;
          border-collapse: collapse;
          margin-top: 10px;
        }
        .flag-table th, .flag-table td {
          border: 1px solid #ddd;
          padding: 8px;
          text-align: left;
        }
        .flag-table th {
          background-color: #f8f9fa;
        }
        .flag-link {
          color: #0066cc;
          text-decoration: underline;
          cursor: pointer;
        }
        .flag-link:hover {
          color: #004c99;
        }
      ")),
      # javascript for the modal
      tags$script(HTML("
        $(document).on('click', '.flag-link#show_flags', function() {
          $('#flag_modal').modal('show');
        });
        $(document).on('click', '.flag-link#show_instruments', function() {
          $('#instrument_modal').modal('show');
        });
        $(document).on('click', '.flag-link#show_column_names', function() {
          $('#column_modal').modal('show');
        });
      "))
    ),

    div(class = "download-container",
        div(class = "download-controls-section",
            uiOutput(ns("download_controls"))
        ),
        div(class = "disclaimer-section",
            uiOutput(ns("disclaimer_content"))
            ),
        uiOutput(ns("flag_modal_content")),
        uiOutput(ns("instrument_modal_content")),
        uiOutput(ns("column_modal_content"))
    ),
    create_info_panel_UI(ns)
  )
}

# Server function for download module
downloadServer <- function(id, first_visits, station_data_types, language, preloaded_data) {
  moduleServer(id, function(input, output, session) {

    setup_info_panel_server(input, output, session, language)

    # bring in preloaded data
    #md_3 <- preloaded_data()$md_3
    if (!is.null(preloaded_data()$md_3)) {
      md_3 <- preloaded_data()$md_3
    } else {
      md_3 <- readRDS("data/md_3.rds")
      md_3 <- update_site_names(md_3)
    }

    all_sites <- sort(unique(md_3$site))
    all_years <- sort(unique(md_3$year))

    # render disclaimer and dataflag modal reactively
    output$disclaimer_content <- renderUI({
      req(language())
      create_disclaimer_content(language())
    })

    output$flag_modal_content <- renderUI({
      req(language())
      create_flag_modal_content(language())
    })

    output$column_modal_content <- renderUI({
      req(language())
      create_column_modal_content(language())
    })

    output$instrument_modal_content <- renderUI({
      req(language())
      create_instrument_modal_content(language())
    })


    # download controls
    output$download_controls <- renderUI({
      req(language())

      # get available sites and years
      all_sites <- sort(unique(md_3$site))
      all_years <- sort(unique(md_3$year), decreasing = FALSE)

      tagList(
        tags$div(
          style = "margin-bottom: 14px;",
          HTML(
            if (language() == "fr"){
              "<h2 style='font-size: 22px; font-weight: bold; margin-bottom: 20px; margin-top: 0; padding: 0; color: #000000;'>Télécharger des données nivométriques</h2>
              Recherchez un site en entrant un nom complet ou partiel. Sélectionnez votre plage d’années, puis cliquez sur Télécharger les données.<br/>"
            }else{
              "<h2 style='font-size: 22px; font-weight: bold; margin-bottom: 20px; margin-top: 0; padding: 0; color: #000000;'>Download Snow Data</h2>
              Search for a site by typing the full or partial site name. Select your date range, and click Download Data.<br/>"
            }
          )
        ),

        # site seach and date range inputs as grid
        tags$div(
          style = "display: grid; grid-template-columns: 160px 1fr; row-gap: 12px; align-items: center;",

          # Searchable site input (row 1)
          tags$div(
            style = "grid-column: 1;",
            tags$strong(if (language() == "fr") "Sélectionner le site" else "Select Site")
          ),
          tags$div(
            style = "grid-column: 2;",
            selectizeInput(
              session$ns("snow_site"),
              label = NULL,
              choices = all_sites,
              selected = character(0),
              options = list(
                placeholder = if (language() == "fr")
                  "Entrez le nom du site (complet ou partiel)"
                else
                  "Enter Full or Partial Site Name",
                maxItems = 1,
                create = FALSE,
                dropdownParent = 'body',
                selectOnTab = FALSE,
                onInitialize = I("function() { this.setValue(''); }")
              )
            )
          ),

          # Date range (row 2)
          tags$div(
            style = "display: grid; grid-template-columns: 160px 1fr; align-items: center; margin-bottom: 12px;",
            # Label column (aligns with "Select Site")
            tags$div(style = "grid-column: 1;",
                     tags$strong(if (language() == "fr") "Pour les années de" else "For years from")),
            # Controls column (same total width as site input)
            tags$div(
              style = "grid-column: 2; display: flex; align-items: center; justify-content: space-between;",
              # Start year (grow a bit to reduce middle gap)
              tags$div(
                style = "flex: 0 0 9.5em;",  # tweak 10–12em to taste
                selectInput(session$ns("start_year"), label = NULL, choices = all_years, selected = min(all_years), width = "100%")
              ),
              # Minimal middle text
              tags$span(style = "flex: 0 0 auto; margin: 0 11px;",
                        if (language() == "fr") "à" else "to"),
              # End year (same width; right edge aligns with site input)
              tags$div(
                style = "flex: 0 0 9.5em;",
                selectInput(session$ns("end_year"), label = NULL, choices = all_years, selected = max(all_years), width = "100%")
              )
            )
          ),
          # Row 3 — note on year selections
          tags$div(
            style = "grid-column: 2 / 3; width: 100%; font-size: 12px; font-style: italic; color: #6b7280; margin-top: 22px;",
            if (language() == "fr") {
              "Note : Les années s’ajustent selon les données disponibles pour le site sélectionné."
            } else {
              "Note: Years update based on available data for the selected site."
            }
          )
        ),

        # download and site year warning
        uiOutput(session$ns("site_year_warning")),
        tags$div(
          style = "display: flex; justify-content: flex-end; margin-top: 16px;",
          downloadButton(session$ns("download_snow"),
                         if(language() == "fr") "Télécharger des données" else "Download Data"
          )
        ),
        # add space between download button and disclaimer
        tags$div(style="height: 8px;")
      )
    })



    observeEvent(input$snow_site, {
      site_years <- md_3$year[md_3$site == input$snow_site]
      site_years <- sort(unique(site_years))
      if (!is.null(input$snow_site) && length(site_years) > 0) {
        updateSelectInput(session, "start_year", choices = site_years, selected = min(site_years))
        updateSelectInput(session, "end_year", choices = site_years, selected = max(site_years))
      }
    })

    output$site_year_warning <- renderUI({
      req(input$snow_site, input$start_year, input$end_year)
      start_y <- as.numeric(input$start_year)
      end_y   <- as.numeric(input$end_year)
      # guide for if invalid range
      if (is.na(start_y) || is.na(end_y) || start_y >= end_y) {
          div(
            style = "color: #d32f2f; font-size: 13px; margin-top: 10px;",
            if (language() == "fr") {
              "Aucune donnée disponible pour ce site et cette plage d'années - assurer que l'année de début est antérieure à l'année de fin."
            } else {
              "No data available for this site and date range - please make sure the start year is before the end year."
            }
          )
      } else {
        NULL
      }
})
      # disable download option when date range is invalid
      observe({
        req(input$snow_site, input$start_year, input$end_year)

        start_y <- as.numeric(input$start_year)
        end_y   <- as.numeric(input$end_year)

        valid_range <- !is.na(start_y) && !is.na(end_y) && start_y < end_y

        shinyjs::toggleState("download_snow", condition = valid_range)
      })


    # Load required data and source in functions
    #md_3 <- readRDS("data/md_3.rds")
    #md_3 <- preloaded_data()$md_3
    # Download snow data
    output$download_snow <- downloadHandler(
      filename = function() {
        year_range <- paste(input$start_year, input$end_year, sep = "-")
        if (language() == "fr") {
          paste0("données_nivometriques_",
                 gsub("[^A-Za-z0-9]", "_", input$snow_site), "_",
                 year_range, ".csv")
        } else {
          paste0("snow_data_",
                 gsub("[^A-Za-z0-9]", "_", input$snow_site), "_",
                 year_range, ".csv")
        }
      },
      content = function(file) {
        # Filter data for selected site and date range
        snow_data <- md_3 %>%
          dplyr::filter(
            site == input$snow_site,
            year >= as.numeric(input$start_year),
            year <= as.numeric(input$end_year)
          ) %>%
          arrange(year, date_time)

        #rename cols to match open report
        if(language() == "en") {
          snow_data <- rename_cols(snow_data)
        }

        if(language() == "fr") {
          snow_data <- snow_data %>%
            dplyr::rename(
              "site_ID" = "site_id",
              "site_nom" = "site_name",
              "date_heure" = "date_time",
              "annee" = "year",
              "mois" = "month",
              "jour" = "day",
              "type_surface" = "surface_type",
              "kit" = "Kit",
              "poids_vide" = "weight_empty_g",
              "poids_plein" = "weight_full_g",
              "EEN_cm" = "swe_cm",
              "epaisseur_neige_cm" = "snow_depth_cm",
              "densite_gcm3" = "density",
              "indicateur_1" = "data_flag_1",
              "indicateur_2" = "data_flag_2",
              "region" = "region",
              "activite" = "activity"
            ) %>%
            dplyr::reframe(
              .by = everything(),
              région = case_when(
                région == "North Slave" ~ "Slave Nord", # from iti website
                région == "South Slave" ~ "Slave Sud", # iti website
                TRUE ~ région
              ),
              type_surface = case_when(
                type_surface == "upland" ~ "terres_hautes",
                type_surface == "lake" ~ "lac",
                TRUE ~ type_surface
              )
            )
        }

        write.csv(
          x = snow_data,
          file = file,
          row.names = FALSE,
          na = "",
          fileEncoding = "UTF-8"
        )
      }
    )
  })
}


