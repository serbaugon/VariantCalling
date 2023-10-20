# This script is aimed to identify SVs associated to previously reported PD genes and classify them according to ACMG criteria. Then, it plots the frequency of those SVs per sample
# and the frequency of their associated genes per sample.
# Besides, it looks for SVs classified as Likely Pathogenic or Pathogenic according to ACMG criteria and their associated genes. Then, it plots the frequency of those SVs per sample
# and the frequency of their associated genes per sample.
# It also counts the different types of SVs (DEL, INS, INV and DUP) per sample before and after filtering.

# Load libraries
library(data.table)
library(ggplot2)
library(dplyr)
library(tidyr)


### Search relevant genes in filtered TSV
# Get the list of TSV files in the folder
folder <- getwd()
tsv_files <- list.files(folder, pattern = "\\.tsv$", full.names = TRUE)

genes <- c("SNCA", "PRKN", "UCHL1", "PARK7", "LRRK2", "PINK1", "POLG", "HTRA2", "ATP13A2", "FBX07", 
           "GIGYF2", "GBA", "PLA2G6", "EIF4G1", "VPS35", "DNAJC6", "SYNJ1", "DNAJC13", "TMEM230", "VPS13C", "LRP10", "FCGBP")

# Function to search for genes and details in a file filtered by gene matches
search_gene_matches <- function(file, genes) {
  # Read the filtered file
  filtered_tsv <- fread(file)
  
  # Filter the data
  filtered_data <- filtered_tsv[(SV_length > 50 & SV_length < 50000) | (SV_length < -50 & SV_length > -50000) & FILTER == "PASS", ]
  
  # Filter by gene matches in Gene_name
  genes_filtered <- filtered_data[Gene_name %in% genes & FILTER == "PASS", .(Sample = basename(file), SV_chrom, SV_start, SV_end, SV_length, SV_type, Gene_name, ACMG_class)]
  
  # Add the ACMG_class_replaced column
  genes_filtered[, ACMG_class_replaced := ifelse(ACMG_class %in% c(3, "full=3"), "VUS", ifelse(ACMG_class %in% c(1, "full=1"), "Benign", NA))]
  
  return(genes_filtered)
}

# Search gene matches in all filtered files
gene_match_results <- rbindlist(lapply(tsv_files, function(file) search_gene_matches(file, genes)))

# Show gene match results with the new ACMG_class_replaced column
print(gene_match_results)

gene_match_results = unique(gene_match_results, by = c("Sample", "SV_start"))

table(gene_match_results$Gene_name)

write.table(gene_match_results, file = "relevant_genes_SV_ACMG.txt", sep = "\t", quote = FALSE, row.names = FALSE)


sample_names = c("Patient_01", "Patient_02", "Patient_03", "Patient_04", "Patient_05", "Patient_06", "Patient_07", "Patient_08", 
                 "Patient_09", "Patient_10", "Patient_11")


##### Gene frequency per sample
# Create stacked bar plot with discrete colors
ggplot(gene_match_results, aes(x = Sample, fill = Gene_name)) +
  geom_bar(position = "stack") +
  labs(title = "Gene frequency",
       x = "Sample",
       y = "Frequency",
       fill = "Gene name") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1), 
        plot.title = element_text(hjust = 0.5)) + 
  scale_x_discrete(labels = sample_names) +
  scale_fill_brewer(palette = "Set3")



##### SVs type per sample
# Create stacked bar plot for gene classification (including NA)
ggplot(gene_match_results, aes(x = Sample, fill = factor(ACMG_class_replaced, levels = c("Benign", "VUS", NA)))) +
  geom_bar(position = "stack") +
  labs(title = "SVs classification",
       x = "Sample",
       y = "Frequency") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1), 
        plot.title = element_text(hjust = 0.5)) +  # Center the title
  scale_x_discrete(labels = sample_names) +
  scale_fill_manual(values = c("green3", "orchid"),
                    na.value = "grey",
                    name = "ACMG classification",
                    labels = c("Benign", "VUS", "NA"))




### Search pathogenic and likely pathogenic genes

# Function to search genes and details in a filtered file with ACMG_class
search_genes_with_details <- function(file, genes) {
  # Read the filtered file
  filtered_tsv <- fread(file)
  
  # Filter the data
  filtered_data <- filtered_tsv[(SV_length > 50 & SV_length < 50000) | (SV_length < -50 & SV_length > -50000) & FILTER == "PASS", ]
  
  # Filter ACMG_class
  acmg_filtered <- filtered_data[ACMG_class %in% c(4, 5), .(Gene_name = toString(unique(Gene_name)))]
  
  # Add information from SV columns to the result
  details_acmg <- filtered_data[ACMG_class %in% c(4, 5), .(Sample = basename(file), SV_chrom, SV_start, SV_end, SV_length, SV_type, Gene_name, ACMG_class)]
  
  # Add ACMG_class_replaced column
  details_acmg[, ACMG_class_replaced := ifelse(ACMG_class %in% c(5, "full=5"), "Pathogenic", ifelse(ACMG_class %in% c(4, "full=4"), "Likely Pathogenic", ACMG_class))]
  
  return(details_acmg)
}

# Search genes and details with ACMG_class in all filtered files
acmg_details_results <- rbindlist(lapply(tsv_files, function(file) search_genes_with_details(file, genes)))

# Show results for ACMG_class with details
print(acmg_details_results)

write.table(acmg_details_results, file = "P_LP_genes_ACMG_SVs.txt", sep = "\t", quote = FALSE, row.names = FALSE)


######## Gene frequencies for P and LP genes
# Step 1: Split genes joined by ;
genes_P_LP <- strsplit(acmg_details_results$Gene_name, ";")

