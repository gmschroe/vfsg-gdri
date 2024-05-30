# Two visualisations on when deaf Nigerians learned sign language relative to
# when they began experiencing hearing loss

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

# Stats for annotations ----

# Sample sizes 
n_surveyed <- nrow(data_gdri)
n_responded <- sum(!is.na(data_gdri$age_hearing_loss) & !is.na(data_gdri$age_learned_sl))

# Years until learn sign language stats
avg_gap <- median(data_gdri$age_learned_sl_minus_age_hearing_loss, na.rm = TRUE)
x_yrs <- 10
n_x_yrs <- sum(data_gdri$age_learned_sl_minus_age_hearing_loss >= x_yrs, na.rm = TRUE)
perc_x_yrs <- round((n_x_yrs / n_responded)*100, 0)

# Colours ----
theme_colours <- get_theme_colours()

# Shared text/annotation variables ----
clr_text_highlight <- theme_colours$gold
text_caption <- paste0(
  'Designed by Gabrielle M. Schroeder for VFSG<br>',
  glue::glue('Survey size: {n_surveyed} people ({n_surveyed - n_responded} nonrespondents)'),
  '<br>Data: Global Deaf Research Institute'
)

# Plot 2 -----------------------------------------------------------------------
# age learned SL vs. age hearing loss 

# Data wrangling ----
gdri_age_combinations <- data_gdri |>
  select(age_hearing_loss, age_learned_sl) |>
  filter(!(is.na(age_hearing_loss) | is.na(age_learned_sl))) |>
  group_by(age_hearing_loss, age_learned_sl) |>
  mutate(n = row_number())

#View(gdri_age_combinations |> arrange(n))

# Limits/ticks ----
max_age <- max(
  c(sl_data$data_gdri$age_hearing_loss, sl_data$data_gdri$age_learned_sl), 
  na.rm = TRUE
)
axis_lim <- c(0, max_age)
year_ticks <- seq(0, max_age, by = 10)
year_labs <- as.character(year_ticks)
year_labs[length(year_labs)] <- paste(year_labs[length(year_labs)], 'y.o.') 

# Text/Annotations ----
text_title <- 'When do deaf Nigerians learn sign language?'

text_subtitle <- paste(
  glue::glue('The Global Deaf Research Institute collected data from {n_responded} deaf Nigerians'),
  'on the ages they learned sign language and started experiencing hearing loss.'
)

text_line <- paste(
  glue::glue('Points on the <b style="color:{clr_text_highlight};">line</b>'),
  'are people who learned sign language at the',
  glue::glue('<b style="color:{clr_text_highlight};">same age</b>'),
  'that they started experiencing hearing loss.'
)

text_line_df <- data.frame(
  x = max_age, y = max_age,
  label = text_line
)

text_above <- 'Learned sign language <b>after</b> hearing loss'

text_above_df <- data.frame(
  x = 0.25, y = 48,
  label = text_above
)

text_below <- 'Learned sign language <b>before</b> hearing loss'

text_below_df <- data.frame(
  x = 30.25, y = 8,
  label = text_below
)

vfsg_width <- 6.5
vfsg_x <- -28.5
vfsg_y <- -18.5

