
db_oliveira_amphibio <- function( species_names, binomial_column, selected_traits, matches ) {
  # todo - add code with Taxize to recognise species synonyms

  amphibio <- read.table( "traitdata/oliveira_amphibio/AmphiBIO_v1.csv", sep=",", header=TRUE )

  # select all columns if a list isn't provided
  if( is.null( selected_traits ) ) {
    selected_traits <- names( amphibio )
  }
  else {
    # otherwise, make sure that the column with the species name
    # is selected
    if( ! "Species" %in% selected_traits ) {
      selected_traits <- c( selected_traits, "Species")
    }
  }

  # select only the relevant columns
  amphibio <- amphibio[ selected_traits ]


  names( amphibio ) <- prefixed_column_names( amphibio, "oliveira" )
  data <- merge( species_names, amphibio, by.x = binomial_column, by.y = "oliveira_Species", all.x = TRUE )

  return( setNames( list(
    data,
    nrow(
      merge( species_names, amphibio, by.x = binomial_column, by.y = "oliveira_Species" )
    ),
    ncol(amphibio) - 1
  ), c(
    "data",
    "matches",
    "columns"
  )
  ) )
}
