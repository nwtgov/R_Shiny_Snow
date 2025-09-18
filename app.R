# app.R
library(shiny)
library(shinyjs)
library(waiter)
library(leaflet)
library(dplyr)
library(sf)
library(utils)
library(ggplot2)

source("R/SWE_summary_shiny.R")
source("R/snowModule.R")
source("R/downloadModule.R")

# Add timeout of 5 min to reduce usage time (default is 15 min)
shinyOptions(timeout = 300) # note timeout is in seconds

# Language selection popup
languageUI <- modalDialog(
  div(
    style = "text-align: center; padding: 20px;",
    actionButton("select_english", "English",
                 style = "font-size: 18px; padding: 15px 30px; margin: 10px; background-color: #0066cc; color: white; border: none; border-radius: 5px;"),
    actionButton("select_french", "Français",
                 style = "font-size: 18px; padding: 15px 30px; margin: 10px; background-color: #0066cc; color: white; border: none; border-radius: 5px;")
  ),
  footer = NULL,
  easyClose = FALSE,
  size = "s"
)

# Main UI
mainUI <- fluidPage(
  useShinyjs(),
  use_waiter(),
  # CSS styles
  tags$head(
    tags$style(HTML("
          body::after {
            content: '';
            position: fixed;
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
          .navbar {
            margin-bottom: 0;
            border-radius: 0;
            background-color: #ffffff;
            height: 60px;
            padding: 0;
            border-bottom: none;
            width: 100% !important;
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
            position: absolute;
            right: 40px;
            top: 0;
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
            justify-content: center;  /* Center the text */
            z-index: 10001;
            box-shadow: 0 -2px 10px rgba(0,0,0,0.1);  /* Fixed typo: rbga -> rgba */
          }
          .contact-text{
          color: #0066cc;
          font-size: 14px;
          font-weight: bold;
          text-align: center;
          }
          "))
  ),

  # Use uiOutput for the entire navbarPage
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

  # Pre-load data while user selects language
  preloaded_data <- reactiveVal(NULL)

  observe({
    # Load data in background while user selects language
    isolate({
      md_3 <- readRDS("data/md_3.rds")
      preloaded_data(list(md_3 = md_3))
    })
  })

  # Add reactive vals to track first visits and current tab
  first_visits <- reactiveValues(
    snow = TRUE
  )

  # Create a reactive value to track language selection
  language <- reactiveVal(NULL)

  # Show language selection immediately when app starts
  observe({
    req(is.null(language()))
    w$hide()  # Hide waiter first
    showModal(languageUI)  # Then show modal
  })

  # Handle language button clicks
  observeEvent(input$select_english, {
    language("en")
    removeModal()
  })

  observeEvent(input$select_french, {
    language("fr")
    removeModal()
  })

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
      tabPanel(
        if(language() == "fr") "Données nivométriques" else "Snow Data",
        snowUI("snow")
      ),
      tabPanel(
        if(language() == "fr") "Télécharger" else "Download Data",
        downloadUI("download")
      )
    )
  })


  # render contact bar dynamically
  output$dynamic_contact_bar <- renderUI({
    req(language())  # Wait for language selection

    div(class = "contact-bar",
        div(class = "contact-text",
            if(language() == "fr") {
              "Pour plus d'information ou pour toute demande, veuillez écrire à nwtwaters@gov.nt.ca"
            } else {
              "Contact nwtwaters@gov.nt.ca for additional information or inquiries"
            }
        )
    )
  })

  # Only run the rest of server once language is selected
  observe({
    req(language())
    req(preloaded_data())

    snowServer("snow", first_visits, language, preloaded_data)
    downloadServer("download", first_visits, station_data_types, language, preloaded_data)
  })

  # Add the tab change observer
  observeEvent(input$navbar, {
    # Hide all info panels when switching tabs
    shinyjs::runjs("
      document.querySelectorAll('.info-panel').forEach(function(panel) {
        panel.style.display = 'none';
      });
    ")

    if (input$navbar == "Snow Data") {
      if (first_visits$snow) {
        first_visits$snow <- FALSE
      }
    }
  })
}

shinyApp(ui = ui, server = server)


