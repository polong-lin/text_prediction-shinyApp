#This is an attempt to streamline pkn calculations but doing them within the data tables
#before any predictions are attempted. This allows for a data.table binary search rather than
#calculating a pkn in real time.

library(data.table)
#
directory <- "~/Dropbox/Coursera/DataScienceSpecialization//dsscapstone-001//"
setwd(directory)

#Load dictionaries
source("predictive-text-analysis/loadDictList.R")
lines = "5e+05"; ngrams = 4; rweka = FALSE; type = "tdm"; sorted = TRUE
ndictlist <- loadDictList("n", lines, ngrams, rweka, type, sorted)
#bdictlist <- loadDictList("b", lines, ngrams, rweka, type, sorted)
rm(lines); rm(ngrams); rm(rweka); rm(type); rm(sorted); rm(loadDictList); rm(importRDS_dt); rm(dtTokenSplit)

#Adding pkn frequencies to unigrams, and bigrams

#set keys
setkey(ndictlist[[1]], token)
setkey(ndictlist[[2]], token2) #to search for token2
denom <- nrow(ndictlist[[2]])

ndictlist[[2]][ , `:=`( NROW = .N), by = token2]
bigram.nrow <- ndictlist[[2]][,unique(.SD), .SDcols = c("token2", "NROW")]

#For unigram in unigram dict, calculate pkn using continuation counts

pkn.unigram <- function(unigram, bigramdict = bigram.nrow, denominator = denom){
    numerator <- bigramdict[unigram]$NROW
    return(numerator/denominator)
}

ndictlist[[1]][,`:=`(PKN = pkn.unigram(token))] #create new column PKN, a pkn-value for each unigram
setkey(ndictlist[[1]], PKN)
ndictlist[[1]][is.na(PKN)]$PKN <- min(ndictlist[[1]][PKN > 0]$PKN)*0.9 #replace NA PKN values with a very small number
setkey(ndictlist[[1]],token) #set key to token

#result of pkn smoothing unigrams based on bigram continuations
ndictlist[[1]][order(-PKN)]


## Bigram smoothing
#For each bigram in bigram dict, calculate pkn based on continuation counts of trigrams


unigram <- copy(ndictlist[[1]])
bigram <- copy(ndictlist[[2]])


pkn.bigram <- function(string, unigram_model = unigram, bigram_model = bigram){
    firstword <- strsplit(string, split = " ")[[1]][1]
    dt.uni.firstword <- unigram_model[firstword]
    setkey(bigram_model, token) #bigram key to token
    c.w1w2 <- bigram_model[string]$count    
    setkey(bigram_model, token1) #bigram key to token1
    cont.w1.any <- nrow(bigram_model[firstword])
    result <- (max(c.w1w2 - 0.75, 0)/dt.uni.firstword$count + (0.75*cont.w1.any/dt.uni.firstword$count) * dt.uni.firstword$PKN)
    return(result)
}

pkn.bigram("hi there")


bigrams <- copy(ndictlist[[2]])

# bigrams[,`:=`(PKN.bigram = pkn.bigram(token))] #doesn't work
# bigrams

# a <- c("is the", "here is")
# pkn.bigram(a)
# 
# sapply(a, FUN = pkn.bigram)[[1]]
# # 
# # sapply(bigrams$token, FUN = pkn.bigram)
# bigrams
# setkey(bigrams, token, count, token1, token2)
# system.time(
# bigrams[, `:=` (PKN.bigram2 = pkn.bigram(token)), by= token]
# # )
# # 
# # install.packages("beepr")
# # library(beepr)
# # 
# # beep(2)


#Add column rowid for rowidnumber
bigrams[, rowid := 1:nrow(bigrams)]
setkey(bigrams, rowid, token)
system.time(
bigrams[, PKN.bigram3 := {pkn.bigram(token)}, by= rowid]
)
bigrams
# 
# key(bigrams)
# system.time(
#     bigrams[1:1000][, PKN.bigram3 := {pkn.bigram(token)}, by= rowid]
# )
# 
# setkey(bigrams, token, rowid)
# setkey(bigrams, rowid, token)
# 
# 
# system.time(
#     bigrams[1:500][, PKN.bigram4 := {pkn.bigram(token)}, by = rowid]
# )
# 
# system.time(
#     apply(bigrams[1:100], 1, function(token) pkn.bigram(token))
#     )
# 
# pkn.bigram(bigrams$token[1:100])
# 
# pkn.bigram(c("hi there", "is the"))
# 
# system.time(
#     unlist(lapply(bigrams[1:100]$token, pkn.bigram))
# )
# 
# bigrams[is.na(PKN.bigram3)]

#Goal:
#To add pkn.bigram values for each bigram in ndictlist[[2]]
#Problem: For some reason, it keeps adding a column of the same pkn value, rather than calculating
#a unique pkn value for each row
saveRDS(bigrams, "final/rds_files/n.5e+05.pkn.bigrams.rds")
setnames(bigrams, c("token1", "token2", "token", "count", "NROW", "rowid", "PKN.bigram3"))
bigrams

setname()
?setnames
setnames(bigrams, "PKN.bigram3", "PKN.bigram")
bigrams[order(-PKN.bigram)]
bigrams[order(-count)][1:1000][order(-PKN.bigram)]
