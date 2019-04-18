
#' Download trait databases
#'
#' Downloads the trait databases used by \code{\link{find_species_traits}} into a folder
#' called 'data' in the current working directory.
#'
#' @return No return value.
#' @examples
#' download_trait_databases()
#' @export
download_trait_databases <- function() {
  folder <- "./traitdata"
  dir.create( folder )

  ###### earnst_mammals
  dir.create( paste( folder, "earnst_mammals", sep="/" ) )
  download.file(
    "http://www.esapubs.org/archive/ecol/E084/093/Mammal_lifehistories_v2.txt",
    paste( folder, "earnst_mammals", "Mammal_lifehistories_v2.txt", sep="/" )
  )

  ###### jones_pantheria
  dir.create( paste( folder, "jones_pantheria", sep="/" ) )
  download.file(
    "http://esapubs.org/archive/ecol/E090/184/PanTHERIA_1-0_WR05_Aug2008.txt",
    paste( folder, "jones_pantheria", "PanTHERIA_1-0_WR05_Aug2008.txt", sep="/" )
  )

  ###### kissling_mammaldiet
  dir.create( paste( folder, "kissling_mammaldiet", sep="/" ) )
  download.file(
    "https://datadryad.org/bitstream/handle/10255/dryad.64565/MammalDIET_v1.0.txt?sequence=1",
    paste( folder, "kissling_mammaldiet", "MammalDIET_v1.0.txt", sep="/" )
  )

  ###### lislevand_avian
  dir.create( paste( folder, "lislevand_avian", sep="/" ) )
  download.file(
    "http://www.esapubs.org/archive/ecol/E088/096/avian_ssd_jan07.txt",
    paste( folder, "lislevand_avian", "avian_ssd_jan07.txt", sep="/" )
  )

  ###### myhrvold_amniotes
  dir.create( paste( folder, "myhrvold_amniotes", sep="/" ) )
  download.file(
    "http://www.esapubs.org/archive/ecol/E096/269/Data_Files/Amniote_Database_Aug_2015.csv",
    paste( folder, "myhrvold_amniotes", "Amniote_Database_Aug_2015.csv", sep="/" )
  )

  ###### oliveira_amphibio
  dir.create( paste( folder, "oliveira_amphibio", sep="/" ) )
  download.file(
    "https://ndownloader.figshare.com/files/8828578",
    paste( folder, "oliveira_amphibio", "amphibio.zip", sep="/" )
  )
  unzip(
    paste( folder, "oliveira_amphibio", "amphibio.zip", sep="/" ),
    files="AmphiBIO_v1.csv",
    exdir= paste( folder, "oliveira_amphibio", sep="/" )
  )

  ###### pacifici_generationlength
  dir.create( paste( folder, "pacifici_generationlength", sep="/" ) )
  download.file(
    "http://natureconservation.pensoft.net//lib/ajax_srv/article_elements_srv.php?action=download_suppl_file&instance_id=31&article_id=1343",
    paste( folder, "pacifici_generationlength", "pacifici_generationlength.xls", sep="/" )
  )

  ###### slavenko_reptiles
  dir.create( paste( folder, "slavenko_reptiles", sep="/" ) )
  download.file(
    "http://www.gardinitiative.org/uploads/2/2/6/0/22600882/appendix_s2_body_sizes_of_all_extant_reptiles.xlsx",
    paste( folder, "slavenko_reptiles", "appendix_s2_body_sizes_of_all_extant_reptiles.xlsx", sep="/" )
  )

  ###### tacutu_anage
  dir.create( paste( folder, "tacutu_anage", sep="/" ) )
  download.file(
    "http://genomics.senescence.info/species/dataset.zip",
    paste( folder, "tacutu_anage", "dataset.zip", sep="/" )
  )
  unzip(
    paste( folder, "tacutu_anage", "dataset.zip", sep="/" ),
    files="anage_data.txt",
    exdir= paste( folder, "tacutu_anage", sep="/" )
  )

  ###### wilman_eltontraitsbirds
  dir.create( paste( folder, "wilman_eltontraitsbirds", sep="/" ) )
  download.file(
    "http://www.esapubs.org/archive/ecol/E095/178/BirdFuncDat.txt",
    paste( folder, "wilman_eltontraitsbirds", "BirdFuncDat.txt", sep="/" )
  )

  ###### wilman_eltontraitsmammals
  dir.create( paste( folder, "wilman_eltontraitsmammals", sep="/" ) )
  download.file(
    "http://www.esapubs.org/archive/ecol/E095/178/MamFuncDat.txt",
    paste( folder, "wilman_eltontraitsmammals", "MamFuncDat.txt", sep="/" )
  )

}
