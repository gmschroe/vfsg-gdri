# Viz for Social Good Project: Global Deaf Research Institute

I made these visualisations for the [May 2024 Viz for Social Good project](https://www.vizforsocialgood.com/join-a-project/2024/global-deaf-research-institute) for the [Global Deaf Research Institute](https://www.globaldeafresearch.org/) (GDRI). GDRI asked for assistance with visualising data from an extensive pilot survey administered to over 200 deaf Nigerians.

## Visualisations

<kbd>
  <img src = "plots/R_plot_sign_language_1.png" width="750">
</kbd>

<kbd>
  <img src = "plots/R_plot_sign_language_2.png" width="750">
</kbd>

<kbd>
  <img src = "plots/R_plot_sign_language_3.png" width="750">
</kbd>

## Data story

GDRI's survey contained over 100 questions with variable response rates. I chose to focus on some of the questions about sign language use and fluency. I was initially curious about whether sign language fluency impacted factors like quality of life or ease of communication (e.g., with healthcare professionals). However, after an initial data exploration I found that most of the respondents were fluent in sign language, and I did not think there was sufficient data on non-sign language users to answer these questions.

Instead, I decided to focus on some other interesting observations from my analysis of the sign language variables: 1) the large proportion of sign language users, and 2) the gap between hearing loss and learning sign language. I also thought that these visualisations would be informative for refining future survey questions (see "Data recommendations"). 

## Design decisions

GDRI expressed a need for visualisations for multiple scenarios (e.g., communicating with stakeholders, presentations, funding bids). I therefore decided to make a series of smaller visualisations, rather than one large visualisation, to give GDRI more flexibility with how they use the visualisations. The layouts also allow my title and caption to be cropped out if GDRI would like to provide different context. Likewise, I stuck with a white background to make it easier to embed the visualisations in reports, presentations, and any printed materials.

I used GDRI branding from their logo and website. I used their main colours (sky blue and dark greys) for most of the visual elements and selected a constrasting accent colour (dark mustard yellow) based on some of the photos on their website. The titles use their website font, Questrial. I paired this font with Lexend, which (to my beginner typographer eyes) shares many similar features with Questrial. Lexend has more open aperatures than Questrial, however, making it easier to read at small font sizes, and it's also generally designed for accessibility. Lexend also has more available font weights than Questrial, which is useful for emphasising subsets of text in annotations.

## Data recommendations

Since this data was collected as part of a pilot survey, GDRI also asked VFSG volunteers to share any recommendations for future data collection. 

## Code

All visualisations were made using the R programming language.

Code dependencies:
- [GDRI data](https://www.vizforsocialgood.com/join-a-project/2024/global-deaf-research-institute) (add to the `data` folder)
- Font files for [Questrial](https://fonts.google.com/specimen/Questrial) and [Lexend](https://fonts.google.com/specimen/Lexend). Functions in `lib/lib_theme.R` that use these files have an optional argument for specifying the path to your local directory that contains font files.
