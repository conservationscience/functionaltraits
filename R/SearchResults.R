
#' An S4 class to represent the search results from a single database
#'
#' @slot results A dataframe containing a column, \code{species}, containing the list of species that was
#'               given to the database
#' @slot numberOfMathces The number of species that trait information was found for in this database
#' @slot numberOfColumns The number of columns that were selected from this database

SearchResults <- setClass( "SearchResults", 
   representation(
     results = "data.frame",
     numberOfMatches = "numeric",
     numberOfColumns = "numeric"
   )
)
