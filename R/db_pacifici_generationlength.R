
db_pacifici_generationlength <- function( species_names, binomial_column, selected_columns, matches ) {

  # todo - add code with Taxize to recognise species synonyms

  pacifici = readxl::read_excel( "traitdata/pacifici_generationlength/pacifici_generationlength.xls")

  # select all columns if a list isn't provided
  if( is.null( selected_columns ) ) {
    selected_columns <- names( pacifici )
  }
  else {
    # otherwise, make sure that the column with the species name
    # is selected
    if( ! "Scientific_name" %in% selected_columns ) {
      selected_columns <- c( selected_columns, "Scientific_name")
    }
  }

  # select only the relevant columns
  pacifici <- pacifici[ selected_columns ]

  names( pacifici ) <- prefixed_column_names( pacifici, "pacifici" )
  data <- merge( species_names, pacifici, by.x = binomial_column, by.y = "pacifici_Scientific_name", all.x = TRUE )

  return( setNames( list(
    data,
    nrow(
      merge( species_names, pacifici, by.x = binomial_column, by.y = "pacifici_Scientific_name" )
    ),
    ncol(pacifici) - 1
  ), c(
    "data",
    "matches",
    "columns"
  )
  ) )
}