# Step 2: Create a vector with all genes
all_genes <- unlist(genes_P_LP)

# Step 3: Use table() to count frequencies
gene_frequencies <- table(all_genes)

# Show the result
print(gene_frequencies)




### Gene frequency per Sample
# Get genes and samples
all_genes <- strsplit(acmg_details_results$Gene_name, ";")
all_samples <- rep(acmg_details_results$Sample, sapply(all_genes, length))

# Create a data.frame with all_genes and Sample
genes_sample_df <- data.frame(Gene = unlist(all_genes), Sample = all_samples)

# Count the number of genes per sample
gene_frequencies_sample <- table(genes_sample_df$Sample)

# Convert the table to a data.frame
gene_frequencies_sample_df <- data.frame(Sample = names(gene_frequencies_sample), Count = as.numeric(gene_frequencies_sample))

# Add a column with the corresponding genes for each sample
genes_sample_df_with_genes <- genes_sample_df %>%
  group_by(Sample) %>%
  summarise(Genes = toString(unique(Gene)))

# Merge the tables on the Sample column
final_results <- merge(gene_frequencies_sample_df, genes_sample_df_with_genes, by = "Sample")

# Show the final result
print(final_results)



# Create a dataframe with the gene count per sample
gene_count_sample <- table(genes_sample_df$Sample, genes_sample_df$Gene)

# Reset the index to make "Sample" a column
gene_count_sample_df <- setDT(genes_sample_df, keep.rownames = "Sample")[]


# Convert the dataframe to long format
gene_count_sample_long <- reshape2::melt(gene_count_sample_df, id.vars = "Sample")

#### Stacked bar plot
custom_colors <- c("#E41A1C", "#377EB8", "#4DAF4A", "#FF7F00", "#FFFF33", "#A65628", "#F781BF", "#999999", "#66C2A5", "#3288BD", "#5E4FA2", "#8DD3C7", "#FFFFB3", "#BEBADA", "#FB8072", "#80B1D3", "#FDB462")

ggplot(gene_count_sample_long, aes(x = Sample, y = variable, fill = value)) +
  geom_bar(stat = "identity") +
  labs(title = "Gene frequency",
       x = "Sample",
       y = "Frequency") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1), 
        plot.title = element_text(hjust = 0.5)) + 
  scale_x_discrete(labels = sample_names) +
  scale_fill_manual(values = custom_colors) +
  labs(fill = "Gene")



############# Plot for SVs classification per Sample
ggplot(acmg_details_results, aes(x = acmg_details_results$Sample, fill = acmg_details_results$ACMG_class_replaced)) +
  geom_bar() +
  labs(title = "SVs classification",
       x = "Sample",
       y = "Frequency") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        plot.title = element_text(hjust = 0.5)) +
  scale_x_discrete(labels = sample_names) +
  scale_fill_manual(values = c("salmon1", "firebrick1"), 
                    name = "ACMG classification",
                    labels = c("Likely Pathogenic", "Pathogenic")) 




#### Count SV types in each sample and before and after filtering

# Before the loop, initialize the data frames
dataframe_raw <- data.frame()
dataframe_filtered <- data.frame()

for (file in tsv_files) {
  # Read the file
  raw_tsv <- fread(file)
  
  # Filter the data using raw_tsv instead of tsv
  filter_tsv <- raw_tsv[(SV_length > 50 & SV_length < 50000) | (SV_length < -50 & SV_length > -50000) & FILTER == "PASS", ]
  
  # Create the frequency table
  raw_SV_frequency <- table(raw_tsv$SV_type)
  filtered_SV_frequency <- table(filter_tsv$SV_type)
  
  # Store the data
  sample_name <- rep(basename(file), nrow(raw_SV_frequency))
  
  # Create data frames with desired columns
  raw_data <- data.frame(sample_name = sample_name, frequency = raw_SV_frequency)
  filtered_data <- data.frame(sample_name = sample_name, frequency = filtered_SV_frequency)
  
  # Merge the results into the corresponding dataframe
  dataframe_raw <- rbind(dataframe_raw, raw_data)
  dataframe_filtered <- rbind(dataframe_filtered, filtered_data)
}



# Sum by rows and columns
# RAW
rowsum(dataframe_raw$frequency.Freq, dataframe_raw$sample_name)
sum(rowsum(dataframe_raw$frequency.Freq, dataframe_raw$sample_name))

subset_del <- dataframe_raw[dataframe_raw$frequency.Var1 == "DEL", ]
sum(subset_del$frequency.Freq)

subset_dup <- dataframe_raw[dataframe_raw$frequency.Var1 == "DUP", ]
sum(subset_dup$frequency.Freq)

subset_ins <- dataframe_raw[dataframe_raw$frequency.Var1 == "INS", ]
sum(subset_ins$frequency.Freq)

subset_inv <- dataframe_raw[dataframe_raw$frequency.Var1 == "INV", ]
sum(subset_inv$frequency.Freq)


# FILTERED
rowsum(dataframe_filtered$frequency.Freq, dataframe_filtered$sample_name)
sum(rowsum(dataframe_filtered$frequency.Freq, dataframe_filtered$sample_name))

subset_del <- dataframe_filtered[dataframe_filtered$frequency.Var1 == "DEL", ]
sum(subset_del$frequency.Freq)

subset_dup <- dataframe_filtered[dataframe_filtered$frequency.Var1 == "DUP", ]
sum(subset_dup$frequency.Freq)

subset_ins <- dataframe_filtered[dataframe_filtered$frequency.Var1 == "INS", ]
sum(subset_ins$frequency.Freq)

subset_inv <- dataframe_filtered[dataframe_filtered$frequency.Var1 == "INV", ]
sum(subset_inv$frequency.Freq)

