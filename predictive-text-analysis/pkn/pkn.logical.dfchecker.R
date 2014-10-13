logical.dfchecker <- function(string_start, token_start, ntokens, string, dict_number){
    ##string_start: number, which word to start in string (e.g., 3 if search starts from w3)
    ##token_start: number, which token to start search in dict (e.g., 3 if search starts at token3)
    ##ntokens: number of words/tokens to search (e.g., 2 for w1 w2)
    ##string_name: name of variable (e.g., "string"), in quotes
    ##dict: specific dictionary number from dictlist (e.g., 2 for "dictlist[[2]]")
    ##return: logical vector to match words in variable to words in dictionary, dict_name
    logicalvectorlist <- c()
    string_name <- deparse(substitute(string))
    for(ntoken in 1:ntokens){
        logical.temp <- paste0("token",token_start+ntoken-1," == ",
                               string_name,"[",string_start+ntoken-1,"]")
        logicalvectorlist <- c(logicalvectorlist, logical.temp)
    }
    result <- paste(logicalvectorlist, collapse = " & ")
    #<<debug printing
    #end debug printing >>
    return(result)
}
