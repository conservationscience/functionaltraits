
#' @include Database.R
#' @include SearchResults.R

db_fishbase <- setRefClass( 
  "db_fishbase",
  contains = "Database",
  
  methods = list(
    
    name = function() {
      return( "" )
    },
    
    author = function() {
      return( "fishbase" )
    },
    
    ready = function() {
      # assume an internet connection exists and that fishbase is up
      # TODO - write a function that actually checks if a connection exists
      return( TRUE )
    },
    
    initialise = function() {
      # no need to initialise anything
    },
    
    columns = function() {
      return( names( rfishbase::species(c("Oncorhynchus apache"), server="fishbase") ) )
    },
    
    search = function( species_names, selected_traits ) {
      .self$check_traits( selected_traits )
      
      # ensure taxonomic column is selected
      if( ! "Species" %in% selected_traits ) {
        selected_traits <- c( selected_traits, "Species")
      }
      
      # select only the relevant columns
      database <- rfishbase::species( as.character( species_names ), fields=selected_traits )
      
      results <- data.frame(
        species = species_names,
        stringsAsFactors = FALSE
      )
      
      data <- merge( results, database, by.x = "species", by.y = "Species", all.x = TRUE )
      
      return( new( "SearchResults",
                   results = data,
                   numberOfMatches = nrow( merge( results, database, by.x = "species", by.y = "Species" ) ),
                   numberOfColumns = ncol(database) - 1
      ))
    }
  )
)


