pkn.findNextWord <- function(string, ncandidates, min_cand_freq = 3, dictlist){
    #Determine candidates that have a min. count of min_cand_freq
    source("predictive-text-analysis/pkn/pkn.candidateList.R")
    print(c("[EC1] Original string:", string))
    library(qdap)
    string <- gsub(pattern = "'", replacement = "", tolower(replace_contraction(tolower(string))))
    string <- gsub(pattern = "takea", replacement = "take a", string)
    print(paste("String:", string))
    cand.list <- candidateList(string, dictlist, min = min_cand_freq)
    if(is.na(cand.list[1])){
        print(paste("Error: No continuation of [", tail(string,1), "] found."))
        return(NULL)
    }
    print(paste("[EC2] cand.list[1:5]:", paste(cand.list[1:5], collapse = " ")))
    
    #Create dt for top n candidates
    source("predictive-text-analysis/pkn/pkn.pkn.calc.R")
    results <- c()
    results.names <- c()
    
    for(q in (1:ncandidates)){
        cand <- cand.list[q]
#         print(c("[EC3] Checking PKN for the candidate:", cand))
        temp <- pkn.calc(string, candidate = cand, dictlist)
        results <- c(results, temp)
        results.names <- c(results.names, cand.list[q])
    }
    dt <- data.table("Candidate" = results.names, "pkn.score" = results)
    return(dt[order(-pkn.score)])
}