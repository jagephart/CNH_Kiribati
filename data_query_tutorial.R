# Start by loading df_tidy or var_labels
# Change file.path directories as needed
rm(list=ls())
library(tidyverse)
datadir <- "/Volumes/jgephart/Kiribati/Data"
outdir <- "/Volumes/jgephart/Kiribati/Outputs"


df_tidy <- read.csv(file = file.path(outdir, "hies_tidy_individual-level.csv"))
var_labels <- read.csv(file = file.path(outdir, "hies_question-id-to-label-key.csv"))

# Set id_cols - these columns are shared across all individual-level surveys
id_cols <- c("interview__key",
             "fweight",
             "division",
             "island",
             "village",
             "rururb",
             "hm_basic__id")

# For non-roster questions, select column name
# example using p319
dat_col_match = "p319"

# Check var_labels to see these match to the correct question_id's
var_labels %>%
  filter(str_detect(col.names, dat_col_match))

# Subset df
df_query <- df_tidy %>%
  select(all_of(id_cols), contains(dat_col_match))

# save df_query
# write.csv(df_query, file = "insert-filename-here.csv")

# For roster questions (i.e., questions that are generated based on responses to other questions):
# example using p923, roster question with a linked question that also contains multiple fill in the blank columns

dat_col_match = "p923" # matches to p923__1, p923__2, p923__3

link_match = "p922_"

fill_in_the_blank_match = "p922n"

# Check var_labels to see these match to the correct question_id's
var_labels %>%
  filter(str_detect(col.names, dat_col_match))

var_labels %>%
  filter(str_detect(col.names, link_match))

var_labels %>%
  filter(str_detect(col.names, fill_in_the_blank_match))

df_query <- df_tidy %>%
  select(all_of(id_cols), contains(c(dat_col_match, link_match, fill_in_the_blank_match)))

# save df_query
# write.csv(df_query, file = "insert-filename-here.csv")

# For even more context can add in p901 (notice p922 only applies if respondent answered 1 to p901)

# Always check var_labels to see these match to the correct question_id's
var_labels %>%
  filter(str_detect(col.names, "p901"))

df_query <- df_tidy %>%
  select(all_of(id_cols), contains(c(dat_col_match, link_match, fill_in_the_blank_match, "p901")))

# Removing all responses that didn't go fishing makes the dataset more manageable
df_query %>%
  filter(p901 == 1) %>%
  dim()

# Make sure to trace back all relevant layers of roster questions
# p318 and p318n relates to respondents who answer "no" to p314
# p315, p316, p317, and p317n relates to respondents who answer "yes" to p314
# p314 only applies to respondents who answered yes to any of the p308
# For multiple layers of roster questions:

dat_col_match <- c("p308", "p314", "p315", "p315n", "p316", "p317", "p317n", "p318", "p318n")

# Check column labels
var_labels %>%
  filter(str_detect(col.names, paste(dat_col_match, collapse = "|")))

df_query <- df_tidy %>%
  select(all_of(id_cols), contains(dat_col_match))

# save df_query
# write.csv(df_query, file = "insert-filename-here.csv")

# For food recall questions: i.e., any questions beginning with "In the last 7 days....", query the expenditures dataset
hies_expenditure <- read.csv(file.path(outdir, "hies_expenditures-standard-units.csv"))

# Notice there are several sections included here:
sort(unique(hies_expenditure$section))

food_recall <- hies_expenditure %>%
  filter(section == "21_foodrecall")

# To get specific types of food recall:
# (1) Filter by specific coicop_class
unique(food_recall$coicop_class)

# For question h1503b and h1503c, filter to coicop_class == "Fish and sea food"

# Or (2) Filter by specific responses in the desciprtion column
# list_of_descriptions <- c("Oceanic fish (Tuna, Wahoo, Mahi-mahi, etc.)",
#                           "Reef fish (fresh or frozen)",
#                           "Lagoon and sandflat fish (fresh or frozen)",
#                           "Deep sea fish (fresh or frozen)",
#                           "Fresh water fish",
#                           "Sharks (fresh or frozen)",
#                           "Sea worm",
#                           "Lobster",
#                           "Cockles",
#                           "Clams",
#                           "Sea snails",
#                           "Tinned tuna",
#                           "Tinned mackerel",
#                           "Other dried, canned or salted fish",
#                           "Land crab (mud crab, coconut crab, etc.)"
#                           )

# Use var_labels to get descriptions of columns in food_recall - cn use this to help decide which are relevant to your data query
var_labels %>%
  filter(col.names %in% names(food_recall))

h1503b_and_c <- food_recall %>%
  #filter(description %in% list_of_descriptions) %>% # if filtering by "Description"
  filter(coicop_class == "Fish and sea food")

write.csv(h1503b_and_c, file.path(outdir, "Data Requests", "2021-06-24_Data-request_IRS_h1503b_and_c.csv"), row.names = FALSE)

