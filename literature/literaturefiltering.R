# Load the revtools package
# revtools GitHub repository: https://github.com/mjwestgate/revtools
library(revtools)

# Set the working directory to the folder where the current script is located
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

# Store the current working directory in a variable
current_dir <- getwd()

# Create file paths for the .bib and .csv files
files <- c(
  file.path(current_dir, "WebofScience.bib"),
  file.path(current_dir, "Scopus.bib"),
  file.path(current_dir, "IEEE.bib"),
  file.path(current_dir, "Ovid.bib"),
  file.path(current_dir, "PubMed.bib"),
  file.path(current_dir, "WileyOnline.bib")
)

# Initialize a list to store bibliographic data from each file
data_list <- list()

# Loop through each file, import data, and print the number of entries
for (i in 1:length(files)) {
  data <- read_bibliography(files[i])
  data_list[[i]] <- data  # Store the data for later use
  cat("Number of literature entries in", basename(files[i]), ":", nrow(data), "\n")
}

# Find the union of all columns
all_columns <- unique(unlist(lapply(data_list, colnames)))

# Standardize the columns in all data frames by filling missing columns with NA
data_list <- lapply(data_list, function(df) {
  missing_cols <- setdiff(all_columns, colnames(df))
  df[missing_cols] <- NA  # Add missing columns as NA
  return(df[all_columns])  # Reorder columns to match
})

# Combine all bibliographic data into a single data frame
combined_data <- do.call(rbind, data_list)

# Print the total number of literature entries after combining
cat("Total number of combined literature entries:", nrow(combined_data), "\n")

# Filter out entries without a DOI
combined_data_with_doi <- combined_data[!is.na(combined_data$doi) & combined_data$doi != "", ]

# Print the number of entries with a DOI
cat("Number of entries with DOI:", nrow(combined_data_with_doi), "\n")

# Check for duplicate entries and extract unique references
x_check <- find_duplicates(combined_data_with_doi)
data_unique <- extract_unique_references(combined_data_with_doi, matches = x_check)

# Print the total number of unique literature entries after removing duplicates
cat("Total number of unique literature entries with DOI:", nrow(data_unique), "\n")

# Define a vector of keywords to search for in the abstract
keywords <- c("sensor", "measurement", "monitoring", "sensing")

# Create a pattern that combines the keywords for searching
pattern <- paste(keywords, collapse = "|")

# Filter articles that contain any of the keywords in the abstract
filtered_data <- data_unique[
  grepl(pattern, data_unique$abstract, ignore.case = TRUE), ]

# Print the number of entries after filtering by keywords in abstract
cat("Number of entries after filtering by keywords in abstract:", nrow(filtered_data), "\n")

