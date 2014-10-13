## Step 2: Generate candidateList ####

# candidateList: list of seen word2s in a bigram model [word1,word2] with count >= min, 
#               where word1 is the ith word in a string of length i.

candidateList <- function(string, dictlist, min = 2) {
    #Inputs:
    # string: a vector of split words
    # dictlist: a list of ngram models
    # min: only bigrams with a minimum frequency of "min" will be returned
    #Output:
    # result: a vector of split words that are candidate "next words" to a string, based on bigrams
    if(length(grep(" ", string)) > 0){
        string <- strsplit(string, split = " ")[[1]]
    }
    result <- dictlist[[2]][token1 == tail(string, 1) & count >= min][order(-count)][1:100]$token2
    result <- result[result!= "s" & result!= "rt" & result!= "th" & result != "st"]
    return(result)
}

