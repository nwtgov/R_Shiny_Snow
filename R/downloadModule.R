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
        .download-section {
          background-color: white;
          padding: 20px;
          border-radius: 5px;
          box-shadow: 0 0 15px rgba(0,0,0,0.1);
          margin-bottom: 20px;
        }
          .disclaimer-section {
          background-color: #f8f9fa;
          padding: 20px;
          border-radius: 5px;
          border-left: 4px solid #0066cc;
          margin-bottom: 20px;
          font-size: 14px;
        }
        .flex-container {
          display: flex;
          gap: 20px;
          margin-bottom: 30px;
        }
        .flex-item {
          flex: 1;
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
        $(document).on('click', '#show_flags', function() {
          $('#flag_modal').modal('show');
        });
      "))
    ),

    div(class = "download-container",
        # uiOutput from server
        uiOutput(ns("download_title")),

        # Snow Data Section
        div(class = "flex-container",
            # Download controls using uiOutput from server
            div(class = "flex-item",
                div(class = "download-section",
                    uiOutput(ns("download_controls"))
                )
            ),

            # disclaimer portal
            div(class = "flex-item",
                div(class = "disclaimer-section",
                    uiOutput(ns("disclaimer_content"))
                )
            )
        ),
       # modal for flag table
       uiOutput(ns("flag_modal_content"))
  )
  )
}

