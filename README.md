
#  functionaltraits

This package searches a number of databases for functional traits. It downloads the databases
to your computer and searches them locally; or accesses them online if possible. It can also 
fetch taxonomic information as well as search the databases with synonyms as well. 

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
You need a list of species, and optionally, a list of the traits you want included in the results. If you don't specify any traits, then all databases are searched and all information is returned.

The list of traits available for selection in each database can be found on [Google Sheets](https://docs.google.com/spreadsheets/d/1-YtnOarUyNURLcGE9p6SdB44hZDAyETQhzZCZYJpFEA/edit?usp=sharing). When selecting a database, use the name given on the sheet, and when selecting columns, use the column name exactly as printed on the sheet. Please note that when column names are returned, sometimes spaces and brackets ('() ') are replaced with dots. Column names are also prepended with the author's name of the database, so that it is clear which database the column originated from.

#### Searching for scientific names only
Note that the databases will be downloaded to the location of your choosing.
~~~~
library(functionaltraits)

databases <- functionaltraits::Databases$new( "path/to/database/folder"" )

scientific_names <- c( "Equus quagga", "Ursus maritimus", "Tachyglossus aculeatus", "Loxodonta africana" )

results <- databases$search( scientific_names )
~~~~

#### Searching for synonyms and getting taxonomic information
The `find_species_traits` function searches for synonyms and also checks these against the databases. If the name supplied is invalid or cannot be verified by the taxonomic service (eg. due to more than one
potential match), then the species is not searched for. This function adds addition information to the output:
* taxonomic information and common names
* a column `found` indicating whether the species was matched by the taxonomic servce
* and a column `ecolid` which is the [Catalogue of Life](http://www.catalogueoflife.org/) taxnomic ID given to the accepted species name.
~~~~
databases <- functionaltraits::Databases$new( "path/to/database/folder"" )

scientific_names <- c( "Equus quagga", "Ursus maritimus", "Tachyglossus aculeatus", "Loxodonta africana" )

results <- find_species_traits( databases, scientific_names )
~~~~


#### Specifying which traits to include
There are many traits which can result in data frames with over 400 columns, so sometimes it is easier
to select the databases and columns you are interested before searching:
~~~~
databases <- functionaltraits::Databases$new( "path/to/database/folder"" )

scientific_names <- c( "Equus quagga", "Ursus maritimus", "Tachyglossus aculeatus", "Loxodonta africana" )

traits <- list( 
  "pacifici_generationlength" = c( "GenerationLength_d" ),
  "tacutu_anage" = c( "Common name", "Adult weight (g)" )
)

results <- databases$search( scientific_names, traits )
# or, if you want to search for synonyms as well:
results <- find_species_traits( databases, scientific_names, traits )
~~~~

#### Getting the traits available to be selected
~~~~
databases <- functionaltraits::Databases$new( "path/to/database/folder"" )
available_traits <- databases$columns()
print( available_traits )
~~~~


### Example output
The output will be a list with two elements, `results` and `statistics`. The element `results` is a dataframe with the relevant traits, as well as additional taxnomic information:
~~~~
                    taxa found                            colid                                           synonyms
1           Equus quagga  TRUE a544b4b97773df703818fb547a3c05bc                                               <NA>
2        Ursus maritimus  TRUE ecf9a73302aa9be16e68c89fb524feb8 Ursus maritimus marinus, Ursus maritimus maritimus
3 Tachyglossus aculeatus  TRUE db1edc1588907fc51323d4829f25036a                                               <NA>
4     Loxodonta africana  TRUE 7b498777d8b86d615d26fb2555362a5d                                               <NA>
           accepted_name                                                        common_name  kingdom   phylum
1           Equus quagga                                               Plains Zebra, Quagga Animalia Chordata
2        Ursus maritimus                                             Polar Bear, ours blanc Animalia Chordata
3 Tachyglossus aculeatus                                               Short-beaked Echidna Animalia Chordata
4     Loxodonta africana African savannah elephant, African elephant, African Bush Elephant Animalia Chordata
     class          order         family        genus pacifici_GenerationLength_d    tacutu_Common.name
1 Mammalia Perissodactyla        Equidae        Equus                    3659.125                Quagga
2 Mammalia      Carnivora        Ursidae        Ursus                    5475.000            Polar bear
3 Mammalia    Monotremata Tachyglossidae Tachyglossus                    5687.020  Short-beaked echidna
4 Mammalia    Proboscidea   Elephantidae    Loxodonta                    9125.000 African bush elephant
  tacutu_Adult.weight..g.
1                  280000
2                  475000
3                    3500
4                 4800000
~~~~

The element `statistics` contains information on how many times a species was present in a database and how many traits were selected from that database:
~~~~
                  database number_of_matches number_of_columns_selected
1 pacifici_generationlength                 4                          1
2              tacutu_anage                 4                          2
~~~~

### Help

See `?Databases` and `?find_species_traits` for more information, contact Stewart Bisset on 
GitHub (stew822) or open an issue.

