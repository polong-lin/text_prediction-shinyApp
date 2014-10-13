pkn.calc <- function(string, candidate, dictlist){
    #Input: 
    # string: a full string of words, without a candidate at the end
    # candidate: a candidate word for which to calculate pkn(candidate|string)
    # dictlist: a list of ngram models as dictionaries
    #Output:
    # print substring used for the search
    # pkn value for pkn(candidate|string)
    
    ##Init
    #Create a logical vector to subset ngram model dataframe:
    source("predictive-text-analysis/pkn/pkn.logical.dfchecker.R")
    #Continuation count:
    source("predictive-text-analysis/pkn/pkn.continuationCount.R")
    
    #Append the candidate to the string
    append.candidate <- function(string, candidate){
        #string: a vector of words in a string
        #candidate: a word to be added to end of string
        cand.result <- paste(string, candidate, collapse = " ")
        return(cand.result)
    }
    
    #Appending a candidate string EXAMPLE: "but he is the" + "one"
    string <- append.candidate(string, candidate)
    
    #reduceString: split the string into words, and reduce length depending on dictlist length
    source("predictive-text-analysis/pkn/pkn.reduceString.R")
    string <- reduceString(string, dictlist)
    
#     print(paste("Calculating pkn for reduced string: [", paste(string, collapse = " "), "]"))
    
    #Highest order calculation PKN
    source("predictive-text-analysis/pkn/pkn.pkn.highest.R")
    
    discount <- 0.75
    n <- length(string)

#     Lowest order calculation ####
#     PKN = continuationCount(any.wi.to.n) / continuationCount(any.wi.to.n.minus.1.any)
    pkn.lowest <- nrow(dictlist[[2]][token2 == tail(string,1),]) / 
        nrow(dictlist[[2]]) #the best, the same, the world    

    #List of results for lower order pkn calculations  
    pkn.lower.list <- list("lowest" = pkn.lowest)   

    #Lower order calculation
    for(i in (n-2):2){ #i is the recursion counter, from i until n-1 
        string_start = i
        if(i == 0) break
    
#         print("Lower order calculation -----------")
#         print(paste("-- i <-", i, "---------"))
        
        #Continuation count of [any][wi to n] in dictlist[[n]]
        cont.ANY.wi.to.n <- continuationCount(string_start,
                                              token_start   = 2, 
                                              ntokens       = n-i+1, 
                                              string, 
                                              dict_number   = n-i+2, 
                                              dictlist)
        if(length(cont.ANY.wi.to.n) == 0){cont.ANY.wi.to.n = discount + 0.01}
#         if(length(cont.ANY.wi.to.n) == 0){cont.ANY.wi.to.n = 0.1}
        
        #Continuation count of [any][wi to n-1][any] in dictlist[[n]]
        cont.ANY.wi.to.n.minus.1.ANY <- continuationCount(string_start, 
                                                          token_start   = 2, 
                                                          ntokens       = n-i, 
                                                          string, 
                                                          dict_number   = n-i+2, 
                                                          dictlist)
        if(length(cont.ANY.wi.to.n.minus.1.ANY) == 0 | is.nan(cont.ANY.wi.to.n.minus.1.ANY)){cont.ANY.wi.to.n.minus.1.ANY = 0.75}
        
        #Continuation count of [wi to n-1][any] in dictlist[[n-1]]
        cont.wi.to.n.minus.1.ANY <- continuationCount(string_start, 
                                                      token_start   = 1, 
                                                      ntokens       = n-i, 
                                                      string, 
                                                      dict_number   = n-i+1, 
                                                      dictlist)
        if(length(cont.wi.to.n.minus.1.ANY) == 0){cont.wi.to.n.minus.1.ANY = 0.1}
#         if(length(cont.wi.to.n.minus.1.ANY) == 0){cont.wi.to.n.minus.1.ANY = 0.1}
        
        #<<print debugging
        #end print debugging>>
        
        #Set to temporary result
        lowerorder <- tail(pkn.lower.list,1)[[1]]
        pkn.result.temp <- max(cont.ANY.wi.to.n - discount,0)/cont.ANY.wi.to.n.minus.1.ANY + 
            discount * lowerorder * cont.wi.to.n.minus.1.ANY/cont.ANY.wi.to.n.minus.1.ANY

        pkn.lower.list <- c(pkn.lower.list, lower.pkn = pkn.result.temp)
    }
    lowerorder <- tail(pkn.lower.list,1)[[1]]
    
    pkn.result <- FALSE
    counter <- 1
    while(pkn.result == FALSE & length(string) > 2){
        pkn.result <- pkn.highest(string, lowerorder, discount, dictlist)
        #if still is FALSE, then reduce string by one word, and revert lowerorder value to a lower pkn value:
        if(pkn.result == FALSE & length(string) > 2){
            counter <- counter + 1
            string <- string[-1]
            n <- length(string)
            print("Warning: String reduced to:")
            print(string)
            lowerorder <- tail(pkn.lower.list,counter)[[1]]
        } 
    }
    if(pkn.result == FALSE & length(string) == 2){
        print("Warning: Reverted to pkn.lowest:")
        return(pkn.lowest)
    }
    return(pkn.result)
}

