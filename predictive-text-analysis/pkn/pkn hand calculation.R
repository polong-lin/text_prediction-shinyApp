source("predictive-text-analysis/pkn/pkn.pkn.calc.R")
string1 <- c("wait to", "go") #high
string2 <- c("wait to", "eat") #medium
string3 <- c("wait to", "home") #low

#pkn(candidate | wait to)

#term1: numerator
highest.c.wait_to_go <- bdictlist[[3]][token == "wait to go", count] #31

highest.c.wait_to_eat <- bdictlist[[3]][token == "wait to eat", count] #6

highest.c.wait_to_home <- bdictlist[[3]][token == "wait to home", count] #0
highest.c.wait_to_home <- 0

#term1 and 2: denominator
highest.c.wait_to <- bdictlist[[2]][token == "wait to", count] #1046

#term2: numerator: continuation count
highest.cont.wait_to_ANY <- nrow(bdictlist[[3]][token1 == "wait" & token2 == "to"])


##pkn(candidate | wait)

#term1: numerator
lower.cont.ANY_to_go <- nrow(bdictlist[[3]][token2 == "to" & token3 == "go"]) #484
lower.cont.ANY_to_eat <- nrow(bdictlist[[3]][token2 == "to" & token3 == "eat"]) #179
lower.cont.ANY_to_home <- nrow(bdictlist[[3]][token2 == "to" & token3 == "home"]) #9

#term1 and 2: denominator
lower.cont.ANY_to_ANY <- nrow(bdictlist[[3]][token2 == "to"]) #54102

#term2: numerator: continuation count
lower.cont.to_ANY <- nrow(bdictlist[[3]][token1 == "to"]) #46359



##pkn(candidate)
#numerator
lowest.cont.ANY_go <- nrow(bdictlist[[2]][token2 == "go"]) #577
lowest.cont.ANY_eat <- nrow(bdictlist[[2]][token2 == "eat"]) #138
lowest.cont.ANY_home <- nrow(bdictlist[[2]][token2 == "home"]) #530

#denominator
lowest.cont.ANY_ANY <- nrow(bdictlist[[2]]) #1109141

#Formula
discount = 0.75

#--------pkn.lowest----------
go.lowest <- lowest.cont.ANY_go/lowest.cont.ANY_ANY #577/1109141 = 0.0005
eat.lowest <- lowest.cont.ANY_eat/lowest.cont.ANY_ANY #0.0001
home.lowest <- lowest.cont.ANY_home/lowest.cont.ANY_ANY #0.0004

#----pknlower-------
go.lower.term1 <- max(lower.cont.ANY_to_go - discount, 0)/lower.cont.ANY_to_ANY
eat.lower.term1 <- max(lower.cont.ANY_to_eat - discount, 0)/lower.cont.ANY_to_ANY
home.lower.term1 <- max(lower.cont.ANY_to_home - discount, 0)/lower.cont.ANY_to_ANY

go.lower.term2 <- (discount * lower.cont.to_ANY/lower.cont.ANY_to_ANY) * go.lowest
eat.lower.term2 <- (discount * lower.cont.to_ANY/lower.cont.ANY_to_ANY) * eat.lowest
home.lower.term2 <- (discount * lower.cont.to_ANY/lower.cont.ANY_to_ANY) * home.lowest

go.lower <- go.lower.term1 + go.lower.term2
eat.lower <- eat.lower.term1 + eat.lower.term2
home.lower <- home.lower.term1 + home.lower.term2

#------pkn.highest---------
go.highest.term1 <- max(highest.c.wait_to_go - discount, 0)/highest.c.wait_to
eat.highest.term1 <- max(highest.c.wait_to_eat - discount, 0)/highest.c.wait_to
home.highest.term1 <- max(highest.c.wait_to_home - discount, 0)/highest.c.wait_to

go.highest.term2 <- (discount * highest.cont.wait_to_ANY/highest.c.wait_to) * go.lower
eat.highest.term2 <- (discount * highest.cont.wait_to_ANY/highest.c.wait_to) * eat.lower
home.highest.term2 <- (discount * highest.cont.wait_to_ANY/highest.c.wait_to) * home.lower

go.highest <- go.highest.term1 + go.highest.term2
eat.highest <- eat.highest.term1 + eat.highest.term2
home.highest <-home.highest.term1 + home.highest.term2


go.highest
eat.highest
home.highest

pkn.go <- pkn.calc(string = "wait to", candidate = "go", dictlist = bdictlist)
pkn.eat <- pkn.calc(string = "wait to", candidate = "eat", dictlist = bdictlist)
pkn.home <- pkn.calc(string = "wait to", candidate = "home", dictlist = bdictlist)

bdictlist[[3]][token == "wait to go",count] #31
bdictlist[[3]][token == "wait to eat",count] #6
bdictlist[[3]][token == "wait to home",count] #0

data.frame(hand = c(go.highest, eat.highest, home.highest), pkn = c(pkn.go, pkn.eat, pkn.home))


pkn.calc(string = "wait to", candidate = "actualize", dictlist = bdictlist)
