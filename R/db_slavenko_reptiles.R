
#' @include Database.R
#' @include SearchResults.R

db_slavenko_reptiles <- setRefClass( 
  "db_slavenko_reptiles",
  contains = "Database",
  
  methods = list(
    
    filename = function() {
      return( file.path( dir, "appendix_s2_body_sizes_of_all_extant_reptiles.xlsx") )
    },
    
    name = function() {
      return( "reptiles" )
    },
    
    author = function() {
      return( "slavenko" )
    },
    
    ready = function() {
      if( file.exists( .self$filename() ) )
        return( TRUE )
      else return( FALSE )
    },
    
    initialise = function() {
      download.file(
        "http://www.gardinitiative.org/uploads/2/2/6/0/22600882/appendix_s2_body_sizes_of_all_extant_reptiles.xlsx",
        .self$filename()
      )
    },
    
    database = function() {
      if( !file.exists( .self$filename() ) )
        stop( paste0( "error - file '", .self$filename(), "' doesn't exist"))
      
      database = readxl::read_excel( .self$filename() )
      # convert logged data to non-logged data
      unlogged_data = database[["Maximum mass (log10(g))"]]
      unlogged_data = 10^unlogged_data
      
      # NOTE - check if rounding to 2 decimal places is okay with the team
      unlogged_data <- round(unlogged_data, 2)
      database["Maximum_mass_g"] <- unlogged_data
      return( database )
    },
    
    columns = function() {
      if( !file.exists( .self$filename() ) )
        stop( paste0( "error - file '", .self$filename(), "' doesn't exist"))
      
      return( names( .self$database() ) )
    },
    
    search = function( species_names, selected_traits ) {
      .self$check_traits( selected_traits )
      
      database <- .self$database()
      
      # ensure taxonomic column is selected
      if( ! "Binomial" %in% selected_traits ) {
        selected_traits <- c( selected_traits, "Binomial")
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
      
      data <- merge( results, database, by.x = "species", by.y = "Binomial", all.x = TRUE )
      
      return( new( "SearchResults",
                   results = data,
                   numberOfMatches = nrow( merge( results, database, by.x = "species", by.y = "Binomial" ) ),
                   numberOfColumns = ncol(database) - 1
      ))
    }
  )
)


