## Kneser-Ney Smoothing
directory <- "/Users//polong//Dropbox//Coursera/DataScienceSpecialization/dsscapstone-001/"
setwd(directory)

# #Create ngram models
# source("predictive-text-analysis/ngramModel.R")
# ngramModel(sourceletter ="t", lines = "5e+05", ngrams = 4, rweka = FALSE, precleaned = TRUE)
# ngramModel(sourceletter ="t", lines = "5e+05", ngrams = 5, rweka = FALSE, precleaned = TRUE)
# ngramModel(sourceletter ="b", lines = "5e+05", ngrams = 4, rweka = FALSE, precleaned = TRUE)
# ngramModel(sourceletter ="b", lines = "5e+05", ngrams = 5, rweka = FALSE, precleaned = TRUE)
# ngramModel(sourceletter ="n", lines = "5e+05", ngrams = 4, rweka = FALSE, precleaned = TRUE)
# ngramModel(sourceletter ="n", lines = "5e+05", ngrams = 5, rweka = FALSE, precleaned = TRUE)

#Load dictionaries
source("predictive-text-analysis/loadDictList.R")
lines = 500000; ngrams = 5; rweka = FALSE; type = "tdm"; sorted = TRUE
tdictlist <- loadDictList("t", lines, ngrams, rweka, type, sorted)
bdictlist <- loadDictList("b", lines, ngrams, rweka, type, sorted) #3.8gb when including mincount=2
ndictlist <- loadDictList("n", lines, ngrams, rweka, type, sorted)
tdictlist.5gram <- loadDictList("t", lines = 100000, ngrams = 5, rweka, type, sorted)
rm(lines); rm(ngrams); rm(rweka); rm(type); rm(sorted); rm(dtTokenSplit); rm(importRDS_dt); rm(loadDictList)

# string <- "i do not know but he is the"
# string <- "Guy at my table's wife got up to go to the bathroom and I asked about dessert and he started telling me about his"
# string <- "Talking to your mom has the same effect as a hug and helps reduce your"
# string <- "I'd just like all of these questions answered, a presentation of evidence, and a jury to settle the"


## Step 2: Generate candidatelist ####

# candidateList: list of seen word2s in a bigram model [word1,word2] with count >= min, 
#               where word1 is the ith word in a string of length i.

# source("predictive-text-analysis/pkn/pkn.candidateList.R")


#PKN calculation (fully recursive)

source("predictive-text-analysis/pkn/pkn.pkn.findNextWord.R")
# pkn.findNextWord(string = s, ncandidates = ncandidates, dictlist = dictlist)
source("Quiz-attempts/quiz2.R")

takea <- pkn.findNextWord(string = quiz2[[5]][1],ncandidates = 50,min_cand_freq = 2,dictlist = tdictlist.5gram)


t.results <- quiz2.getResults(tdictlist, 1)
b.results <- quiz2.getResults(bdictlist, 10)
n.results <- quiz2.getResults(ndictlist, 10)

b.results



useFirstLetter <- function(results, number){
    #results: from quiz2.getResults; a list of data.tables
    #wordlist: four words as potential answers
    wordlist <- quiz2[[number]][2:5]
    first <- substring(wordlist[[1]],1,1)
    second <- substring(wordlist[[2]],1,1)
    third <- substring(wordlist[[3]],1,1)
    fourth <- substring(wordlist[[4]],1,1)
    results[[number]][substring(results[[number]]$Candidate,1,1) == first |
                                   substring(results[[number]]$Candidate,1,1) == second |
                                   substring(results[[number]]$Candidate,1,1) == third |
                                   substring(results[[number]]$Candidate,1,1) == fourth]
}

for(qnumber in 1:10){
    useFirstLetter(t.results.5grams,qnumber)
}
useFirstLetter(t.results.5grams,10)

takea[substring(takea$Candidate,1,1) == "l" | 
    substring(takea$Candidate,1,1) == "p" | 
    substring(takea$Candidate,1,1) == "w" | 
    substring(takea$Candidate,1,1) == "m" ]


