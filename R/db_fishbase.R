
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
      # note -- we can't use rfishbase::species_fields, because that variable doesn't hold all of the information
      # that is available from rfishbase::species()
      columns <- names( rfishbase::species( c("Thunnus alalunga"), server = "fishbase" ) )
      columns <- c( columns, c("DietTroph") )
      return( columns )
    },
    
    search = function( species_names, selected_traits ) {
      .self$check_traits( selected_traits )
      
      # ensure taxonomic column is selected
      if( ! "Species" %in% selected_traits ) {
        selected_traits <- c( selected_traits, "Species")
      }
      
      results <- data.frame(
        species = species_names,
        stringsAsFactors = FALSE
      )
      
      # add special case for DietTroph
      if( "DietTroph" %in% selected_traits ) {
        results$DietTroph <- rep( NA, length( species_names ) )
        
        ecology <- rfishbase::ecology( as.character( species_names ), server="fishbase" )
        ecology <- ecology[c("Species", "DietTroph")]
        
        # find each species that was returned but remove any NA values for species which weren't found
        for( species in na.omit(unique( ecology$Species ) ) ) {
          diettroph_values <- ecology[which(ecology$Species == species), "DietTroph"][["DietTroph"]]
          diettroph_values <- na.omit( unique( diettroph_values ) )
          
          
          if( length( diettroph_values ) == 1 ) {
            results[[ which( results$species == species ), "DietTroph"]] <- diettroph_values
          }
          else if( length( diettroph_values ) > 1 ) {
            warning( paste0(
              "ignoring fishbase::DietTroph data for species '", species,
              "', because multiple values are available"
            ))
          }
          # if there are no values, they must have been NA anyway; so just continue with the loop
        }
        
        # remove DietTroph from selected_traits, because we have already gotten the data
        # and it isn't available in the rfishbase::species function
        selected_traits <- selected_traits[ !(selected_traits %in% "DietTroph") ]
      }
      
      # select only the relevant columns
      database <- rfishbase::species( as.character( species_names ), fields=selected_traits )
      
      data <- merge( results, database, by.x = "species", by.y = "Species", all.x = TRUE )
      
      return( new( "SearchResults",
                   results = data,
                   numberOfMatches = nrow( merge( results, database, by.x = "species", by.y = "Species" ) ),
                   numberOfColumns = ncol(database) - 1
      ))
    }
  )
)


