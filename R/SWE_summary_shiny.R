#Summary Snow Survey values

# user_path <- "C:/Users/maucl/Documents/"
# data_path <- paste0(user_path,"Data/")

# other req functions:
######################################
# opposite of %in%:
`%!in%` = Negate(`%in%`)
library(dplyr)

#######################################
# New SWEsummary fun with density filter and reframe instead of summarize to rid of warning

SWEsummary_shiny <- function(data,
                       surface,
                       minyear = NULL,  # Make minyear optional
                       flags,
                       maxyear = NULL,  # Make maxyear optional
                       curmaxyear,
                       act,
                       hdensity_sd = NULL, # standard deviations for upper bound - should be 3
                       ldensity_sd = NULL, #  standard deviations for lower bound - should be 2
                       ldensity_limit = NULL, # should be 0.1
                       write)
  {
  # Calc site-specific min and max years
  site_years <- data %>%
    dplyr::filter(surface_type == surface,
                  data_flag_1 %!in% flags,
                  data_flag_2 %!in% flags,
                  activity == act) %>%
    dplyr::group_by(region, site) %>%
    dplyr::summarize(
      site_min_year = min(year, na.rm = TRUE),
      site_max_year = max(year, na.rm = TRUE),
      .groups = "drop"
    )

  # Filter flags and create upper and lower bounds based on density
  densityrange <- data %>%
    dplyr::filter(surface_type==surface,
                  data_flag_1%!in% flags,
                  data_flag_2%!in% flags) %>%
    dplyr::select(density)

  meanD <- mean(densityrange$density, na.rm=T) # avg density
  SDD<-sd(densityrange$density, na.rm=T) # sd of density

  # Process the data
  df = data %>%
    dplyr::filter(surface_type==surface,
                  data_flag_1%!in% flags,
                  data_flag_2%!in% flags,
                  # upper bound if hdensity_sd is specified (default = 3)
                  is.na(density) | if(!is.null(hdensity_sd)) {
                    density < (meanD + (hdensity_sd * SDD))
                  } else TRUE,
                  # lower bound if ldensity_sd is specified (default = 2)
                  is.na(density) | if(!is.null(ldensity_sd)) {
                    density > (meanD - (ldensity_sd * SDD))
                  } else TRUE,
                  #  fixed lower limit if ldensity is specified (default = 0.1)
                  is.na(density) | if(!is.null(ldensity_limit)) {
                    density > ldensity_limit
                  } else TRUE,
                  activity==act) %>%
    dplyr::group_by(region, site, year) %>%
    dplyr::summarize(yearlySWE = mean(swe_cm, na.rm=TRUE),
                     yearlydepth = mean(snow_depth_cm, na.rm=TRUE),
                     long = mean(longitude),
                     lat = mean(latitude),
                     date = if(all(is.na(date_time))) {
                       as.Date(NA)
                     } else {
                       as.Date(max(date_time, na.rm = TRUE))
                     },
                     ) %>%
    dplyr::mutate(rank = dplyr::dense_rank(dplyr::desc(yearlySWE)))

  # Join with site-specific year ranges
  df <- df %>%
    dplyr::left_join(site_years, by = c("region", "site"))

  Table = df %>%
    dplyr::group_by(region, site) %>%
    dplyr::reframe(
      #yrs = dplyr::n_distinct(year, na.rm = TRUE), # n unique years for each site - commented out by MA Jul
      yrs = dplyr::n_distinct(year[!is.na(yearlySWE)], na.rm = TRUE), # n unique years where data exists for each site
      yrs2 = if(is.null(minyear) || is.null(maxyear)) # n yrs within specified range, same as yrs if min/max are null
        {
        dplyr::n_distinct(year[year >= site_min_year & year <= site_max_year], na.rm = TRUE)
      } else {
        dplyr::n_distinct(year[year > minyear & year < maxyear], na.rm = TRUE)
      },
      meanSWE_specRange = if(is.null(minyear) || is.null(maxyear)) {
        round(mean(yearlySWE[year >= site_min_year & year <= site_max_year & year != curmaxyear], na.rm = TRUE) * 10, 4)
      } else {
        round(mean(yearlySWE[year > minyear & year < maxyear & year != curmaxyear], na.rm = TRUE) * 10, 4)
      },

      ##
      meandepth_cur = round(mean(yearlydepth[year == curmaxyear], na.rm = TRUE), 4),
      meanSWE_cur = round(mean(yearlySWE[year == curmaxyear], na.rm = TRUE) * 10, 6),
      meanSWE01_cur = if(is.null(minyear)) {
        round(mean(yearlySWE[year >= site_min_year], na.rm = TRUE) * 10, 2)
      } else {
        round(mean(yearlySWE[year > minyear], na.rm = TRUE) * 10, 2)
      },
      meanSWE_allyears = round(mean(yearlySWE, na.rm = TRUE) * 10, 2),
      pernorm = ((meanSWE_cur/ meanSWE_specRange) * 100),
      pernorm_allyrs = ((meanSWE_cur/meanSWE_allyears) * 100),
      rank = (rank[year == curmaxyear]),
      Long = mean(long),
      Lat = mean(lat),
      Date = max(as.Date(date, na.rm = TRUE)),
      site_min_year = dplyr::first(site_min_year),
      site_max_year = dplyr::first(site_max_year)
    )

    if(write == T) {
    write.csv(Table, file = paste0(data_path, "csv_data/", curmaxyear, ".csv"))
  }

  return(Table)
}


##
##
##




