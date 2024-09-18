# Load the revtools package
# revtools GitHub repository: https://github.com/mjwestgate/revtools
library(revtools)


# Set the working directory to the folder where the current script is located
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

# Store the current working directory in a variable
current_dir <- getwd()

# Create file paths for the .bib files
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
  cat("Number of literature entries in", 
      basename(files[i]), ":", nrow(data), "\n")
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
cat("Total number of literature entries:", nrow(combined_data), "\n")

# Filter out entries without a DOI
combined_data_with_doi <- 
  combined_data[!is.na(combined_data$doi) & combined_data$doi != "", ]

# Print the number of entries with a DOI
cat("Number of entries with DOI:", nrow(combined_data_with_doi), "\n")

# Check for duplicate entries and extract unique references
x_check <- find_duplicates(combined_data_with_doi)
data_unique <- extract_unique_references(combined_data_with_doi, 
                                         matches = x_check)

# Define moisture-related terms (soil moisture OR soil water content)
moisture_terms <- "(soil moisture|soil water content)"

# Define sensing/measuring-related terms
action_terms <- "(sensing|measurement|monitoring|detection|measuring|detecting)"

# Add more method-related words to narrow the scope
method_terms <- "(remote sensing|proximal|dielectric|electromagnetic|spectral|optical|capacitance|conductivity|impedance|hyperspectral|multispectral|acoustic|thermal|microwave|radar|LIDAR)"

# Combine moisture, action, and method terms
query_pattern <- paste0(moisture_terms, ".*", action_terms, ".*", method_terms, "|",
                        action_terms, ".*", moisture_terms, ".*", method_terms)

# Define a vector of keywords for nutrient-related search in the abstract
nutrient_keywords <- c("soil nitrogen", "soil phosphorus", "soil potassium", 
                       "soil nutrient", "soil NPK", "soil fertility")
nutrient_pattern <- paste(nutrient_keywords, collapse = "|")

# Combine both moisture and nutrient queries with OR logic
combined_query <- paste0("(", query_pattern, ")|(", nutrient_pattern, ")")

# Filter articles that match either the moisture or nutrient query
filtered_combined_data <- data_unique[grepl(combined_query, 
                                            data_unique$abstract, 
                                            ignore.case = TRUE), ]

# Print the number of entries after applying the OR logic query
cat("Number of entries after filtering:", nrow(filtered_combined_data), "\n")

# Optionally, save the filtered results for further review
# write_bibliography(filtered_combined_data, file = "filtered_combined_literature_query.bib")