# Server function for download module
downloadServer <- function(id, first_visits, station_data_types, language, preloaded_data) {
  moduleServer(id, function(input, output, session) {

    # title
    output$download_title <- renderUI({
      req(language())
      h2(if(language() == "fr") "Télécharger des données nivométriques" else "Download Snow Data")
    })

    # download controls
    output$download_controls <- renderUI({
      req(language())

      # moved from observe blocks to upload site and year choices
      available_years <- sort(unique(md_3$year), decreasing = TRUE)
      available_years <- available_years[!available_years %in% c(1976, 1977)]
      selected_year <- if (length(available_years) > 0) max(available_years) else NULL

      sites <- character(0)
      if (!is.null(input$snow_year) && input$snow_year %in% available_years) {
        sites <- sort(unique(md_3$site[md_3$year == input$snow_year]))
      }

      tagList(
        h3(if(language() == "fr") "Données nivométriques" else "Snow Data"),
        selectInput(session$ns("snow_year"),
                    if(language() == "fr") "Sélectionner l'année:" else "Select Year:",
                    choices = available_years,  # MOVED: Set choices directly
                    selected = if (!is.null(input$snow_year)) input$snow_year else selected_year),
        selectInput(session$ns("snow_site"),
                    if(language() == "fr") "Sélectionner le site:" else "Select Site:",
                    choices = sites,  # MOVED: Set choices directly
                    selected = if (!is.null(input$snow_site)) input$snow_site else NULL),
        downloadButton(session$ns("download_snow"),
                       if(language() == "fr") "Télécharger des données" else "Download Data")
      )
    })

    # Added by MA July 2025 - french - helper function for data disclaimer
    create_disclaimer_content <- function(lang) {
      if(lang == "fr") {
        HTML("
          <h4 style='font-weight: bold; font-size: 18px;'>Avertissement concernant les données nivométriques</h4>
          <p>Veuillez consulter ce <a href='https://doi.org/10.46887/2025-005' target='_blank'> lien </a>du rapport de données ouvertes qui inclut les métadonnées des sites et instruments de relevés nivométriques, des informations plus détaillées sur les indicateurs de données, notre clause de non-responsabilité, nos conditions d'utilisation et notre méthodologie de relevés nivométriques. Cette application est destinée à servir d'aide visuelle pour les informations clés fournies dans le rapport de données ouvertes.</p>

          <p><strong>Ressources supplémentaires :</strong></p>
          <ul>
            <li><span class='flag-link' id='show_flags'>Descriptions des indicateurs de données</span>.</li>
            <li>Les valeurs résumées sont incluses dans les <a href='https://www.gov.nt.ca/ecc/fr/services/gestion-et-suivi-de-leau/apercu-des-niveaux-deau-printaniers' target='_blank'>l'aperçu des niveaux d’eau printaniers aux TNO</a> chaque année.</li>
          </ul>
        ")
      } else {
        HTML("
          <h4 style='font-weight: bold; font-size: 18px;'>Snow Data Disclaimer</h4>
          <p>Please see this open data report <a href='https://doi.org/10.46887/2025-005' target='_blank'> link </a>for that includes snow survey site and instrument metadata, more specific data flag information, our data disclaimer, terms of use, and our snow survey methodology. This application is intended to act as a visual aide for the key information provided in the open data report.</p>

          <p><strong>Additional Resources:</strong></p>
          <ul>
            <li><span class='flag-link' id='show_flags'>Data flags</span> descriptions.</li>
            <li>Summary values are included in the <a href='https://www.gov.nt.ca/ecc/en/services/snow_monitoring' target='_blank'>NWT Spring Water Level Outlook</a> each year.</li>
          </ul>
        ")
      }
    }

    # Added by MA July 2025 - french - helper fun for data flags popup
    create_flag_modal_content <- function(lang) {
      if (lang == "fr") {
        tags$div(
          id = "flag_modal", class = "modal fade", tabindex = "-1", role = "dialog",
          tags$div(class = "modal-dialog modal-lg", role = "document",
                   tags$div(class = "modal-content",
                            tags$div(class = "modal-header",
                                     tags$h4(class = "modal-title", "Indicateurs de données nivométriques"),
                                     tags$button(type = "button", class = "close", "data-dismiss" = "modal", "×")
                            ),
                            tags$div(class = "modal-body",
                                     tags$table(class = "flag-table",
                                                tags$thead(
                                                  tags$tr(
                                                    tags$th("Indicateur"),
                                                    tags$th("Description"),
                                                    tags$th("Mesure à prendre")
                                                  )
                                                ),
                                                  tags$tbody(
                                                    tags$tr(tags$td("Y"), tags$td("Marque les valeurs/relevés qui ne représentent pas l'accumulation maximale d'EEN"), tags$td("selon le contexte")),
                                                    tags$tr(tags$td("HS"), tags$td("Relevés forestiers historiques des régions Dehcho et Sahtu. Métadonnées des instruments non disponibles pour ces relevés."), tags$td("considérer retirer")),
                                                    tags$tr(tags$td("P"), tags$td("Problème avec les données"), tags$td("retirer")),
                                                    tags$tr(tags$td("Q"), tags$td("Données douteuses"), tags$td("considérer retirer")),
                                                    tags$tr(tags$td("S"), tags$td("Données sommaires (points de relevés individuels non disponibles)"), tags$td("garder")),
                                                    tags$tr(tags$td("Sk"), tags$td("Doute sur la qualité des données"), tags$td("retirer")),
                                                    tags$tr(tags$td("Sk_2"), tags$td("Doute sur la la qualité des données pour raisons propre au site"), tags$td("retirer")),
                                                    tags$tr(tags$td("unvrfd"), tags$td("Données non vérifiées par le personnel senior"), tags$td("garder")),
                                                    tags$tr(tags$td("z"), tags$td("Poids des tubes enregistrés comme zéro"), tags$td("garder")),
                                                    tags$tr(tags$td("ED"), tags$td("Mesures de profondeur supplémentaires"), tags$td("selon le contexte")),
                                                    tags$tr(tags$td("VAR"), tags$td("Non inclus dans le sommaire 2022"), tags$td("garder")),
                                                    tags$tr(tags$td("M"), tags$td("Le site utilise une moyenne pondérée pour les comparaison temporelles. Les comparaisons spatiales doivent utiliser les mesures d'EEN des terres hautes. Cela s'applique uniquement au site Pocket Lake."), tags$td("selon le contexte"))
                                                  )

                                     )
                            )
                   )
          )
        )
      } else {
        tags$div(
          id = "flag_modal", class = "modal fade", tabindex = "-1", role = "dialog",
          tags$div(class = "modal-dialog modal-lg", role = "document",
                   tags$div(class = "modal-content",
                            tags$div(class = "modal-header",
                                     tags$h4(class = "modal-title", "Snow Data Flags"),
                                     tags$button(type = "button", class = "close", "data-dismiss" = "modal", "×")
                            ),
                            tags$div(class = "modal-body",
                                     tags$table(class = "flag-table",
                                                tags$thead(
                                                  tags$tr(
                                                    tags$th("Flag"),
                                                    tags$th("Description"),
                                                    tags$th("Action")
                                                  )
                                                ),
                                                tags$tbody(
                                                  tags$tr(tags$td("Y"), tags$td("Flags values/surveys that do not represent maximum accumulation of SWE "), tags$td("context dependent")),
                                                  tags$tr(tags$td("HS"), tags$td("Historic Forestry surveys from Dehcho and Sahtu regions. Instrument metadata not available for these surveys."), tags$td("consider remove")),
                                                  tags$tr(tags$td("P"), tags$td("Problem with data"), tags$td("remove")),
                                                  tags$tr(tags$td("Q"), tags$td("Questionable data"), tags$td("consider remove")),
                                                  tags$tr(tags$td("S"), tags$td("Summary data (individual surveys points not available)"), tags$td("keep")),
                                                  tags$tr(tags$td("Sk"), tags$td("Skeptical of data quality"), tags$td("remove")),
                                                  tags$tr(tags$td("Sk_2"), tags$td("Skeptical of data quality for site specific reasons"), tags$td("remove")),
                                                  tags$tr(tags$td("unvrfd"), tags$td("Data is unverified by senior staff"), tags$td("keep")),
                                                  tags$tr(tags$td("z"), tags$td("Tube weights recorded as zero"), tags$td("keep")),
                                                  tags$tr(tags$td("ED"), tags$td("Extra depth measurements"), tags$td("context dependent")),
                                                  tags$tr(tags$td("VAR"), tags$td("Not included in 2022 summary"), tags$td("keep")),
                                                  tags$tr(tags$td("M"), tags$td("Site uses weighted average for temporal comparison. Spatial comparisons should use upland swe measurements. This only applies to site Pocket Lake."), tags$td("keep"))



                                                )
                                     )
                            )
                   )
          )
        )
      }
    }

  # render disclaimer and dataflag modal reactively
  output$disclaimer_content <- renderUI({
    req(language())
    create_disclaimer_content(language())
  })

  output$flag_modal_content <- renderUI({
    req(language())
    create_flag_modal_content(language())
  })


    # Load required data and source in functions
    #md_3 <- readRDS("data/md_3.rds")
  md_3 <- preloaded_data()$md_3
    # Download snow data
    output$download_snow <- downloadHandler(
      filename = function() {
        if(language() == "fr") {
          paste0("données_nivometriques_",
                 input$snow_site, "_",
                 input$snow_year, ".csv")
        } else {
          paste0("snow_data_",
              input$snow_site, "_",
              input$snow_year, ".csv")
        }
      },
      content = function(file) {
        # Filter data for selected site and year
        snow_data <- md_3 %>%
          dplyr::filter(site == input$snow_site,
                 year == input$snow_year) %>%
          arrange(date_time)  #

        if(language() == "fr") {
          snow_data <- snow_data %>%
            dplyr::rename(
              "date_heure" = "date_time",
              "annee" = "year",
              "mois" = "month",
              "jour" = "day",
              "type_surface" = "surface_type",
              "poids_vide_g" = "weight_empty_g",
              "poids_plein_g" = "weight_full_g",
              "een_cm" = "swe_cm",
              "epaisseur_neige_cm" = "snow_depth_cm",
              "densite" = "density",
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

