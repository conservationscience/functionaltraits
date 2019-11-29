
#' Find traits and taxonomic information for a list of species
#' 
#' This function takes a list of species, collects taxonomic information for them, 
#' and then searches the databases for the valid scientific names, as well as any 
#' synonyms that were found. 
#' 
#' The main difference between this function, and \code{Databases::search()}, is that 
#' it also collects taxonomic information, and searches the databases for synonyms.
#' 
#' It returns a dataframe with the following columns (TODO: this is outdated):
#' - species: the species name given in the \code{species} argument
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
#' @param get_common_names=NULL Whether to get common name information as well. This significantly increases the time
#'                              that this function takes to run.
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
  
  sql_integer_list <- function(x){
    if(any(is.na(x))){
      stop("Cannot pass NA into SQL query")
    }
    x <- as.character(x)
    if(!all(grepl('^[0-9]+$', x, perl=TRUE))){
      stop("Found non-integer where integer required in SQL input")
    }
    paste(x, collapse=", ")
  }
  
  taxizedb::db_download_ncbi()
  
  src_ncbi <- src_ncbi()
  
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
    species = species,
    found = rep( FALSE, length( species ) ),
    tsn = rep( NA, length( species ) ),
    accepted_name = rep( NA, length( species) ),
    synonyms = rep( NA, length( species) ),
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
  # STEP ONE: get the taxonomic information
  ######################################
  
  # get NCBI IDs where available (NA if not available)
  results$tsn = sapply( species, taxizedb::name2taxid )
  
  # load accepted names into the results dataframe
  for( tsn in na.omit( unique( results$tsn ) ) ) {
    classification <- taxizedb::classification( tsn )[[tsn]]
    relevant_rows <- which( results$tsn == tsn )
    
    # set taxonomic information
    if( 
      is.data.frame( classification )
      && length( relevant_rows ) != 0
      && length(which(classification$rank == "kingdom")) != 0
      && length(which(classification$rank == "phylum")) != 0
      && length(which(classification$rank == "class")) != 0
      && length(which(classification$rank == "order")) != 0
      && length(which(classification$rank == "family")) != 0
      && length(which(classification$rank == "genus")) != 0
    ) {
      results[relevant_rows, "kingdom" ] <- classification[[which(classification$rank == "kingdom"), "name"]]
      results[relevant_rows, "phylum" ] <- classification[[which(classification$rank == "phylum"), "name"]]
      results[relevant_rows, "class" ] <- classification[[which(classification$rank == "class"), "name"]]
      results[relevant_rows, "order" ] <- classification[[which(classification$rank == "order"), "name"]]
      results[relevant_rows, "family" ] <- classification[[which(classification$rank == "family"), "name"]]
      results[relevant_rows, "genus" ] <- classification[[which(classification$rank == "genus"), "name"]]
    }
    
    # set accepted name
    if( 
      is.data.frame( classification )
      && length( relevant_rows ) != 0
      && length(which(classification$rank == "species")) != 0
    ) {
      results[relevant_rows, "accepted_name" ] <- classification[[which(classification$rank == "species"), "name"]]
      results[relevant_rows, "found" ] <- TRUE
    }
    
    # set common name
    common_names <- sql_collect(src_ncbi, paste0("SELECT * FROM names WHERE tax_id=", tsn, " AND name_class='common name'" ) )
    results[which(results$tsn == tsn), "common_name" ] <- paste0( common_names$name_txt, collapse = ", " )
    
    # set synonyms
    common_names <- sql_collect(src_ncbi, paste0("SELECT * FROM names WHERE tax_id=", tsn, " AND name_class='common name'" ) )
    results[which(results$tsn == tsn), "common_name" ] <- paste0( common_names$name_txt, collapse = ", " )
  }

  
  ######################
  # STEP 3: find synonyms, and make a list of all possible names
  ######################
  
  # get the list of relevant ids
  relevant_tsns <- na.omit( unique( results$tsn ) )
  
  # make a list of all the names available and tsns to match
  query <- "SELECT * FROM names WHERE tax_id IN(%s) AND( name_class='scientific name' OR name_class='synonym')"
  query <- sprintf(query, sql_integer_list( relevant_tsns ))
  search_names <- sql_collect(src_ncbi, query)
  
  search_names <- data.frame(
    tsn = search_names$tax_id,
    species = search_names$name_txt
  )
  
  
  #######################################################
  # STEP 4: search the databases for the synonyms and match back results to the initial list of names that were given
  #######################################################
  
  # TODO - not sure if this will throw an error if traits is NULL
  search_results <- databases$search( search_names$species, traits )
  
  
  
  # add a tsn column
  trait_data <- merge( search_results$results, search_names, by.x = "species", by.y = "species", all.x = TRUE )
  
  # there are multiple rows in the search_results for a single species, 
  # because a species has multiple synonynms
  # so we must compress these into a single row for the species
  
  for( tsn in relevant_tsns ) {
    # get a dataframe containing just the information for one species
    single_species <- trait_data[ which(trait_data$tsn == tsn), ]
    for( column in names( single_species ) ) {
      if( column == "species" || column == "tsn" ) next
      # get the single column, remove all the NA values, and then take the first value available
      # if there are multiple values available, then it's an error in the database, because
      # we just searched for synonyms
      
      results[which(results$tsn == tsn), column] <- na.omit( single_species[[column]] )[1]
    }
  }
  
  return( list(
    results = results,
    statistics = search_results$statistics
  ))
}

