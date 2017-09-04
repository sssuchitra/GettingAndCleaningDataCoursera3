#Download zip file and unzip it
if(!file.exists("./data")){dir.create("./data")}
zipUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
zipFile <- download.file(zipUrl, destfile = "./data/uciFiles.zip")
outDir <- "./data"
unzip(zipfile = "./data/uciFiles.zip", exdir = outDir)

#Need package plyr for this code
library(plyr)

#Train and Test datasets are merged to create one dataset
xTrain <- read.table("./data/UCI HAR Dataset/train/X_train.txt")
yTrain <- read.table("./data/UCI HAR Dataset/train/y_train.txt")
subjectTrain <- read.table("./data/UCI HAR Dataset/train/subject_train.txt")
xTest <- read.table("./data/UCI HAR Dataset/test/X_test.txt")
yTest <- read.table("./data/UCI HAR Dataset/test/y_test.txt")
subjectTest <- read.table("./data/UCI HAR Dataset/test/subject_test.txt")

#Create x, y and subject datasets
xData <- rbind(xTrain, xTest)
yData <- rbind(yTrain, yTest)
subjectData <- rbind(subjectTrain, subjectTest)

#Mean and standard deviation is extracted from the measurements
features <- read.table("./data/UCI HAR Dataset/features.txt")
meanAndStd <- grep("-(mean|std)\\(\\)", features[, 2])
xData <- xData[, meanAndStd]
names(xData) <- gsub('[-()]', '',features[meanAndStd, 2])

#Descriptive activity names used
activities <- read.table("./data/UCI HAR Dataset/activity_labels.txt")
yData[, 1] <- activities[yData[, 1], 2]
names(yData) <- "activity"

#Label the dataset variable names appropriately and bind all data
names(subjectData) <- "subject"
completeData <- cbind(xData, yData, subjectData)

#second independent tidy data consisting average of each variable
tidyAverageData <- ddply(completeData, .(subject, activity), function(x) colMeans(x[, 1:66]))
write.table(tidyAverageData, "./data/UCI HAR Dataset/tidyAverageData.txt", row.name=FALSE, quote = FALSE)

#make codebook
require(knitr)
require(markdown)
knit("./data/UCI HAR Dataset/codebook.rmd", output="./data/UCI HAR Dataset/codebook.md", encoding="ISO8859-1", quiet=TRUE)
markdownToHTML("./data/UCI HAR Dataset/codebook.md", "./data/UCI HAR Dataset/codebook.html")
