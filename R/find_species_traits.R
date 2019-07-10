
#' Find traits and taxonomic information for a list of species
#' 
#' This function takes a list of species, collects taxonomic information for them, 
#' and then searches the databases for the valid scientific names, as well as any 
#' synonyms that were found. 
#' 
#' The main difference between this function, and \code{Databases::search()}, is that 
#' it also collects taxonomic information, and searches the databases for synonyms.
#' 
#' It returns a dataframe with the following columns:
#' - taxa: the species name given in the \code{species} argument
#' - found: whether or not the species name was recognised by the Catalogue of Life (https://www.catalogueoflife.org/)
#'          taxonomic database.
#' - colid: the ID for the taxonomic name in the Catalogue of Life
#' - synonyms: any synonyms found
#' - accepted_name: the accepted name for the species (according to Catalogue of Life)
#' - common_name: the common name(s) of the species
#' - kingdom, phylum, class, order, family, genus: taxonomic information when available
#' 
#' In addition, it includes all the columns selects via the \code{traits} argument. Columns are preprended
#' with database author's name to ensure that the source of the information can be traced and appropriately
#' cited.
#'
#' @param species A vector of species names in the format "Genus species". Note: if the same name 
#'                is given more than once, the extra occurances are discarded. Consequently, you
#'                cannot be guaranteed that the number of rows in the resulting dataframe has the same
#'                length as the number of species that were given.
#'                
#'                Note that it also removes duplicate species names that are given. It only takes
#'                species names, NOT genus or family names. If genus or other taxonomic ranks are given,
#'                they are ignored.
#'                
#' @param traits=NULL A list of trait databases, with each value being a vector of column names. Eg.
#'                   \code{list( "fishbase" = c( "Weight" ) )} to search fishbase and include the
#'                   Weight column in the output. If \code{NULL}, then all databases and all columns
#'                   will be selected.
#'                   
#'
#' @return A \code{list} with \code{list[["results"]]} being a dataframe containing the list of species
#'         and any matched trait data from the selected columns; and \code{list[["statistics"]]} being
#'         a dataframe containing the number of matches and number of columns selected from each database.
#' @examples
#' find_species_traits( c("Betta splendens"), list( "fishbase" = c( "Weight" ) ))
#' find_species_traits( c("Betta splendens"), list( "pacifici_generationlength" = c( "GenerationLength_d" ) ))
#' find_species_traits( c("Betta splendens"))
#' @export


