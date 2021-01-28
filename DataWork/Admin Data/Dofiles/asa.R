#------------------------------------------------------------------------------#
#                                                                              #
#                                     DIME                                     #
#                        ASA Projects - Quality Measure                        #                                     
#                                                                              #
#------------------------------------------------------------------------------#
# PURPOSE:    ASA deliverables
# NOTES:      

# WRITTEN BY: Sushmita Samaddar
# 
rm(list = ls())
rm(list = ls(all.names = TRUE))

# PART 1: Select sections to run ----------------------------------------------
PACKAGES             <- 1

# PART 2: Load packages   -----------------------------------------------------
packages  <- c("readstata13", "foreign",
               "doBy", "broom", "dplyr",
               "stargazer", "htmltools",
               "ggplot2", "plotly", "ggrepel",
               "RColorBrewer", "RCurl", "XML",
               "sp", "rgdal", "rgeos",
               "ggmap", "leaflet",
               "htmlwidgets", "geosphere",
               "eeptools", "purrr", "ggforce",
               "formattable", "tidyr", 
               "manipulate", "data.table", 
               "tm", "SnowballC", "wordcloud", 
               "webshot", "stringr", "devtools",
               "ggrepel")

# If you selected the option to install packages, install them
if (PACKAGES) {
  
  # Install packages that are not yet installed
  sapply(packages, function(x) {
    if (!(x %in% installed.packages())) {
      install.packages(x, dependencies = TRUE) 
    }
  }
  )
}
# Load all packages -- this is equivalent to using library(package) for each 
# package listed before

invisible(sapply(packages, library, character.only = TRUE))

# PART 3: Set folder folder paths --------------------------------------------
#-------------#
# Root folder #
#-------------#

# Add your username and folder path here (for Windows computers)
# To find out what your username is, type Sys.getenv("USERNAME")
if (Sys.getenv("USERNAME") == "wb522556") {
  
  projectFolder  <- "C:/Users/wb522556/WBG/Vivian De Fatima Amorim - Governance/WB Admin ODBC Data/II. Projects/1. ASA/DataWork"
  gitHub         <- "C:/Users/wb522556/Documents/GitHub/Agile_Productivity_Radar/DataWork/Admin Data"
}

#--------------------#
# Project subfolders #
#--------------------#
dataFolder        <- file.path(projectFolder,"Datasets")
mydataFolder      <- file.path(dataFolder,"Sushmita")
Intermediate      <- file.path(mydataFolder,"Intermediate")
outputFolder      <- file.path(projectFolder, "Output")
myoutputFolder    <- file.path(outputFolder, "Sushmita")
outputRaw         <- file.path(myoutputFolder, "Raw")

asadeliverables <- read.dta13(file.path(Intermediate, "asa_deliverables.dta"),
                  convert.dates            = TRUE, 
                  convert.factors          = TRUE, 
                  missing.type             = TRUE, 
                  convert.underscore       = TRUE,
                  generate.factors         = TRUE,
                  nonint.factors           = TRUE)


#MOST FREQUENT ASA DELIVERABLES
excludeWords <- c("a", "the", "that", "an", "at", "by", "for", "from", "of", "off", "on", "out", "through", "with", "project")
deliverable <- asadeliverables$DeliverableName
deliverable <- Corpus(VectorSource(deliverable))
dtm <- DocumentTermMatrix(deliverable)
# Convert the text to lower case
deliverable <- tm_map(deliverable, content_transformer(tolower))
# Remove numbers
deliverable <- tm_map(deliverable, removeNumbers)
# Remove stopwords for the language 
deliverable <- tm_map(deliverable, removeWords, stopwords("english"))
# Remove punctuations
deliverable <- tm_map(deliverable, removePunctuation)
# Eliminate extra white spaces
deliverable <- tm_map(deliverable, stripWhitespace)
# Remove your own stopwords
if(!is.null(excludeWords)) 
  deliverable <- tm_map(deliverable, removeWords, excludeWords) 

tdm <- TermDocumentMatrix(deliverable)
m <- as.matrix(tdm)
v <- sort(rowSums(m),decreasing=TRUE)
d <- data.frame(word = names(v),freq=v)
# Plot the word cloud
set.seed(1234)
wordcloud(d$word,d$freq, min.freq=1, max.words=25,
          random.order=FALSE, rot.per=0.35, 
          colors=brewer.pal(8, "Dark2"),
          use.r.layout=FALSE)

invisible(list(tdm=tdm, freqTable = d))

d_trunc <- subset(d, freq>80)
pdf(file.path(outputRaw, "deliverablewordcloud.pdf"))
wordcloud(d$word,d$freq, min.freq=1, max.words=25,
          random.order=FALSE, rot.per=0.35, 
          colors=brewer.pal(8, "Dark2"),
          use.r.layout=TRUE)
dev.off()

#TAKING THE REMAINING UNCHARACTERIZED DELIEVRABLES IN THE WORD CLOUD
asadeliverables <- read.dta13(file.path(Intermediate, "asa_deliverables_type.dta"),
                              convert.dates            = TRUE, 
                              convert.factors          = TRUE, 
                              missing.type             = TRUE, 
                              convert.underscore       = TRUE,
                              generate.factors         = TRUE,
                              nonint.factors           = TRUE)


#MOST FREQUENT ASA DELIVERABLES
excludeWords <- c("a", "the", "that", "an", "at", "by", "for", "from", "of", "off", "on", "out", "through", "with", "project")
deliverable <- asadeliverables$DeliverableName
deliverable <- Corpus(VectorSource(deliverable))
dtm <- DocumentTermMatrix(deliverable)
# Convert the text to lower case
deliverable <- tm_map(deliverable, content_transformer(tolower))
# Remove numbers
deliverable <- tm_map(deliverable, removeNumbers)
# Remove stopwords for the language 
deliverable <- tm_map(deliverable, removeWords, stopwords("english"))
# Remove punctuations
deliverable <- tm_map(deliverable, removePunctuation)
# Eliminate extra white spaces
deliverable <- tm_map(deliverable, stripWhitespace)
# Remove your own stopwords
if(!is.null(excludeWords)) 
  deliverable <- tm_map(deliverable, removeWords, excludeWords) 

tdm <- TermDocumentMatrix(deliverable)
m <- as.matrix(tdm)
v <- sort(rowSums(m),decreasing=TRUE)
d <- data.frame(word = names(v),freq=v)
# Plot the word cloud
set.seed(1234)
wordcloud(d$word,d$freq, min.freq=1, max.words=25,
          random.order=FALSE, rot.per=0.35, 
          colors=brewer.pal(8, "Dark2"),
          use.r.layout=FALSE)

invisible(list(tdm=tdm, freqTable = d))

d_trunc <- subset(d, freq>80)
pdf(file.path(outputRaw, "deliverablewordcloud.pdf"))
wordcloud(d$word,d$freq, min.freq=1, max.words=25,
          random.order=FALSE, rot.per=0.35, 
          colors=brewer.pal(8, "Dark2"),
          use.r.layout=TRUE)
dev.off()


