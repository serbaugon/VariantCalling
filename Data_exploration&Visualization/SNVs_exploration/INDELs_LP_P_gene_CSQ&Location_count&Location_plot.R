# Libraries
library(vcfR)
library(stringr)
library(dplyr)
library(ggplot2)
library(RColorBrewer)

# Path to the folder containing VCF files
folder_path = getwd()

# Get the list of VCF files in the folder
vcf_files = list.files(path = folder_path, pattern = "\\.vcf$", full.names = TRUE)

# Initialize a dataframe to store the results
total_results = data.frame(Variant_Type = character(), Frequency = integer(), stringsAsFactors = FALSE)
total_variants = data.frame(Sample = character(), Variants = integer(), stringsAsFactors = FALSE)

# Loop over each VCF file
for (vcf_file in vcf_files) {
  # Read the VCF file
  vcf_data = read.vcfR(vcf_file, verbose = FALSE)
  
  # Extract information from CSQ and keep only the variant types
  info_CSQ = extract_info_tidy(vcf_data, info_fields = "CSQ", info_types = TRUE, info_sep = ";")
  matches = str_match(info_CSQ$CSQ, "\\|([^|]+)\\|")
  info_CSQ$CSQ = matches[, 2]
  
  # Count the frequency of each unique value in the CSQ column
  frequency_elements = table(info_CSQ$CSQ)
  variant_type_count = as.data.frame(frequency_elements)
  variant_type_count$File = basename(vcf_file)  # Add a column for the file name
  
  # Rename the columns
  colnames(variant_type_count) = c("Type", "Count", "File")
  
  # Add the results to the total dataframe
  total_results = rbind(total_results, variant_type_count)
  
  # Count the number of variants
  variants_number = nrow(info_CSQ)
  total_variants = rbind(total_variants, data.frame(Sample = basename(vcf_file), Variants = variants_number))
}

### Total variants
# Print the total variants for each file
print(total_variants)

# Print the sum of all total variants
total_variants_sum = sum(total_variants$Variants)
print(total_variants_sum)

### Variant type
# Print the different types of variants in each sample
print(total_results)

# Aggregate the counts across all files
final_results = aggregate(Count ~ Type, data = total_results, sum)

# Print the sum of all different types of variants
print(final_results)

### Aggregation of the variants in groups for each sample and total
## 5'-UTR
types_5UTR <- c("5_prime_UTR_variant")
count_5UTR <- subset(total_results, Type %in% types_5UTR)
sum(count_5UTR$Count)

## 3'-UTR
types_3UTR <- c("3_prime_UTR_variant","3_prime_UTR_variant&NMD_transcript_variant")
count_3UTR <- subset(total_results, Type %in% types_3UTR)
sum(count_3UTR$Count)

## Exonic
# Nonsense
types_nonsense <- c("stop_gained","stop_gained&frameshift_variant&splice_region_variant","stop_gained&frameshift_variant")
count_nonsense <- subset(total_results, Type %in% types_nonsense)
sum(count_nonsense$Count)

# INDELs
types_indel <- c("frameshift_variant", "inframe_deletion", "inframe_insertion", "inframe_deletion&splice_region_variant", "inframe_insertion&splice_region_variant")
count_indels <- subset(total_results, Type %in% types_indel)
sum(count_indels$Count)

# No coding
types_no_coding <- c("non_coding_transcript_exon_variant", "splice_region_variant&non_coding_transcript_exon_variant")
count_no_coding <- subset(total_results, Type %in% types_no_coding)
sum(count_no_coding$Count)

## Splicing site
types_intronic <- c("splice_donor_variant", "splice_acceptor_variant&non_coding_transcript_variant", "splice_donor_variant&non_coding_transcript_variant", "splice_acceptor_variant&frameshift_variant")
count_intronic <- subset(total_results, Type %in% types_intronic)
sum(count_intronic$Count)

## Intergenic
types_intergenic<- c("intergenic_variant", "downstream_gene_variant", "upstream_gene_variant", "TF_binding_site_variant", "regulatory_region_variant", "TFBS_ablation&TF_binding_site_variant")
count_intergenic <- subset(total_results, Type %in% types_intergenic)
sum(count_intergenic$Count)

total_sum = sum(count_5UTR$Count, count_3UTR$Count, count_nonsense$Count, count_indels$Count, count_no_coding$Count, count_intronic$Count, count_intergenic$Count)
print(total_sum)



# Data preparation
stacked_bar_data <- total_results %>%
  mutate(Type = ifelse(Type %in% types_5UTR, "5'-UTR",
                       ifelse(Type %in% types_3UTR, "3'-UTR",
                              ifelse(Type %in% types_nonsense, "Exonic (Nonsense)",
                                     ifelse(Type %in% types_indel, "Exonic (INDELs)",
                                            ifelse(Type %in% types_no_coding, "Exonic (No Coding)",
                                                   ifelse(Type %in% types_intronic, "Splicing site", "Intergenic")))))))

