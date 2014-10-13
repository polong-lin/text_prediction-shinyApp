continuationCount <- function(string_start, token_start, ntokens, string, dict_number, dictlist) {
    #<<debug printing:
    #end debug printing>>
    source("predictive-text-analysis/pkn/pkn.logical.dfchecker.R")
    return(nrow(dictlist[[dict_number]][eval(parse(text = logical.dfchecker(string_start, token_start, ntokens, string, dict_number))),]))
}