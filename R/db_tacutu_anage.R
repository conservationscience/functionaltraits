
db_tacutu_anage <- function( species_names, binomial_column, selected_columns, matches ) {

  # todo - add code with Taxize to recognise species synonyms

  anageDB = read.table( "traitdata/tacutu_anage/anage_data.txt", sep="\t", header=TRUE, quote="" )

  # create a column with the species name
  anageDB["Species_name"] <- with(anageDB, paste(Genus, Species, sep=" "))
  
  
  # select all columns if a list isn't provided
  if( is.null( selected_columns ) ) {
    selected_columns <- names( anageDB )
  }
  else {
    # if a list is proivided, turn all of '() ' into dots
    selected_columns <- gsub( " ", ".", selected_columns, fixed=TRUE )
    selected_columns <- gsub( "(", ".", selected_columns, fixed=TRUE )
    selected_columns <- gsub( ")", ".", selected_columns, fixed=TRUE )
    # otherwise, make sure that the column with the species name
    # is selected
    if( ! "Species_name" %in% selected_columns ) {
      selected_columns <- c( selected_columns, "Species_name")
    }
  }

  # select only the relevant columns
  anageDB <- anageDB[ selected_columns ]


  names( anageDB ) <- prefixed_column_names( anageDB, "tacutu" )
  data <- merge( species_names, anageDB, by.x = binomial_column, by.y = "tacutu_Species_name", all.x = TRUE )

  return( setNames( list(
    data,
    nrow(
      merge( species_names, anageDB, by.x = binomial_column, by.y = "tacutu_Species_name" )
    ),
    ncol(anageDB) - 1
  ), c(
    "data",
    "matches",
    "columns"
  )
  ) )
}
