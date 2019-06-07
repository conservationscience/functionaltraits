
#' @include Database.R
#' @include SearchResults.R

db_jones_pantheria <- setRefClass( 
  "db_jones_pantheria",
  contains = "Database",
  
  methods = list(
    
    filename = function() {
      return( file.path( dir, "PanTHERIA_1-0_WR05_Aug2008.txt") )
    },
    
    name = function() {
      return( "pantheria" )
    },
    
    author = function() {
      return( "jones" )
    },
    
    ready = function() {
      if( file.exists( .self$filename() ) )
        return( TRUE )
      else {
        warning( "the database file for jones_pantheria has not been downloaded")
        return( FALSE )
      }
    },
    
    initialise = function() {
      download.file(
        "http://esapubs.org/archive/ecol/E090/184/PanTHERIA_1-0_WR05_Aug2008.txt",
        .self$filename()
      )
    },
    
    columns = function() {
      if( !file.exists( .self$filename() ) )
        stop( paste0( "error - file '", .self$filename(), "' doesn't exist"))
      pantheriaDB = read.table( .self$filename(), sep="\t", na.strings = "-999.00", header=TRUE )
      return( names( pantheriaDB ) )
    },
    
    search = function( species_names, selected_traits ) {
      .self$check_traits( selected_traits )
      
      if( !file.exists( .self$filename() ) )
        stop( paste0( "error - file '", .self$filename(), "' doesn't exist"))
      
      pantheriaDB <- read.table( .self$filename(), na.strings = "-999.00", sep="\t", header=TRUE )
      
      # ensure taxonomic column is selected
      if( ! "MSW05_Binomial" %in% selected_traits ) {
        selected_traits <- c( selected_traits, "MSW05_Binomial")
      }
      
      # read.table converts column names into valid data.frame variable names with
      # make.names, so we need to convert the user-supplied column names with this too
      selected_traits <- make.names( selected_traits )
      
      # select only the relevant columns
      pantheriaDB <- pantheriaDB[selected_traits]
      
      df <- data.frame(
        species = species_names,
        stringsAsFactors = FALSE
      )
      
      data <- merge( df, pantheriaDB, by.x = "species", by.y = "MSW05_Binomial", all.x = TRUE )
      
      return( new( "SearchResults",
        results = data,
        numberOfMatches = nrow( merge( df, pantheriaDB, by.x = "species", by.y = "MSW05_Binomial" ) ),
        numberOfColumns = ncol(pantheriaDB) - 1
      ))
    }
  )
)


