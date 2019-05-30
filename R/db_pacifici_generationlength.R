
#' @include Database.R
#' @include SearchResults.R

db_pacifici_generationlength <- setRefClass( 
  "db_pacifici_generationlength",
  contains = "Database",
  
  methods = list(
    
    filename = function() {
      return( file.path( dir, "pacifici_generationlength.xls") )
    },
    
    name = function() {
      return( "generationlength" )
    },
    
    author = function() {
      return( "pacifici" )
    },
    
    ready = function() {
      if( file.exists( .self$filename() ) )
        return( TRUE )
      else return( FALSE )
    },
    
    initialise = function() {
      download.file(
        "http://natureconservation.pensoft.net//lib/ajax_srv/article_elements_srv.php?action=download_suppl_file&instance_id=31&article_id=1343",
        .self$filename()
      )
    },
    
    columns = function() {
      if( !file.exists( .self$filename() ) )
        stop( paste0( "error - file '", .self$filename(), "' doesn't exist"))
      database = readxl::read_excel( .self$filename() )
      return( names( database ) )
    },
    
    search = function( species_names, selected_traits ) {
      .self$check_traits( selected_traits )
      
      if( !file.exists( .self$filename() ) )
        stop( paste0( "error - file '", .self$filename(), "' doesn't exist"))
      
      database <- readxl::read_excel( .self$filename() )
      
      # ensure taxonomic column is selected
      if( ! "Scientific_name" %in% selected_traits ) {
        selected_traits <- c( selected_traits, "Scientific_name")
      }
      
      # read.table converts column names into valid data.frame variable names with
      # make.names, so we need to convert the user-supplied column names with this too
      selected_traits <- make.names( selected_traits )
      
      # have to then convert the names in the excel database to make.names format too
      names(database) <- make.names( names(database) )
      
      # select only the relevant columns
      database <- database[selected_traits]
      
      results <- data.frame(
        species = species_names,
        stringsAsFactors = FALSE
      )
      
      data <- merge( results, database, by.x = "species", by.y = "Scientific_name", all.x = TRUE )
      
      return( new( "SearchResults",
                   results = data,
                   numberOfMatches = nrow( merge( results, database, by.x = "species", by.y = "Scientific_name" ) ),
                   numberOfColumns = ncol(database) - 1
      ))
    }
  )
)


