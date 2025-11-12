

#########################################################################

######           1. PREPARE SUBSET OF RED LIST SPECIES             ######
####    FOR AUTO-CLASSIFICATION OF THREAT FROM INTERNATIONAL TRADE   ####

#########################################################################


# Step 1. Collate Red List files (assessment, taxonomy, threats and use.trade)

# Step 2. Shortlist species based on set parameters
      # A. species categorised as Critically Endangered (CR), Endangered (EN), Vulnerable (VU), Near Threatened (NT), 
      # Low Risk/near threatened (LR/nt) or Low Risk/conservation dependent (LR/cd); and 
      # B: either 
        # >= one of 55 text strings in rationale, threats, and/or use and trade; or 
        # >= one of 11  biological resource use threat codes (5.1.1, 5.1.4, 5.2.1, 5.2.4, 5.3.1, 5.3.2, 5.3.5, 5.4.1, 5.4.2, 5.4.4, 5.4.6)
        # "international" use under end uses = TRUE (identify any additional species to #1)
        # "International trade is a significant driver of threat" = TRUE (identify any additional species to #1 and #2)

# Step 3. Cleans free text fields (threats, rationale, usetrade)
      # removes special characters/ punctuation
      # remove stop words

# Step 4. Output prepared files for automated classification by codes
      # 2a. Animal auto-classification
      # 2p. Plant auto-classification


#####################################################################################################################################################

rm(list = ls())

#####################################################################################################################################################

library("stopwords")


# set file locations
coreWD <- ""

inputlocation <- paste0(coreWD, "")
outputlocation <- paste0(coreWD, "")

# read in RL data files -----------
# assessments (core data - species, free text for threat, rationale, conservation, useTrade)

IUCNassessment <- read.csv(paste0(inputlocation,"Assessments.csv"))

# taxonomy
IUCNTaxonomy <- read.csv(paste0(inputlocation,"Taxonomy.csv"))

# threats (species threats)
IUCNThreats <- read.csv(paste0(inputlocation,"Threats.csv"))

# usetrade (species end uses)
IUCNUseTrade <- read.csv(paste0(inputlocation,"UseTrade.csv"))


#####################################################################################################################################################


# Universal vectors ----------

threatcodes <- c("5.1.1","5.1.4","5.4.1","5.4.2","5.4.4","5.4.6","5.2.1","5.2.4","5.3.1","5.3.2","5.3.5")
threatcodes.animals <- c("5.1.1","5.1.4","5.4.1","5.4.2","5.4.4","5.4.6")
threatcodes.plants <- c("5.2.1","5.2.4","5.3.1","5.3.2","5.3.5")


#####################################################################################################################################################


# global assessments only ----------
IUCNassessment <- IUCNassessment[grepl("Global", IUCNassessment$scopes),]


#####################################################################################################################################################


# add higher taxonomy ----------
traderaw <- merge(IUCNTaxonomy[c("internalTaxonId", "kingdomName", "phylumName", "className", "orderName", "familyName")],
                  IUCNassessment[c("assessmentId", "internalTaxonId", "redlistCategory", "scientificName", "rationale", "threats", "useTrade")], 
                  by = "internalTaxonId", all.y = T)


# add threat codes  ----------

# species where threat$internationalTrade == "YES"
# exclude instances where the threat is "Past, Unlikely to Return"
# create separate vector because multiple threats might have different responses
Species_internationalTrade <- c(IUCNThreats$internalTaxonId[IUCNThreats$internationalTrade == "Yes" & !IUCNThreats$timing == "Past, Unlikely to Return"])

IUCNThreats <- IUCNThreats[order(IUCNThreats$code),]
species.threats <- reshape2::dcast(IUCNThreats[which(IUCNThreats$code %in% c(threatcodes) & !IUCNThreats$timing == "Past, Unlikely to Return"),],
                                   internalTaxonId ~ "ThreatCodes",
                                   value.var = "code", 
                                   fun.aggregate = function(x) paste(x, collapse = "; ")) # existing threats

species.threats_Past <- reshape2::dcast(IUCNThreats[which(IUCNThreats$code %in% c(threatcodes) & IUCNThreats$timing == "Past, Unlikely to Return"),],
                                        internalTaxonId ~ "ThreatCodes_PastUnlikely",
                                        value.var = "code",
                                        fun.aggregate = function(x) paste(x, collapse = "; "))

