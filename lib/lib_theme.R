# Functions for applying a consistent theme to GDRI visualisations

library(monochromeR)
library(ggplot2)
library(systemfonts)
library(ggtext)
library(png)


# Theme colours (not all used) ----
get_theme_colours <- function() {
  theme_colours <- list(
    blue = '#29ABE3',
    blue_light = '#b3e1f5',
    gold = '#C78D10',
    gold_light = '#E09F12',
    gold_dark = '#7D590A', #'#9E700D',
    white = '#FFFFFF',
    grey_light = '#BFBFBF',
    grey = '#616161',
    grey_mid = '#424242',
    grey_dark = '#262626',
    black = '#000000',
    pal_discrete = c('#0b2e3d', '#155875', '#2085b1', '#44b5e6', '#b3e1f5')
  )
  
  theme_colours$pal_grey = monochromeR::generate_palette(
    theme_colours$grey,
    modification = 'go_lighter',
    n_colours = 5
  )
  
  return(theme_colours)
}

# ggplot theme ----
theme_gdri <- function(
    base_size = 14, 
    theme_style = 'light',
    font_path = '/Users/gmschroe/Library/Fonts'
  ){
  
  # Use style argument to leave room for different options (e.g., dark theme) in future
  
  # Colours
  theme_colours <- get_theme_colours()
  if (theme_style == 'light') {
    clr_text_mid <- theme_colours$grey_mid
    clr_text_dark <- theme_colours$grey_dark
    clr_text_light <- theme_colours$pal_grey[2]
    clr_bg <- theme_colours$white 
  } 
  
  # Fonts
  font_name_title <- 'Questrial-Regular'
  register_font(
    name = font_name_title,
    plain = file.path(font_path, 'Questrial-Regular.ttf'),
    bold = file.path(font_path, 'Questrial-Regular.ttf')
  )
  
  # Font
  font_name <- 'Lexend-Light'
  register_font(
    name = font_name,
    plain = file.path(font_path, 'Lexend-Light.ttf'),
    bold = file.path(font_path, 'Lexend-SemiBold.ttf')
  )
  
  font_family_title <- font_name_title
  font_family_text <- font_name
  
  # Relative font sizes
  sz1 <- 1.75
  sz2 <- 1
  sz3 <- 0.85
  sz4 <- 0.7
  
  # Create theme
  my_theme <-
    theme_minimal(base_size = base_size) +
    theme(text = element_text(colour = clr_text_mid, family = font_family_text, lineheight = 1),
          plot.title = element_textbox(
            colour = theme_colours$blue, 
            family = font_family_title, 
            size = rel(sz1), 
            margin = margin(0, 0, 1, 0, unit = "char"),
            width = unit(1, 'npc'),
            lineheight = 1.2
          ),
          plot.subtitle = element_textbox(
            colour = clr_text_dark,
            size = rel(sz2), 
            margin = margin(0, 0, 3, 0, unit = "char"),
            width = unit(1, 'npc'),
            lineheight = 1.2
          ),
          axis.text = element_text(colour = clr_text_light, size = rel(sz3)),
          legend.text = element_text(colour = clr_text_light, size = rel(sz3)),
          axis.title.y = element_text(
            size = rel(sz2), margin = margin(1, 1, 0, 0, unit = "char"), angle = 0, hjust = 1,
          ),
          axis.title.x = element_text(
            size = rel(sz2), margin = margin(1, 0, 0, 0, unit = "char"),
          ),
          legend.position = "right",
          legend.justification = "bottom",
          legend.title = element_text(size = rel(sz3)),
          panel.grid = element_line(linewidth = 0.1, colour = clr_text_light),
          panel.grid.minor = element_blank(),
          axis.ticks = element_line(linewidth = 0.3, colour = clr_text_mid),
          axis.ticks.length = unit(-5, 'pt'),
          plot.caption = element_markdown(
            size = rel(sz4), margin = margin(3.5, 0, 0, 3, "char"), colour = clr_text_light,
            lineheight = 1.2, hjust = 0
          ),
          plot.margin = margin(0.35, 0.35, 0.35, 0.35, "in"),
          panel.background = element_rect(fill = clr_bg, colour = clr_bg),
          plot.background = element_rect(fill = clr_bg, colour = clr_bg),
          plot.title.position = "plot",
          plot.caption.position = "plot"
        )
  
  # Palette for fill (discrete numbers)
  scale_fill <- scale_fill_discrete(
    name = 'Number of\npeople', 
    type = rev(theme_colours$pal_discrete)
  )
  
  # Theme and palette
  return(list(my_theme, scale_fill))
}

# Default settings for annotation textboxes
geom_textbox_gdri <- function(
    data, 
    text_size = 10, 
    lineheight = 1.1, 
    vjust = 1, 
    hjust = 0, 
    box_colour = NA,
    fill = NA,
    font_path = '/Users/gmschroe/Library/Fonts',
    ...
) {
  
  # Colours
  theme_colours <- get_theme_colours()
  clr_text <- theme_colours$grey
  
  # Font
  font_name <- 'Lexend-Light'
  register_font(
    name = font_name,
    plain = file.path(font_path, 'Lexend-Light.ttf'),
    bold = file.path(font_path, 'Lexend-SemiBold.ttf')
  )
  
  # Textbox
  textbox_gdri <- geom_textbox(
    data = data,
    mapping = aes(x = x, y = y, label = label),
    colour = clr_text,
    family = font_name,
    size = text_size/.pt,
    lineheight = lineheight,
    box.colour = box_colour, 
    fill = fill,
    vjust = vjust,
    hjust = hjust,
    ...
  )
  
  return(textbox_gdri)
}

# VFSG Logo
vfsg_logo_layer <- function(
    vfsg_path, 
    xmin,
    xmax,
    ymin,
    ymax,
    alpha = 1
) {
  
  vfsg_png <- readPNG(vfsg_path)
  
  vfsg_alpha <- vfsg_png[,,4]
  vfsg_alpha[vfsg_alpha > 0] <- vfsg_alpha[vfsg_alpha > 0] * alpha
  vfsg_png[,,4] <- vfsg_alpha
  
  vfsg_layer <- annotation_raster(
    vfsg_png, 
    ymin = ymin,
    ymax = ymax,
    xmin = xmin,
    xmax = xmax
  )
  
  return(vfsg_layer)
}

# Annotations for area plot squares
make_square_annotation <- function(
    n,
    label,
    n_dark = TRUE,
    label_dark = TRUE,
    sz_n = 16,
    sz_label = 10
) {
  
  theme_colours <- get_theme_colours()
  
  if (label_dark) {
    clr_label <- theme_colours$grey_dark
  } else {
    clr_label <- theme_colours$white
  }
  if (n_dark) {
    clr_n <- theme_colours$grey_dark
  } else {
    clr_n <- theme_colours$white
  }
  
  text_square <- paste0( 
    glue::glue('<b style="font-size:{sz_n}pt; color: {clr_n};">{n}</b>'),
    glue::glue('<span style="font-size:{sz_label}pt; color: {clr_label};"> {label}</span>')
  )
  return(text_square)
}