
db_myhrvold_amniotes <- function( species_names, binomial_column, selected_traits, matches ) {
  # todo - add code with Taxize to recognise species synonyms

  filename <- "traitdata/myhrvold_amniotes/Amniote_Database_Aug_2015.csv"
  if( file.exists(filename) ) {
    amniotes <- read.table( filename, sep=",", header=TRUE, quote="\"" )
  }
  else stop( paste( "Cannot find file '", filename, "'", sep="" ) )

  # create a column with the species name
  amniotes["Species_name"] <- with(amniotes, paste(genus, species, sep=" "))

  # select all columns if a list isn't provided
  if( is.null( selected_traits ) ) {
    selected_traits <- names( amniotes )
  }
  else {
    # otherwise, make sure that the column with the species name
    # is selected
    if( ! "Species_name" %in% selected_traits ) {
      selected_traits <- c( selected_traits, "Species_name")
    }
  }

  # select only the relevant columns
  amniotes <- amniotes[selected_traits]

  names( amniotes ) <- prefixed_column_names( amniotes, "myhrvoid" )

  data <- merge( species_names, amniotes, by.x = binomial_column, by.y = "myhrvoid_Species_name", all.x = TRUE )

  return( setNames( list(
    data,
    nrow(
      merge( species_names, amniotes, by.x = binomial_column, by.y = "myhrvoid_Species_name" )
    ),
    ncol(amniotes)  - 1
  ), c(
    "data",
    "matches",
    "columns"
  )
  ) )
}