traderaw$internationalTrade [traderaw$internalTaxonId %in% Species_internationalTrade] <- "Yes" # add #international trade is as threat'
traderaw$ThreatCodes <- species.threats$ThreatCodes[match(traderaw$internalTaxonId, species.threats$internalTaxonId)] # add relevant species threat codes (exc. past, unlikely to return)
traderaw$ThreatCodes_PastUnlikely <- species.threats_Past$ThreatCodes_PastUnlikely[match(traderaw$internalTaxonId, species.threats_Past$internalTaxonId)]# add relevant species threat codes (past, unlikely to return)


# add end uses ----------

# number of end uses under "intenational", "national" and "subsistence"
enduse <- data.frame(merge(table(IUCNUseTrade$internalTaxonId[IUCNUseTrade$international == "true"]),
                           merge(table(IUCNUseTrade$internalTaxonId[IUCNUseTrade$national == "true"]),
                                 table(IUCNUseTrade$internalTaxonId[IUCNUseTrade$subsistence == "true"]), by = "Var1", all=T), by = "Var1", all=T))
names(enduse) <- c("internalTaxonId","International","National","Subsistence")


# concatenate end uses for "international"
enduse.int <- reshape2::dcast(IUCNUseTrade[which(IUCNUseTrade$international=="true"),],internalTaxonId~"International_EndUses",
                              value.var="name",fun.aggregate=function(x) paste(x,collapse="; "))

enduse.intONLY <- reshape2::dcast(IUCNUseTrade[which(IUCNUseTrade$international=="true" & IUCNUseTrade$subsistence=="" & IUCNUseTrade$national==""),],
                                  internalTaxonId~"InternationalOnly_EndUses",
                                  value.var="name",fun.aggregate=function(x) paste(x,collapse="; "))

# combine number of end uses and lists of international end uses with previous df
multi_merge_function <- function(df1, df2){
  merge(df1, df2, by="internalTaxonId", all = T) 
} # "full outer join", by internalTaxonId

traderaw <- Reduce(multi_merge_function, list(traderaw, enduse, enduse.int, enduse.intONLY)) 
traderaw <- unique(traderaw)


#####################################################################################################################################################
#####################################################################################################################################################


## First queries to identify shortlist of species ##

# Defining parameters ----------

# A. species categorised as Critically Endangered (CR), Endangered (EN), Vulnerable (VU), Near Threatened (NT), 
# Low Risk/near threatened (LR/nt) or Low Risk/conservation dependent (LR/cd); and 
# B: either 
# >= one of 55 text strings in rationale, threats, and/or use and trade; or 
# >= one of 11  biological resource use threat codes (5.1.1, 5.1.4, 5.2.1, 5.2.4, 5.3.1, 5.3.2, 5.3.5, 5.4.1, 5.4.2, 5.4.4, 5.4.6)
# "international" use under end uses = TRUE (identify any additional species to #1)
# "International trade is a significant driver of threat" = TRUE (identify any additional species to #1 and #2)


#####################################################################################################################################################


# vectors ----------
threatcategory <- c("Critically Endangered", "Endangered", "Vulnerable", "Near Threatened", "Lower Risk/near threatened", "Lower Risk/conservation dependent")
threatstrings.major <- c("trade", "export", "collect", "enthusiast", "harvest", "exploit", "demand", "market", "cites")
threatstrings.minor1 <- c("nternational", "ransboundary", "ntercontinental", "border", "pet", "aquari", "horticultur", "timber", "commercial", "world", "ornamental",
                          "cage.?bird", "curio", "medicin", "fisher", "regional", "pharmaceutical", "unsustainabl")
threatstrings.minor2 <- c(" use", "utili")


# 1. text string ----------
# text string major = keyword alone
traderaw$Shortlisted <- NA
traderaw$Shortlisted [!!rowSums(sapply(traderaw[c("threats", "rationale", "useTrade")], 
                                       grepl, 
                                       pattern = paste(threatstrings.major,collapse="|")))] <- "yes.i"

# text string minor = must include at least one from each of minor1 and minor2
# minor1 and minor2 do NOT have to occur next to one another in the text strings
traderaw$Shortlisted [grepl(paste(threatstrings.minor1,collapse="|"),traderaw$threats) & 
                        grepl(paste(threatstrings.minor2,collapse="|"),traderaw$threats)] <- "yes.i"

