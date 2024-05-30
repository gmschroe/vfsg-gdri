# Visualisation of number of people fluent in sign language and the sign languages
# they know

# Set up ----

rm(list = ls())
library(dplyr)
library(ggplot2)
library(glue)
library(ggtext)

source(file.path('lib', 'lib_data.R'))
source(file.path('lib', 'lib_theme.R'))

# Load and prep data ----
file_gdri <- file.path('data', 'Deaf Community Research Nigeria Data for Viz for Social Good V.2.xlsx')
sl_data <- load_and_prep_sign_language_data(file_gdri)
#View(sl_data$data_gdri)
data_gdri <- sl_data$data_gdri

# Compute n for each category --------------------------------------------------

n = list()

n$total <- nrow(data_gdri)

# Number of people who "know sign language" - defined as either at least 
# neutral (neither poor nor good) fluency in sign language OR listing a sign language
# in languages
n$know_sl <- sum(data_gdri$knows_sl, na.rm = TRUE)
print(glue::glue('{n$know_sl} know SL'))

# Number of people not fluent in sign language
# Listed fluency as either poor or very poor 
n$not_fluent_sl <- sum(data_gdri$knows_sl == FALSE, na.rm = TRUE)
print(glue::glue('{n$not_fluent_sl} had poor SL fluency'))

# No response (did not list sign language in languages or fluency)
# Note that not listing sign language in languages is not strong evidence that
# the respondent doesn't know sign language - many people who expressed high 
# levels of fluency did not list sign language in languages
n$no_response <- sum(is.na(data_gdri$knows_sl))
print(glue::glue('{n$no_response} did not list fluency or include SL in languages'))

# Check sum matches number of rows
(n$know_sl + n$not_fluent_sl + n$no_response) == n$total

# Number of people who know each sign language
# Nigerian Sign Language
n$nsl <- sum(data_gdri$languages_include_nsl)
# American Sign Language
n$asl <- sum(data_gdri$languages_include_asl)
# Only Nigerian Sign Language
n$only_nsl <- sum(data_gdri$languages_include_nsl & (data_gdri$languages_include_asl == FALSE))
# Only American Sign Language
n$only_asl <- sum(data_gdri$languages_include_asl & (data_gdri$languages_include_nsl == FALSE))
# NSL and ASL
n$asl_and_nsl <- sum(data_gdri$languages_include_asl & data_gdri$languages_include_nsl)
# Unspecified sign language (either noted good fluency, but did not list a sign language, or list unspecified sign language)
n$unspecified_sl <- n$know_sl - (n$only_nsl + n$only_asl + n$asl_and_nsl)

# Make squares -----------------------------------------------------------------
# Function for making square with area = n  
make_square_data <- function(area, x_shift = 0, y_shift = 0) {
  width <- sqrt(area)
  square_data <- data.frame(
    x = c(0, 0, width, width) + x_shift,
    y = c(0, width, width, 0) + y_shift
  )
}

# Coordinate calculations
gap <- 1.5
w_know_sl <- sqrt(n$know_sl)
w_not_fluent <- sqrt(n$not_fluent_sl)
w_no_response <- sqrt(n$no_response)
w_nsl <- sqrt(n$nsl)
w_asl <- sqrt(n$asl)
w_both <- sqrt(n$asl_and_nsl)

# Squares
square_know_sl <- make_square_data(n$know_sl)
square_no_response <- make_square_data(
  n$no_response, x_shift = w_know_sl + gap, y_shift = w_know_sl - (w_not_fluent + (gap * 2) + w_no_response)
)
square_not_fluent <- make_square_data(
  n$not_fluent_sl, x_shift = w_know_sl + gap, y_shift = w_know_sl - w_not_fluent)

square_nsl <- make_square_data(
  n$nsl, x_shift = w_know_sl/2 - w_nsl + w_both/2, y_shift = w_know_sl/2 - w_both/2
)

square_asl <- make_square_data(
  n$asl, x_shift = w_know_sl/2 - w_both/2, w_know_sl/2 - w_asl + w_both/2
)

square_both <- make_square_data(
  n$asl_and_nsl, x_shift = w_know_sl/2 - w_both/2, y_shift = w_know_sl/2 - w_both/2
)
# Text -------------------------------------------------------------------------

text_title <- "Most of the surveyed deaf Nigerians know<br>sign language"
text_subtitle <- paste(
  glue::glue("In the Global Deaf Research Institute's survey of {n$total} deaf Nigerians,"),
  "most respondents indicated that they are fluent in sign language: they either expressed that they were comfortable",
  'using sign language or self-rated their sign language fluency as neutral ("neither good nor poor") or higher.'
)

text_caption <- paste0(
  'Designed by Gabrielle M. Schroeder for VFSG<br>',
  'Data: Global Deaf Research Institute<br>',
  '<b>NSL</b>: Nigerian Sign Language, <b>ASL</b>: American Sign Language'
)

sz_n_large <- 28
sz_label_large <- 12

label_know_sl <- data.frame(
  x = 0, y = w_know_sl,
  label = make_square_annotation(n$know_sl, "are fluent in sign language", sz_n = sz_n_large, sz_label = sz_label_large)
)

label_within_know_sl <-
  data.frame(
    x = 0, y = w_know_sl,
    label = make_square_annotation("", "Of those people...")
  )

label_not_fluent <- data.frame(
  x = square_not_fluent$x[1], y = w_know_sl,
  label = make_square_annotation(n$not_fluent_sl, "are not fluent", sz_n = sz_n_large, sz_label = sz_label_large)
)

