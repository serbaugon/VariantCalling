# Load the gtools package
library(gtools)
library(ggplot2)

# Function to process .cns files and obtain the count data frame
get_cn_count_dataframe = function() {
  # List to store data frames for each file
  dataframe_list = list()
  
  # Directory where .cns files are located
  directory = getwd()
  # List of .cns files in the directory
  files = list.files(path = directory, pattern = "\\.cns$", full.names = TRUE)
  
  # Loop to read each file and store in the list
  for (file in files) {
    # Read the file and extract the "cn" column
    data = read.table(file, header = TRUE)
    sample = tools::file_path_sans_ext(basename(file))  # Get the sample name
    data$sample = sample  # Add sample information to the data frame
    
    # Group values greater than 10 into a special category
    data$cn = ifelse(data$cn > 10, "> 10", as.character(data$cn))
    
    dataframe_list[[sample]] = data  # Store the data frame in the list
  }
  
  # Combine all data frames into one
  combined_data = do.call(rbind, dataframe_list)
  
  # Obtain the count data frame
  cn_count_dataframe = as.data.frame.matrix(table(combined_data$sample, combined_data$cn))
  
  # Sort columns alphanumerically using mixedsort
  cn_count_dataframe = cn_count_dataframe[, mixedsort(colnames(cn_count_dataframe))]
  
  # Rename columns
  colnames(cn_count_dataframe) = paste("cn_", colnames(cn_count_dataframe), sep = "")
  
  return(cn_count_dataframe)
}

# Obtain the count data frame for all cases
all_cn_count_dataframe = get_cn_count_dataframe()
rownames(all_cn_count_dataframe) = c("Patient_01", "Patient_02", "Patient_03", "Patient_04", "Patient_05", "Patient_06",
                                     "Patient_07", "Patient_08", "Patient_09", "Patient_10", "Patient_11")

# Write the count data frame to a file
write.table(all_cn_count_dataframe, file = "cn_count.txt", quote = FALSE, sep = "\t")

# Function to process .cns files with a specified condition
process_cns = function(condition) {
  # List to store data frames for each file
  dataframe_list = list()
  
  # Directory where .cns files are located
  directory = getwd()
  # List of .cns files in the directory
  files = list.files(path = directory, pattern = "\\.cns$", full.names = TRUE)
  
  # Loop to read each file and store in the list
  for (file in files) {
    # Read the file and extract the "cn" column
    data = read.table(file, header = TRUE)
    sample = tools::file_path_sans_ext(basename(file))  # Get the sample name
    data$sample = sample  # Add sample information to the data frame
    
    # Apply the condition based on the argument
    if (condition == "without_cn2") {
      data = data[data$cn != 2, ]
    } else {
      # Default: include all cases
      data = data
    }
    
    # Group values greater than 10 into a special category
    data$cn = ifelse(data$cn > 10, "> 10", as.character(data$cn))
    
    dataframe_list[[sample]] = data  # Store the data frame in the list
  }
  
  # Combine all data frames into one
  combined_data = do.call(rbind, dataframe_list)
  
  # Convert sample to an ordered factor
  combined_data$sample = factor(combined_data$sample, levels = unique(combined_data$sample))
  
  # Create an ordered factor for cn
  combined_data$cn = factor(combined_data$cn, levels = c(as.character(0:10), "> 10"))
  
  return(combined_data)
}

# List to store data frames for each file
dataframe_list = list()

# Process with the condition cn != 2
combined_data_cn2 = process_cns("without_cn2")

sample_names = c("Patient_01", "Patient_02", "Patient_03", "Patient_04", "Patient_05", "Patient_06",
                 "Patient_07", "Patient_08", "Patient_09", "Patient_10", "Patient_11")

# Stacked bar chart with rotated x-axis labels and numerically ordered
ggplot(combined_data_cn2, aes(x = sample, fill = cn)) +
  geom_bar(position = "stack") +
  labs(title = "CN frequency (removing CN = 2)", x = "Sample", y = "Frequency", fill = "CN") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        plot.title = element_text(hjust = 0.5)) +
  scale_x_discrete(labels = sample_names) +
  scale_fill_manual(values = c("#1f78b4", "#33a02c", "#ff7f00", "#6a3d9a", "#b15928", "#a6cee3", "#b2df8a", "#fb9a99", "#fdbf6f", "#cab2d6", "#ffff99"))

# Reset the list to store data frames for each file
dataframe_list = list()

# Process with all cases (without applying condition)
combined_data_all = process_cns("all")

# Stacked bar chart with rotated x-axis labels and numerically ordered
ggplot(combined_data_all, aes(x = sample, fill = cn)) +
  geom_bar(position = "stack") +
  labs(title = "CN frequency", x = "Sample", y = "Frequency", fill = "CN") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        plot.title = element_text(hjust = 0.5)) +
  scale_x_discrete(labels = sample_names) +
  scale_fill_manual(values = c("#1f78b4", "#33a02c", "#e31a1c", "#ff7f00", "#6a3d9a", "#b15928", "#a6cee3", "#b2df8a", "#fb9a99", "#fdbf6f", "#cab2d6", "#ffff99"))

