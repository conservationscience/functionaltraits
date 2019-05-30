

#' Compute a column from species traits
#' 
#' This is a simple helper function which allows you to compute a column based on 
#' a row (a single species) from the output of find_species_traits or Databases::search().
#' For example, you may search multiple databases for body mass information, and have multiple
#' bodymass values for a single species. You can use this helper function to calculate a single
#' value for the species.
#' 
#' Alternatively, you may need to process trait information in some way. This function
#' can also help you do that.
#'
#' @param input A dataframe (usually returned from \code{\link{find_species_traits}} or 
#'              \code{Databases::search()}
#               where each row represents a species and each column holds trait information.

#' @param calculator A function that calculates a value for the species. It takes a single argument,
#'                   which is a list where the name of the list is the same as the column names in the
#'                   \code{input} dataframe, and the values are the values for this species.
#' 
#' @return A \code{vector} with a length equivalent to the number of rows in the \code{input} dataframe,
#'         where each value is the result of applying the \code{calculator} function to the row of the
#'         dataframe.
#'  
#' @examples
#' input <- data.frame( 
#'   species_name = c( "Equus quagga", "Ursus maritimus", "Tachyglossus aculeatus" ),
#'   bodymass_from_database1 = c( 25, 120, 80 ),
#'   bodymass_from_database2 = c( 27, 126, 79 )
#' )
#' 
#' input$mean_bodymass = compute_column( input, function( species ) {
#'   bodymass_values = c( species[["bodymass_from_database1"]], species[["bodymass_from_database2"]] )
#'   return( mean( bodymass_values ) )
#' })
#' 
#' print(input)
#' #             species_name bodymass_from_database1 bodymass_from_database2 mean_bodymass
#' # 1           Equus quagga                      25                      27          26.0
#' # 2        Ursus maritimus                     120                     126         123.0
#' # 3 Tachyglossus aculeatus                      80                      79          79.5
#' @export

compute_column <- function( input, calculator ) {
  
  output <- data.frame(
    computed <- rep( NA, nrow( input ) )
  )
  
  for( i in 1:nrow( input ) ) {
    values <- as.list( input[i, ] )
    output[ i, "computed" ] <- calculator( values )
  }
  
  return( output$computed )
}
