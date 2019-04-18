
db_jones_pantheria <- function( species_names, binomial_column, selected_traits, matches ) {

  pantheriaDB = read.table( "traitdata/jones_pantheria/PanTHERIA_1-0_WR05_Aug2008.txt", sep="\t", header=TRUE )

  # select all columns if a list isn't provided
  if( is.null( selected_traits ) ) {
    selected_traits <- names( pantheriaDB )
  }
  else {
    # otherwise, make sure that the column with the species name
    # is selected
    if( ! "MSW05_Binomial" %in% selected_traits ) {
      selected_traits <- c( selected_traits, "MSW05_Binomial")
    }
  }

  # select only the relevant columns
  pantheriaDB <- pantheriaDB[selected_traits]


  names( pantheriaDB ) <- prefixed_column_names( pantheriaDB, "jones" )
  data <- merge( species_names, pantheriaDB, by.x = binomial_column, by.y = "jones_MSW05_Binomial", all.x = TRUE )

  return( setNames( list(
    data,
    nrow( merge( species_names, pantheriaDB, by.x = binomial_column, by.y = "jones_MSW05_Binomial" ) ),
    ncol(pantheriaDB)  - 1
  ), c(
    "data",
    "matches",
    "columns"
  )
  ) )
}
