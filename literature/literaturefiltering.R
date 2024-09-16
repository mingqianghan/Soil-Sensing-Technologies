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
  file.path(current_dir, "IEEE.bib")
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

# Check for duplicate entries and extract unique references
x_check <- find_duplicates(combined_data)
x_unique <- extract_unique_references(combined_data, matches = x_check)

# Print the total number of unique literature entries
cat("Total number of unique literature entries:", nrow(x_unique), "\n")


# Launch a graphical interface to screen the topics in the imported data
# screen_topics(data)

