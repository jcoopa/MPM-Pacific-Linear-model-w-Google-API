library(ggplot2)
library(tidyverse)
library(gmapsdistance)
library(lpSolve)
library(zipcode)
library(githubinstall)
library(devtools)
#devtools::install_github("rodazuero/gmapsdistance@058009e8d77ca51d8c7dbc6b0e3b622fb7f489a2")
data(zipcode)


setwd("C:/Users/212617316/Desktop/MPM March 2018")
Assets <- read.csv(file="C:/Users/212617316/Desktop/MPM March 2018/FE to Asset - Master File 2-8-18.csv", 
                   header=TRUE, 
                   sep=",")
#################DELTE ME AFTER TESTING########################################
###############################################################################
##############################################################################
astfiltered <- Assets[!Assets$Primary.State %in% c("AK"),]
astfiltered <- astfiltered[!astfiltered$Primary.State %in% c("HI"),]
astfiltered <- astfiltered[!astfiltered$Primary.State %in% c("GU"),]
astfiltered <- astfiltered[!astfiltered$Primary.Postal.Code %in% c("96910"),]#zip from guam. why?
###above 3 lines are temporary for testing only #############################
#################################################################################
#################################################################################
astfiltered <- astfiltered[astfiltered$Service.Region %in% c("PACIFIC_WEST_SURGERY"),]
str(astfiltered)
summary(astfiltered$Primary.State)
#3.7.18 Pacific fe only FROM fe addresses
FieldEngineers <- read.csv(file="file:///C:/Users/212617316/Desktop/MPM March 2018/FSE Addresses - 2018.csv", 
                           header=TRUE, 
                           sep=",")
summary(FieldEngineers)
engfiltered <- FieldEngineers[FieldEngineers$Region %in% c("Pacific"),]
engfiltered <- engfiltered[!engfiltered$OHR.State %in% c("HI"),]
engfiltered <- engfiltered[!engfiltered$OHR.State %in% c("AK"),]
summary(as.factor(engfiltered$Zip))###Check that each zip only has 1 Engineer
summary(engfiltered$OHR.State)
###FE
RegionEng <- engfiltered
RegionEng$zip <- clean.zipcodes(RegionEng$Zip)
rfe <- merge(RegionEng, zipcode, all.x=TRUE, by='zip')
rfe$AstClosestCent1 <- 1:nrow(rfe)
rfe$Zip <- NULL

###Assets
RegAssets3 <- astfiltered
RegAssets3$zip <- clean.zipcodes(RegAssets3$Primary.Postal.Code)
#Delete if no issues RegAssets <- RegAssets3[!duplicated(RegAssets3$Primary.Postal.Code),]
RegAssets <- RegAssets3[!duplicated(RegAssets3$zip),]
RegAssets<- merge(RegAssets, zipcode, all.x=TRUE,by='zip')

###Assets
RegAst <- RegAssets
RegAst$XCenter <- as.numeric(RegAst$longitude)
RegAst$YCenter <- as.numeric(RegAst$latitude)
RegAst <- within(RegAst, RegAstyx <- paste(YCenter, XCenter, sep = "+"))
RegAst <- data.frame(RegAst)
RegAst$longitude <- NULL
RegAst$latitude <- NULL
#this adds a number to every group of RegAstyx, hopeing to tie back to avoid NA's in data
RegAst <- transform(RegAst,id=as.numeric(factor(RegAstyx)))

###FE
RegFE <- rfe
RegFE$ENG.x <- as.numeric(RegFE$longitude)
RegFE$ENG.y <- as.numeric(RegFE$latitude)
RegFE <- within(RegFE, ENGyx <- paste(ENG.y, ENG.x, sep='+'))
RegFE <- data.frame(RegFE)
RegFE$longitude <- NULL
RegFE$latitude <- NULL
RegFE$OHR.City <- NULL
RegFE$OHR.State <- NULL
##Assets
#the following line reduced #of obs from 870 to 863, 863 is the same obs as Pacificwide
RegAstDeduped <- RegAst[!duplicated(RegAst$RegAstyx),]
RegAstDeduped$postpostnum = 1:nrow(RegAstDeduped)
RegAstDeduped <- as.data.frame(RegAstDeduped)
set.api.key("AIzaSyCiIUU5K9YGfcreFxJVa-x44ib4rXQr-qU")
# Pacificwidev2 <- gmapsdistance(RegFE$ENGyx, RegAstDeduped$RegAstyx,
#                                         combinations = "all",
#                                         mode = "driving",
#                                         shape = "wide",
#                                         dep_date = "2021-11-02",
#                                         dep_time = "05:00:00",)


setwd("C:/Users/212617316/Desktop/K-MEANS")
#save(Pacificwide, file = "3.7.18pacificMPMOPTBYrdsv1.RData")
load("3.7.18pacificMPMOPTBYrdsv1.RData")

m <- (t(Pacificwide$Time))
m <- m[-1,]
tt <- ncol(m)
rr <- nrow(m)
m <- mapply(m, FUN=as.numeric)
m <- matrix(data=m, ncol=tt, nrow=rr)

