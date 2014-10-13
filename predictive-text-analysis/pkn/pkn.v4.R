## Kneser-Ney Smoothing
directory <- "/Users//polong//Dropbox//Coursera/DataScienceSpecialization/dsscapstone-001/"
setwd(directory)

t.1 <- readRDS("final/rds_files/n.5e+05.1grams.split.rds")
t.2 <- readRDS("final/rds_files/n.5e+05.2grams.split.rds")
t.3 <- readRDS("final/rds_files/n.5e+05.3grams.split.rds")

dictlist <- list(t.1, t.2, t.3)
rm(t.1); rm(t.2); rm(t.3); rm(t.4); rm(t.5)

string <- "vehicle of the"
# string <- "Guy at my table's wife got up to go to the bathroom and I asked about dessert and he started telling me about his"
# string <- "Talking to your mom has the same effect as a hug and helps reduce your"
# string <- "I'd just like all of these questions answered, a presentation of evidence, and a jury to settle the"
## Step 2: Generate candidatelist ####

# candidateList: list of seen word2s in a bigram model [word1,word2] with count >= min, 
#               where word1 is the ith word in a string of length i.

source("predictive-text-analysis/pkn/pkn.candidateList.R")
candidateList <- candidateList(string, dictlist, min = 2)
candidateList <- candidateList$token2

#PKN calculation (fully recursive)
source("predictive-text-analysis/pkn/pkn.pkn.calc.R")

results <- c()
for(q in 1:length(head(candidateList))){
    temp <- pkn.calc(string, candidate = head(candidateList)[q], dictlist)
    results <- c(results, temp)
    names(results)[q] <- head(candidateList)[q]
}
pkn.results.sorted <- sort(results, decreasing = TRUE)
pkn.results.df <- data.frame("pkn" = pkn.results.sorted)
pkn.results.df

#Raw count results
rawstring <- strsplit(string, split = " ")[[1]]
rawresult <- dictlist[[2]][token1 == tail(rawstring, 1) &
                            count >= 2][order(-count)]
head(rawresult[, c("token2", "count"), with=FALSE])

#PKN results
pkn.results.df

#Original string
string