# Plot ----
plot_scatter <- ggplot(
  data = gdri_age_combinations, 
  aes(x = age_hearing_loss, y = age_learned_sl, fill = factor(n))
) +
  # identity line
  geom_line(
    data = tibble(x = axis_lim, y = axis_lim), 
    aes(x = x, y = y),
    alpha = 0.75, 
    inherit.aes = FALSE, 
    colour = clr_text_highlight, 
    size = 1
  ) +
  # survey data
  geom_point(
    shape = 21,
    colour = theme_colours$grey_dark,
    size = 2.25,
    stroke = 0.2
) +
  # Labels, coordinates
  coord_fixed(clip = "off") +
  xlab('Age started experiencing hearing loss') +
  ylab('Age learned sign\nlanguage') + 
  labs(
    title = text_title,
    subtitle = text_subtitle,
    caption = text_caption,
    fill = 'Number of\npeople'
  ) +
  scale_x_continuous(breaks = year_ticks, labels = year_labs, limits = axis_lim) + 
  scale_y_continuous(breaks = year_ticks, labels = year_labs, limits = axis_lim) + 
  # annotations
  geom_textbox_gdri(
    data = text_line_df, width = unit(1.6, 'inch'), box.padding = unit(c(0, 0, 0, 2), 'char')
  ) +
  geom_textbox_gdri(
    data = text_above_df, fill = theme_colours$white
  ) +
  geom_textbox_gdri(
    data = text_below_df, fill = theme_colours$white
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
  theme_gdri()

plot_scatter

plot_dir <- 'plots'
file_name <- file.path(plot_dir, glue::glue('R_plot_sign_language_2.png'))
ggsave(file_name, plot = plot_scatter, width = 8, height = 7.5, units = "in", dpi = 600)

# Plot 3 -----------------------------------------------------------------------

# Text/Annotations ---

text_title <- 'Most deaf Nigerians learn sign language years after experiencing hearing loss'

text_subtitle <- paste(
  glue::glue('Most of the {n_responded} survey respondents did not learn sign language'),
  'until at least a few years after they began experiencing hearing loss,',
  'and many learned sign language a decade or more later.'
)

text_average <- glue::glue('The average (median) gap was <b style="color:{clr_text_highlight};">{avg_gap} years</b>')

text_average_df <- data.frame(
    x = avg_gap, y = 19.75,
    label = text_average
  )

text_x_yrs <- paste(
  glue::glue('{n_x_yrs} people ({perc_x_yrs}%) learned sign language after'),
  glue::glue('<b style="color:{clr_text_highlight};">{x_yrs} or more years</b> with hearing loss')
)

text_x_yrs_df <- data.frame(
  x = x_yrs, y = 14.75,
  label = text_x_yrs
)

text_before <- 'Several people learned sign language before experiencing hearing loss'

text_before_df <- data.frame(
  x = -21, y = 9.75,
  label = text_before
)

vfsg_width <- 4.6
vfsg_x <- -33.5
vfsg_y <- -10.8

coord_ratio <- 1.3

# Plot: histogram of number of years before learned sign language ---
plot_histogram <- ggplot(data_gdri, aes(x = age_learned_sl_minus_age_hearing_loss)) +
  # Annotations
  geom_textbox_gdri(text_average_df, width = unit(1.75, 'inch')) +
  annotate(
    "segment", x = avg_gap, xend = avg_gap, y = 0, yend = text_average_df$y,
    colour = clr_text_highlight, size = 1
  ) + 
  geom_textbox_gdri(text_x_yrs_df, width = unit(2.25, 'inch')) +
  annotate(
    "segment", x = x_yrs, xend = x_yrs, y = 0, yend = text_x_yrs_df$y,
    colour = clr_text_highlight, size = 1
  ) + 
  geom_textbox_gdri(text_before_df, width = unit(1.85, 'inch')) +
  # vfsg_logo
  vfsg_logo_layer(
    file.path('data','vfsg_logo.png'),
    ymin = vfsg_y - (vfsg_width/coord_ratio),
    ymax = vfsg_y,
    xmin = vfsg_x - vfsg_width,
    xmax = vfsg_x
  ) + 
  # Histogram
  geom_histogram(
    binwidth = 1, 
    center = 0, 
    fill = theme_colours$blue_light,
    colour = theme_colours$grey_dark
  ) +
  # Labels/axes
  xlab('Number of years between hearing loss\nand learning sign language') +
  ylab('Number of\npeople') +
  labs(
    title = text_title,
    subtitle = text_subtitle,
    caption = text_caption
  ) +
  scale_y_continuous(limits = c(0, 25), expand = c(0.025, 0)) +
  coord_fixed(clip = 'off', ratio = coord_ratio) +
  # Theme
  theme_gdri() +
  theme(
    panel.grid.major.x = element_blank()
  )

plot_histogram

plot_dir <- 'plots'
file_name <- file.path(plot_dir, glue::glue('R_plot_sign_language_3.png'))
ggsave(file_name, plot = plot_histogram, width = 8, height = 8, units = "in", dpi = 600)


