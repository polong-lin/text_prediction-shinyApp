## Step 1: String reduction ####

#Reducing a given string to a substring that can be analyzed using the available ngrams

reduceString <- function(string, dictlist){
    #Input: a string (single vector of words, unsplit), and a list of ngram models, dictlist
    string <- strsplit(string, split = " ")[[1]]
    #Compute minimum of string length or dictlist length
    min.length <- min(length(string), length(dictlist)-1)
    #Reduce string to min.length
    string <- tail(string, min.length)
    names(string) <- paste("w",1:length(string), sep = "") #label each word in string is w1... wi.
    return(string)
}