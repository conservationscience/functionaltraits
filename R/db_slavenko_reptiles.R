
db_slavenko_reptiles <- function( species_names, binomial_column, selected_columns, matches ) {

  # todo - add code with Taxize to recognise species synonyms

  slavenkoreptilesDB = readxl::read_excel( "traitdata/slavenko_reptiles/appendix_s2_body_sizes_of_all_extant_reptiles.xlsx")

  # convert logged data to non-logged data
  unlogged_data = slavenkoreptilesDB[["Maximum mass (log10(g))"]]
  unlogged_data = 10^unlogged_data

  # NOTE - check if rounding to 2 decimal places is okay with the team
  unlogged_data <- round(unlogged_data, 2)
  slavenkoreptilesDB["Maximum_mass_g"] <- unlogged_data

  # select all columns if a list isn't provided
  if( is.null( selected_columns ) ) {
    selected_columns <- names( slavenkoreptilesDB )
  }
  else {
    # otherwise, make sure that the column with the species name
    # is selected
    if( ! "Binomial" %in% selected_columns ) {
      selected_columns <- c( selected_columns, "Binomial")
    }
  }

  # select only the relevant columns
  slavenkoreptilesDB <- slavenkoreptilesDB[ selected_columns ]

  names( slavenkoreptilesDB ) <- prefixed_column_names( slavenkoreptilesDB, "slavenko" )
  data <- merge( species_names, slavenkoreptilesDB, by.x = binomial_column, by.y = "slavenko_Binomial", all.x = TRUE )

  return( setNames( list(
    data,
    nrow(
      merge( species_names, slavenkoreptilesDB, by.x = binomial_column, by.y = "slavenko_Binomial" )
    ),
    ncol(slavenkoreptilesDB) - 1
  ), c(
    "data",
    "matches",
    "columns"
  )
  ) )
}
