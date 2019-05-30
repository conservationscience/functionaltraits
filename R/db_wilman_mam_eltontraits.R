
#' @include Database.R
#' @include SearchResults.R

db_wilman_mam_eltontraits <- setRefClass( 
  "db_wilman_mam_eltontraits",
  contains = "Database",
  
  methods = list(
    
    filename = function() {
      return( file.path( dir, "MamFuncDat.txt") )
    },
    
    name = function() {
      return( "eltontraits" )
    },
    
    author = function() {
      return( "wilman_mam" )
    },
    
    ready = function() {
      if( file.exists( .self$filename() ) )
        return( TRUE )
      else return( FALSE )
    },
    
    initialise = function() {
      download.file(
        "http://www.esapubs.org/archive/ecol/E095/178/MamFuncDat.txt",
        .self$filename()
      )
    },
    
    columns = function() {
      if( !file.exists( .self$filename() ) )
        stop( paste0( "error - file '", .self$filename(), "' doesn't exist"))
      database = read.table( .self$filename(), sep="\t", header=TRUE, quote="\"" )
      return( names( database ) )
    },
    
    search = function( species_names, selected_traits ) {
      .self$check_traits( selected_traits )
      
      if( !file.exists( .self$filename() ) )
        stop( paste0( "error - file '", .self$filename(), "' doesn't exist"))
      
      database <- read.table( .self$filename(), sep="\t", header=TRUE, quote="\"" )
      
      # ensure taxonomic column is selected
      if( ! "Scientific" %in% selected_traits ) {
        selected_traits <- c( selected_traits, "Scientific")
      }
      
      # read.table converts column names into valid data.frame variable names with
      # make.names, so we need to convert the user-supplied column names with this too
      selected_traits <- make.names( selected_traits )
      
      # select only the relevant columns
      database <- database[selected_traits]
      
      results <- data.frame(
        species = species_names,
        stringsAsFactors = FALSE
      )
      
      data <- merge( results, database, by.x = "species", by.y = "Scientific", all.x = TRUE )
      
      return( new( "SearchResults",
                   results = data,
                   numberOfMatches = nrow( merge( results, database, by.x = "species", by.y = "Scientific" ) ),
                   numberOfColumns = ncol(database) - 1
      ))
    }
  )
)


