
db_wilman_eltontraitsbirds <- function( species_names, binomial_column, selected_traits, matches ) {

  # todo - add code with Taxize to recognise species synonyms
  # todo - make the use of MS05 or the other system interchangable

  wilman_eltontraitsbirds = read.table( "traitdata/wilman_eltontraitsbirds/BirdFuncDat.txt", sep="\t", header=TRUE, quote="\"" )

  # select all columns if a list isn't provided
  if( is.null( selected_traits ) ) {
    selected_traits <- names( wilman_eltontraitsbirds )
  }
  else {
    # otherwise, make sure that the column with the species name
    # is selected
    if( ! "Scientific" %in% selected_traits ) {
      selected_traits <- c( selected_traits, "Scientific")
    }
  }

  # select only the relevant columns
  wilman_eltontraitsbirds <- wilman_eltontraitsbirds[selected_traits]


  names( wilman_eltontraitsbirds ) <- prefixed_column_names( wilman_eltontraitsbirds, "wilman_birds" )
  data <- merge( species_names, wilman_eltontraitsbirds, by.x = binomial_column, by.y = "wilman_birds_Scientific", all.x = TRUE )

  return( setNames( list(
    data,
    nrow(
      merge( species_names, wilman_eltontraitsbirds, by.x = binomial_column, by.y = "wilman_birds_Scientific" )
    ),
    ncol(wilman_eltontraitsbirds) - 1
  ), c(
    "data",
    "matches",
    "columns"
  )
  ) )
}
