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
source("R/aboutModule.R")
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
    tags$link(
      rel = "stylesheet",
      href = "https://fonts.googleapis.com/css2?family=Noto+Sans:wght@400;700&display=swap"
    ),
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
            width: 90% !important;
            height: 90% !important;
          }
          .welcome-modal .modal-body {
            overflow-y: auto;
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

  /* ===== Mobile side panel ===== */
  .mobile-hamburger {
    display: none;
    position: fixed;
    top: 8px;
    right: 12px;
    z-index: 10010;
    background: #0066cc;
    border: none;
    color: #ffffff;
    font-size: 28px;
    padding: 4px 12px;
    border-radius: 4px;
    cursor: pointer;
    line-height: 1;
  }
  .mobile-side-panel {
    display: none;
    position: fixed;
    top: 0;
    right: -280px;
    width: 280px;
    height: 100%;
    background-color: #ffffff;
    z-index: 10020;
    box-shadow: -4px 0 20px rgba(0,0,0,0.25);
    transition: right 0.3s ease;
    overflow-y: auto;
    padding: 0;
  }
  .mobile-side-panel.open {
    right: 0;
  }
  .side-panel-header {
    background-color: #0066cc;
    color: #ffffff;
    padding: 16px 20px;
    font-size: 16px;
    font-weight: bold;
    display: flex;
    justify-content: space-between;
    align-items: center;
  }
  .side-panel-close {
    background: none;
    border: none;
    color: #ffffff;
    font-size: 24px;
    cursor: pointer;
    padding: 0 4px;
    line-height: 1;
  }
  .side-panel-title {
    padding: 16px 20px;
    font-size: 15px;
    font-weight: bold;
    color: #333;
    border-bottom: 2px solid #2699D5;
  }
  .side-panel-nav a {
    display: block;
    padding: 14px 20px;
    color: #333;
    text-decoration: none;
    font-size: 15px;
    border-bottom: 1px solid #eee;
    cursor: pointer;
  }
  .side-panel-nav a:hover,
  .side-panel-nav a.active-link {
    background-color: #f0f7ff;
    color: #0066cc;
    font-weight: bold;
  }
  .side-panel-footer {
    padding: 16px 20px;
    border-top: 2px solid #2699D5;
    font-size: 13px;
    color: #666;
    position: absolute;
    bottom: 0;
    width: 100%;
    box-sizing: border-box;
    background: #ffffff;
  }
  .side-panel-footer .side-contact {
    color: #0066cc;
    font-weight: bold;
    font-size: 12px;
    margin-top: 8px;
    word-wrap: break-word;
  }
  .mobile-overlay {
    display: none;
    position: fixed;
    top: 0; left: 0; right: 0; bottom: 0;
    background: rgba(0,0,0,0.4);
    z-index: 10015;
  }
  .mobile-overlay.open {
    display: block;
  }


  /* ===== GNWT site footer (curve + dark band) ===== */
  .site-footer.tab-footer-curve-stack,
  .tab-footer-curve-stack {
    width: 100vw;
    max-width: 100vw;
    margin: 28px calc(50% - 50vw) 0 calc(50% - 50vw);
    padding: 0;
    box-sizing: border-box;
    display: block;
    clear: both;
    overflow-x: clip;
    overflow-y: visible;
    position: relative;
    opacity: 0;
    visibility: hidden;
    transition: opacity 0.12s linear;
  }

  .tab-pane.active.footer-visible .tab-footer-curve-stack {
    opacity: 1;
    visibility: visible;
  }

.site-footer__graphic {
  width: 100%;
  line-height: 0;
  position: relative;
  z-index: 1;
}

.site-footer__curve {
  width: 100%;
  height: auto;
  display: block;
}

  .site-footer__content {
    position: relative;
    z-index: 2;
    background-color: #001F30;
    color: #f5f5f5;
    margin-top: calc(-1 * min(5vw, 80px));
    overflow: hidden;
    padding-bottom: 33px;
    min-height: 120px;
    display: flex;
    align-items: center;
  }

  .site-footer__inner {
    display: flex;
    flex-wrap: wrap;
    align-items: center;
    justify-content: space-between;
    gap: 16px;
    width: 100%;
    max-width: 1140px;
    margin: 0 auto;
    padding-left: 32px;
    padding-right: 32px;
    box-sizing: border-box;

  }

  /* Links on dark band */
  .site-footer__content .gnwt-footer-links {
    display: flex;
    flex-wrap: nowrap;
    justify-content: flex-start;
    align-items: center;
    gap: 10px;
    padding: 0;
    margin: 0;
    background: transparent;
    flex: 1 1 auto;
  }

  .site-footer__content .gnwt-footer-link {
    display: flex;
    align-items: center;
    justify-content: center;
    color: inherit;
    font-family: Arial, sans-serif;
    font-size: 17px;
    font-weight: bold;
    text-decoration: none;
    padding: 8px 16px;
    white-space: nowrap;
    border: none;
    background: transparent;
    transition: background-color 0.15s ease, color 0.15s ease;
  }

  .site-footer__content .gnwt-footer-link:hover,
  .site-footer__content .gnwt-footer-link:focus {
    background-color: rgba(255, 255, 255, 0.15);
    color: inherit;
    text-decoration: none;
    outline: none;
  }

  .site-footer__content .gnwt-footer-link + .gnwt-footer-link {
    border-left: none;
  }

  /* Branding (clickable text) */
  .site-footer__branding {
    flex: 0 0 auto;
  }

  .site-footer__brand {
    color: inherit;
    text-decoration: none;
    display: inline-block;
    text-align: right;
    line-height: 1.15;
    cursor: pointer;
    padding: 8px 12px;
    border-radius: 4px;
    transition: background-color 0.15s ease, opacity 0.15s ease;
  }

  .site-footer__brand:hover,
  .site-footer__brand:focus {
    color: inherit;
    text-decoration: none;
    background-color: rgba(255, 255, 255, 0.12);
    outline: 2px solid rgba(255, 255, 255, 0.5);
    outline-offset: 2px;
  }

  .site-footer__brand-line--small {
    font-family: Calibri, sans-serif;
    font-size: 16px;
    font-weight: 355;
    letter-spacing: 0.02em;
  }

  .site-footer__brand-line--large {
    font-family: Candara, sans-serif;
    font-size: 22px;
    font-weight: 355;
    letter-spacing: 0.01em;
  }


  /* ===== Footer on medium sized screen ===== */
@media (min-width: 769px) and (max-width: 980px) {

  .site-footer__inner {
    flex-wrap: nowrap;
    align-items: center;   /* branding aligns to top of multi-row links */
    min-height: auto;
  }

  .site-footer__content .gnwt-footer-links {
    flex: 1 1 auto;
    min-width: 0;
    max-width: calc(100% - 240px);
    flex-wrap: wrap;
    justify-content: flex-start;
    gap: 10px;
    row-gap: 10px;
    flex-direction: row;
  }

  .site-footer__branding {
    flex: 0 0 auto;
    align-self: center;        /* or flex-start — tune vertical position beside wrapped links */
    margin-left: auto;         /* keep branding on the right */
  }
}



  /* ===== Mobile media query ===== */
  @media (max-width: 768px) {
    .mobile-hamburger {
      display: block !important;
    }
    .mobile-side-panel {
      display: block;
    }
    /* Hide desktop navbar tabs and language toggle */
    .navbar-nav {
      display: none !important;
    }
    .language-toggle-container {
      display: none !important;
    }
    /* Hide desktop bottom bar on mobile */
    .contact-bar {
      display: none !important;
    }
    /* Simplify navbar for mobile */
    .navbar {
      height: 45px !important;
    }
    .navbar-brand {
      height: 45px !important;
    }
    .navbar-title-text {
      font-size: 16px !important;
      margin-left: 10px !important;
      margin-right: 10px !important;
    }
    .navbar-brand img {
      height: 28px;
    }
    body::after {
      top: 45px !important;
      height: 6px !important;
    }
    /* Adjust map for mobile header */
    #map, #snow-snow_map {
      top: 45px !important;
      bottom: 0 !important;
      height: calc(100vh - 50px) !important;
    }
    /* Download form: stack labels above inputs on mobile */
    .download-container {
      padding: 10px !important;
    }
    .download-controls-section {
      padding: 12px !important;
    }
    .download-controls-section div[style*='grid-template-columns'] {
      display: block !important;
    }
    .download-controls-section div[style*='grid-column'] {
      margin-bottom: 6px;
    }
    .download-controls-section div[style*='flex'] {
      display: block !important;
    }
    .download-controls-section div[style*='flex'] > div {
      width: 100% !important;
      flex: none !important;
      margin-bottom: 6px;
    }
    .download-controls-section .selectize-input,
    .download-controls-section .form-control {
      width: 100% !important;
      max-width: 100% !important;
    }
    /* Metadata floating panel: fit mobile */
    .floating-panel {
      max-width: 170px !important;
      font-size: 13px !important;
      padding: 10px !important;
      top: 55px !important;
      left: 8px !important;
    }
    /* Metadata map: adjust for mobile header */
    #metadata-metadata_map {
      top: 45px !important;
      bottom: 0 !important;
      height: calc(100vh - 50px) !important;
    }
    /* Hide navbar title on mobile (it's in the side panel instead) */
    .navbar-title-text {
      display: none !important;
    }
    /* FAQ: reduce side padding on mobile */
    .faq-container {
      padding: 8px !important;
      max-width: 100% !important;
    }
    .faq-section {
      padding: 10px !important;
    }
    /* Hide hover tooltips on mobile (can't hover on touch) */
    .leaflet-tooltip {
      display: none !important;
    }
    /* Metadata popup: smaller text on mobile */
    .metadata-popup .leaflet-popup-content-wrapper {
      min-width: unset !important;
      max-width: 90vw !important;
    }
    .metadata-popup .leaflet-popup-content {
      font-size: 13px !important;
      margin: 8px 10px !important;
    }
    .metadata-popup .metadata-table td {
      font-size: 12px !important;
      padding: 4px 6px 4px 0 !important;
    }
    .metadata-popup .metadata-header {
      font-size: 14px !important;
    }
    /* Snow legend: smaller text on mobile */
    .leaflet .legend {
      font-size: 11px !important;
      padding: 6px 8px !important;
      max-width: 140px !important;
    }
    .leaflet .legend i {
      width: 14px !important;
      height: 14px !important;
    }
        .tab-footer-curve-stack {
      padding-bottom: 0;
      margin-top: 10px;
        }

    /* GNWT footer — mobile */
    .site-footer__content {
      align-items: stretch;      /* stop single-row vertical centering */
      min-height: auto;          /* let the bar grow taller */
      padding-top: 1.25rem;
    }

    .site-footer__inner {
      flex-direction: column;
      align-items: stretch;
    }

    .site-footer__content .gnwt-footer-links {
      flex-direction: row;
      flex-wrap: wrap;
      width: 100%
    }

    .site-footer__branding {
      width: 100%;
      margin-top: 1rem;
      padding-top: 1rem;
      border-top: 1px solid rgba(255, 255, 255, 0.35);
      text-align: right;
      align-self: stretch;
    }

    .site-footer__brand {
      text-align: right;
      width: auto;
      display: inline-block;
    }

  }



          "))
  ),

  # Hamburger button for mobile
  tags$button(
    class = "mobile-hamburger",
    id = "mobile_menu_toggle",
    onclick = "toggleMobileMenu()",
    HTML("&#9776;")
  ),

  # Mobile overlay
  div(class = "mobile-overlay", id = "mobile_overlay",
      onclick = "toggleMobileMenu()"),

  # Mobile side panel (populated dynamically)
  uiOutput("mobile_side_panel"),

  uiOutput("dynamic_navbar"),
  uiOutput("dynamic_contact_bar"),

  # JavaScript for mobile menu
  tags$script(HTML("
    function toggleMobileMenu() {
      var panel = document.getElementById('side_panel');
      var overlay = document.getElementById('mobile_overlay');
      if (panel && overlay) {
        panel.classList.toggle('open');
        overlay.classList.toggle('open');
      }
    }
    function switchTabOnly(tabValue) {
    var tabLink = $('#navbar').find('a[data-value=\"' + tabValue + '\"]');
    if (tabLink.length > 0) {
      tabLink.click();
    }
  }
    function mobileSwitchTab(tabValue) {
      var tabLink = $('#navbar').find('a[data-value=\"' + tabValue + '\"]');
      if (tabLink.length > 0) {
        tabLink.click();
      }
      $('.side-panel-nav a').removeClass('active-link');
      $('.side-panel-nav a[data-tab=\"' + tabValue + '\"]').addClass('active-link');
      toggleMobileMenu();
    }
    // Footer reveal controller (simple deterministic delay)
    var footerRevealTimer = null;

    function revealActiveFooter(delayMs) {
      if (footerRevealTimer) {
        clearTimeout(footerRevealTimer);
      }
      $('.tab-pane').removeClass('footer-visible');
      footerRevealTimer = setTimeout(function() {
        $('.tab-pane.active').addClass('footer-visible');
      }, delayMs || 450);
    }

    // Initial reveal: poll until the active tab-pane exists in the DOM
$(function() {
  var tries = 0;
  var maxTries = 75; // 15 seconds at 200ms intervals — covers any cold start
  function tryReveal() {
    tries++;
    if ($('.tab-pane.active').length > 0) {
      revealActiveFooter(150);
    } else if (tries < maxTries) {
      setTimeout(tryReveal, 200);
    }
  }
  tryReveal();
});

// Safety net: also reveal whenever Shiny finishes any work
$(document).on('shiny:idle', function() {
  if ($('.tab-pane.active').length > 0 && $('.tab-pane.active.footer-visible').length === 0) {
    revealActiveFooter(150);
  }
});

      // Tab shown: reveal footer after a short delay and then fix Leaflet sizing
  $(document).on('shown.bs.tab', 'a[data-toggle=\"tab\"]', function(e) {
    revealActiveFooter(450);

    setTimeout(function() {
      $(window).trigger('resize');
      $('.leaflet-container').each(function() {
        var map = $(this).data('leaflet-map') || HTMLWidgets.find('#' + this.id);
        if (map && map.getMap) {
          map.getMap().invalidateSize();
        }
      });
    }, 200);
  });
  "))
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

    # make logo button for About tab
    about_tab <- if (language() == "fr") "À propos" else "About"
    js_esc <- gsub("'", "\\\\'", about_tab)

    navbarPage(
      title = div(
        style = "display: flex; align-items: center; padding: 0; margin: 0; box-shadow: none;",
        tags$div(
          class = "navbar-logo-click",
          style = "display: flex; align-items: center; cursor: pointer;",
          title = if (language() == "fr") "Aller à À propos" else "Go to About",
          onclick = I(sprintf("switchTabOnly('%s');", js_esc)),
          img(
            src = "logo_PB.png",
            style = "height: 35px; object-fit: contain; padding: 0; filter: none; box-shadow: none"
          )
        ),
        span(
          if(language() == "fr") {
            "Explorateur des données nivométriques – TNO"
          } else {
            "Northwest Territories Snow Data Explorer"
          },
          class = "navbar-title-text",
          style = "font-size: 24px; margin-left: 35px; margin-right: 35px; cursor: pointer;",
          onclick = I(sprintf("switchTabOnly('%s');", js_esc)),
          title = if (language() == "fr") "Aller à À propos" else "Go to About"
        )
      ),
      id = "navbar",
      selected = if(language() == "fr") "À propos" else "About",  # Changed to AboutModule
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
        aboutUI("about")
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
        if(language() == "fr") "Métadonnées" else "Metadata",
        metadataUI("metadata")
      ),
      tabPanel(
        if(language() == "fr") "FAQ" else "FAQ",
        faqUI("faq")
      )
    )
  })

  # Render mobile side panel
  output$mobile_side_panel <- renderUI({
    req(language())
    lang <- language()

    tab_names <- if(lang == "fr") {
      list(
        c("À propos", "À propos"),
        c("Données Nivométriques", "Données Nivométriques"),
        c("Télécharger", "Télécharger"),
        c("Métadonnées", "Métadonnées"),
        c("FAQ", "FAQ")
      )
    } else {
      list(
        c("About", "About"),
        c("Snow Data", "Snow Data"),
        c("Download Data", "Download Data"),
        c("Metadata", "Metadata"),
        c("FAQ", "FAQ")
      )
    }

    app_title <- if(lang == "fr") {
      "Explorateur des données nivométriques – TNO"
    } else {
      "Northwest Territories Snow Data Explorer"
    }

    lang_label <- if(lang == "fr") "English" else "Français"
    contact_text <- if(lang == "fr") {
      "NWTHydrology-HydrologieTNO@gov.nt.ca"
    } else {
      "NWTHydrology-HydrologieTNO@gov.nt.ca"
    }

    div(class = "mobile-side-panel", id = "side_panel",
        div(class = "side-panel-header",
            span(if(lang == "fr") "Menu" else "Menu"),
            tags$button(class = "side-panel-close", onclick = "toggleMobileMenu()",
                        HTML("&times;"))
        ),
        div(class = "side-panel-title", app_title),
        div(class = "side-panel-nav",
            lapply(tab_names, function(tab) {
              tags$a(
                href = "javascript:void(0)",
                `data-tab` = tab[1],
                onclick = sprintf("mobileSwitchTab('%s')", gsub("'", "\\\\'", tab[1])),
                tab[2]
              )
            }),
            tags$a(
              href = "javascript:void(0)",
              onclick = "Shiny.setInputValue('toggle_language', Math.random()); toggleMobileMenu();",
              style = "color: #0066cc; font-weight: bold;",
              lang_label
            )
        ),
        div(class = "side-panel-footer",
            div(paste0("Version ", app_version)),
            div(class = "side-contact", contact_text)
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

      aboutServer("about", language)
      snowServer("snow", first_visits, language, preloaded_data)
      metadataServer("metadata", language, preloaded_data)
      downloadServer("download", first_visits, station_data_types, language, preloaded_data)
      faqServer("faq", first_visits, language, app_version)

      modules_initialized(TRUE)
      last_language(current_lang)

      initializing(FALSE)
    }
  })
}

shinyApp(ui = ui, server = server)



