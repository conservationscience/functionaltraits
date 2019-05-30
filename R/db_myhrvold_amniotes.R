
#' @include Database.R
#' @include SearchResults.R

db_myhrvold_amniotes <- setRefClass( 
  "db_myhrvold_amniotes",
  contains = "Database",
  
  methods = list(
    
    filename = function() {
      return( file.path( dir, "Amniote_Database_Aug_2015.csv") )
    },
    
    name = function() {
      return( "amniotes" )
    },
    
    author = function() {
      return( "myhrvold" )
    },
    
    ready = function() {
      if( file.exists( .self$filename() ) )
        return( TRUE )
      else return( FALSE )
    },
    
    initialise = function() {
      download.file(
        "http://www.esapubs.org/archive/ecol/E096/269/Data_Files/Amniote_Database_Aug_2015.csv",
        .self$filename()
      )
    },
    
    columns = function() {
      if( !file.exists( .self$filename() ) )
        stop( paste0( "error - file '", .self$filename(), "' doesn't exist"))
      database = read.table( .self$filename(), sep=",", na.strings="-999", header=TRUE, quote="\"" )
      return( names( database ) )
    },
    
    search = function( species_names, selected_traits ) {
      .self$check_traits( selected_traits )
      
      if( !file.exists( .self$filename() ) )
        stop( paste0( "error - file '", .self$filename(), "' doesn't exist"))
      
      database <- read.table( .self$filename(), sep=",", na.strings="-999", header=TRUE, quote="\"" )
      
      # create a column with the species name
      database["Species_name"] <- with(database, paste(genus, species, sep=" "))
      
      # ensure taxonomic column is selected
      if( ! "Species_name" %in% selected_traits ) {
        selected_traits <- c( selected_traits, "Species_name")
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
      
      data <- merge( results, database, by.x = "species", by.y = "Species_name", all.x = TRUE )
      
      return( new( "SearchResults",
                   results = data,
                   numberOfMatches = nrow( merge( results, database, by.x = "species", by.y = "Species_name" ) ),
                   numberOfColumns = ncol(database) - 1
      ))
    }
  )
)