stacked_bar_data$File <- factor(stacked_bar_data$File, levels = unique(stacked_bar_data$File), 
                                labels = c("Patient_01", "Patient_02", "Patient_03", "Patient_04", "Patient_05", "Patient_06",
                                           "Patient_07", "Patient_08", "Patient_09", "Patient_10", "Patient_11"))
filtered_data <- stacked_bar_data %>%
  filter(Type != "Intergenic")


# Create a stacked bar plot
ggplot(filtered_data, aes(x = File, y = Count, fill = Type)) +
  geom_bar(stat = "identity") +
  labs(title = "INDELs location",
       x = "Sample", y = "Frequency",
       fill = "Location") +
  scale_fill_manual(values = c("lightgoldenrod1","darkseagreen3", "firebrick1", "cyan3", "blue1", "chocolate1")) +  
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        plot.title = element_text(hjust = 0.5))  




#### Count the number of Uncertain significance, likely pathogenic and pathogenic variants in all files

# Function to count "Likely_pathogenic" and "Pathogenic" variants
count_pathogenic_variants = function(vcf_file) {
  # Load the VCF file
  vcf_data = read.vcfR(vcf_file, verbose = FALSE)
  
  # Get the info_df dataframe
  info_verdict = extract_info_tidy(vcf_data, info_fields = "acmg_verdict", info_types = TRUE, info_sep = ";")
  
  # Count the number of likely pathogenic and pathogenic variants
  count_uncertain_signifiance = nrow(subset(info_verdict, acmg_verdict %in% "Uncertain_Significance"))
  count_likely_pathogenic = nrow(subset(info_verdict, acmg_verdict %in% "Likely_Pathogenic"))
  count_pathogenic = nrow(subset(info_verdict, acmg_verdict %in% "Pathogenic"))
  
  # Return the result as a list
  return(list(uncertain_significance = count_uncertain_signifiance,
              likely_pathogenic = count_likely_pathogenic,
              pathogenic = count_pathogenic))
}

# List to store the results
results = list()

# Iterate over the VCF files and count pathogenic variants
for (vcf_file in vcf_files) {
  file_name = basename(vcf_file)
  cat("Processing file:", file_name, "\n")
  
  results[[file_name]] = count_pathogenic_variants(vcf_file)
}

# Create an empty data frame
result_df = data.frame(
  File = character(),
  Uncertain_Significance = numeric(),
  Likely_Pathogenic = numeric(),
  Pathogenic = numeric(),
  stringsAsFactors = FALSE
)

# Fill the data frame with the results using dplyr functions
for (file_name in names(results)) {
  result_df = bind_rows(result_df, tibble(
    File = file_name,
    Uncertain_Significance = results[[file_name]]$uncertain_significance,
    Likely_Pathogenic = results[[file_name]]$likely_pathogenic,
    Pathogenic = results[[file_name]]$pathogenic
  ))
}

# Print the data frame
print(result_df)



#### Assign  genes and types of variants 

# List to store results from all files
total_results = list()

# Iterate over the VCF files
for (file in vcf_files) {
  # Load the VCF file
  vcf_data = read.vcfR(file, verbose = FALSE)
  
  # Extract necessary information
  info_CSQ = extract_info_tidy(vcf_data, info_fields = "CSQ", info_types = TRUE, info_sep = ";")
  matches = str_match(info_CSQ$CSQ, "\\|([^|]+)\\|")
  info_CSQ$CSQ = matches[, 2]
  
  info_verdict = extract_info_tidy(vcf_data, info_fields = "acmg_verdict", info_types = TRUE, info_sep = ";")
  
  info_gene = extract_info_tidy(vcf_data, info_fields = "gene", info_types = TRUE, info_sep = ";")
  
  info_variant = extract_info_tidy(vcf_data, info_fields = "original_variant", info_types = TRUE, info_sep = ";")
  
  # Identify variants with "Pathogenic" or "Likely_Pathogenic" verdicts
  interesting_indices = which(info_verdict$acmg_verdict %in% c("Pathogenic", "Likely_Pathogenic"))
  
  # Get the sample name (file name)
  sample_name = basename(file)
  
  # Store the results in the list
  results = data.frame(
    Sample = rep(sample_name, length(interesting_indices)),
    ACMG_Verdict = info_verdict$acmg_verdict[interesting_indices],
    Gene = info_gene$gene[interesting_indices],
    CSQ = info_CSQ$CSQ[interesting_indices],
    Original_variant = info_variant$original_variant[interesting_indices])
  
  # Assign numeric row names
  rownames(results) = seq_len(nrow(results))
  
  # Add results to the total list
  total_results[[sample_name]] = results
}

# Combine all results into a single data frame
total_results = do.call(rbind, total_results)

rownames(total_results) = seq_len(nrow(total_results))

# Show the results
print(total_results)

# Write the results
write.table(total_results, file = "genes_P_LP_INDELs.txt", quote = FALSE, row.names = FALSE, sep = "\t")


