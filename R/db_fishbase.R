

db_fishbase <- function( species_names, binomial_column, selected_traits, matches ) {
  # note -- see list of available fields to include at https://github.com/ropensci/rfishbase

  # select all columns if a list isn't provided
  if( is.null( selected_traits ) ) {
    selected_traits <- NULL
  }
  else {
    # otherwise, make sure that the column with the species name
    # is selected
    if( ! "Species" %in% selected_traits ) {
      selected_traits <- c( selected_traits, "Species")
    }
  }

  # select only the relevant columns
  result <- rfishbase::species( as.character( species_names[[binomial_column]] ), fields=selected_traits )
  # note we have converted the species name to a character vector specifically to avoid a warning

  # rename the columns so we know where our data came from
  names(result) <- prefixed_column_names( result, "fishbase" )

  data <- merge( species_names, result, by.x = binomial_column, by.y = "fishbase_Species", all.x = TRUE )

  return( setNames( list(
    data,
    nrow( merge( species_names, result, by.x = binomial_column, by.y = "fishbase_Species" ) ),
    ncol(result) - 1
  ), c(
    "data",
    "matches",
    "columns"
  )
  ) )
}
