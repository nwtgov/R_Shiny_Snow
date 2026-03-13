# aboutModule

# Function to create about content
create_about_content <- function(lang) {
  if(lang == "fr") {
    HTML("<div style='font-size: 14px;'>

  <h2 style='font-weight: bold; font-size: 24px; margin-bottom: 20px;'>Bienvenue dans l'Explorateur des données nivométriques des Territoires du Nord-Ouest</h2>

  <p style='font-size: 16px; line-height: 1.6;'>Cet Explorateur héberge les données de relevés nivométriques du Gouvernement des Territoires du Nord-Ouest (GTNO) recueillies à divers sites à travers les Territoires due Nord-Ouest. Les utilisateurs peuvent consulter des données résumées à l'aide d'une carte interactive et télécharger les données sous forme de fichier CSV.</p>

  <div style='margin-top: 25px; padding-top: 20px; border-top: 1px solid #0066cc;'>
    <h3 style='font-size: 18px; font-weight: bold; margin-top: 25px; margin-bottom: 10px;'>À propos</h3>

    <p style='font-size: 15px; line-height: 1.6;'>Le gouvernement des Territoires du Nord-Ouest–Ministère de l'Environnement et des Changements climatiques (GTNO–ECC) effectue des relevés nivométriques sur le terrain à travers le Territoires du Nord-Ouest chaque année.
    Les relevés nivométriques mesurent les caractéristiques du manteau neigeux, telles que la profondeur de neige et l'équivalent en eau de la neige (EEN).
    Ces relevés nivométriques son effectués à la fin de l'hiver (généralement, à la fin de mars ou au début d'avril) afin de mesurer le manteau neigeux à son maximum, avant qu'il commence à fondre.
    Les données recueillies lors des relevés nivométriques sont utilisées pour informer les aperçus saisonniers des niveaux d'eau, et les évaluations des risques d'inondation et de feux de forêt, pou comprendre la variabilité d'une à l'autre, et pour d'autre recherches liées à l'eau et au climat. </p>

    <p style='font-size: 15px; line-height: 1.6;'>Pour plus d'informations sur cet Explorateur, la collecte de données, l'utilisation des données et d'autres sujets connexes, veuillez visiter la section FAQ.</p>
  </div>

  <div style='margin-top: 25px; padding-top: 20px; border-top: 1px solid #0066cc;'>
    <h3 style='font-size: 18px; font-weight: bold; margin-top: 25px; margin-bottom: 10px;'>Explorer les données</h3>

    <p style='font-size: 15px; line-height: 1.6;'>Sélectionnez une année sur la carte interactive pour voir les conditions du manteau neigeux pour cette année. Les données de relevés nivométriques sont résumées et exprimées en pourcentage de la moyenne, montrant comment chaque site se compare à son historique à long terme.</p>

    <div style='font-size: 15px; font-weight: bold; margin-top: 15px; margin-bottom: 10px;'>Interprétation des données:</div>

    <ul style='padding-left: 20px; margin-top: 10px;'>
      <li><strong>Cliquez sur les sites</strong> pour voir des informations détaillées sur:
        <ul style='padding-left: 15px; margin-top: 5px;'>
          <li>Équivalent en eau de la neige (EEN)</li>
          <li>Épaisseur de neige (NaN = aucune mesure)</li>
          <li>Pourcentage de la moyenne</li>
        </ul>
      </li>
      <li><strong>Couleurs des sites:</strong> Les couleurs indiquent les valeurs d'EEN en pourcentage de la moyenne:
        <ul style='padding-left: 15px; margin-top: 5px;'>
          <li><span style='background-color: #BFEFFF; color: black; padding: 2px 6px; border-radius: 3px;'>Bleu</span> = Supérieur à la moyenne</li>
          <li><span style='background-color: #FFFFBF; color: black; padding: 2px 6px; border-radius: 3px;'>Jaune</span> = Près de la moyenne</li>
          <li><span style='background-color: #E88878; color: black; padding: 2px 6px; border-radius: 3px;'>Rouge</span> = Inférieur à la moyenne</li>
        </ul>
      </li>
    </ul>
  </div>

  <div style='margin-top: 25px; padding-top: 20px; border-top: 1px solid #0066cc;'>
    <h3 style='font-size: 18px; font-weight: bold; margin-top: 25px; margin-bottom: 10px;'>Télécharger les données</h3>

    <p style='font-size: 15px; line-height: 1.6;'>Sélectionnez un site et les plages de dates à l'aide des outils de recherche et des listes déroulantes. Cliquez sur le bouton « Télécharger les donées » pour télécharger un fichier CSV contenant toutes les measures de relevés nivométriques du site et des années sélectionnés.</p>
  </div>

</div>")
  } else {
    HTML("<div style='font-size: 14px;'>

  <h2 style='font-weight: bold; font-size: 24px; margin-bottom: 20px;'>Welcome to the Northwest Territories Snow Data Explorer</h2>

  <p style='font-size: 16px; line-height: 1.6;'>This Explorer hosts Government of Northwest Territories snow survey data collected from various locations across the Northwest Territories. Users can view summarised data in an interactive map and can download all data in CSV file format.</p>

  <div style='margin-top: 25px; padding-top: 20px; border-top: 1px solid #0066cc;'>
    <h3 style='font-size: 18px; font-weight: bold; margin-top: 25px; margin-bottom: 10px;'>About</h3>

    <p style='font-size: 15px; line-height: 1.6;'>The Government of Northwest Territories–Department of Environment and Climate Change (GNWT–ECC) conducts on-the-ground snow surveys across the Northwest Territories every year. Snow surveys measure characteristics of the snowpack, such as snow depth and snow water equivalent (SWE). These snow surveys are undertaken at the end of winter (typically, in late March or early April) in order to measure the snowpack at its maximum, before it starts to melt. Data gathered during snow surveys are used to inform seasonal water level outlooks, and flood and wildfire risk assessments, to understand year-to-year variability, and for other water- and climate-related research.</p>

    <p style='font-size: 15px; line-height: 1.6;'>For more information on this Explorer, data collection, data usage, and other related topics, please visit the FAQ section.</p>
  </div>

  <div style='margin-top: 25px; padding-top: 20px; border-top: 1px solid #0066cc;'>
    <h3 style='font-size: 18px; font-weight: bold; margin-top: 25px; margin-bottom: 10px;'>Explore the Data</h3>

    <p style='font-size: 15px; line-height: 1.6;'>Select a year on the interactive map to view snowpack conditions for that year. Snow survey data are summarised and expressed as a percent of average, showing how each site compares to its long-term record. </p>

    <div style='font-size: 15px; font-weight: bold; margin-top: 15px; margin-bottom: 10px;'>Data Interpretation:</div>

    <ul style='padding-left: 20px; margin-top: 10px;'>
      <li><strong>Click sites</strong> to see detailed information about:
        <ul style='padding-left: 15px; margin-top: 5px;'>
          <li>Snow Water Equivalent (SWE)</li>
          <li>Snow depth (NaN = no measurements)</li>
          <li>Percent of average</li>
        </ul>
      </li>
      <li><strong>Site colours:</strong> Colours indicate SWE values as a percentage of average:
        <ul style='padding-left: 15px; margin-top: 5px;'>
          <li><span style='background-color: #BFEFFF; color: black; padding: 2px 6px; border-radius: 3px;'>Blue</span> = Above average</li>
          <li><span style='background-color: #FFFFBF; color: black; padding: 2px 6px; border-radius: 3px;'>Yellow</span> = Near average</li>
          <li><span style='background-color: #E88878; color: black; padding: 2px 6px; border-radius: 3px;'>Red</span> = Below average</li>
        </ul>
      </li>
    </ul>
  </div>

  <div style='margin-top: 25px; padding-top: 20px; border-top: 1px solid #0066cc;'>
    <h3 style='font-size: 18px; font-weight: bold; margin-top: 25px; margin-bottom: 10px;'>Download Data</h3>

    <p style='font-size: 15px; line-height: 1.6;'>Select a site and date ranges using the search tools and drop-down lists. Click the 'Download Data' button to download a CSV file containing all snow survey measurements from the selected site and years.</p>
  </div>

</div>")
  }
}

# UI function
aboutUI <- function(id) {
  ns <- NS(id)
  div(
    style = "padding: 20px; max-width: 900px; margin: 0 auto;",
    uiOutput(ns("about_content"))
  )
}

# Server function
aboutServer <- function(id, language) {
  moduleServer(id, function(input, output, session) {
    output$about_content <- renderUI({
      req(language())
      create_about_content(language())
    })
  })
}

##
##
##
