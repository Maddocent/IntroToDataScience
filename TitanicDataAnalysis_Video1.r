### Maddocent Edited this File on 18-06-2015: Use of Uppercase and lowercase in R code causes erros if you are using the current Dataframes from Kaggle/Titanic

#### Copyright 2012 Dave Langer

#### Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 
####  	http://www.apache.org/licenses/LICENSE-2.0

#### Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

### This R source code file corresponds to video 1 of the YouTube series
### "Introduction to Data Science with R" located at the following URL: http://www.youtube.com/watch?v=32o0DnuRjfg

# R code lines and explanations:

## Load raw data
train <- read.csv("train.csv", header = TRUE)
test <- read.csv("test.csv", header = TRUE)

## Add a "Survived" variable to the test set to allow for combining data sets
test.survived <- data.frame(Survived = rep("None", nrow(test)), test[,])

## the order of the colomns between the two data frames  "test.survided" and "train" are not the same: 
This line of code changes the order of the first two colomns in the data frame "test.survided"
After running this line the order will be: Passengerid, Survived,...,... as it is in the "train" dataframe 
the following line corrects the error that would otherwise arise. 

test.survived <- test.survived[c(2,1,3,4,5,6,7,8,9,10,11,12)]


## Combine data sets
data.combined <- rbind(train, test.survived)

#A A bit about R data types (e.g., factors)
str(data.combined)

data.combined$Survived <- as.factor(data.combined$Survived)
data.combined$Pclass <- as.factor(data.combined$Pclass)


## Take a look at gross survival rates
table(data.combined$Survived)


## Distribution across classes
table(data.combined$Pclass)


## Load up ggplot2 package to use for visualizations
library(ggplot2)

### To install package use: package install in the right lower box in Rstudio, install dependencies

## Hypothesis - Rich folks survived at a higer rate
train$pclass <- as.factor(train$pclass)
ggplot(train, aes(x = pclass, fill = factor(Survived))) +
  geom_histogram(width = 0.5) +
  xlab("Pclass") +
  ylab("Total Count") +
  labs(fill = "Survived") 


## Examine the first few names in the training data set
head(as.character(train$Name))


## How many unique names are there across both train & test?
length(unique(as.character(data.combined$Name)))


# Two duplicate names, take a closer look
# First, get the duplicate names and store them as a vector
dup.names <- as.character(data.combined[which(duplicated(as.character(data.combined$Name))), "Name"])


## Next, take a look at the records in the combined data set
data.combined[which(data.combined$Name %in% dup.names),]


## What is up with the 'Miss.' and 'Mr.' thing?
library(stringr)


## Any correlation with other variables (e.g., sibsp)?
misses <- data.combined[which(str_detect(data.combined$Name, "Miss.")),]
misses[1:5,]


## Hypothesis - Name titles correlate with age
mrses <- data.combined[which(str_detect(data.combined$Name, "Mrs.")), ]
mrses[1:5,]


## Check out males to see if pattern continues
males <- data.combined[which(train$Sex == "male"), ]
males[1:5,]

## the above line holds an error, we want to extract the males from the data.combined data frame the code that has to be used:
males <- data.combined[which(data.combined$Sex == "male"), ]
males[1:5,]



## Expand upon the realtionship between `Survived` and `Pclass` by adding the new `Title` variable to the
## data set and then explore a potential 3-dimensional relationship.

## Create a utility function to help with title extraction
## NOTE - Using the grep function here, but could have used the str_detect function as well.
extractTitle <- function(name) {
  name <- as.character(name)
  
  if (length(grep("Miss.", name)) > 0) {
    return ("Miss.")
  } else if (length(grep("Master.", name)) > 0) {
    return ("Master.")
  } else if (length(grep("Mrs.", name)) > 0) {
    return ("Mrs.")
  } else if (length(grep("Mr.", name)) > 0) {
    return ("Mr.")
  } else {
    return ("Other")
  }
}


## NOTE - The code below uses a for loop which is not a very R way of
#        doing things
titles <- NULL
for (i in 1:nrow(data.combined)) {
  titles <- c(titles, extractTitle(data.combined[i,"name"]))
}
data.combined$title <- as.factor(titles)

##Change the name of the variable "title" tot "Title"
# install and load package plyr

library(plyr)
#use rename command

data.combined <- rename(data.combined, c(title="Title"))

#load ggplot2 to make a graph

library(ggplot2)


## Since we only have survived lables for the train set, only use the
## first 891 rows
ggplot(data.combined[1:891,], aes(x = Title, fill = Survived)) +
  geom_bar(binwidth = 0.5) +
  facet_wrap(~Pclass) + 
  ggtitle("Pclass") +
  xlab("Title") +
  ylab("Total Count") +
  labs(fill = "Survived")