gwide <- m
dir <- "min"
objective.in <- c(gwide)
A <- t(rep(1, tt)) %x% diag(rr)
B <- diag(tt) %x% t(rep(1, rr))
const.mat <- rbind(A, B, B)
const.dir <- c(rep("==", rr), rep(">=", tt), rep("<=", tt))
const.rhs <- c(rep(1, rr), rep(24, tt), rep(50, tt))
res <- lp(dir, objective.in, const.mat, const.dir, const.rhs, all.bin = TRUE)
soln <- matrix(res$solution, rr, tt)

e <- m
AstClosestCent1 <- apply(soln, 1, which.max)
h <- as.data.frame(AstClosestCent1)
h$postpostnum = 1:nrow(h)
h$time.secs <- apply( h, 1, function(x) e[x[2], x[1]] )

d <- RegAstDeduped[,c("postpostnum","zip", "YCenter", "XCenter", "RegAstyx")]

x <- merge(d, h, all.x=TRUE, by="postpostnum")
x$postpostnum <- NULL

names <- c('XCenter', 'YCenter')
x[,names] <- lapply(x[,names] , factor)
#z <- RegFE[,c(2:4, 7:8,1,9,11,10,12)]
z <- RegFE
y <- merge(x, z, by="AstClosestCent1")
y$Primary.Postal.Code <- y$zip.x
y$zip.x <- NULL


filtasset <- RegAssets3
filtasset$Primary.Postal.Code <- clean.zipcodes(filtasset$Primary.Postal.Code)
allassets <- merge(filtasset, y, all.x=TRUE, by="Primary.Postal.Code")
allassets$OPT.Dist.Mins <- (allassets$time.secs / 60 ) 
allassets$OPT.Dist.Mins <- as.factor(allassets$OPT.Dist.Mins)
allassets$OPT.FE.ZIP <- allassets$zip.y
allassets$zip.y <- NULL
allassets$time.secs <- NULL
ns <- c('ENG.y', 'ENG.x')
allassets[,ns] <- lapply(allassets[,ns] , factor)

##############################Driving Time CURRENT FE to ASSET###########################

k <- FieldEngineers
p <- allassets
str(p)
#add zip code to data set for cur FE
k$Primary.User.ID <- k$SSO
k$CurFE.Zip <- k$Zip
k <- k[,c("Primary.User.ID","CurFE.Zip")]
j <- merge(p,k, all.x=TRUE, by = "Primary.User.ID")
j$CurFE.Zip <- clean.zipcodes(j$CurFE.Zip)
j$zip <- j$CurFE.Zip
field<- merge(j, zipcode, all.x = TRUE, by='zip')
field$CFE.ZIP <- field$zip
field$zip <- NULL
field$CurFE.Zip <- NULL


field$CFE.x <- as.numeric(field$longitude)
field$CFE.y <- as.numeric(field$latitude)
fieldFRAME <- data.frame(field)
fieldFRAME <- within(fieldFRAME, fieldyx <- paste(CFE.y, CFE.x, sep='+'))
field$longitude <- NULL
field$latitude <- NULL


ats <- fieldFRAME
ats <- within(ats, concat <- paste(CFE.ZIP, Primary.Postal.Code, sep='-'))
ats <- within(ats, concatlatlong <- paste(fieldyx, RegAstyx, sep='--'))
deduped <- ats[!duplicated(ats$concat),]
######################################################Diffieldrent versions of DM saved so I CURcan use them at work. #####
# PacificPairwise<- gmapsdistance(deduped$fieldyx, deduped$RegAstyx,
#                         combinations = "pairwise",
#                         mode = "driving",
#                         shape = "Wide",
#                         dep_date = "2021-11-02",
#                         dep_time = "05:00:00",)

setwd("C:/Users/212617316/Documents")
#save(PacificPairwise, file = "3-20-18PacificPairwise.Data")
load("3-20-18PacificPairwise.Data")
############################################################

#pacWide$Time
Curtime <- PacificPairwise$Time
Curtime <- within(Curtime, concatlatlong <- paste(or, de, sep='--'))
df <- merge(ats, Curtime, all.x=TRUE, by= 'concatlatlong')
df$CFE.Dist.mins <- (df$Time / 60 )
str(df)
df$CFE.ZIP <- as.factor(df$CFE.ZIP)
df$Opt.FSE <- df$FSE
df$CFE.SSO <- df$Primary.User.ID
df$CFE.x <- as.factor(df$CFE.x)
df$CFE.y <- as.factor(df$CFE.y)
df$CFE.Dist.mins <- as.factor(df$CFE.Dist.mins)
df$Opt.SSO <- df$SSO
names(df)[28]<-"OPT.City"
names(df)[29]<-"OPT.State"
names(df)[25]<-"OPT.SSO"
names(df)[26]<-"OPT.FSE"
names(df)[35]<-"CFE.City"
names(df)[36]<-"CFE.State"
names(df)[13]<-"CFE.Name"
str(df)
zz <- df
coltofact <- c(40:41, 47)
zz[,coltofact] <- lapply(zz[,coltofact] , factor)
zz <- zz[,c(4,5,6,7,8,9,3,23,22,20,10,49,13,35,36,39,40,41,47,25,26,28,29,34,30,31,33,27)]
zzz <- unique( zz[ ,c(1:28)])