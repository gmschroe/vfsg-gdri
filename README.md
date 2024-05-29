# Viz for Social Good Project: Global Deaf Research Institute

I made these visualisations for the [May 2024 Viz for Social Good project](https://www.vizforsocialgood.com/join-a-project/2024/global-deaf-research-institute) for the [Global Deaf Research Institute](https://www.globaldeafresearch.org/) (GDRI). GDRI asked for assistance with visualising data from an extensive pilot survey administered to over 200 deaf Nigerians.

## Visualisations


## Data story

## Design decisions

GDRI expressed a need for visualisations for multiple scenarios (e.g., communicating with stakeholders, presentations, funding bids). I therefore decided to make a series of smaller visualisations, rather than one large visualisation, to give GDRI more flexibility with how they use the visualisations. The layouts also allow my title and caption to be cropped out if GDRI would like to provide different context.

I used GDRI branding based on their website. I used their main colours (sky blue and dark greys) for most of the visual elements and selected a constrasting accent colour (dark mustard yellow) based on some of the photos on their website. The titles use their website font, Questrial. I paired this font with Lexend, which (to my beginner typographer eyes) shares many similar features with Questrial. Lexend has more open aperatures than Questrial, however, making it easier to read at small font sizes, and it's also generally designed for accessibility. Lexend also has more available font weights than Questrial, which is useful for emphasising subsets of text in annotations.

## Data recommendations

Since this data was collected as part of a pilot survey, GDRI also asked VFSG volunteers to share any recommendations for future data collection. 

## Code dependencies

- [GDRI data](https://www.vizforsocialgood.com/join-a-project/2024/global-deaf-research-institute) (add to the `data` folder)
- Font files for [Questrial](https://fonts.google.com/specimen/Questrial) and [Lexend](https://fonts.google.com/specimen/Lexend). Functions in `lib/lib_theme.R` that use these files have an optional argument for specifying the path to your local directory that contains font files.
