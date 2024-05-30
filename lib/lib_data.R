# Functions for data prep and wrangling

library('dplyr')
library('readxl')
library('janitor')
library('lubridate')

# Load data and clean variables names
load_data <- function(data_file) {
  my_data <- readxl::read_excel(data_file)
  my_data <- janitor::clean_names(my_data)
  
  return(my_data)
}

# Select variables for sign language analysis (+ some demographic/QoL variables)
# Shorten variables so easier to reference
# Format some variables (e.g., to lowercase, integers)
select_and_format_sign_language_data <- function(data_gdri) {
  
  # Keep columns containing these strings
  keep_col <- c('response_id', 'date_of_birth', 'sex', 'experiencing_hearing_loss', 'language', 
                'quality_of_life', 'enjoy_life',
                'meaningful', 'communication_access', 'crisis', 'available', 'communicate')
  
  data_gdri <- data_gdri |>
    select(contains(keep_col)) |>
    # Remove some unneeded variables caught by general string match
    select(!contains(c('queer', 'how_satisfied', 'personal_relationships', 'violence', 'cost'))) 
  
  var_original <- colnames(data_gdri) # save original names for later reference
  
  # Shorten variable names
  data_gdri <- data_gdri |>
    rename(id = response_id,
           dob = what_is_your_date_of_birth,
           age_hearing_loss = at_what_age_did_you_begin_experiencing_hearing_loss,
           languages = languages_you_use_comfortably,
           age_learned_sl = how_old_were_you_when_you_learned_sign_language,
           want_learn_sl = do_you_want_to_learn_sign_language,
           how_fluent_sl = how_fluent_are_you_in_sign_language,
           where_learn_sl = where_did_you_learn_sign_language,
           qol = how_would_you_rate_your_quality_of_life,
           enjoy_life = how_much_do_you_enjoy_life,
           meaningful_life = to_what_extent_do_you_feel_your_life_to_be_meaningful,
           communication_access_work = if_you_require_communication_access_at_work_can_you_get_it,
           communication_access_school = if_you_require_communication_access_at_school_can_you_get_it,
           communication_access_social = if_you_require_communication_access_at_social_events_e_g_festivals_weddings_religious_gatherings_can_you_get_it,
           communication_access_healthcare = if_you_require_communication_access_in_healthcare_can_you_get_it,
           crisis_can_access_info = in_a_crisis_like_natural_disasters_or_disease_are_you_confident_about_accessing_necessary_information_and_communication,
           crisis_where_access_info = in_a_crisis_like_natural_disasters_or_disease_where_do_you_get_necessary_information_and_communication,
           available_info_need_daily_life = how_available_to_you_is_the_information_that_you_need_in_your_day_to_day_life,
           can_communicate_doctor = can_you_communicate_with_your_doctor,
           how_communicate_family = how_do_you_communicate_with_your_family_members
    )
  
  var_new <- colnames(data_gdri) # new variable names
  
  # Formatting
  data_gdri <- data_gdri |>
    mutate(
      # age of hearing loss --> int
      age_hearing_loss = as.integer(age_hearing_loss),
      # languages text to lowercase
      languages = tolower(languages),
      # format date of birth
      dob = as.Date(dob, format = "%m/%d/%Y")
    )
  
  # Store data frame and variable names in a list
  sl_data <- list(data_gdri = data_gdri, var_original = var_original, var_new = var_new)
  return(sl_data)
  
}

# Add additional sign language variables:
# - Numeric sign language fluency
# - Number of years between hearing loss and learning sign language
# - Approximate year learned sign language and year hearing loss started
# - languages_include_asl - listed ASL or "English" sign language
# - langauges_include_nsl - listed NSL
# - languages_include_unspecified_sl - listed ambiguous/unclear or non-specified SL
# - languages_include_any_sl - listed any SL
# - knows_sl: listed any SL or SL fluency level at least 3 (neither good nor poor) 
compute_additional_sl_variables <- function(data_gdri) {
  
  # Add numeric sign language fluency variable
  data_gdri <- data_gdri |>
    mutate(how_fluent_sl_num = 
             case_match(
               how_fluent_sl,
               "Very good" ~ 5,
               "Good" ~ 4,
               "Neither poor nor good" ~ 3,
               "Poor" ~ 2,
               "Very poor" ~ 1,
               NA ~ NA
             )
    )
  
  # Number of years between hearing loss and learning sign language
  data_gdri <- data_gdri |>
    mutate(
      age_learned_sl_minus_age_hearing_loss = age_learned_sl - age_hearing_loss
    )
  
  # Approximate year learned sign language and year hearing loss started
  data_gdri <- data_gdri |>
    mutate(
      dob_year = lubridate::year(dob),
      year_learned_sl = dob_year + age_learned_sl,
      year_hearing_loss = dob_year + age_hearing_loss
    ) 
  
  # Sign languages respondents know and whether respondent knows in sign language
  # (combining info from fluency and language questions)
  
  #languages_include_asl - ASL or english sign language
  #langauges_include_nsl - NSL
  #languages_include_unspecified_sl - ambiguous/unclear or non-specified SL
  #languages_include_any_sl - any of the above
  
  asl_strings <- c(
    'asl', 'a.s.l', 'america sign language',
    'english language \\(sign language', 
    'english language of sign language', 
    'english sign language for the deaf',
    'sign language-english'
  ) 
  # Did not include "english sign language" since unclear if should be
  # "english, sign language" (i.e., separate languages) (7 responses)
  
  nsl_strings <- c(
    'nsl', 'n.s.l', 'nigeria sign language', 
    'nigerian sign language'
  )
  
  sl_strings <- c('sign language')
  
  data_gdri <- data_gdri |>
    # ASL and NSL; starting point for unspecified SL
    mutate(
      languages_include_asl = grepl(paste0(asl_strings, collapse = '|'), languages),
      languages_include_nsl = grepl(paste0(nsl_strings, collapse = '|'), languages),
      languages_include_unspecified_sl = grepl(paste0(sl_strings, collapse = '|'), languages)
    ) |>
    # remove ASL and NLS from unspecified sign language
    mutate(
      languages_include_unspecified_sl = (languages_include_unspecified_sl & !(languages_include_asl | languages_include_nsl))
    ) |>
    # any SL
    mutate(
      languages_include_any_sl = (languages_include_asl | languages_include_nsl | languages_include_unspecified_sl)
    )
  
  # Add "knows sign language" variable based on combined info from the 
  # languages and sign language fluency questions
  # Note:
  #    TRUE | NA --> TRUE (will be true if languages include SL, even if no fluency response)
  #    FALSE | NA --> NA (will be NA if languages do not include SL and no fluency response)
  data_gdri <- data_gdri |>
    mutate(
      knows_sl = (languages_include_any_sl | how_fluent_sl_num >= 3)
    )
  
  return(data_gdri)
}


# Load data and perform all prep steps 
load_and_prep_sign_language_data <- function(file_gdri) {
  
  data_gdri <- load_data(file_gdri)
  sl_data <- select_and_format_sign_language_data(data_gdri)
  sl_data$data_gdri <- compute_additional_sl_variables(sl_data$data_gdri)
  
  return(sl_data)
  
}