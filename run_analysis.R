# Reading data. 

temp <- tempfile()
download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip",temp,method = "curl")
temp1<-tempdir()
unzip(zipfile = temp,exdir = temp1)
list.files(temp1)
list.dirs(temp1)
setwd(temp1)

##install.packages("dplyr")
##install.packages("tidyr")
require(dplyr)
require(tidyr)

## Reading the test data. 

features<-read.table(paste(temp1,"/UCI HAR Dataset/features.txt",sep=""))
alabels<-read.table(paste(temp1,"/UCI HAR Dataset/activity_labels.txt", sep = ""))
x_test<-read.table(paste(temp1,"/UCI HAR Dataset/test/X_test.txt",sep=""))
y_test<-read.table(paste(temp1, "/UCI HAR Dataset/test/y_test.txt",sep = ""))
subject_test<-read.table(paste(temp1, "/UCI HAR Dataset/test/subject_test.txt",sep = ""))

## Combinig alltogether the imported test data

x_test<-tbl_df(x_test)
y_test<-tbl_df(y_test) %>%
  full_join(alabels,by="V1") %>%
  rename(id=V1,label=V2) %>%
  mutate(sample=rep("test",2947))
test<-tbl_df(bind_cols(x_test,y_test))
test$subject<-subject_test$V1
glimpse(test)
str(test)

## Reading train data

## Combinig alltogether the imported train data

x_train<-read.table(paste(temp1,"/UCI HAR Dataset/train/X_train.txt",sep=""))
y_train<-read.table(paste(temp1,"/UCI HAR Dataset/train/y_train.txt",sep=""))
subject_train<-read.table(paste(temp1,"/UCI HAR Dataset/train/subject_train.txt",sep=""))

x_train<-tbl_df(x_train)
y_train<-tbl_df(y_train) %>%
  full_join(alabels,by="V1") %>%
  rename(id=V1,label=V2) %>%
  mutate(sample=rep("train",7352))
train<-tbl_df(bind_cols(x_train,y_train))
train$subject<-subject_train$V1
glimpse(train)
str(train)

b<-nrow(test)+nrow(train)
b

### Uniting two datasets 

df<-bind_rows(train,test)
names<-make.unique(as.character(features$V2), sep = "_")

colnames(df)
colnames(df)<-c(names,"label","activity","sample","subject")
dim(df)
glimpse(df[,560:565])
head(df[,560:565])

## Select mean and stdev measurements

dim(df)
rm(df1)

df1<-df %>%
  select(matches("mean()|std()"),label, activity, sample, subject)

rm(df2)
df1<-tbl_df(df1)
df2<-df1 %>%
  gather(name,value,-activity,-sample,-subject,-label) %>%
  group_by(activity,subject) %>%
  summarise(average=mean(value))


write.csv(x=df1,file = "df1.csv")
write.csv(x=df2,file = "df2.csv")

write.table(x=df1,file = "df1.txt",row.name = FALSE)
write.table(x=df2,file = "df2.txt",row.name = FALSE)