label_no_response <- data.frame(
  x = square_no_response$x[1], y = square_no_response$y[2],
  label = make_square_annotation(n$no_response, "did not respond", sz_n = sz_n_large, sz_label = sz_label_large)
)

label_nsl <- data.frame(
  x = square_nsl$x[1], y = square_nsl$y[2],
  label = make_square_annotation(n$only_nsl, "only know <b>NSL<b>")
)

label_asl <- data.frame(
  x = square_asl$x[1], y = square_asl$y[1],
  label = make_square_annotation(n$only_asl, "only know <b>ASL<b>", n_dark = FALSE, label_dark = FALSE)
)

label_both <- data.frame(
  x = square_both$x[3], y = square_both$y[3],
  label = make_square_annotation(n$asl_and_nsl, "know both")
)

label_unspecified <- data.frame(
  x = square_know_sl$x[4], y = square_know_sl$y[4],
  label = make_square_annotation(n$unspecified_sl, "did not specify the sign language", sz_n = 10)
)

vfsg_width <- 1.55
vfsg_x <- 0.3
vfsg_y <- -2.9

# Plot -------------------------------------------------------------------------

theme_colours <- get_theme_colours()
clr_border <- theme_colours$grey_mid
sz_border <- 0.5

ggplot() +
  geom_polygon(
    data = square_know_sl, 
    mapping = aes(x = x, y = y), 
    fill = theme_colours$blue_light,
    colour = clr_border,
    size = sz_border
  ) +
  geom_textbox_gdri(
    label_know_sl,
    width = unit(5, 'inch'),
    vjust = 0,
    box.padding = unit(c(0, 0, 2, 0), "pt")
  ) +
  geom_textbox_gdri(
    label_within_know_sl,
    width = unit(5, 'inch')
  ) +
  geom_polygon(
    data = square_no_response, 
    mapping = aes(x = x, y = y), 
    fill = theme_colours$grey_light,
    colour = clr_border,
    size = sz_border
  ) +
  geom_textbox_gdri(
    label_no_response,
    width = unit(3, 'inch'),
    vjust = 0,
    box.padding = unit(c(0, 0, 2, 0), "pt")
  ) +
  geom_polygon(
    data = square_not_fluent, 
    mapping = aes(x = x, y = y), 
    fill = theme_colours$pal_grey[1],
    colour = clr_border,
    size = sz_border
  ) +
  geom_textbox_gdri(
    label_not_fluent,
    width = unit(3, 'inch'),
    vjust = 0,
    box.padding = unit(c(0, 0, 2, 0), "pt")
  ) +
  geom_polygon(
    data = square_nsl,
    mapping = aes(x = x, y = y), 
    fill = theme_colours$gold_light,
    colour = clr_border,
    size = sz_border
  ) +
  geom_textbox_gdri(
    label_nsl,
    width = unit(4, 'inch'),
    box.padding = unit(c(4, 2, 2, 4), "pt")
  ) +
  geom_polygon(
    data = square_asl,
    mapping = aes(x = x, y = y), 
    fill = theme_colours$pal_discrete[2],
    colour = clr_border,
    size = sz_border
  ) +
  geom_textbox_gdri(
    label_asl,
    width = unit(4, 'inch'),
    vjust = 0,
    box.padding = unit(c(4, 2, 2, 4), "pt")
  ) +
  geom_polygon(
    data = square_both,
    mapping = aes(x = x, y = y), 
    fill = theme_colours$gold_dark,
    colour = clr_border,
    size = sz_border
  ) +
  geom_textbox_gdri(
    label_both,
    width = unit(3, 'inch'),
    vjust = 0
  ) +
  geom_segment(
    data = data.frame(
      x = c(w_know_sl/2 + w_both/2 + 0.25),
      y = c(w_know_sl/2 + w_both/2 + 0.25),
      xend = c(w_know_sl/2 + 0.1 ),
      yend = c(w_know_sl/2 + 0.1)
    ),
    mapping = aes(x = x, y = y, xend = xend, yend = yend),
    linewidth = 0.5,
    arrow = arrow(length = unit(5, 'pt'), type = "closed"),
    colour = "black"
  ) +
  geom_textbox_gdri(
    label_unspecified,
    width = unit(3, 'inch'),
    vjust = 0, hjust = 1, halign = 1
  ) +
  coord_fixed(clip = "off") +
  scale_y_continuous(expand = c(0.075, 0)) +
  scale_x_continuous(limits = c(0, (w_know_sl + w_no_response + gap)*1.05), expand = c(0.05, 0)) +
  labs(
    title = text_title,
    subtitle = text_subtitle,
    caption = text_caption
  ) +
  # vfsg_logo
  vfsg_logo_layer(
    file.path('data','vfsg_logo.png'),
    ymin = vfsg_y - vfsg_width,
    ymax = vfsg_y,
    xmin = vfsg_x - vfsg_width,
    xmax = vfsg_x
  ) + 
  # theme
  theme_gdri() +
  theme(
    axis.text = element_blank(),
    axis.ticks = element_blank(),
    axis.title.y = element_blank(),
    axis.title.x = element_blank(),
    panel.grid = element_blank()
  )


plot_dir <- 'plots'
file_name <- file.path(plot_dir, glue::glue('R_plot_sign_language_1.png'))
ggsave(file_name, width = 8, height = 9, units = "in", dpi = 300)

