# Load the revtools package
# revtools GitHub repository: https://github.com/mjwestgate/revtools
library(revtools)

# Set the working directory to the folder where the current script is located
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

# Store the current working directory in a variable
current_dir <- getwd()

# Create a file path for the "savedrecs.bib" file
file_location <- file.path(current_dir, "savedrecs.bib")

# Import the bibliographic information from the .bib file into a data.frame
data <- read_bibliography(file_location)

# Launch a graphical interface to screen the topics in the imported data
screen_topics(data)

