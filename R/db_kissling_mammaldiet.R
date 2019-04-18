
db_kissling_mammaldiet <- function( species_names, binomial_column, selected_columns, matches ) {

  # todo - add code with Taxize to recognise species synonyms

  mammaldietDB = read.table( "traitdata/kissling_mammaldiet/MammalDIET_v1.0.txt", sep="\t", header=TRUE, quote="" )

  # create a column with the species name
  mammaldietDB["Species_name"] <- with(mammaldietDB, paste(Genus, Species, sep=" "))
  # ditch the other two columns which aren't needed any more
  #mammaldietDB <- mammaldietDB[ , !(names(mammaldietDB) %in% c("Genus", "Species"))]

  # select all columns if a list isn't provided
  if( is.null( selected_columns ) ) {
    selected_columns <- names( mammaldietDB )
  }
  else {
    # otherwise, make sure that the column with the species name
    # is selected
    if( ! "Species_name" %in% selected_columns ) {
      selected_columns <- c( selected_columns, "Species_name")
    }
  }

  # select only the relevant columns
  mammaldietDB <- mammaldietDB[selected_columns]

  names( mammaldietDB ) <- prefixed_column_names( mammaldietDB, "kissling" )
  data <- merge( species_names, mammaldietDB, by.x = binomial_column, by.y = "kissling_Species_name", all.x = TRUE )

  return( setNames( list(
    data,
    nrow(
      merge( species_names, mammaldietDB, by.x = binomial_column, by.y = "kissling_Species_name" )
    ),
    ncol(mammaldietDB) - 1
  ), c(
    "data",
    "matches",
    "columns"
  )
  ) )
}
