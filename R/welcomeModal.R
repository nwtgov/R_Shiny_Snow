# welcomeModal

# pre-load welcome content
content_html_en <- create_welcome_content("en")
content_html_fr <- create_welcome_content("fr")

# pre-load button configs
button_config_en <- list(
  lang_toggle = "Français",
  got_it = "Got it!",
  keep_info = "Keep info visible"
)

button_config_fr <- list(
  lang_toggle = "English",
  got_it = "Compris!",
  keep_info = "Garder l'info visible"
)

show_welcome_modal <- function(session, language) {
  current_lang <- language()

  # Select pre-loaded content based on current language
  content_html <- if(current_lang == "fr") {
    content_html_fr
  } else {
    content_html_en
  }

  # Select button config based on current language
  button_config <- if(current_lang == "fr") {
    button_config_fr
  } else {
    button_config_en
  }

  showModal(modalDialog(
    title = div(
      style = "position: relative; width: 100%; padding-top: 10px;",
      div(
        style = "position: absolute; right: 0; top: -5px;",
        actionButton(
          "toggle_language_modal",
          button_config$lang_toggle,
          style = "background: none !important; border: none !important; color: #666666 !important; font-size: 14px !important; padding: 0 !important; cursor: pointer; box-shadow: none !important; text-decoration: none;"
        )
      )
    ),
    HTML(as.character(content_html)),
    easyClose = TRUE,
    footer = tagList(
      modalButton(button_config$got_it),
      actionButton("keep_info", button_config$keep_info)
    )
  ))
  shinyjs::runjs("$('.modal-dialog').last().addClass('welcome-modal');")
}

# welcome modal handlers
setup_welcome_modal_handlers <- function(session, language, show_welcome_trigger = NULL) {

  # Handle language toggle within modal
  observeEvent(session$input$toggle_language_modal, {
    current_lang <- isolate(language())
    new_lang <- if(current_lang == "en") "fr" else "en"
    language(new_lang)

    # select pre-loaded content
    new_content_html <- if(new_lang == "fr") {
      content_html_fr
    } else {
      content_html_en
    }

    # select pre-loaded button config
    new_button_config <- if(new_lang == "fr") {
      button_config_fr
    } else {
      button_config_en
    }

    # Convert and escape for JavaScript
    new_content_str <- as.character(new_content_html)
    escaped_content <- new_content_str %>%
      gsub("\\\\", "\\\\\\\\", .) %>%
      gsub("'", "\\\\'", .) %>%
      gsub('"', '\\\\"', .) %>%
      gsub("\n", " ", .) %>%
      gsub("\r", "", .) %>%
      gsub("  +", " ", .)

    # Escape button text for JavaScript
    escaped_lang_toggle <- gsub("'", "\\\\'", new_button_config$lang_toggle)
    escaped_got_it <- gsub("'", "\\\\'", new_button_config$got_it)
    escaped_keep_info <- gsub("'", "\\\\'", new_button_config$keep_info)


    # Update modal body content w smooth transition
    shinyjs::runjs(sprintf("
      var modalBody = $('.modal-body').last();
      if (modalBody.length > 0) {
        modalBody.html('%s');
      }
    ", escaped_content))


    # Update buttons - alternative approach using innerHTML
    shinyjs::runjs(sprintf("
      setTimeout(function() {
        // Update language toggle button in title
        var langBtn = document.getElementById('toggle_language_modal');
        if (langBtn) {
          // Shiny buttons often have text in a span or directly as textContent
          var span = langBtn.querySelector('span');
          if (span) {
            span.textContent = '%s';
          } else {
            langBtn.textContent = '%s';
            // Also try innerHTML as backup
            if (langBtn.textContent !== '%s') {
              langBtn.innerHTML = '%s';
            }
          }
        }

        // Update footer 'Got it!' button
        var gotItBtn = $('.modal-footer button[data-dismiss=\"modal\"]');
        if (gotItBtn.length > 0) {
          var gotItSpan = gotItBtn.find('span');
          if (gotItSpan.length > 0) {
            gotItSpan.text('%s');
          } else {
            gotItBtn.text('%s');
          }
        }

        // Update footer 'Keep info' button
        var keepInfoBtn = document.getElementById('keep_info');
        if (keepInfoBtn) {
          var keepInfoSpan = keepInfoBtn.querySelector('span');
          if (keepInfoSpan) {
            keepInfoSpan.textContent = '%s';
          } else {
            keepInfoBtn.textContent = '%s';
            if (keepInfoBtn.textContent !== '%s') {
              keepInfoBtn.innerHTML = '%s';
            }
          }
        }
      }, 50);
    ",
      escaped_lang_toggle,  # lang toggle - span
      escaped_lang_toggle,  # lang toggle - textContent
      escaped_lang_toggle,  # lang toggle - check
      escaped_lang_toggle,  # lang toggle - innerHTML
      escaped_got_it,       # got it - span
      escaped_got_it,       # got it - text
      escaped_keep_info,    # keep info - span
      escaped_keep_info,    # keep info - textContent
      escaped_keep_info,    # keep info - check
      escaped_keep_info     # keep info - innerHTML
    ))
  }, ignoreInit = TRUE)

  # Handle keep info button - show info panel in current active module
  observeEvent(session$input$keep_info, {
    #print(paste("Keep info button clicked globally at", Sys.time()))
    removeModal()

    # Determine which module is active based on current tab
    current_tab <- isolate(session$input$navbar)

    # Map tab names to module IDs
    module_id <- if(current_tab == "Snow Data" || current_tab == "Données nivométriques") {
      "snow"
    } else if(current_tab == "Download Data" || current_tab == "Télécharger") {
      "download"
    } else if(current_tab == "FAQ") {
      "faq"
    } else {
      "snow"  # default
    }

    # Show the info panel for the active module
    info_panel_id <- paste0("#", module_id, "-info_panel")
    #print(paste("Showing panel:", info_panel_id, "for tab:", current_tab))

    shinyjs::runjs(sprintf("
      var panel = document.querySelector('%s');
      if (panel) {
        panel.style.display = 'block';
        console.log('Panel shown:', '%s');
      } else {
        console.log('Panel NOT found:', '%s');
      }
    ", info_panel_id, info_panel_id, info_panel_id))
  })

  # Watch for trigger to show modal (if using reactive trigger)
  if (!is.null(show_welcome_trigger)) {
    observeEvent(show_welcome_trigger(), {
      req(show_welcome_trigger())
      show_welcome_modal(session, language)
      show_welcome_trigger(FALSE)  # Reset trigger
    })
  }
}

# function to create info panel UI (for use in modules)
create_info_panel_UI <- function(ns) {
  absolutePanel(
    id = ns("info_panel"),
    class = "info-panel",
    fixed = TRUE,
    draggable = TRUE,
    bottom = 20,
    left = 20,
    # Close button in top-right corner
    actionButton(
      ns("close_info_panel"),
      label = "×",
      class = "close-info-btn"
      ),
    uiOutput(ns("info_panel_content"))
  )
}

# function to set up info panel server logic (for use in modules)
setup_info_panel_server <- function(input, output, session, language) {
  # Keep info panel content for "keep info visible" feature
  output$info_panel_content <- renderUI({
    req(language())
    create_welcome_content(language())
  })
  # handle close button click to hide info panel
  observeEvent(input$close_info_panel, {
    info_panel_id <- paste0("#", session$ns("info_panel"))
    shinyjs::runjs(sprintf("document.querySelector('%s').style.display = 'none';", info_panel_id))
  })
}
