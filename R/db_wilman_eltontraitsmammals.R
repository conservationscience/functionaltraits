
db_wilman_eltontraitsmammals <- function( species_names, binomial_column, selected_traits, matches ) {

  # todo - add code with Taxize to recognise species synonyms
  # todo - make the use of MS05 or the other system interchangable

  wilman_eltontraitsmammals = read.table( "traitdata/wilman_eltontraitsmammals/MamFuncDat.txt", sep="\t", header=TRUE, quote="\"" )

  # select all columns if a list isn't provided
  if( is.null( selected_traits ) ) {
    selected_traits <- names( wilman_eltontraitsmammals )
  }
  else {
    # if a list is proivided, turn all of '- ' into dots
    selected_traits <- gsub( "-", ".", selected_traits, fixed=TRUE )
    selected_traits <- gsub( " ", ".", selected_traits, fixed=TRUE )
    
    # otherwise, make sure that the column with the species name
    # is selected
    if( ! "Scientific" %in% selected_traits ) {
      selected_traits <- c( selected_traits, "Scientific")
    }
  }

  # select only the relevant columns
  wilman_eltontraitsmammals <- wilman_eltontraitsmammals[selected_traits]


  names( wilman_eltontraitsmammals ) <- prefixed_column_names( wilman_eltontraitsmammals, "wilman_mams" )
  data <- merge( species_names, wilman_eltontraitsmammals, by.x = binomial_column, by.y = "wilman_mams_Scientific", all.x = TRUE )

  return( setNames( list(
    data,
    nrow(
      merge( species_names, wilman_eltontraitsmammals, by.x = binomial_column, by.y = "wilman_mams_Scientific" )
    ),
    ncol(wilman_eltontraitsmammals)  - 1
  ), c(
    "data",
    "matches",
    "columns"
  )
  ) )
}
