# Load necessary libraries
library(vcfR)
library(stringr)
library(ggplot2)
library(gtools)

# Specify the path to the folder containing the .vcf files
folder_path = getwd()

# Get the list of .vcf files in the folder
vcf_files = list.files(path = folder_path, pattern = "\\SNPs.AlphaMissense.vcf$", full.names = TRUE)

# Create an empty dataframe to store the results
result_data = data.frame(File = character(),
                          ACMG_verdict = character(),
                          CSQ = character(),
                          AlphaMissense = character(),
                          Gene = character(),
                          Original_variant = character(),
                          stringsAsFactors = FALSE)

# Iterate over each .vcf file in the folder
for (vcf_file in vcf_files) {
  # Read the .vcf file
  vcf_data = read.vcfR(vcf_file, verbose = FALSE)
  
  # Extract the 'CSQ' information
  info_CSQ = extract_info_tidy(vcf_data, info_fields = "CSQ", info_types = TRUE, info_sep = ";")
  matches = str_match(info_CSQ$CSQ, "\\|([^|]+)\\|")
  info_CSQ$CSQ = matches[, 2]
  
  # Extract 'acmg_verdict' information
  info_acmg_verdict = extract_info_tidy(vcf_data, info_fields = "acmg_verdict", info_types = TRUE, info_sep = ";")
  
  # Extract 'CSQ' information again for a different purpose
  info_AlphaMissense = extract_info_tidy(vcf_data, info_fields = "CSQ", info_types = TRUE, info_sep = ";") 
  
  # Keep only the last two elements in the 'info_AlphaMissense' column
  info_AlphaMissense$CSQ = sapply(strsplit(info_AlphaMissense$CSQ, "\\|"), function(x) paste(tail(x, 2), collapse = "|"))
  
  # Extract 'gene' information
  info_gene = extract_info_tidy(vcf_data, info_fields = "gene", info_types = TRUE, info_sep = ";")
  
  # Extract 'orignial_variant' information
  info_OriginalVariant = extract_info_tidy(vcf_data, info_fields = "original_variant", info_types = TRUE, info_sep = ";")
  
  # Filter rows that meet the conditions for each file and add to the result_data dataframe
  filtered_rows = which(info_acmg_verdict$acmg_verdict == "Uncertain_Significance" & 
                           (info_CSQ$CSQ == "missense_variant" | info_CSQ$CSQ == "missense_variant&splice_region_variant"))
  
  if (length(filtered_rows) > 0) {
    result_data = rbind(result_data, data.frame(File = basename(vcf_file),
                                                 ACMG_verdict = info_acmg_verdict$acmg_verdict[filtered_rows],
                                                 CSQ = info_CSQ$CSQ[filtered_rows],
                                                 AlphaMissense = info_AlphaMissense$CSQ[filtered_rows],
                                                 Gene = info_gene$gene[filtered_rows],
                                                 Original_variant = info_OriginalVariant$original_variant[filtered_rows],
                                                 stringsAsFactors = FALSE))
  }
}

# Print the results
print(result_data)

# Create a new dataframe to store the filtered rows
filtered_data = result_data[grepl("likely_pathogenic", result_data$AlphaMissense), ]

# Write the filtered data to a file
write.table(filtered_data, file = "variants_alpha_missense.txt", quote = FALSE, row.names = FALSE, sep = "\t")

# Read the fixed data from a file
fix_data = read.table("variants_alpha_missense_fix.txt", header = TRUE)

# Order the dataframe using mixedorder from gtools
fix_data = fix_data[mixedorder(fix_data$Original_variant), ]
fix_data$Original_variant = factor(fix_data$Original_variant, levels = fix_data$Original_variant)

# Create a ggplot for visualization
ggplot(fix_data, aes(x = Original_variant, y = AlphaMissense_score)) +
  geom_point(position = position_jitter(width = 0.3, height = 0), alpha = 0.7) +
  labs(title = "AlphaMissense score per variant",
       x = "Variant",
       y = "AlphaMissense score") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1),
        plot.title = element_text(hjust = 0.5))
