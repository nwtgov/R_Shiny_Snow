# Snow Shiny content functions

# SnowModule content
# Welcome popup content for snowModule
create_welcome_content <- function(lang) {
  if(lang == "fr") {
    HTML("<div style='font-size: 14px;'>

  <h2 style='font-weight: bold; font-size: 24px; margin-bottom: 20px;'>Bienvenue dans l'Explorateur des données nivométriques des Territoires du Nord-Ouest</h2>

  <p style='font-size: 16px; line-height: 1.6;'>Cette application héberge les données de relevés nivométriques du GTNO collectées à partir de divers emplacements sur le territoire. Les utilisateurs peuvent consulter des données résumées sur une carte interactive et télécharger des données brutes pour une analyse plus approfondie.</p>

  <div style='margin-top: 25px; padding-top: 20px; border-top: 1px solid #0066cc;'>
    <h3 style='font-size: 18px; font-weight: bold; margin-top: 25px; margin-bottom: 10px;'>À propos</h3>

    <p style='font-size: 15px; line-height: 1.6;'>Le gouvernement des Territoires du Nord-Ouest–Ministère de l'Environnement et des Changements climatiques (GTNO–ECC) effectue des relevés nivométriques sur le terrain à travers le territoire à la fin de l'hiver chaque année pour informer la surveillance des inondations, la prédiction des feux de forêt, la variabilité d'une année à l'autre et la recherche. Ces relevés nivométriques manuels comprennent des mesures de la profondeur de neige en fin d'hiver et de l'équivalent en eau de la neige (EEN).</p>

    <p style='font-size: 15px; line-height: 1.6;'>Pour plus d'informations sur la collecte de données, l'utilisation des données et d'autres sujets connexes, veuillez visiter la section FAQ.</p>
  </div>

  <div style='margin-top: 25px; padding-top: 20px; border-top: 1px solid #0066cc;'>
    <h3 style='font-size: 18px; font-weight: bold; margin-top: 25px; margin-bottom: 10px;'>Explorer les données</h3>

    <p style='font-size: 15px; line-height: 1.6;'>Sélectionnez une année sur la carte interactive pour voir les conditions résumées pour cette année. Les données de relevés nivométriques sont résumées et exprimées en pourcentage de la moyenne, montrant comment chaque site se compare à son historique à long terme.</p>

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

    <p style='font-size: 15px; line-height: 1.6;'>Sélectionnez les sites et les plages de dates à l'aide des outils de recherche. Les données sélectionnées peuvent être exportées sous forme de fichier CSV contenant les mesures brutes des relevés nivométriques.</p>
  </div>

</div>")
  } else {
    HTML("<div style='font-size: 14px;'>

  <h2 style='font-weight: bold; font-size: 24px; margin-bottom: 20px;'>Welcome to the Northwest Territories Snow Data Explorer</h2>

  <p style='font-size: 16px; line-height: 1.6;'>This application hosts GNWT snow survey data collected from various locations across the territory. Users can view summarized data in an interactive map and download raw data for further analysis.</p>

  <div style='margin-top: 25px; padding-top: 20px; border-top: 1px solid #0066cc;'>
    <h3 style='font-size: 18px; font-weight: bold; margin-top: 25px; margin-bottom: 10px;'>About</h3>

    <p style='font-size: 15px; line-height: 1.6;'>The Government of Northwest Territories–Department of Environment and Climate Change (GNWT–ECC) conducts on-the-ground snow surveys across the territory at the end of winter every year to inform flood monitoring, wildfire prediction, year-to-year variability, and research. These manual snow surveys include measurements of end-of-winter snow depth and snow water equivalent (SWE).</p>

    <p style='font-size: 15px; line-height: 1.6;'>For more information on data collection, data usage, and other related topics, please visit the FAQ section.</p>
  </div>

  <div style='margin-top: 25px; padding-top: 20px; border-top: 1px solid #0066cc;'>
    <h3 style='font-size: 18px; font-weight: bold; margin-top: 25px; margin-bottom: 10px;'>Explore the Data</h3>

            <p style='font-size: 15px; line-height: 1.6;'>Select a year on the interactive map to view summary conditions for that year. Snow survey data are summarized and expressed as a percent of average, showing how each site compares to its long-term record. </p>

      <div style='font-size: 15px; font-weight: bold; margin-top: 15px; margin-bottom: 10px;'>Data Interpretation:</div>

      <ul style='padding-left: 20px; margin-top: 10px;'>
              <li><strong>Click sites</strong> to see detailed information about:
          <ul style='padding-left: 15px; margin-top: 5px;'>
            <li>Snow Water Equivalent (SWE)</li>
            <li>Snow Depth (NaN = no measurements)</li>
            <li>Percent of Average</li>
          </ul>
        </li>
        <li><strong>Site Colours:</strong> Colours indicate SWE values as a percentage of average:
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

      <p style='font-size: 15px; line-height: 1.6;'>Select sites and date ranges using the search tools. Selected data can be exported as a CSV file containing raw snow survey measurements.</p>
  </div>

</div>")
  }
}

# DownloadModule
# Data transformations
update_site_names <- function(df) {
  df$site <- gsub("_f$", " (Forestry)", df$site)
  df$site <- gsub("_m$", " Muskeg", df$site)
  df$site <- gsub("^IT64", "Ingraham Trail 64 ", df$site)
  return(df)
}

rename_cols <- function(df) {

  rename_cols <- c(
    "site_id" = "site_ID",
    "site" = "site_name",
    "instrument" = "instrument_id",
    "Kit" = "kit",
    "weight_empty_g" = "weight_empty",
    "weight_full_g" = "weight_full",
    "swe_cm" = "SWE_cm",
    "density" = "density_gcm3"
  )

  for(old_name in names(rename_cols)) {
    if(old_name %in% colnames(df)) {
      colnames(df)[colnames(df) == old_name] <- rename_cols[old_name]
    }
  }
  return(df)
}

# note - popup descriptions for flags, colnames and instruments are in the disclaimer content
create_disclaimer_content <- function(lang) {
  if(lang == "fr") {
    HTML("
          <div style='margin-bottom: 30px;'>
          <h4 style='font-weight: bold; font-size: 18px;'>Avertissement concernant les données</h4>
          <p>Cette application a été créée par le ministère de l'Environnement et des Changements climatiques (ECC), gouvernement des Territoires du Nord-Ouest (GTNO). Cette application sert de complément visuel et interactif au <a href='https://doi.org/10.46887/2025-005' target='_blank'> Rapport sur les données ouvertes (2025) </a> préparé par l'ECC et la Commission géologique des Territoires du Nord-Ouest (CG-TNO). Le rapport comprend des données nivométriques sommaires et brutes, la méthodologie des relevés nivométriques, les processus de contrôle de qualité des données et les métadonnées des sites pour les relevés nivométriques collectés entre 1965 et 2024 dans les TNO. Cette application présente les mêmes informations, avec l'ajout de données de relevés nivométriques plus récentes.</p>
          <p>Cette application est fournie à titre informatif uniquement. Elle ne contient aucune garantie, représentation ou engagement de qualité, qu'elle soit expresse ou implicite, et ne contient aucune garantie concernant l'exactitude, l'intégrité et la qualité de l'information.</p>
          <p> Pour l'avertissement complet sur les données, les conditions d'utilisation et des informations supplémentaires, veuillez consulter le <a href='https://doi.org/10.46887/2025-005' target='_blank'> Rapport sur les données ouvertes (2025). </a> </p>
           </div>


          <div style='margin-top: 30px; padding-top: 20px;'>
            <h4 style='font-weight: bold; font-size: 18px;'>Ressources supplémentaires</h4>
            <h5 style='font-weight: bold; font-size: 16px; margin-top: 15px; margin-bottom: 10px;'>Documents de référence rapide</h5>
            <ul>
              <li><span class='flag-link' id='show_column_names'>Descriptions des noms de colonnes</span> - explication des en-têtes de colonnes inclus dans les données téléchargeables.</li>
              <li><span class='flag-link' id='show_flags'>Dictionnaire des indicateurs de données</span> - définitions des indicateurs de qualité des données utilisés dans le jeu de données.</li>
              <li><span class='flag-link' id='show_instruments'>Descriptions des instruments</span> - informations sur les types d'instruments utilisés pour les mesures de profondeur de neige et d'EEN.</li>
            </ul>
            <p style='margin-top: 12px; font-size: 14px;'>Ces documents de référence sont disponibles pour consultation rapide dans cette application, mais ils peuvent également être téléchargés sous forme de fichiers CSV à partir du <a href='https://doi.org/10.46887/2025-005' target='_blank'>Rapport sur les données ouvertes (2025)</a> pour une utilisation hors ligne.</p>
            <h5 style='font-weight: bold; font-size: 16px; margin-top: 25px; margin-bottom: 10px;'>Publications supplémentaires</h5>
            <ul>
              <li>Les valeurs résumées sont incluses dans les <a href='https://www.gov.nt.ca/ecc/fr/services/gestion-et-suivi-de-leau/apercu-des-niveaux-deau-printaniers' target='_blank'>l'aperçu des niveaux d'eau printaniers aux TNO</a> chaque année.</li>
              <li>Les données sommaires sont également disponibles via le jeu de données CanSWE compilé par <a href='https://doi.org/10.5194/essd-13-4603-2021' target='_blank'>Vionnet et al. (2021)</a>.</li>
            </ul>
          </div>
        ")
  } else {
    HTML("
          <div style='margin-bottom: 30px;'>
          <h4 style='font-weight: bold; font-size: 18px;'>Data Disclaimer</h4>
          <p>This application was created by the Department of Environment and Climate Change (ECC), Government of Northwest Territories (GNWT). This application serves as a visual and interactive companion to the <a href='https://doi.org/10.46887/2025-005' target='_blank'> Open Data Report (2025) </a> prepared by ECC and the Northwest Territories Geological Survey (NTGS). The report includes summarised and raw snow survey data, snow survey methodology, data quality control processes, and site metadata for snow surveys collected between 1965 and 2024 in the NWT. This application features the same information, with the addition of more recent snow survey data.</p>
          <p>This application is provided for informational purposes only. It does not contain any warranties, representations, or quality commitments, whether expressed or implicit, nor does it contain any guarantees regarding the correctness, integrity, and quality of the information. </p>
          <p> For the full data disclaimer, terms of use, and additional information, please refer to the <a href='https://doi.org/10.46887/2025-005' target='_blank'> Open Data Report (2025). </a> </p>
           </div>


          <div style='margin-top: 30px; padding-top: 20px;'>
            <h4 style='font-weight: bold; font-size: 18px;'>Additional Resources</h4>
            <h5 style='font-weight: bold; font-size: 16px; margin-top: 15px; margin-bottom: 10px;'>Quick reference materials</h5>
            <ul>
              <li><span class='flag-link' id='show_column_names'>Column name</span> descriptions - explanation of column headers included in the downloadable data.</li>
              <li><span class='flag-link' id='show_flags'>Data Flags</span> dictionary - definitions of data quality flags used in the dataset.</li>
              <li><span class='flag-link' id='show_instruments'>Instrument</span> descriptions - information on the types of instruments used for snow depth and SWE measurements.</li>
            </ul>
            <p style='margin-top: 12px; font-size: 14px;'>These reference materials are available for quick lookup in this application, but they can also be downloaded as CSV files from the <a href='https://doi.org/10.46887/2025-005' target='_blank'>Open Data Report (2025)</a> for offline use.</p>
            <h5 style='font-weight: bold; font-size: 16px; margin-top: 25px; margin-bottom: 10px;'>Additional publications</h5>
            <ul>
              <li>Summary values are included in the <a href='https://www.gov.nt.ca/ecc/en/services/snow_monitoring' target='_blank'>NWT Spring Water Level Outlook</a> each year.</li>
              <li>Summarised data are also available via the CanSWE dataset compiled by <a href='https://doi.org/10.5194/essd-13-4603-2021' target='_blank'>Vionnet et al. (2021)</a>.</li>
            </ul>
          </div>
        ")
  }
}

# fun for data flags popup
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

# fun for colnames popup
create_column_modal_content <- function(lang) {
  if (lang == "fr") {
    tags$div(
      id = "column_modal", class = "modal fade", tabindex = "-1", role = "dialog",
      tags$div(class = "modal-dialog modal-lg", role = "document",
               tags$div(class = "modal-content",
                        tags$div(class = "modal-header",
                                 tags$h4(class = "modal-title", "Noms de colonnes"),
                                 tags$button(type = "button", class = "close", "data-dismiss" = "modal", "×")
                        ),
                        tags$div(class = "modal-body",
                                 tags$table(class = "flag-table",
                                            tags$thead(
                                              tags$tr(
                                                tags$th("Nom de la colonne"),
                                                tags$th("Description")
                                              )
                                            ),
                                            tags$tbody(
                                              tags$tr(tags$td("site_ID"), tags$td("Identifiant unique du site selon les protocoles internes du gouvernement des Territoires du Nord-Ouest.")),
                                              tags$tr(tags$td("site_nom"), tags$td("Nom du site selon les protocoles internes du gouvernement des Territoires du Nord-Ouest. Les noms ont souvent été déterminés en utilisant les lacs à proximité.")),
                                              tags$tr(tags$td("date_heure"), tags$td("Heure de la Montagne, format AAAA-MM-JJ.")),
                                              tags$tr(tags$td("annee"), tags$td("AAAA")),
                                              tags$tr(tags$td("mois"), tags$td("MM")),
                                              tags$tr(tags$td("jour"), tags$td("JJ")),
                                              tags$tr(tags$td("point"), tags$td("Point de relevé nivométrique. Il y a généralement 10 points par relevé.")),
                                              tags$tr(tags$td("type_surface"), tags$td("Type de surface sous-jacente. Les catégories sont relativement larges, comprenant les surfaces de prairie, de lac ou de terres hautes. Pour les sites sous la limite des arbres, les surfaces de terres hautes sont toujours dans des zones forestières. Les valeurs de caractères incluent : « fen », « fen_shield », « lake », « meadow », « mixed », « unknown » et « upland ».")),
                                              tags$tr(tags$td("instrument_id"), tags$td("Identifiant de l'instrument pour le tube à neige utilisé pour prendre les mesures d'EEN et de profondeur de neige. Les valeurs alphanumériques incluent : « AD », « ESC30 », « magnaprobe », « metric », « MSC » et « mt rose ». Pour plus d'informations sur les instruments, consultez le fichier instruments.csv.")),
                                              tags$tr(tags$td("kit"), tags$td("Numéro du kit d'instrument. Cela suit les tubes à neige et les balances spécifiques utilisés pour les relevés nivométriques qui sont calibrés et entretenus annuellement.")),
                                              tags$tr(tags$td("poids_vide"), tags$td("Poids du tube à neige vide (instrument).")),
                                              tags$tr(tags$td("poids_plein"), tags$td("Poids du tube à neige et de l'échantillon de neige.")),
                                              tags$tr(tags$td("EEN_cm"), tags$td("Équivalent en eau de la neige (EEN), calculé en utilisant les champs « poids_plein » et « poids_vide ». Les tubes à neige sont fabriqués de telle sorte que la différence entre ces champs donne l'EEN (unité : cm).")),
                                              tags$tr(tags$td("epaisseur_neige_cm"), tags$td("Profondeur verticale de la neige (unité : cm) déterminée à l'aide des lignes graduées sur le côté du tube à neige (instrument).")),
                                              tags$tr(tags$td("densite_gcm3"), tags$td("Densité de l'échantillon de neige (unité : g cm⁻³), calculée en utilisant le champ « SWE_cm » et le champ « snow_depth_cm » (density_gcm3 = SWE_cm/snow_depth_cm).")),
                                              tags$tr(tags$td("indicateur_1"), tags$td("Champ pour signaler les échantillons de neige, suivant les protocoles internes de contrôle de qualité du gouvernement des Territoires du Nord-Ouest. Les valeurs alphanumériques incluent : « ED », « P », « S », « Sk », « Sk_2 », « VAR » et « Y ». Pour plus d'informations sur les indicateurs de données, consultez le fichier flags.csv.")),
                                              tags$tr(tags$td("indicateur_2"), tags$td("Champ pour signaler les échantillons de neige, suivant les protocoles internes de contrôle de qualité du gouvernement des Territoires du Nord-Ouest. Les valeurs de caractères incluent : « HS », « M », « P », « Q », « Sk », « unvrfd » et « Y ». Pour plus d'informations sur les indicateurs de données, consultez le fichier flags.csv.")),
                                              tags$tr(tags$td("region"), tags$td("Région")),
                                              tags$tr(tags$td("activite"), tags$td("Activité")),
                                              tags$tr(tags$td("longitude"), tags$td("Longitude")),
                                              tags$tr(tags$td("latitude"), tags$td("Latitude"))
                                            )
                                 )
                        )
               )
      )
    )
  } else {
    tags$div(
      id = "column_modal", class = "modal fade", tabindex = "-1", role = "dialog",
      tags$div(class = "modal-dialog modal-lg", role = "document",
               tags$div(class = "modal-content",
                        tags$div(class = "modal-header",
                                 tags$h4(class = "modal-title", "Column Names"),
                                 tags$button(type = "button", class = "close", "data-dismiss" = "modal", "×")
                        ),
                        tags$div(class = "modal-body",
                                 tags$table(class = "flag-table",
                                            tags$thead(
                                              tags$tr(
                                                tags$th("Column Name"),
                                                tags$th("Description")
                                              )
                                            ),
                                            tags$tbody(
                                              tags$tr(tags$td("site_ID"), tags$td("Site identification given following internal Government of Northwest Territories identification protocols.")),
                                              tags$tr(tags$td("site_name"), tags$td("Site name given following internal Government of Northwest Territories protocols. Names were often determined using nearby lakes.")),
                                              tags$tr(tags$td("date_time"), tags$td("Mountain Time, YYYY-MM-DD format.")),
                                              tags$tr(tags$td("year"), tags$td("YYYY")),
                                              tags$tr(tags$td("month"), tags$td("MM")),
                                              tags$tr(tags$td("day"), tags$td("DD")),
                                              tags$tr(tags$td("point"), tags$td("Snow survey point. There are usually 10 points per survey.")),
                                              tags$tr(tags$td("surface_type"), tags$td("Underlying surface type. Categories are relatively broad, consisting of meadow, lake, or upland surfaces. For sites below the treeline, upland surfaces are always within forested areas. Character values include: \"fen\", \"fen_shield\", \"lake\", \"meadow\", \"mixed\", \"unknown\" and \"upland\".")),
                                              tags$tr(tags$td("instrument_id"), tags$td("Instrument id for the snow tube used to take SWE and snow depth measurements. Alphanumeric values include: \"AD\", \"ESC30\", \"magnaprobe\", \"metric\", \"MSC\" and \"mt rose\". For more information on instruments, see the instruments.csv file.")),
                                              tags$tr(tags$td("kit"), tags$td("Instrument kit number. This tracks specific snow tubes and scales used for snow surveys that are calibrated and maintained annually.")),
                                              tags$tr(tags$td("weight_empty"), tags$td("Weight of the empty snow tube (instrument).")),
                                              tags$tr(tags$td("weight_full"), tags$td("Weight of the snow tube and the snow sample.")),
                                              tags$tr(tags$td("SWE_cm"), tags$td("Snow water equivalent (SWE), calculated using fields \"weight_full\" and \"weight_empty\". Snow tubes are manufactured such that the difference between these fields yields the SWE (unit: cm).")),
                                              tags$tr(tags$td("snow_depth_cm"), tags$td("Vertical depth of the snow (unit: cm) as determined using the graduated lines on the side of the snow tube (instrument).")),
                                              tags$tr(tags$td("density_gcm3"), tags$td("Density of the snow sample (unit: g cm⁻³), calculated using the \"SWE_cm\" field and the \"snow_depth_cm\" field (density_gcm3 = SWE_cm/snow_depth_cm).")),
                                              tags$tr(tags$td("data_flag_1"), tags$td("Field for flagging snow samples, following internal Government of Northwest Territories quality control protocols. Alphanumeric values include: \"ED\", \"P\", \"S\", \"Sk\", \"Sk_2\", \"VAR\", and \"Y\". For more information on data flags, see the flags.csv file.")),
                                              tags$tr(tags$td("data_flag_2"), tags$td("Field for flagging snow samples, following internal Government of Northwest Territories quality control protocols. Character values include: \"HS\", \"M\", \"P\", \"Q\", \"Sk\", \"unvrfd\", and \"Y\". For more information on data flags, see the flags.csv file.")),
                                              tags$tr(tags$td("region"), tags$td("Region")),
                                              tags$tr(tags$td("activity"), tags$td("Activity")),
                                              tags$tr(tags$td("longitude"), tags$td("Longitude")),
                                              tags$tr(tags$td("latitude"), tags$td("Latitude"))
                                            )
                                 )
                        )
               )
      )
    )
  }
}

# fun for instrument popup
create_instrument_modal_content <- function(lang) {
  if (lang == "fr") {
    tags$div(
      id = "instrument_modal", class = "modal fade", tabindex = "-1", role = "dialog",
      tags$div(class = "modal-dialog modal-lg", role = "document",
               tags$div(class = "modal-content",
                        tags$div(class = "modal-header",
                                 tags$h4(class = "modal-title", "Instruments"),
                                 tags$button(type = "button", class = "close", "data-dismiss" = "modal", "×")
                        ),
                        tags$div(class = "modal-body",
                                 tags$table(class = "flag-table",
                                            tags$thead(
                                              tags$tr(
                                                tags$th("identifiant_instrument"),
                                                tags$th("nom_instrument"),
                                                tags$th("superficie_cm2"),
                                                tags$th("longueur_cm"),
                                                tags$th("diametre_interne_cm"),
                                                tags$th("metrique_imperial")
                                              )
                                            ),
                                            tags$tbody(
                                              tags$tr(tags$td("MSC"), tags$td("Service météorologique du Canada"), tags$td("39.05"), tags$td("110"), tags$td("7.05"), tags$td("impérial")),
                                              tags$tr(tags$td("AD"), tags$td("Adirondack"), tags$td("34.94"), tags$td("120"), tags$td("6.67"), tags$td("métrique")),
                                              tags$tr(tags$td("metric"), tags$td("fédéral standard"), tags$td("11.4"), tags$td("76.2"), tags$td("3.77"), tags$td("métrique")),
                                              tags$tr(tags$td("mt rose"), tags$td("fédéral mt rose"), tags$td("11.4"), tags$td("76.2"), tags$td("3.77"), tags$td("impérial")),
                                              tags$tr(tags$td("ESC30"), tags$td("ESC-30 métrique"), tags$td("30"), tags$td("121.5"), tags$td("6.18"), tags$td("métrique")),
                                              tags$tr(tags$td("magnaprobe"), tags$td("magnaprobe"), tags$td(""), tags$td("153"), tags$td(""), tags$td("métrique"))
                                            )
                                 )
                        )
               )
      )
    )
  } else {
    tags$div(
      id = "instrument_modal", class = "modal fade", tabindex = "-1", role = "dialog",
      tags$div(class = "modal-dialog modal-lg", role = "document",
               tags$div(class = "modal-content",
                        tags$div(class = "modal-header",
                                 tags$h4(class = "modal-title", "Instruments"),
                                 tags$button(type = "button", class = "close", "data-dismiss" = "modal", "×")
                        ),
                        tags$div(class = "modal-body",
                                 tags$table(class = "flag-table",
                                            tags$thead(
                                              tags$tr(
                                                tags$th("instrument_id"),
                                                tags$th("instrument_name"),
                                                tags$th("area_cm2"),
                                                tags$th("length_cm"),
                                                tags$th("internal_diameter_cm"),
                                                tags$th("metric_imperial")
                                              )
                                            ),
                                            tags$tbody(
                                              tags$tr(tags$td("MSC"), tags$td("Meteorological Service of Canada"), tags$td("39.05"), tags$td("110"), tags$td("7.05"), tags$td("imperial")),
                                              tags$tr(tags$td("AD"), tags$td("Adirondack"), tags$td("34.94"), tags$td("120"), tags$td("6.67"), tags$td("metric")),
                                              tags$tr(tags$td("metric"), tags$td("standard federal"), tags$td("11.4"), tags$td("76.2"), tags$td("3.77"), tags$td("metric")),
                                              tags$tr(tags$td("mt rose"), tags$td("mt rose federal"), tags$td("11.4"), tags$td("76.2"), tags$td("3.77"), tags$td("imperial")),
                                              tags$tr(tags$td("ESC30"), tags$td("metric ESC-30"), tags$td("30"), tags$td("121.5"), tags$td("6.18"), tags$td("metric")),
                                              tags$tr(tags$td("magnaprobe"), tags$td("magnaprobe"), tags$td(""), tags$td("153"), tags$td(""), tags$td("metric"))
                                            )
                                 )
                        )
               )
      )
    )
  }
}






