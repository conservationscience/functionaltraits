
#' Abstract base class for databases
#' 
#' This class is an interface defining the functions that database classes (db_xxx.R) must implement.
#' It is not intented for use by end-users, however if you wish to add your own database to this
#' package, you can create a file db_databaseauthor_databasename.R and add a class that "contains" 
#' this class, in a similar manner to how the other db_xxx.R files are constructed. 
#' 
#' The functions that subclasses (classes in db_xxx.R files) must implement are the functions
#' which contain the "stop" function, which means that an error will be thrown if the subclass
#' does not implement that function. 
#'
#' @field dir character containing the path to this database's folder where it can store data.

Database <- setRefClass( "Database",
  fields = list(
    dir  = "character"
  ),
  
  methods = list(
    
    # the author of the database
    author = function() { stop( paste0(class(.self), "does not implement method 'author'" ) ) },
    
    # the name of the database
    name = function() { stop( paste0(class(.self), "does not implement method 'name'" ) ) },
    
    # full name of the database
    full_name = function() { 
      if( .self$name() == "" ) return( .self$author() )
      else return( paste0( .self$author(), "_", .self$name() ) ) 
    },
    
    # whether the database is ready for use (either downloaded or connected to the internet)
    # when this function returns FALSE, it should also provide a warning message via warning()
    ready = function() { stop( paste0(class(.self), "does not implement method 'ready'" ) ) },
    
    # connect to the database, eg. through an access token or by downloading the file
    initialise = function() { stop( paste0(class(.self), "does not implement method 'initialise'" ) ) },
    
    # get the list of columns that are available from the database (once it is ready)
    columns = function() { stop( paste0(class(.self), "does not implement method 'initialise'" ) ) },
    
    # check whether the provided species_names and traits are valid
    check_traits = function( selected_traits ) {
      # convert them both into comparable formats, 
      # because often the original column names are modified a bit when
      # they are loaded from a CSV file into a dataframe
      available_traits <- make.names( .self$columns() )
      selected_traits <- make.names( selected_traits )
      # are the selected traits available from this databases
      if( !all(selected_traits %in% available_traits ) ) {
        
        # find the trait that isn't available
        unavailable_traits <- selected_traits[!selected_traits %in% available_traits]
        stop( paste0("functionaltraits: the trait(s) '", paste0(unavailable_traits, collapse=", "),
                     "' are not available in the '", .self$full_name(),"' database") )
      }
    },
    
    # search the database for a list of species and specified traits
    # takes species_names, selected_traits (character vector) and classification
    search = function() { stop( paste0(class(.self), "does not implement method 'search'" ) ) }
  )
)




