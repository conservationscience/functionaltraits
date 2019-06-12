
#' @include Database.R
#' @include SearchResults.R

db_oliveira_amphibio <- setRefClass( 
  "db_oliveira_amphibio",
  contains = "Database",
  
  methods = list(
    
    filename = function() {
      return( file.path( dir, "AmphiBIO_v1.csv") )
    },
    
    name = function() {
      return( "amphibio" )
    },
    
    author = function() {
      return( "oliveira" )
    },
    
    ready = function() {
      if( file.exists( .self$filename() ) )
        return( TRUE )
      else {
        warning( "the database file for oliveira_amphibio has not been downloaded")
        return( FALSE )
      }
    },
    
    initialise = function() {
      download.file(
        "https://ndownloader.figshare.com/files/8828578",
        file.path( dir, "amphibio.zip"),
        mode = "wb"
      )
      utils::unzip(
        file.path( dir, "amphibio.zip" ),
        files="AmphiBIO_v1.csv",
        exdir= dir
      )
    },
    
    columns = function() {
      if( !file.exists( .self$filename() ) )
        stop( paste0( "error - file '", .self$filename(), "' doesn't exist"))
      database = read.table( .self$filename(), sep=",", na.strings="NA", header=TRUE )
      return( names( database ) )
    },
    
    search = function( species_names, selected_traits ) {
      .self$check_traits( selected_traits )
      
      if( !file.exists( .self$filename() ) )
        stop( paste0( "error - file '", .self$filename(), "' doesn't exist"))
      
      database <- read.table( .self$filename(), sep=",", na.strings="NA", header=TRUE )
      
      # ensure taxonomic column is selected
      if( ! "Species" %in% selected_traits ) {
        selected_traits <- c( selected_traits, "Species")
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
      
      data <- merge( results, database, by.x = "species", by.y = "Species", all.x = TRUE )
      
      return( new( "SearchResults",
                   results = data,
                   numberOfMatches = nrow( merge( results, database, by.x = "species", by.y = "Species" ) ),
                   numberOfColumns = ncol(database) - 1
      ))
    }
  )
)


