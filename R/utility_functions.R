
# function to add a prefix to the column names of a dataframe
prefixed_column_names <- function( dataframe, prefix ) {

  return( paste( rep( prefix, length( names(dataframe) ) ),
                 names( dataframe ),
                 sep = "_"
  ))
}



# function that, given a list of species names, validates the names and returns a list with three elements:
# $accepted_names is a character vector of the accepted names
# $all_names is a list of character vectors, with each vector containing the accepted name and any synonyms
# $all_names_df is a dataframe containing the Caalogue of Life ID of the species accepted name,
# and synonyms (column names ecol_id and binomial)
# param species_names: a character vector of species names in the format "Genus specific_epithet"

find_synonyms <- function( species_names) {
  # find the Catalogue of Life taxnomic name IDs
  result <- taxize::get_colid( species_names, ask = FALSE )

  # TODO - make a list of the species names that weren't accepted as valid input

  # filter out the valid scientific names
  valid_ids <- result[ which( attr(result, "match") == "found" ) ]
  # invalid_ids <- result[ which( attr(result, "match") != "found" ) ]

  # get the scientific names of the IDs and other information
  scientific_names <- taxize::id2name( valid_ids, db="col" )

  # ditch the taxonomic identifiers which aren't species names (eg. Orders, Classes, Families AND Infraspecific species)
  # NOTE - TODO!! Keep infraspecific taxon names and instead convert them to accepted species names
  tmp <- sapply(scientific_names, function(x) x[["rank"]] == "species")
  scientific_names <- scientific_names[
    which( tmp == TRUE )
    ]
  # TODO - do we need to keep a list of the orders and classes that were ditched?

  # update the list of valid ids
  valid_ids = sapply(scientific_names, function(x) x[["id"]])

  # get the synonyms for the valid scientific names
  synonyms <- taxize::synonyms( valid_ids, db="col" )

  # merge the accepted scientific name and synonyms into single character vector,
  # so that the end result is a list of character vectors

  ret <- list()

  # make a list of all the names available
  ret[["all_names"]] <- list()
  for( id in valid_ids ) {
    ret[["all_names"]][[ id ]] = c(
      scientific_names[[id]][["name"]],
      synonyms[[id]][["name"]]
    )
  }

  # make a data frame of all the names available
  df_ids <- c()
  df_accepted_names <- c()
  df_binomial <- c()

  for( id in valid_ids ) {
    df_ids <- c( df_ids, id )
    df_accepted_names <- c( df_accepted_names, scientific_names[[id]][["name"]] )
    df_binomial <- c( df_binomial, scientific_names[[id]][["name"]] )

    for( synonym in synonyms[[id]][["name"]] ) {
      df_ids <- c( df_ids, id )
      df_accepted_names <- c( df_accepted_names, scientific_names[[id]][["name"]] )
      df_binomial <- c( df_binomial, synonym )
    }
  }

  ret[["all_names_df"]] <- data.frame( df_ids, df_accepted_names, df_binomial )
  colnames( ret[["all_names_df"]] ) <- c( "ecol_id", "accepted_name", "bionomial" )

  # make a dataframe of the synonyms
  df_accepted_names <- c()
  df_synonyms <- c()
  for( id in valid_ids ) {
    df_accepted_names <- c( df_accepted_names, scientific_names[[id]][["name"]] )
    df_synonyms <- c( df_synonyms, paste( synonyms[[id]][["name"]], collapse=", " ) )
  }
  ret[["synonyms"]] <- data.frame( valid_ids, df_accepted_names, df_synonyms )
  colnames( ret[["synonyms"]] ) <- c( "ecol_id", "accepted_name", "synonyms" )

  # make a list of the accepted names, for convenience
  ret[["accepted_names"]] <- unlist( sapply(scientific_names, function(x) x[["name"]]) )

  return( ret )
}
