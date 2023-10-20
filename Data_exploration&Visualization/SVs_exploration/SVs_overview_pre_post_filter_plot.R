# Load necessary libraries
library(data.table)
library(ggplot2)
library(dplyr)
library(ParallelLogger)
library(SVIV)

# Source the external script containing the svOverviewPlot function
source("plot_sv_overview.R")

# Columns of interest in the SV data
columns_of_interest = c('SV_chrom', 'SV_start', 'SV_end', 'SV_type', 'Samples_ID')

# Specify the folder containing the .tsv files
folder_path = getwd()

# Get a list of all .tsv files in the folder
tsv_files = list.files(path = folder_path, pattern = "\\.tsv$", full.names = TRUE)


# Initialize an empty data.table to store the combined data
combined_data = data.table()
combined_data_filtered =  data.table()


### Plot BEFORE filtering
# Loop through each .tsv file
for (file in tsv_files) {
  # Read the data from the current file
  current_data = fread(file, select = columns_of_interest)
  
  # Process and clean the data (similar to the previous code)
  modified_data = unique(current_data)
  setnames(modified_data, c('SV_chrom', 'SV_start', 'SV_end', 'SV_type', 'Samples_ID'), c('Chr', 'Start', 'End', 'Type', 'Sample'))
  modified_data$Start = as.numeric(modified_data$Start)
  modified_data$End = as.numeric(modified_data$End)
  modified_data$Chr = paste("chr", modified_data$Chr, sep = "")
  
  # Combine data into the main data.table
  combined_data = rbind(combined_data, modified_data)
}


# Change sample names

combined_data = mutate(combined_data, 
                        Sample = case_when(
                          Sample == "2010_Sample_2010" ~ "Patient_01",
                          Sample == "2285_Sample_2285" ~ "Patient_02",
                          Sample == "2316_Sample_2316" ~ "Patient_03",
                          Sample == "2845_Sample_2845" ~ "Patient_04",
                          Sample == "2878_Sample_2878" ~ "Patient_05",
                          Sample == "3316_Sample_3316" ~ "Patient_06",
                          Sample == "633_Sample_633" ~ "Patient_07",
                          Sample == "643_Sample_643" ~ "Patient_08",
                          Sample == "idm4323_Sample_idm4323" ~ "Patient_09",
                          Sample == "idm4438_Sample_idm4438" ~ "Patient_10",
                          Sample == "IM11893_V01_Sample_IM11893_V01" ~ "Patient_11",
                          TRUE ~ Sample  # Mantener el valor original si no coincide con ninguna condición
                        ))




# Call the svOverviewPlot function with the combined SV data
svOverviewPlot(sv = combined_data, color_palette = c("coral1","green4","skyblue3","orchid"),title = "SVs overview before filtering",ylab = "Chromosome",xlab = "Sample")




### Plot AFTER filtering
# Loop through each .tsv file
for (indel_file in tsv_files) {
  # Read the data from the current file
  current_data_filtered = fread(indel_file)
  
  # Filter the files:
  # - PASS filter
  # - SV length > 50 pb and SV length < 100 kb
  current_data_filtered = current_data_filtered[(SV_length > 50 & SV_length < 50000) | (SV_length < -50 & SV_length > -50000) & FILTER == "PASS", ]
  
  # Select only the columns of interest
  current_data_filtered = current_data_filtered[, ..columns_of_interest, with = FALSE]
  
  # Combine data into the main data.table
  combined_data_filtered = rbindlist(list(combined_data_filtered, current_data_filtered), fill = TRUE)
}

# Drop duplicates in the combined data
combined_data_filtered = unique(combined_data_filtered)

# Process and clean the data
setnames(combined_data_filtered, c('SV_chrom', 'SV_start', 'SV_end', 'SV_type', 'Samples_ID'), c('Chr', 'Start', 'End', 'Type', 'Sample'))
combined_data_filtered$Start = as.numeric(combined_data_filtered$Start)
combined_data_filtered$End = as.numeric(combined_data_filtered$End)
combined_data_filtered$Chr = paste("chr", combined_data_filtered$Chr, sep = "")


# Change sample names

combined_data_filtered = mutate(combined_data_filtered, 
                        Sample = case_when(
                          Sample == "2010_Sample_2010" ~ "Patient_01",
                          Sample == "2285_Sample_2285" ~ "Patient_02",
                          Sample == "2316_Sample_2316" ~ "Patient_03",
                          Sample == "2845_Sample_2845" ~ "Patient_04",
                          Sample == "2878_Sample_2878" ~ "Patient_05",
                          Sample == "3316_Sample_3316" ~ "Patient_06",
                          Sample == "633_Sample_633" ~ "Patient_07",
                          Sample == "643_Sample_643" ~ "Patient_08",
                          Sample == "idm4323_Sample_idm4323" ~ "Patient_09",
                          Sample == "idm4438_Sample_idm4438" ~ "Patient_10",
                          Sample == "IM11893_V01_Sample_IM11893_V01" ~ "Patient_11",
                          TRUE ~ Sample  # Mantener el valor original si no coincide con ninguna condición
                        ))



# Call the svOverviewPlot function with the filtered SV data
svOverviewPlot(sv = combined_data_filtered, color_palette = c("green4","coral1","skyblue3","orchid"),title = "SVs overview after filtering",ylab = "Chromosome",xlab = "Sample")




