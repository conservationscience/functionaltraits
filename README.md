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
- EltonTRAITS (http://www.esapubs.org/archive/ecol/E095/178/default.php)
- "Generation length for mammals" Pacifici et al. (https://natureconservation.pensoft.net/articles.php?id=1343&element_type=5&display_type=element&element_id=31)

The list of traits available for selection in each database can be found at https://docs.google.com/spreadsheets/d/1-YtnOarUyNURLcGE9p6SdB44hZDAyETQhzZCZYJpFEA/edit?usp=sharing 

### How to install
You need to have the devtools package installed and loaded in order for the `install_github` function to be available:
~~~~
install.packages("devtools")
library(devtools)
~~~~

Then you can install this package with the following code:
~~~~
install_github("conservationscience/functional-traits")
~~~~


### How to use
There are two main functions:
* `find_species_traits` accepts a list of species and a list of traits that you're interested in, and returns a dataframe with the species and the trait information. 
* `download_trait_databases` simply downloads the required files (Pantheria, Anage, etc.) that the find_species_traits function needs to function. A folder is created in the current working directory (see the function `getwd()`) and the files are stored there.

For example:
~~~~
library(functional-traits)
# creates a folder called 'traitdata' in the current working directory and downloads the required files to it
download_trait_databases()

# looks for a 'traitdata' folder in the current working directory for several of the databases that are accessed
find_species_traits( c("Betta splendens", "Loxodonta africana" ), list( "pacifici_generationlength" = c( "GenerationLength_d" ) ))
~~~~

See `?find_species_traits` and `?download_trait_databases` for more information. 