# Initial exploration of GDRI data
# See lib/lib_data.R for data wrangling functions

# Set up ----

rm(list = ls())
library(dplyr)
library(ggplot2)
library(glue)

source(file.path('lib', 'lib_data.R'))

# Load data and clean column names ----

file_gdri <- file.path('data', 'Deaf Community Research Nigeria Data for Viz for Social Good V.2.xlsx')
data_gdri <- load_data(file_gdri)
View(data_gdri)

# Keep and format variables needed for analysis ----

sl_data <- select_and_format_sign_language_data(data_gdri)

# Compute new variables ----

sl_data$data_gdri <- compute_additional_sl_variables(sl_data$data_gdri)

View(sl_data$data_gdri |> select(contains(c("fluent", "want_learn"))))
View(sl_data$data_gdri |> select(contains(c('dob', 'age_', 'year', 'learn'))))
View(
  sl_data$data_gdri |> 
    select(contains(c('dob', 'age_', 'year', 'learn'))) |> 
    filter(age_learned_sl_minus_age_hearing_loss < 0)
)

View(sl_data$data_gdri |> select(contains(c('languages', 'fluent', 'knows'))))
View(sl_data$data_gdri |> select(contains(c('languages', 'fluent', 'knows'))) |>
       filter(knows_sl == FALSE | is.na(knows_sl)))
View(sl_data$data_gdri |> select(contains(c('languages', 'fluent', 'knows'))) |>
       filter(how_fluent_sl_num <= 3))

# Check whether anyone who had poor/very poor fluency marked themselves as comfortable using SL
sum(sl_data$data_gdri$languages_include_any_sl & sl_data$data_gdri$how_fluent_sl_num < 3, na.rm = TRUE)
# answer: 0. Supports not counting poor/very poor fluency as "knows SL".

# Check whether anyone who had neutral fluency marked themselves as comfortable using SL
sum(sl_data$data_gdri$languages_include_any_sl & sl_data$data_gdri$how_fluent_sl_num == 3, na.rm = TRUE)
# answer: 8. Supports counting this fluency level as "knows SL".

# Check number of people that marked good+ fluency, but didn't include SL in languages
sum(!sl_data$data_gdri$languages_include_any_sl & sl_data$data_gdri$how_fluent_sl_num > 3, na.rm = TRUE)
# answer: 94. Many people very comfortable with SL didn't list SL in their languages
# As such, the absence of SL listed in languages != doesn't know SL (may be biased towards spoken languages?)

n_fluent_sl <- sum(sl_data$data_gdri$how_fluent_sl_num >= 3, na.rm = TRUE)
print(glue::glue('{n_fluent_sl} indicated at least neutral (neither good nor poor) fluency with SL'))

n_languages_include_sl <- sum(sl_data$data_gdri$languages_include_any_sl, na.rm = TRUE)
print(glue::glue('{n_languages_include_sl} include sign language in their languages'))

n_know_sl <- sum(sl_data$data_gdri$knows_sl, na.rm = TRUE)
print(glue::glue('{n_know_sl} know SL based on either criteria'))

n_sl_no_response_fluency <- sum(sl_data$data_gdri$languages_include_any_sl & is.na(data_gdri$how_fluent_sl))
print(glue::glue('{n_sl_no_response_fluency} included SL in languages, but did not rate fluency'))

# Exploratory computations/vis --------------------------------------------------
data_gdri <- sl_data$data_gdri

# age lost hearing ----
ggplot(data_gdri, aes(x = age_hearing_loss)) +
  geom_histogram(binwidth = 2)
sum(is.na(data_gdri$age_hearing_loss)) # number of missing values

# by sex
ggplot(data_gdri, aes(x = age_hearing_loss)) +
  geom_histogram(binwidth = 2) +
  facet_wrap(vars(sex), ncol = 1)

# by SL fluency
ggplot(data_gdri, aes(x = age_hearing_loss)) +
  geom_histogram(binwidth = 2) +
  facet_wrap(vars(how_fluent_sl_num), ncol = 1)

# age learned SL ----

ggplot(data_gdri, aes(x = age_learned_sl)) +
  geom_histogram(binwidth = 2)
sum(is.na(data_gdri$age_learned_sl)) # number of missing values

# by sex
ggplot(data_gdri, aes(x = age_learned_sl)) +
  geom_histogram(binwidth = 2) +
  facet_wrap(vars(sex), ncol = 1)

# by SL fluency
ggplot(data_gdri, aes(x = age_learned_sl)) +
  geom_histogram(binwidth = 2) +
  facet_wrap(vars(how_fluent_sl_num), ncol = 1)

# age lost hearing vs age learned SL ----

ggplot(data = data_gdri, aes(x = age_hearing_loss, y = age_learned_sl)) +
  geom_point(alpha = 0.2) +
  coord_fixed()

# gap until learned SL vs age ----

ggplot(data_gdri, aes(x = age_learned_sl_minus_age_hearing_loss)) +
  geom_histogram(binwidth = 1) 

ggplot(data_gdri, aes(x = age_learned_sl_minus_age_hearing_loss)) +
  geom_histogram(binwidth = 1) +
  facet_wrap(vars(how_fluent_sl_num), ncol = 1)

ggplot(data_gdri, aes(x = age_learned_sl_minus_age_hearing_loss)) +
  geom_histogram(binwidth = 1) +
  facet_wrap(vars(sex), ncol = 1)

median(data_gdri$age_learned_sl_minus_age_hearing_loss, na.rm = TRUE)

n <- sum(!is.na(data_gdri$age_learned_sl_minus_age_hearing_loss))
(sum(data_gdri$age_learned_sl_minus_age_hearing_loss >= 10, na.rm = TRUE) / n) * 100

sum(is.na(data_gdri$age_learned_sl_minus_age_hearing_loss)) # number of missing values

# year of hearing loss ----
ggplot(data_gdri, aes(x = year_hearing_loss)) +
  geom_histogram(binwdith = 2)

# learning "wait" vs year of hearing loss ----

ggplot(data_gdri, aes(x = year_hearing_loss, y = age_learned_sl_minus_age_hearing_loss)) +
  geom_point(alpha = 0.2) 

ggplot(data_gdri, aes(x = year_hearing_loss, y = age_learned_sl_minus_age_hearing_loss)) +
  geom_point(alpha = 0.2) +
  geom_smooth(method = "lm")

# ----

View(data_gdri |> filter(is.na(how_fluent_sl)))