find_species_traits <- function( databases, species, traits = NULL ) {
  
  ## TODO - check that variables are of appropriate class
  
  species <- unique( species )
  
  # first check if the databases are ready to be searched
  if( !databases$ready() ) {
    stop( "the databases are not ready to be searched. Try running Databases$initialise()")
  }
  
  # check if the selected traits are okay
  if( !is.null( traits ) ) {
    databases$check_traits( traits )
  }
  
  # create the final results dataframe
  results <- data.frame(
    taxa = species,
    found = rep( FALSE, length( species ) ),
    colid = rep( NA, length( species ) ),
    synonyms = rep( NA, length( species) ),
    accepted_name = rep( NA, length( species) ),
    common_name = rep( NA, length( species ) ),
    kingdom = rep( NA, length( species) ),
    phylum = rep( NA, length( species) ),
    class = rep( NA, length( species) ),
    order = rep( NA, length( species) ),
    family = rep( NA, length( species) ),
    genus = rep( NA, length( species) ),
    stringsAsFactors = FALSE
  )
  
  
  ######################################
  # STEP ONE: get the accepted names
  ######################################
  # find the Catalogue of Life taxnomic name IDs
  taxonomic_ids <- taxize::get_colid( species, ask = FALSE )
  
  results[["colid"]] <- taxonomic_ids
  
  # filter out the valid scientific names
  valid_ids <- taxonomic_ids[ which( attr(taxonomic_ids, "match") == "found") ]
  
  # get the scientific names of the IDs and other information
  scientific_names <- taxize::id2name( valid_ids, db="col" )
  
  # loop through each of the valid names
  for( colid in names( scientific_names ) ) {
    
    # set the accepted name if it is available
    if( scientific_names[[colid]][["rank"]] == "species" 
        && scientific_names[[colid]][["status"]] == "accepted name" ) 
      {
      results[[ which(results$colid == colid), "accepted_name" ]] <- scientific_names[[colid]][["name"]]
      results[[ which(results$colid == colid), "found" ]] <- TRUE
    }
    
  }
  
  # filter out any names which aren't valid species names (eg. are genus names, or family names)
  # update the list of valid ids
  valid_ids <- results[ which( results$found == TRUE), "colid" ]
  
  ######################################################
  # Step 2: add the taxonomic information to the output
  ######################################################
  taxonomy <- taxize::classification( na.omit( results$accepted_name ), db = 'itis' )
  
  for( species_name in names( taxonomy ) ) {
    species_taxonomy <- taxonomy[[species_name]]
    
    if( 
          is.data.frame( species_taxonomy )
          && length(which(results$accepted_name == species_name)) != 0
          && length(which(species_taxonomy$rank == "kingdom")) != 0
          && length(which(species_taxonomy$rank == "phylum")) != 0
          && length(which(species_taxonomy$rank == "class")) != 0
          && length(which(species_taxonomy$rank == "order")) != 0
          && length(which(species_taxonomy$rank == "family")) != 0
          && length(which(species_taxonomy$rank == "genus")) != 0
          ) {
      results[[which(results$accepted_name == species_name), "kingdom" ]] <-
        species_taxonomy[[which(species_taxonomy$rank == "kingdom"), "name"]]
      results[[which(results$accepted_name == species_name), "phylum" ]] <-
        species_taxonomy[[which(species_taxonomy$rank == "phylum"), "name"]]
      results[[which(results$accepted_name == species_name), "class" ]] <-
        species_taxonomy[[which(species_taxonomy$rank == "class"), "name"]]
      results[[which(results$accepted_name == species_name), "order" ]] <-
        species_taxonomy[[which(species_taxonomy$rank == "order"), "name"]]
      results[[which(results$accepted_name == species_name), "family" ]] <-
        species_taxonomy[[which(species_taxonomy$rank == "family"), "name"]]
      results[[which(results$accepted_name == species_name), "genus" ]] <-
        species_taxonomy[[which(species_taxonomy$rank == "genus"), "name"]]
    }
  }
  
  
  ######################
  # STEP 3: find synonyms, and make a list of all possible names
  ######################
  
  # find the synonyms for the valid ids
  synonyms <- taxize::synonyms( valid_ids, db="col" )
  
  # make a list of all the names available and colids to match
  all_names <- c()
  colids <- c()
  for( colid in names( synonyms ) ) {
    # add the accepted name
    all_names <- c( all_names, scientific_names[[colid]][["name"]] )
    colids <- c( colids, colid )
    
    # add the synonyms
    all_names <- c( all_names, synonyms[[colid]][["name"]] )
      # add as many colid's as we added synonyms
    colids <- c( colids, rep( colid, length( synonyms[[colid]][["name"]] )))
    
    # while we are looping through the species, we can add the synonyms to the final dataframe
    if( length( synonyms[[colid]][["name"]] ) > 0 ) {
      results[[ which(results$colid == colid), "synonyms" ]] <- paste( 
        synonyms[[colid]][["name"]], collapse=", "
      )
    }
  }
  
  intermediate_results <- data.frame(
    colid = colids,
    taxa = all_names,
    stringsAsFactors = FALSE
  )
  # have to continue from here
  
  
  #######################################################
  # STEP 4: search the databases and match back results to the initial list of names that were given
  #######################################################
  
  # TODO - not sure if this will throw an error if traits is NULL
  search_results <- databases$search( all_names, traits )
  
  # add an ecolid column
  trait_data <- merge( search_results$results, intermediate_results, by.x = "taxa", by.y = "taxa", all.x = TRUE )
  
  # there are multiple rows in the search_results for a single species, 
  # because a species has multiple synonynms
  # so we must compress these into a single row for the species
  
  for( colid in valid_ids ) {
    # get a dataframe containing just the information for one species
    single_species <- trait_data[ which(trait_data$colid == colid), ]
    for( column in names( single_species ) ) {
      if( column == "taxa" || column == "colid" ) next
      # get the single column, remove all the NA values, and then take the first value available
      # if there are multiple values available, then it's an error in the database, because
      # we just searched for synonyms
      
      results[which(results$colid == colid), column] <- na.omit( single_species[[column]] )[1]
    }
  }
  
  ######################################################
  # Step 5: add common names to the output
  ######################################################
  common_names <- taxize::sci2comm( na.omit( results[["accepted_name"]] ), db = "itis", simplify = TRUE )
  
  for( taxa in names( common_names ) ) {
    t <- taxa
    if( !is.na( common_names[[taxa]] ) && length( common_names[[taxa]] > 0) ) {
      results[[which(results$accepted_name == taxa), "common_name" ]] <- paste0( common_names[[taxa]], collapse = ", " )
    }
  }
  
  return( list(
    results = results,
    statistics = search_results$statistics
  ))
}

