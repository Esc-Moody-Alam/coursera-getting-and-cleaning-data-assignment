library(tidyr)
library(dplyr)

#First, let's make sure we the data
datafile <- "getdata_dataset.zip"
dirName <- "UCI HAR Dataset"

if (!file.exists(datafile))
  download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip", datafile)
if (!file.exists(dirName)) 
  unzip(datafile) 


# Now let's get the activity labels and features
activityLabels <- read.table(paste0(dirName,"/activity_labels.txt"))
activityLabels[,2] <- as.character(activityLabels[,2])
features <- read.table(paste0(dirName,"/features.txt"))
features[,2] <- as.character(features[,2])

# Extract the mean and standard deviation data
fRequired <- grep(".*mean.*|.*std.*", features[,2])
fRequiredNames <- features[fRequired,2]
fRequiredNames = gsub("-mean", "mean", fRequiredNames)
fRequiredNames = gsub("-std", "std", fRequiredNames)
fRequiredNames <- gsub("[-()]", "", fRequiredNames)


# Now load the datasets
train <- read.table(paste0(dirName,"/train/X_train.txt"))[fRequired]
trainActivities <- read.table(paste0(dirName,"/train/Y_train.txt"))
trainSubjects <- read.table(paste0(dirName,"/train/subject_train.txt"))
train <- cbind(trainSubjects, trainActivities, train)

test <- read.table(paste0(dirName,"/test/X_test.txt"))[fRequired]
testActivities <- read.table(paste0(dirName,"/test/Y_test.txt"))
testSubjects <- read.table(paste0(dirName,"/test/subject_test.txt"))
test <- cbind(testSubjects, testActivities, test)

print("allData loaded")
# let's merge the data
allData <- rbind(train, test)
colnames(allData) <- c("subject", "activity", fRequiredNames)

print("allData merged")
# turn activities & subjects into factors
allData$activity <- factor(allData$activity, levels = activityLabels[,1], labels = activityLabels[,2])
allData$subject <- as.factor(allData$subject)

print("Going for gather and spread functions")
allDataLong <- gather(allData, key="variable", value="value",3:ncol(allData))
allDataMean <- dcast(allDataLong, subject + activity ~ variable, mean)

print("Writing table")
write.table(allDataMean, "tidyoutput.txt", row.names = FALSE, quote = FALSE)

print("Wrote tidyoutput.txt successfully! Exiting now.")