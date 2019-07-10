
#' Search, download manage databases
#' 
#' The class \code{Databases} handles initialising databases (eg. downloading relevant files)
#' and dispatching requests to each database for searching them.
#' 
#' Note that this class does not handle synonym-checking; this is performed by the 
#' \code{\link{find_species_traits}} function. This class also has a custom $new function, which
#' takes two arguments: \code{directory}, which is the directory that 
#' you want to store downloaded database files in (usually CSV or Excel files); and 
#' \code{database_classes}, which is a list of the databases you would like it to 
#' manage. It defaults to \\code{functionaltraits_db_list}, which includes all available databases.
#' If a database is causing errors or cannot connect to the server and is causing the ready() function
#' to fail, then you can omit it from this argument and it will not be included."
#' 
#' @field dir character containing the path to a folder that all of the database files will be downloaded to
#' @field databases a list with the names of the databases as the key and the value being the actual
#'        class of the database.
#' 
#' @include database_list.R
#' @export Databases
Databases <- setRefClass( "Databases",
  fields = list(
    dir  = "character",
    databases = "list"
  ),
  
  methods = list(
    initialize = function( directory, database_classes = NULL ) {
      .self$dir <- directory
      
      # create the base data directory if it doesn't exist
      if( !dir.exists( .self$dir ) ) {
        dir.create( .self$dir, recursive = TRUE )
      }
      
      if( is.null( database_classes ) )
        database_classes <- database_list
      
      for( database_class in database_classes ) {
        db <- database_class$new()
        db$dir <- file.path( .self$dir, db$full_name() )
        
        # create the database's subdirectory if it doesn't exist
        if( !dir.exists( db$dir ) ) {
          dir.create( db$dir, recursive = TRUE )
        }
        
        .self$databases[[ db$full_name() ]] <- db
      }
    },
    
    drop = function( database_name ) {
      "This function removes a database. It can be used if a database cannot properly configure itself using the $initialise() 
      function and consequently would not return TRUE when $ready() is called. It takes one argument, database_name, which is 
      a string containing the name of the database that you want to remove."
      if( database_name %in% names( .self$databases ) ) {
        .self$databases[[database_name]] <- NULL
      }
      else {
        stop( paste0("no such database '", database_name, "'") )
      }
    },
    
    check_traits = function( traits ) {
      "This function takes one argument, \\code{traits}, and checks whether it is a validly formatted
      list. The names of the list elements must correspond to the names of the databases as provided
      in \\code{database_classes} to the $new function, and the elements must be vectors containing
      the names of the columns selected from the database. If the list is not valid, this function
      will throw an error explaining why."
      if( !is.list( traits ) ) { stop("you must specify traits as a list(). See ?find_species_traits") }
      
      # check that the traits are available from the databases
      for( database_name in names( traits ) ) {
        selected_traits <- make.names( traits[[database_name]] )
        available_traits <- make.names( .self$databases[[ database_name ]]$columns() )
        
        # TODO
        # is the selected_traits variable a vector?
        if( !is.vector( selected_traits ) ) 
          stop( paste0( "error - the variable selected_traits has to be supplied as a vector ",
                        "(check your arguments passed to find_species_traits or Databases::search()"))
        
        # are the selected traits in the columns available from the databases
        if( !all(selected_traits %in% available_traits ) ) {
          
          # find the trait that isn't available
          unavailable_traits <- selected_traits[!selected_traits %in% available_traits]
          stop( paste0("functionaltraits: the trait(s) '", paste0(unavailable_traits, collapse=", "),
                       "' are not available in the '", database_name,"' database") )
        }
      }
    },
    
    ########## methods that are the same as contained classes
    # whether the database is ready for use (either downloaded or connected to the internet)
    ready = function() {
      "This function checks whether all the databases are ready for use. If they are, it returns TRUE.
      If not, it returns FALSE. Each database that is not ready will print a warning message."
      results <- c()
      for( db in .self$databases ) {
        results <- c( results, db$ready() )
      }
      return( all(results) )
    },
    
    # connect to the database, eg. through an access token or by downloading the file
    initialise = function() {
      "This functions initialises the databases if they are not already initialised."
      for( db in .self$databases ) {
        
        if( suppressWarnings( !db$ready() ) ) {
          db$initialise()
        }
      }
    },
    
    # get the list of columns that are available from the database (once it is ready)
    columns = function() {
      "This function returns a list of all columns that are available for each database, in
      a format suitable to be provided to $search or $check_traits. You can use it to find out
      what columns are available and what their names are."
      ret <- list()
      for( db in .self$databases ) {
        if( db$ready() ) {
          ret[[ db$full_name() ]] <- db$columns()
        }
      }
      return( ret )
    },
    
    # search the database for a list of species and specified traits
    search = function( species, traits = NULL) {
      "This function takes one argument, \\code{species} and searches the databases for those species.
      It can optionally take another argument, \\code{traits}, which is a list of the traits to return 
      from each database. It is a list of vectors, where the name of each list element is
      the name of a database and the vectors hold the names of the traits to return, 
      eg. list( fishbase = c( 'Weight' ) ). 
      
      It returns a list, with one element \\code{results} containing a dataframe of the results; 
      and another element \\code{statistics} being a dataframe with the number of matches and columns
      selected from each database.
      
      Note that duplicate species are removed from the list using unique(), so the dataframe that is returned
      is not guaranteed to have the same amount of rows as the number of species provided (unless you run
      unique() on your list of species first)."
      
      species <- unique( species )
      
      # firstly check if all of the databases are ready and available
      for( database_name in names( traits ) ) {
        if( is.null( .self$databases[[ database_name ]] ) ) {
          stop( paste0("functionaltraits: Unknown database '", database_name,"'. Is it spelt correctly?") )
        }
        if( !.self$databases[[ database_name ]]$ready() ) {
          stop( paste0("functionaltraits: database '", database_name,"' is not ready. ",
                      "Have you run Databases$initialise() yet?") )
        }
      }
      
      # if no traits are provided, assume that the user wants all the traits from all databases
      if( is.null( traits ) ) {
        traits <- .self$columns()
      }
      # otherwise check that the user-supplied traits are A-okay
      else {
        .self$check_traits( traits )
    }
      
      # prepare the results data frame
      results <- data.frame(
        taxa = species,
        stringsAsFactors = FALSE
      )
      
      # prepare the summary statistics data frame
      statistics <- data.frame(
        database = names( traits ),
        number_of_matches = rep( NA, length( names( traits ) ) ),
        number_of_columns_selected = rep( NA, length( names( traits ) ) ),
        stringsAsFactors = FALSE
      )
      
      # search each database for the traits
      for( database_name in names( traits ) ) {
        cat( paste( "searching '", database_name, "'\n", sep="" ) )
        
        # in the case that no columns are selected
        if( is.null( traits[[database_name]] ) || length( traits[[database_name ]]) == 0 ) {
          statistics[ which(statistics$database == database_name), "number_of_matches" ] <- "0"
          statistics[ which(statistics$database == database_name), "number_of_columns_selected" ] <- "0"
          next
        }
        
        search_results <- .self$databases[[ database_name ]]$search( species, traits[[ database_name ]] )
        
        # prepend the author name to the results
        names( search_results@results ) <-
          paste( 
            rep( .self$databases[[ database_name ]]$author(), length( names( search_results@results ) ) ),
            names( search_results@results ),
            sep = "_"
          )
        
        # add new columns to the results
        results <- merge( results, search_results@results, by.x = "taxa", 
                          # also have to prepend author name to the species column name
                          by.y = paste0(.self$databases[[ database_name ]]$author(), "_species"), all.x = TRUE )
  
        statistics[ which(statistics$database == database_name), "number_of_matches" ] <- search_results@numberOfMatches
        statistics[ which(statistics$database == database_name), "number_of_columns_selected" ] <- search_results@numberOfColumns
        
      }
      
      return( list(
        results = results,
        statistics = statistics
      ) )
    }
  )
)
