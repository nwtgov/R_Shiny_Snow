# Snow Shiny helper funs

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

