# Load the revtools package
# revtools GitHub repository: https://github.com/mjwestgate/revtools
library(revtools)

# Set the working directory to the folder where the current script is located
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

# Store the current working directory in a variable
current_dir <- getwd()

# Create a file path for the "savedrecs.bib" file
file1 <- file.path(current_dir, "webofscience_1.bib")
file2 <- file.path(current_dir, "webofscience_2.bib")


# Combine them into a single data frame
combined_bib <- rbind(file1, file2)

# Import the bibliographic information from the .bib file into a data.frame
data <- read_bibliography(combined_bib)

# Print the total number of literature entries in the combined bibliography
cat("Total number of literature entries:", nrow(data), "\n")

x_check <- find_duplicates(data)
x_unique <- extract_unique_references(data, matches = x_check)

# Print the total number of literature entries in the combined bibliography
cat("Total number of unique literature entries:", nrow(x_unique), "\n")


# Launch a graphical interface to screen the topics in the imported data
# screen_topics(data)

