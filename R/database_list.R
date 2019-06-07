
#' @include db_fishbase.R
#' @include db_earnst_mammals.R
#' @include db_jones_pantheria.R
#' @include db_kissling_mammaldiet.R
#' @include db_lislevand_avian.R
#' @include db_myhrvold_amniotes.R
#' @include db_oliveira_amphibio.R
#' @include db_pacifici_generationlength.R
#' @include db_slavenko_reptiles.R
#' @include db_tacutu_anage.R
#' @include db_wilman_mam_eltontraits.R
#' @include db_wilman_bird_eltontraits.R


#' Holds a list of the databases that are available
#'
#' This list is used in Databases.R as the default list of databases to search where no list is
#' provided. In general, most users will not supply a list, and so this will be the list that is
#' used. If there is ever a problem with any of the databases, you can supply your own list 
#' to Databases$new(), similar to this one, except with the problem database removed.
#' 
#' The format of the list is database_name = class_of_databases, where the class of the database inherits
#' from Database.R
#' @export

database_list <- list(
  earnst_mammals = db_earnst_mammals,
  fishbase = db_fishbase,
  jones_pantheria = db_jones_pantheria,
  kissling_mammaldiet = db_kissling_mammaldiet,
  lislevand_avian = db_lislevand_avian,
  myhrvold_amniotes = db_myhrvold_amniotes,
  oliveira_amphibio = db_oliveira_amphibio,
  pacifici_generationlength = db_pacifici_generationlength,
  slavenko_reptiles = db_slavenko_reptiles,
  tacutu_anage = db_tacutu_anage,
  wilman_mam_eltontraits = db_wilman_mam_eltontraits,
  wilman_bird_eltontraits = db_wilman_bird_eltontraits
)
