
databases <- list(
  "earnst_mammals" = db_earnst_mammals,
  "fishbase" = db_fishbase,
  "jones_pantheria" = db_jones_pantheria,
  "kissling_mammaldiet" = db_kissling_mammaldiet,
  "lislevand_avian" = db_lislevand_avian,
  "myhrvold_amniotes" = db_myhrvold_amniotes,
  "oliveira_amphibio" = db_oliveira_amphibio,
  "pacifici_generationlength" = db_pacifici_generationlength,
  "slavenko_reptiles" = db_slavenko_reptiles,
  "tacutu_anage" = db_tacutu_anage,
  "wilman_eltontraitsbirds" = db_wilman_eltontraitsbirds,
  "wilman_eltontraitsmammals" = db_wilman_eltontraitsmammals
)

# This would be the final function that given a list of species names, would return
# a dataframe with all of the relevant traits.

# param species_names: vector of strings, each of a binomial species name in the format "Genus species".
#                      whitepace is trimmed if present from either side of the string

# selected columns is a list; the name of each element is the database (exactly as written in the
# database_functions folder), and the value being a vector of the column names (exactly as written
# in the databases themselves, INCLUDING spaces between words)


#' Find traits for a list of species
#'
#' @param species A vector of species names in the format "Genus species"
#' @param attributes=NULL A list of trait databases, with each value being a vector of column names. Eg.
#'                   \code{list( "fishbase" = c( "Weight" ) )} to search fishbase and include the
#'                   Weight column in the output. If \code{NULL}, then all databases and all columns
#'                   will be selected.
#' @return A \code{list} with \code{list[["traits"]]} being a dataframe containing the list of species
#'         and any matched trait data from the selected columns.
#' @examples
#' find_species_traits( c("Betta splendens"), list( "fishbase" = c( "Weight" ) ))
#' find_species_traits( c("Betta splendens"), list( "pacifici_generationlength" = c( "GenerationLength_d" ) ))
#' find_species_traits( c("Betta splendens"))
#' @export
find_species_traits <- function( species, attributes = NULL ) {

  # if the attributes variable is not supplied, then assume all databases and all columns
  if( is.null( attributes ) ) {
    attributes <- list()
    for( database_name in names( databases ) ) {
      attributes[[ database_name ]] <- NA
    }

  }


  dbfiles <- list()

  # firstly check if the attributes variable is correctly formatted
  for( database_name in names( attributes ) ) {
    if( !database_name %in% names( databases ) ) {
      cat( paste("in function find_species_attributes: unknown database '", database_name,
                 "'. Is it spelt correctly in the 'attributes' variable?") )
      return( NULL )
    }
  }

  # now we can assume all of the databases given in the attribute variable are valid
  # however at this point we don't know if the column names are valid

  # find the synonyms
  species_names <- find_synonyms( species )

  # create the data frame which we will add trait columns to
  # it has a list of all the synonyms, and the database accessing functions treat each synonym like
  # a separate species. We will therefore need to merge the data for the separate synoynms later
  data <- species_names[["all_names_df"]]
  colnames( data ) <- c( "ecol_id", "Accepted name", "Species" )

  # add the synonyms to the data for convenience, as a list of synonyms
  # we do this now so that the dataframe ends up in the right order
  data <- merge( data, species_names[["synonyms"]][, c("ecol_id", "synonyms") ], by.x = "ecol_id", by.y = "ecol_id", all.x = TRUE )

  ret <- list()

  ret[["matches"]] <- data.frame(matrix(ncol = 3, nrow = 0))

  # load the functions for accessing the different databases
  # TODO: make folder configurable
  # TODO: only load these functions once (?) otherwise inefficient
  for( database_name in names( attributes ) ) {
    cat( paste( "loading '", database_name, "'\n", sep="" ) )

    # load the file with the function that accesses the database
    # the function in each file that is loaded is called "collect_traits"
    # it is overwritten each time the loop is run
    # the collect_traits function takes a dataframe with a column of Species names
    # in the format of "Genus species" (no quotes), a variable with the name of this column,
    # and a list of columns to extract from the database
    # if the list of columns is NULL, then the function must get all available
    # attributes

    database_function <- databases[[database_name]]

    columns <- NULL

    if( !is.null(attributes) && !is.na( attributes[[database_name]])) {
      columns <- attributes[[ database_name ]]
    }

    result <- database_function( data, "Species", columns, database_matches )
    data <- result[["data"]]

    ret[["matches"]] <- rbind( ret[["matches"]], data.frame(
      database_name, result[["matches"]], result[["columns"]] )
    )
  }

  colnames( ret[["matches"]] ) <- c( "database_name", "no_of_matches", "no_of_traits_selected")

  # now we have a dataframe with rows, where each row has a species name (can be synonyms of the same species),
  # so we have to find all the synonyms and merge their data together
  # the column ecol_id has the same value for each species

  ## NOTE AND TODO: when a database contains the same species TWICE, under different synonyms,
  # and has a value for a trait for each listing of the species, this bit of code simply takes
  # the first trait value from the database and omits the second. This should be a rare case
  # as a database should really not have the same species listed twice under different synonyms.


  mergeddata <- aggregate( data, list(data[,"ecol_id"]), function(x){
    x = na.omit(x)
    if( is.null(x)) return(NA)
    else return(x[1])
  } )

  # drop the Species column as the aggregate function messes up the species name with the synonyms
  mergeddata <- mergeddata[ , !(names(mergeddata) %in% c("Species", "Group.1"))]


  ret[["traits"]] <- mergeddata

  return( ret )
}

