
# Warning
- species names may be rejected if more than one TSN is returned
- synonyms may return unexpected results from ITIS if they are really old
- find_species_traits only takes in species names. If genus names are inputted, unexpected results may occur
- Your list of species also cannot be empty

#  functionaltraits

This package takes a list of species and finds functional trait information for those species from
a number of databases. It downloads the databases
to your computer and searches them locally; or accesses them online if possible. It
can search the databases for synonyms of the species, in case the names in the database are outdated.

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




### Set up
~~~~
library(functionaltraits)

# select a location to store the databases files on your computer
# this will create a folder for each database
databases <- functionaltraits::Databases$new( "path/to/database/folder" )
# this 'databases' object manages the folder of downloaded files on your computer

# this downloads the databases to your computer. If you get an error message, see Help, below
databases$initialise()

# check that they downloaded properly (if they haven't, see Help below)
# you may need to use the warnings() function if many of the databases failed to download
databases$ready()
~~~~

For the rest of the examples, we assume you have created the `databases` variable.



#### Searching for scientific names only
~~~~
scientific_names <- c( "Equus quagga", "Ursus maritimus", "Tachyglossus aculeatus", "Loxodonta africana" )

results <- databases$search( scientific_names )
~~~~

#### Searching for synonyms and getting taxonomic information
The `find_species_traits` function searches for synonyms and also checks these against the databases. If the name supplied is invalid or cannot be verified by the taxonomic service (eg. due to more than one
potential match), then the species is not searched for. This function adds additional information to the output:
* taxonomic information and common names
* a column `found` indicating whether the species was matched by the taxonomic servce
* and a column `ecolid` which is the [Catalogue of Life](http://www.catalogueoflife.org/) taxnomic ID given to the accepted species name.
~~~~
scientific_names <- c( "Equus quagga", "Ursus maritimus", "Tachyglossus aculeatus", "Loxodonta africana" )

results <- functionaltraits::find_species_traits( databases, scientific_names )
~~~~


#### Specifying which traits to include
There are many traits which can result in data frames with over 400 columns, so sometimes it is easier
to select the databases and columns you are interested before searching:
~~~~
scientific_names <- c( "Equus quagga", "Ursus maritimus", "Tachyglossus aculeatus", "Loxodonta africana" )

traits <- list( 
  "pacifici_generationlength" = c( "GenerationLength_d" ),
  "tacutu_anage" = c( "Common name", "Adult weight (g)" )
)

results <- databases$search( scientific_names, traits )
# or, if you want to search for synonyms as well:
results <- functionaltraits::find_species_traits( databases, scientific_names, traits )
~~~~

You can also find the list of traits available to be selected:
~~~~
print( databases$columns() )

# for example, you could select all databases with the following code:
traits <- databases$columns()
results <- databases$search( scientific_names, traits )

# you can subset from databases$columns() if you want all of the columns from a single database, eg.
traits <- databases$columns()[c( "jones_pantheria", "earnst_mammals" )]
results <- databases$search( scientific_names, traits )
~~~~


### Example output
The output from `find_species_traits` will be a list with two elements, `results` and `statistics`. The element `results` is a dataframe with the relevant traits, as well as additional taxnomic information:
~~~~
                    taxa found                            colid                                           synonyms          accepted_name                                                        common_name  kingdom   phylum    class          order         family        genus pacifici_GenerationLength_d    tacutu_Common.name tacutu_Adult.weight..g.
1           Equus quagga  TRUE a544b4b97773df703818fb547a3c05bc                                               <NA>           Equus quagga                                               Plains Zebra, Quagga Animalia Chordata Mammalia Perissodactyla        Equidae        Equus                    3659.125                Quagga                  280000
2        Ursus maritimus  TRUE ecf9a73302aa9be16e68c89fb524feb8 Ursus maritimus marinus, Ursus maritimus maritimus        Ursus maritimus                                             Polar Bear, ours blanc Animalia Chordata Mammalia      Carnivora        Ursidae        Ursus                    5475.000            Polar bear                  475000
3 Tachyglossus aculeatus  TRUE db1edc1588907fc51323d4829f25036a                                               <NA> Tachyglossus aculeatus                                               Short-beaked Echidna Animalia Chordata Mammalia    Monotremata Tachyglossidae Tachyglossus                    5687.020  Short-beaked echidna                    3500
4     Loxodonta africana  TRUE 7b498777d8b86d615d26fb2555362a5d                                               <NA>     Loxodonta africana African savannah elephant, African elephant, African Bush Elephant Animalia Chordata Mammalia    Proboscidea   Elephantidae    Loxodonta                    9125.000 African bush elephant                 4800000
~~~~

The element `statistics` contains information on how many times a species was present in a database and how many traits were selected from that database:
~~~~
                  database number_of_matches number_of_columns_selected
1 pacifici_generationlength                 4                          1
2              tacutu_anage                 4                          2
~~~~

The output will be similar when using `databases$search()`, except that there will be no taxonomic information or common names.

### Help
If you receive an error from a database when you call `databases$ready()`, you can remove the database using `databases$drop( "database_name"" )`, eg.
~~~~
databases <- functionaltraits::Databases$new( "path/to/database/folder" )
databases$ready()
# Warning: the database file for earnst_mammals has not been downloaded
databases$drop( "earnst_mammals" )

# you need to re-run the initialise() function to download the databases again
databases$initialise()

databases$ready()
# TRUE
~~~~
Alternatively, if you don't want to access all of the databases, you can supply a list of the 
databases you are interested in to `databases$new()`, eg.
~~~~
databases <- functionaltraits::Databases$new( "path/to/database/folder",
  functionaltraits::database_list[ c(
    "jones_pantheria",
    "earnst_mammals",
    "kissling_mammaldiet"
  )]
)
databases$columns()
~~~~
This will speed up your code as it won't have to download or search the database files 
that you don't use. 


You can also see `?Databases` and `?find_species_traits` for more information, contact Stewart Bisset on 
GitHub (stew822) or open an issue.

### Contributing
In order to contribute, you can fork this repository and send pull requests.

When you make a change to the code, you must rebuild and reload the package:
1. run devtools::document() if you add/remove a file, or change documentation
2. run Build -> Clean and Rebuild from the RStudio menu
3. run Session -> Restart R from the RStudio menu
4. overwrite any instances of the Database class by running databases <- functionaltraits::Databases$new()