traderaw$Shortlisted [grepl(paste(threatstrings.minor1,collapse="|"),traderaw$rationale) & 
                        grepl(paste(threatstrings.minor2,collapse="|"),traderaw$rationale)] <- "yes.i"

traderaw$Shortlisted [grepl(paste(threatstrings.minor1,collapse="|"),traderaw$useTrade) & 
                        grepl(paste(threatstrings.minor2,collapse="|"),traderaw$useTrade)] <- "yes.i"


# 2. Threat codes  ----------
traderaw$Shortlisted [grepl(paste(threatcodes,collapse="|"), traderaw$ThreatCodes) | 
                        grepl(paste(threatcodes,collapse="|"), traderaw$ThreatCodes_PastUnlikely)] <- "yes.ii"
  

# 3. international end use ----------
traderaw$Shortlisted [is.na(traderaw$Shortlisted) & traderaw$International>0] <- "yes.iii"


# 4. international trade is a signficiant driver of threat ----------
# include all timings, including "past, unlikely to return" or not
traderaw$Shortlisted [is.na(traderaw$Shortlisted) & 
                        traderaw$internalTaxonId %in% c(IUCNThreats$internalTaxonId[IUCNThreats$internationalTrade == "Yes"])] <- "yes.iii"


# anything not in accepted red list categories = NA ----------
traderaw$Shortlisted [!traderaw$redlistCategory %in% c(threatcategory)] <- NA


# take shortlisted taxa forwards onto first automation step
trade <- traderaw[grepl("yes", traderaw$Shortlisted),]

#####################################################################################################################################################
#####################################################################################################################################################

## Clean free text ##

#####################################################################################################################################################

# key column names
cn <- c("threats", "rationale", "useTrade")
usetrade <- c("Subsistence", "National", "International")

# standardise case and remove unwanted characters
trade[,c(cn)] <- sapply(trade[,c(cn)], function(x) tolower(x)) # to lower
trade[,c(cn)] <- sapply(trade[,c(cn)], function(x) gsub("<[^>]+>","",x)) # exclude everything between < and > 
trade[,c(cn)] <- sapply(trade[,c(cn)], function(x) gsub("[^a-zA-Z|^ ]", "", x)) # remove all characters except alpha and space
trade[,c(cn)] <- sapply(trade[,c(cn)], function(x) gsub("   |  ", " ", x)) # remove double and triple spaces

# standardise abbreviations
trade[,c(cn)] <- sapply(trade[,c(cn)], function(x) gsub("cannot|can not", "cant", x)) 
trade[,c(cn)] <- sapply(trade[,c(cn)], function(x) gsub("is not", "isnt", x)) 
trade[,c(cn)] <- sapply(trade[,c(cn)], function(x) gsub("will not", "wont", x))
trade[,c(cn)] <- sapply(trade[,c(cn)], function(x) gsub("does not", "doesnt", x))
trade[,c(cn)] <- sapply(trade[,c(cn)], function(x) gsub("has not", "hasnt", x))
trade[,c(cn)] <- sapply(trade[,c(cn)], function(x) gsub("have not", "havent", x))

# standardise other keywords
trade[,c(cn)] <- sapply(trade[,c(cn)], function(x) gsub("utiliz", "utilis", x)) 

# remove stopwords
stop <- c(stopwords::stopwords("en"), 
          "also", "can", "further", "general", "includ.?.?.?", "individual.?", "major", "mature", "minor", "much", 
          "species", "still", "therefore", "whether", "wild", "within", "et al")

stop <- stop[!stop %in% c("no", "not")] # dont want to exclude 'no' and 'not' because they are both used in exclusion terms (e.g. 'not traded')
stop <- paste0(" ",c(stop)," ")


# if trade[,c(cn)] contains stopwords, replace with space and repeat until no more stopwords
repeat{
  trade.stop <- unique(trade[sapply(trade[c(cn)], grepl, pattern = paste(stop,collapse="|")),])
  
  if(nrow(trade.stop)=="0"){
    break
  }
  
  if(nrow(trade.stop)>0){
    trade[,c(cn)] <- sapply(trade[,c(cn)],function(x) gsub(paste(stop,collapse="|"), " ", x))
  }
}


# combine three cn fields to increase speed of searching when applying keyword searches to all three
trade$cn <- do.call(paste0, c(trade[cn]))


#####################################################################################################################################################
#####################################################################################################################################################


# output prepared dataset ~

write.csv(trade, paste0(outputlocation, "1. RL_SpeciesShortlist.csv"), row.names = F)

