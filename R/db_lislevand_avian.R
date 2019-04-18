
db_lislevand_avian <- function( species_names, binomial_column, selected_traits, matches ) {
  # todo - add code with Taxize to recognise species synonyms

  lislevand <- read.table( "traitdata/lislevand_avian/avian_ssd_jan07.txt", sep="\t", header=TRUE, quote="", fill=TRUE )

  # select all columns if a list isn't provided
  if( is.null( selected_traits ) ) {
    selected_traits <- names( lislevand )
  }
  else {
    # otherwise, make sure that the column with the species name
    # is selected
    if( ! "Species_name" %in% selected_traits ) {
      selected_traits <- c( selected_traits, "Species_name")
    }
  }

  # select only the relevant columns
  lislevand <- lislevand[selected_traits]

  names( lislevand ) <- prefixed_column_names( lislevand, "lislevand" )

  data <- merge( species_names, lislevand, by.x = binomial_column, by.y = "lislevand_Species_name", all.x = TRUE )

  return( setNames( list(
    data,
    nrow(
      merge( species_names, lislevand, by.x = binomial_column, by.y = "lislevand_Species_name" )
    ),
    ncol(lislevand) - 1
  ), c(
    "data",
    "matches",
    "columns"
  )
  ) )
}
