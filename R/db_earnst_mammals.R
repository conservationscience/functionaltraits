
db_earnst_mammals <- function( species_names, binomial_column, selected_traits, matches ) {
  # todo - add code with Taxize to recognise species synonyms

  earnst <- read.table( "traitdata/earnst_mammals/Mammal_lifehistories_v2.txt", sep="\t", header=TRUE, quote="\"" )

  # create a column with the species name
  earnst["Species_name"] <- with(earnst, paste(Genus, species, sep=" "))

  # select all columns if a list isn't provided
  if( is.null( selected_traits ) ) {
    selected_traits <- names( earnst )
  }
  else {
    # otherwise, make sure that the column with the species name
    # is selected
    if( ! "Species_name" %in% selected_traits ) {
      selected_traits <- c( selected_traits, "Species_name")
    }
  }

  # select only the relevant columns
  earnst <- earnst[selected_traits]

  names( earnst ) <- prefixed_column_names( earnst, "earnst" )

  data <- merge( species_names, earnst, by.x = binomial_column, by.y = "earnst_Species_name", all.x = TRUE )

  return( setNames( list(
      data,
      nrow( merge( species_names, earnst, by.x = binomial_column, by.y = "earnst_Species_name" ) ),
      ncol(earnst) - 1
    ), c(
      "data",
      "matches",
      "columns"
    )
  ) )
}
