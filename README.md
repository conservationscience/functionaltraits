
#  functionaltraits

This package searches a number of databases for functional traits. 

Currently supported databases include
- Pantheria (http://esapubs.org/archive/ecol/E090/184/). Note that we use the MSW05 version.
- Anage (http://genomics.senescence.info/species/)
- MammalDIET (https://datadryad.org/resource/doi:10.5061/dryad.6cd0v)
- "Body masses of all extant reptiles (Slavenko et al.)" (http://www.gardinitiative.org/data.html)
- Fishbase
- AmphiBIO (https://www.ncbi.nlm.nih.gov/pmc/articles/PMC5584397/)
- Amniote database Myhrvold et al. (http://www.esapubs.org/archive/ecol/E096/269/)
- Mammal life histories Ernest (http://www.esapubs.org/archive/ecol/E084/093/default.htm)
- Avian body size Lislevand et al. (https://ecologicaldata.org/wiki/avian-body-size-and-life-history)
- EltonTRAITS (http://www.esapubs.org/archive/ecol/E095/178/default.php). Note we treat this as two separate databases as illustrated in the Google Sheets, below.
- "Generation length for mammals" Pacifici et al. (https://natureconservation.pensoft.net/articles.php?id=1343&element_type=5&display_type=element&element_id=31)

The list of traits available for selection in each database can be found on [Google Sheets](https://docs.google.com/spreadsheets/d/1-YtnOarUyNURLcGE9p6SdB44hZDAyETQhzZCZYJpFEA/edit?usp=sharing). When selecting a database, use the name given on the sheet, and when selecting columns, use the column name exactly as printed on the sheet. Please note that when column names are returned, sometimes spaces and brackets ('() ') are replaced with dots. Column names are also prepended with the author's name of the database, so that it is clear which database the column originated from.




### How to install
You need to have the devtools package installed and loaded in order for the `install_github` function to be available:
~~~~
install.packages("devtools")
library(devtools)
~~~~

Then you can install this package with the following code:
~~~~
install_github("conservationscience/functionaltraits")
~~~~




### How to use
There are two main functions:
* `find_species_traits` accepts a list of species and a list of traits that you're interested in, and returns a dataframe with the species and the trait information. 
* `download_trait_databases` simply downloads the required files (Pantheria, Anage, etc.) that the `find_species_traits function` needs to function. A folder is created in the current working directory (see the function `getwd()`) and the files are stored there.

For example:
~~~~
library(functionaltraits)
# creates a folder called 'traitdata' in the current working directory and downloads the required files to it
download_trait_databases()

# looks for a 'traitdata' folder in the current working directory for several of the databases that are accessed
# the first argument is a vector of species names
# the second argument is a list describing which traits to include from each database
data <- find_species_traits( c("Betta splendens", "Loxodonta africana" ), list( "pacifici_generationlength" = c( "GenerationLength_d" ) ))

# if you want to search all databases and return all traits, you can do 
data <- find_species_traits( c("Betta splendens", "Loxodonta africana" ) )

~~~~


### Example output
If you run

~~~~
data <- find_species_traits(
  c( "Equus quagga", "Ursus maritimus", "Tachyglossus aculeatus" ),
  list( 
    "pacifici_generationlength" = c( "GenerationLength_d" ),
    "tacutu_anage" = c( "Common name", "Adult weight (g)", "Maximum longevity (yrs)" ),
    "kissling_mammaldiet" = c( "TrophicLevel" )
  )
)
~~~~

The variable 'data' will be a list with two elements, `data[["matches"]]` and `data[["traits"]]`. The element `traits` is a dataframe with the relevant traits, as well as additional taxnomic information:
~~~~
                           ecol_id          Accepted name                                           synonyms pacifici_GenerationLength_d   tacutu_Common.name tacutu_Adult.weight..g. tacutu_Maximum.longevity..yrs. kissling_TrophicLevel
1 a544b4b97773df703818fb547a3c05bc           Equus quagga                                                                       3659.125               Quagga                  280000                           38.0             Herbivore
2 db1edc1588907fc51323d4829f25036a Tachyglossus aculeatus                                                                       5687.020 Short-beaked echidna                    3500                           49.5             Carnivore
3 ecf9a73302aa9be16e68c89fb524feb8        Ursus maritimus Ursus maritimus marinus, Ursus maritimus maritimus                    5475.000           Polar bear                  475000                           43.8              Omnivore
~~~~


Note that the `find_species_traits` function searches for synonyms and also checks these against the databases. If the name supplied is invalid, it is not included in the results. The column `ecol_id` is the [Catalogue of Life](http://www.catalogueoflife.org/) taxnomic ID given to the accepted species name.

The element `matches` gives you the number of matches in each database, and the number of traits selected for each database:
~~~~
              database_name no_of_matches no_of_traits_selected
1 pacifici_generationlength             3                     1
2              tacutu_anage             3                     3
3       kissling_mammaldiet             3                     1
~~~~

See `?find_species_traits` and `?download_trait_databases` for more information. 


# TODO
- return proper error messages if invalid trait names or databases are selected
- write about how the function looks for species synonyms and searches for them too
