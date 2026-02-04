# app.R
library(shiny)
library(shinyjs)
library(waiter)
library(leaflet)
library(dplyr)
library(sf)
library(utils)
library(ggplot2)

source("R/content_functions.R")
source("R/welcomeModal.R")
source("R/metadataModule.R")
source("R/SWE_summary_shiny.R")
source("R/snowModule.R")
source("R/downloadModule.R")
source("R/faqModule.R")

# timeout to reduce usage until subscription upgraded
shinyOptions(timeout = 300) # in sec

# Main UI
mainUI <- fluidPage(
  useShinyjs(),
  use_waiter(),
  tags$head(
    tags$style(HTML("
          body::after {
            content: '';
            position: absolute;
            top: 55px;
            left: 0;
            right: 0;
            height: 10px;
            background-color: #2699D5;
            z-index: 1000;
            pointer-events: none;
          }
          .modal {
            z-index: 9999 !important;
          }
          .welcome-modal {
            width: 90% !important;      /* ~90% screen width */
            height: 90% !important;
          }
          .welcome-modal .modal-body {
            overflow-y: auto;           /* scroll content if long */
          }
          .navbar {
            margin-bottom: 0;
            border-radius: 0;
            background-color: #ffffff;
            height: 60px;
            padding: 0;
            border-bottom: none;
            width: 100% !important;
            position: static !important;
          }
          .navbar-header {
            position: static !important;
          }
          .navbar-brand {
            color: #000000 !important;
            font-weight: bold;
            display: flex;
            align-items: center !important;
            padding: 0;
            height: 60px !important;
          }
          .navbar-brand img {
            height: 35px;
            object-fit: contain;
            padding: 0;
          }
          .navbar-title-text{
            margin-right: 20px;
          }
          .navbar-nav {
            background-color: #0066cc;
            height: 60px;
            padding: 0;
            display: flex;
            align-items:center !important;
            margin: 0;
            border: none;
            position: static !important;
          }
          .navbar-nav > li > a {
            color: #ffffff !important;
            font-size: 14px;
            margin: 0;
            border: none;
          }
          .navbar-nav > li.active > a {
            color: #ffffff !important;
            background-color: #2699D5 !important;
            margin: 0;
            border: none;
            height: 60px;
          }
          .navbar-nav > li.active > a:hover,
          .navbar-nav > li.active > a:focus,
          .navbar-nav > li.active > a:active {
           background-color: #2699D5 !important;
            color: #ffffff !important;
          }
          #map, #snow-snow_map {
            height: calc(100vh - 90px) !important;
            width: 100% !important;
            position: absolute;
            top: 60px;
            left: 0;
            right: 0;
            bottom: 30px;
            z-index: 1;
          }
                    .leaflet-tooltip {
          font-size: 16px !important;
          font-weight: bold;
        padding: 6px 10px !important;
  }
          .floating-panel {
            background-color: #ffffff;
            padding: 20px;
            border-radius: 5px;
            box-shadow:
              0 0 0 rgba(0,0,0,0),
              0 2px 15px rgba(0,0,0,0.2),
              2px 0 15px rgba(0,0,0,0.1),
              -2px 0 15px rgba(0,0,0,0.1);
            max-width: 300px;
            z-index: 2;
            font-size: 15px !important;
          }
          .contact-bar {
            position: fixed;
            bottom: 0;
            left: 0;
            right: 0;
            height: 30px;
            background-color: #ffffff;
            border-top: 3px solid #2699D5;
            display: flex;
            align-items: center;
            justify-content: center;
            z-index: 10001;
            box-shadow: 0 -2px 10px rgba(0,0,0,0.1);
          }
          .contact-text{
          color: #0066cc;
          font-size: 14px;
          font-weight: bold;
          text-align: center;
          }
            .version-text {
    position: absolute;
    left: 20px;
    font-size: 13px;
    color: #666;
  }
          .language-toggle-container {
            position: absolute;
            right: 20px;
            top: 0;
            height: 60px;
            display: flex;
            align-items: center;
            z-index: 1000;
          }
          .language-toggle-link {
            background: none !important;
            border: none !important;
            color: #333333 !important;
            font-size: 14px !important;
            padding: 8px 12px !important;
            cursor: pointer;
            box-shadow: none !important;
          }
          .language-toggle-link:hover {
            opacity: 0.8;
            text-decoration: underline;
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
            display: none;
            position: relative;
          }
          .close-info-btn {
            position: absolute;
            top: 5px;
            right: 5px;
            background: none;
            border: none;
            font-size: 24px;
            color: #666;
            cursor: pointer;
            z-index: 10;
            padding: 0 8px;
            line-height: 1;
          }
          .close-info-btn:hover {
            color: #000;
            font-weight: bold;
          }
          "))
  ),
  uiOutput("dynamic_navbar"),
  uiOutput("dynamic_contact_bar")
)

# Main UI structure
ui <- fluidPage(
  useShinyjs(),
  mainUI
)

# Basic server structure
server <- function(input, output, session) {
  w <- Waiter$new()
  preloaded_data <- reactiveVal(NULL)

  # define app version
  app_version <- "1.1.0"

  observe({
    isolate({
      md_3 <- readRDS("data/snow_data.rds")
      nwt_boundary <- load_github_rdsshp("NWT_ENR_BND_FND.rds")
      mackenzie_basin <- load_github_rdsshp("MackenzieRiverBasin_FDA.rds")
      slave <- load_github_rdsshp("07NC005_DrainageBasin_BassinDeDrainage.rds")
      snare <- load_github_rdsshp("07SA001_DrainageBasin_BassinDeDrainage.rds")
      YKriver <- load_github_rdsshp("07SB002_DrainageBasin_BassinDeDrainage.rds")
      peel <- load_github_rdsshp("10MC002_DrainageBasin_BassinDeDrainage.rds")
      hay <- load_github_rdsshp("07OB001_DrainageBasin_BassinDeDrainage.rds")
      liard <- load_github_rdsshp("10ED002_DrainageBasin_BassinDeDrainage.rds")

      preloaded_data(list(
        nwt_boundary = nwt_boundary,
        md_3 = md_3,
        mackenzie_basin = mackenzie_basin,
        slave = slave,
        snare = snare,
        YKriver = YKriver,
        peel = peel,
        hay = hay,
        liard = liard
        ))
    })
    w$hide()
  })

  # reactive vals to track first visits and current tab
  first_visits <- reactiveValues(
    snow = TRUE
  )

  language <- reactiveVal("en") # set default lang
  show_welcome_trigger <- reactiveVal(FALSE) # reactive modal trigger
  previous_tab <- reactiveVal(NULL) # travk prev tab ( for "About" button)

  setup_welcome_modal_handlers(session, language, show_welcome_trigger) # lang toggle, keep info button, etc

  observe({
    # Store current tab as previous before it potentially changes
    if(!is.null(input$navbar) &&
       input$navbar != "About" &&
       input$navbar != "À propos") {
      previous_tab(input$navbar)
    }
  })

  # Handle About tab click - show welcome modal and stay on current tab
  observeEvent(input$navbar, {
    # Check if About tab was clicked (in either language)
    if(input$navbar == "About" || input$navbar == "À propos") {
      show_welcome_trigger(TRUE)
      # Switch back to previous tab (or default)
      target_tab <- if(!is.null(isolate(previous_tab()))) {
        isolate(previous_tab())
      } else {
        if(language() == "fr") "Données nivométriques" else "Snow Data"
      }
      # Switch back immediately
      updateNavbarPage(
        session,
        "navbar",
        selected = target_tab
      )
    }
  }, ignoreInit = TRUE)
  # language toggle and tab preservation
  desired_tab <- reactiveVal(NULL)

  # Language toggle handler - preserve current tab (for navbar language button)
  observeEvent(input$toggle_language, {
    # Save current tab before language change
    current_tab <- input$navbar
    current_lang <- language()
    if(current_lang == "en") {
      language("fr")
      tab_map <- list(
        "Snow Data" = "Données nivométriques",
        "Metadata" = "Métadonnées",
        "Download Data" = "Télécharger",
        "FAQ" = "FAQ",
        "About" = "À propos"
      )
    } else {
      language("en")
      tab_map <- list(
        "Données nivométriques" = "Snow Data",
        "Métadonnées" = "Metadata",
        "Télécharger" = "Download Data",
        "FAQ" = "FAQ",
        "À propos" = "About"
      )
    }

    # Store desired tab name for after navbar re-renders
    if(!is.null(current_tab) && current_tab %in% names(tab_map)) {
      desired_tab(tab_map[[current_tab]])
    } else {
      desired_tab(NULL)
    }
  }, ignoreInit = TRUE)

  # Restore tab after navbar re-renders
  observeEvent(language(), {
    if(!is.null(desired_tab())) {
      # set the selected tab immediately
      updateNavbarPage(
        session,
        "navbar",
        selected = desired_tab()
      )
      # JavaScript backup with longer delay
      shinyjs::runjs(sprintf("
      setTimeout(function() {
        var tabLink = $('#navbar').find('a[data-value=\"%s\"]');
        if (tabLink.length > 0) {
          tabLink.click();
        }
      }, 300);
    ", desired_tab()))
      # Clear desired_tab after use
      desired_tab(NULL)
    }
    # If language change came from modal let navbar re-render naturally
  }, ignoreInit = TRUE)

  # RENDER THE ENTIRE NAVBAR DYNAMICALLY
  output$dynamic_navbar <- renderUI({
    req(language())  # Wait for language selection

    navbarPage(
      title = div(
        style = "display: flex; align-items: center; padding: 0; margin: 0; box-shadow: none;",
        img(src = "logo_PB.png", style = "height: 35px; contain; padding: 0; filter: none; box-shadow: none"),
        span(
          if(language() == "fr") {
            "Explorateur des données nivométriques – TNO"
          } else {
            "Northwest Territories Snow Data Explorer"
          },
          class = "navbar-title-text",
          style = "font-size: 24px; margin-left: 35px; margin-right: 35px;"
        )
      ),
      id = "navbar",
      selected = if(language() == "fr") "Données nivométriques" else "Snow Data", #default tab
      header = tags$div(
        class = "language-toggle-container",
        actionButton(
          "toggle_language",
          if(language() == "fr") "English" else "Français",
          class = "language-toggle-link",
          style = "background: none; border: none; font-size: 12px; padding: 8px 12px; cursor: pointer;"
        )
      ),
      tabPanel(
        if(language() == "fr") "À propos" else "About",
        div(style = "display: none;")  # Empty div, tab acts as button for popup
      ),
      tabPanel(
        if(language() == "fr") "Métadonnées" else "Metadata",  # Metadata tab comes first
        metadataUI("metadata")
      ),
      tabPanel(
        if(language() == "fr") "Données nivométriques" else "Snow Data",
        snowUI("snow")
      ),
      tabPanel(
        if(language() == "fr") "Télécharger" else "Download Data",
        downloadUI("download")
      ),
      tabPanel(
        if(language() == "fr") "FAQ" else "FAQ",
        faqUI("faq")
      )
    )
  })

  # render contact bar including version number dynamically
  output$dynamic_contact_bar <- renderUI({
    req(language())

    div(class = "contact-bar",
        div(class = "version-text",
            style = "position: absolute; left: 20px; font-size: 12px; color: #666;",
            paste0("Version ", app_version)
        ),
        div(class = "contact-text",
            if(language() == "fr") {
              "Pour plus d'information ou pour toute demande, veuillez écrire à NWTHydrology-HydrologieTNO@gov.nt.ca"
            } else {
              "Contact NWTHydrology-HydrologieTNO@gov.nt.ca for additional information or inquiries"
            }
        )
    )
  })

  # Track module initialization to prevent double initialization
  modules_initialized <- reactiveVal(FALSE)
  last_language <- reactiveVal(NULL)
  initializing <- reactiveVal(FALSE)  # Add flag to prevent concurrent initialization

  # Only run the rest of server once language is selected
  observe({
    req(language())
    req(preloaded_data())

    # Prevent concurrent initialization
    if (isolate(initializing())) {
      return()
    }

    current_lang <- isolate(language())
    prev_lang <- isolate(last_language())

    # Initialize modules on first run or when language changes
    if (!isolate(modules_initialized()) || (current_lang != prev_lang)) {
      initializing(TRUE)  # Set flag to prevent concurrent runs

      snowServer("snow", first_visits, language, preloaded_data, show_welcome_trigger)
      metadataServer("metadata", language, preloaded_data)
      downloadServer("download", first_visits, station_data_types, language, preloaded_data)
      faqServer("faq", first_visits, language, app_version)

      modules_initialized(TRUE)
      last_language(current_lang)

      initializing(FALSE)  # Clear flag
    }
  })
}

shinyApp(ui = ui, server = server)



