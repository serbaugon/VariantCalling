# This script is aimed to count how many VUS, Likely Pathogenic and Pathogenic variants are in SNP and INDEL files
# 2 plots are also drawn (one for SNPs and one for INDELs) with the frequency of VUS, Likely Pathogenic and Pathogenic variants per sample.

# Libraries
library(vcfR)
library(tidyverse)


# Function to count "Uncertain Significance", "Likely Pathogenic", and "Pathogenic" variants
count_acmg_verdict = function(vcf_file) {
  # Load the VCF file
  vcf_data = read.vcfR(vcf_file, verbose = FALSE)
  
  # Get the info_df dataframe
  info_verdict = extract_info_tidy(vcf_data, info_fields = "acmg_verdict", info_types = TRUE, info_sep = ";")
  
  # Count the number of uncertain significance, likely pathogenic, and pathogenic variants
  count_uncertain_significance = nrow(subset(info_verdict, acmg_verdict %in% "Uncertain_Significance"))
  count_likely_pathogenic = nrow(subset(info_verdict, acmg_verdict %in% "Likely_Pathogenic"))
  count_pathogenic = nrow(subset(info_verdict, acmg_verdict %in% "Pathogenic"))
  
  # Return the result as a list
  return(list(
    Uncertain_Significance = count_uncertain_significance,
    Likely_Pathogenic = count_likely_pathogenic,
    Pathogenic = count_pathogenic
  ))
}

# Function to process files in a given folder
process_folder = function(folder_path) {
  # Get the list of VCF files in the folder
  vcf_files = list.files(path = folder_path, pattern = "\\.vcf$", full.names = TRUE)
  
  # List to store the results
  results = list()
  
  # Iterate over the VCF files and count ACMG verdict variants
  for (vcf_file in vcf_files) {
    file_name = basename(vcf_file)
    cat("Processing file:", file_name, "\n")
    
    results[[file_name]] = count_acmg_verdict(vcf_file)
  }
  
  # Create an empty data frame
  result_df = data.frame(
    Sample = character(),
    Uncertain_Significance = numeric(),
    Likely_Pathogenic = numeric(),
    Pathogenic = numeric(),
    stringsAsFactors = FALSE
  )
  
  # Fill the data frame with the results using dplyr functions
  for (file_name in names(results)) {
    sample_name = str_replace_all(file_name, fixed(".vcf"), "")
    result_df = bind_rows(result_df, tibble(
      Sample = sample_name,
      Uncertain_Significance = results[[file_name]]$Uncertain_Significance,
      Likely_Pathogenic = results[[file_name]]$Likely_Pathogenic,
      Pathogenic = results[[file_name]]$Pathogenic
    ))
  }
  
  return(result_df)
}

# Process SNPs folder
snps_folder_path = "ACMG_SNPs"
snps_result_df = process_folder(snps_folder_path)

# Process INDELs folder
indels_folder_path = "ACMG_indels"
indels_result_df = process_folder(indels_folder_path)


### PLOTS
sample_names = c("Patient_01", "Patient_02", "Patient_03", "Patient_04", "Patient_05", "Patient_06", 
                 "Patient_07", "Patient_08", "Patient_09", "Patient_10", "Patient_11")
column_names = c("Sample", "Count", "Classification")

# For SNPs
snps_result_df$Sample = sample_names
snps_order = as.data.frame(cbind(snps_result_df$Sample, snps_result_df$Uncertain_Significance, (rep("Uncertain_Significance",nrow(snps_result_df)))))
snps_order = rbind(snps_order, (cbind(snps_result_df$Sample, snps_result_df$Likely_Pathogenic, (rep("Likely_Pathogenic",nrow(snps_result_df))))))
snps_order = rbind(snps_order, (cbind(snps_result_df$Sample, snps_result_df$Pathogenic, (rep("Pathogenic",nrow(snps_result_df))))))
colnames(snps_order) = column_names
snps_order$Count= as.numeric(snps_order$Count)

ggplot(snps_order, aes(x = Sample, y = Count, fill = Classification)) +
  geom_bar(stat = "identity") +
  labs(title = "SNPs classification",
       x = "Sample", y = "Frequency",
       fill = "ACMG classification") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        plot.title = element_text(hjust = 0.5)) + 
  scale_x_discrete(labels = sample_names) +
  scale_fill_manual(values = c("firebrick1", "salmon1", "orchid"),
                    name = "ACMG classification",
                    labels = c("Pathogenic", "Likely Pathogenic", "VUS"))


# For INDELs
indels_result_df$Sample = sample_names
indels_order = as.data.frame(cbind(indels_result_df$Sample, indels_result_df$Uncertain_Significance, (rep("Uncertain_Significance",nrow(indels_result_df)))))
indels_order = rbind(indels_order, (cbind(indels_result_df$Sample, indels_result_df$Likely_Pathogenic, (rep("Likely_Pathogenic",nrow(indels_result_df))))))
indels_order = rbind(indels_order, (cbind(indels_result_df$Sample, indels_result_df$Pathogenic, (rep("Pathogenic",nrow(indels_result_df))))))
colnames(indels_order) = column_names
indels_order$Count= as.numeric(indels_order$Count)

ggplot(indels_order, aes(x = Sample, y = Count, fill = Classification)) +
  geom_bar(stat = "identity") +
  labs(title = "SNPs classification",
       x = "Sample", y = "Frequency",
       fill = "ACMG classification") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        plot.title = element_text(hjust = 0.5)) + 
  scale_x_discrete(labels = sample_names) +
  scale_fill_manual(values = c("firebrick1", "salmon1", "orchid"),
                    name = "ACMG classification",
                    labels = c("Pathogenic", "Likely Pathogenic", "VUS"))





