# Clean and output tidy VRS data:
# Clean, format, and output data as the starting point for all data requests
# Reminder: keep cleaning and plotting code separate (for plotting, see prelim_VRS_and_market_survey_review.Rmd, etc)

rm(list=ls())
library(haven)
library(tidyverse)
library(magrittr)

# MacOS
datadir <- "/Volumes/jgephart/Kiribati/Data"
outdir <- "/Volumes/jgephart/Kiribati/Outputs"

# Windows
#datadir <- "K:/Kiribati/Data"
#outdir <- "K:/Kiribati/Outputs"

source("Data_cleaning/cleaning_functions.R")

# Looks to be already tidy
vrs_tidy <- read_dta(file.path(datadir, "20201013_VRS", "KIR_VILLAGE_RESOURCE_SURVEY.dta")) %>%
  clean_data(return = "df") %>% # extract attributes
  arrange(interview__key)

id_cols <- c("interview__key", "interview__id")

vrs_long <- pivot_dat_i(vrs_tidy, id_cols = id_cols) %>%
  filter(value != "##N/A##") %>%
  arrange(interview__key)

# Extract column labels
vrs_labels <- clean_data(vrs_tidy, return = "var_labels")

# Assume that fill in the blank responses will be those that have no other matching
vrs_alpha <- vrs_long %>%
  filter(str_detect(value, pattern = "[:alpha:]")) %>%
  # Try sort(unique(vrs_alpha$question_id) to figure out which questions to filter
  filter(question_id %in% c("respondent_names__0", "respondent_names__1", "start_vrs", "villageGPS__Timestamp")) %>%
  select(question_id, value) %>%
  arrange(question_id) %>%
  unique()

# Outputs:
# Final long format of all uniquely identified questions: vrs_long
# Final tidy format: vrs_tidy
# Key for matching col.names (question_id) to col.labels: vrs_labels
# "Alpha" response for translation: vrs_fill_in_the_blank

write.csv(vrs_long, file = file.path(outdir, "vrs_long.csv"), row.names = FALSE)
write.csv(vrs_tidy, file = file.path(outdir, "vrs_tidy.csv"), row.names = FALSE)
write.csv(vrs_labels, file = file.path(outdir, "vrs_question-id-to-label-key.csv"), row.names = FALSE)
write.csv(vrs_alpha, file = file.path(outdir, "vrs_text-responses-for-translation.csv"), row.names = FALSE)

