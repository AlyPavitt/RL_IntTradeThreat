
#########################################################################

######            2a. CLASSIFY THREAT FROM INT. TRADE              ######
####     FOR SUBSET OF ANIMAL SPECIES BASED ON IUCN RL ASSESSMENT    ####

#########################################################################

# two step process

# Step 1: Pre-decision tree -----------
# Two basis for automated scoring step 1
# #1: "Use and Trade" field contains keywords indicating that use and trade are (a) unlikely to be a threat (score "U") or (b) there is insufficient information (score "I") 
# #2: "International trade is a significant threat" field is selected (score "L")


# Step 2: Decision tree -----------
# Following the rules of the decision tree 
# note that the first step of the decision tree "is international trade a sig driver of trade" = YES 
# already forms part of the first automated scoring

# #1. Is there evidence that use and/or trade takes place?
# (a) No/past/future/potential/possiblr
# (b) Yes/probable 
# if yes/probably keywords = 1(b) ELSE 1(a)

# #2a. IF 1(a) THEN is there evidence that use and/or trade is a potential future threat?
# (a) No == U1
# (b) Yes == I3

# #2b. IF 1(b) THEN is there evidence that use and/or trade is NOT international
# (a) No
# (b) Yes == U2
# if 2b(b) ELSE 2b(a)
# 2b(b) = international is not ticked but national/subsistance is,  use/trade NOT international keywords

# #3. IF 2b(a) THEN is there evidence that use/trade is NOT a threat?
# (a) No 
# (b) Yes == U3
# if 3(b) ELSE 3(a)
# 3(b) = threat codes OTHER THAN use threat codes ticked, use/trade NO threat keywords

# #4. IF 3(a) THEN is there evidence that use/trade IS a threat?
# (a) No/past/future/potential/possible = I2
# (b) Yes/probable
# if 4(b) ELSE 4(a)
# 4(b) = use-related threat code selected, use/trade as threat keywords

# #5. IF 4(b) THEN is there evidence that use/trade is international?
# (a) yes/probably = L2
# (b) No/past/future/potential/possible = I1


#####################################################################################################################################################

rm(list = ls())

#####################################################################################################################################################


# set file locations
coreWD <- ""


inputlocation <- paste0(coreWD, "")
outputlocation <- paste0(coreWD, "")


# Read in Red List assessment working document from script '1. Create working Red List document.R'  
 rla <- read.csv(paste0(inputlocation, "1. RL_SpeciesShortlist.csv"))


#####################################################################################################################################################


# prep Red List dataset --------------------------------------

# animals only, remove subspecies
rla <- rla[rla$kingdomName %in% c("ANIMALIA"),]
rla <- rla[!grepl(" ssp\\. |subpopulation", rla$scientificName),]


#####################################################################################################################################################
#####################################################################################################################################################


# Read in library and create objects of relevant text strings  ---------------
# subset on coverage = All and A (animals) only to exclude plants

librarytext <- paste0(dirname(rstudioapi::getSourceEditorContext()$path),"/Library/")


#####################################################################################################################################################


# TRADE #

# trade -----------
Trade_core <- read.csv(paste0(librarytext, "Trade/Trade_core.csv"))
Trade_core <- Trade_core$String[Trade_core$Coverage %in% c("All", "A")]

Trade_prefix <- read.csv(paste0(librarytext, "Trade/Trade_prefix.csv"))
Trade_prefix <- Trade_prefix$String[Trade_prefix$Coverage %in% c("All", "A")]

Trade_suffix <- read.csv(paste0(librarytext, "Trade/Trade_suffix.csv"))
Trade_suffix <- Trade_suffix$String[Trade_suffix$Coverage %in% c("All", "A")]

TradeKeywords <- c(paste(sapply(Trade_prefix,paste0,Trade_core)),
                   paste(sapply(Trade_core,paste0,Trade_suffix)),
                   paste(sapply(Trade_core,paste0,c(".?trade"))))


# no trade  -----------
NoTrade_core <- read.csv(paste0(librarytext, "No trade/NoTrade_core.csv"))
NoTrade_core <- NoTrade_core$String[NoTrade_core$Coverage %in% c("All", "A")]

NoTrade_Prefix <- read.csv(paste0(librarytext, "No trade/NoTrade_prefix.csv"))
NoTrade_Prefix <- NoTrade_Prefix$String

NoTrade_Keywords <- c(paste(sapply(NoTrade_Prefix,paste,c(Trade_prefix,Trade_core,"international trad","use"))),NoTrade_core) 
NoTrade_Keywords  <- NoTrade_Keywords[ -c(1:19)]


# unknown trade  -----------
UnknownTrade_Keywords <- read.csv(paste0(librarytext, "Unknown trade/UnknownTrade_keywords.csv"))
UnknownTrade_Keywords <- UnknownTrade_Keywords$String


#####################################################################################################################################################


# SCOPE #

# Future scope  -----------
Future_scope <- read.csv(paste0(librarytext, "Scope/Future_scope.csv"))
Future_scope <- Future_scope$String

FutureKeywords <- c(paste(sapply(c(Trade_core,Trade_prefix),paste,Future_scope)),
                    paste(sapply(Future_scope,paste,c(Trade_core,Trade_prefix))),
                    "collector.? item")


# International scope  -----------
International_scope <- read.csv(paste0(librarytext, "Scope/International_scope.csv"))
International_scope <- International_scope$String

Int_TradeKeywords <- unique(c(paste(sapply(International_scope,paste,Trade_core)),
                              paste(sapply(International_scope,paste,Trade_prefix)),
                              paste(sapply(International_scope,paste,c("market","demand","touris.?.?"))),
                              paste(sapply(Trade_core,paste,International_scope)),
                              #"ebay","internet trad.?.?.?","internet collect.?.?.?.?","online demand.?","online market.?","webmarket.?","on.?.?.?.? internet",
                              "commercial.?.? overexploit.?.?.?.?.?","international.?.? sought after","smuggl.?.?","out country"))

# Not international in scope --
No_prefix <- c("no.?","no know.?")
NoInt_TradeKeywords <- unique(c(paste(sapply(No_prefix,paste,Int_TradeKeywords)),
                                paste(sapply(Int_TradeKeywords,paste,"no.? know")),
                                "only local", "only domestic","domestic use only","domestic trad.?.?.? only","subsistence only"))


#####################################################################################################################################################


# THREAT #

# Threat -----------
Threat_prefix <- read.csv(paste0(librarytext, "Threat/Threat_prefix.csv"))
Threat_prefix <- Threat_prefix$String

Threat_suffix1 <- read.csv(paste0(librarytext, "Threat/Threat_suffix1.csv"))
Threat_suffix2 <- read.csv(paste0(librarytext, "Threat/Threat_suffix2.csv"))
Threat_suffix <- c(paste(sapply(c(Threat_suffix1$String), paste, c(Threat_suffix2$String))), Threat_suffix2$String) # concern

# split out to allow for more strings to be searched
# note remove the dup of "exploit...." in pref by excluding "exploit.?.?.?.?.?" from tradekeywords
# also remove trade and export strings from tradekeywords - since these are both evidence of trade alreadt, they can be added to threat without the additional info (e.g. fishing, cagebird)
Threat_core <- c(paste0(sapply(c("over.?"),paste0,c(Trade_core, "fish.?.?.?"))))
Threat_TradeKeywordsPref <- c(Threat_core,"illegal.?.?.?trad",
                              paste(sapply(Threat_prefix,paste,c(TradeKeywords[!grepl("exploit.?.?.?.?.?|trad.?.?.?|export", TradeKeywords)], "fish.?.?.?", "trad.?.?.?", "export"))))
Threat_TradeKeywordsSuff <- c(paste(sapply(c(Trade_prefix, Trade_core),paste,Threat_suffix)))


# No threat -----------
NoThreat_prefix <- c(paste0(sapply(c("no known","no.?"),paste,c("threat.?.?.?.?"))))
NoThreat_TradeKeywords <- c(paste(sapply(NoThreat_prefix,paste,c(Trade_core))),
                            paste(sapply(Trade_core,paste,NoTrade_Prefix)))


# Potential threat  -----------
# expanded to include unknown threat
PotentialThreat_prefix_suffix <- read.csv(paste0(librarytext, "Threat/PotentialThreat_prefix_suffix.csv"))
PotentialThreat_prefix_suffix <- PotentialThreat_prefix_suffix$String

PotentialThreat_prefix <- c(PotentialThreat_prefix_suffix,paste(sapply(c(PotentialThreat_prefix_suffix,"may"),paste,c("pose.?"))))

PotentialThreat_suffix <- c(paste(sapply(c("may pose", "may become"),paste,PotentialThreat_prefix_suffix)),
                            "could become","may pose",PotentialThreat_prefix_suffix)
PotentialThreat_suffix <- PotentialThreat_suffix[!(PotentialThreat_suffix %in% c("may pose may.?be", "may become may.?be"))]

PotentialThreat_suffix <- c(paste(sapply(c(PotentialThreat_suffix,"may", "might", "might suffer"), paste, 
                                         c("risk","threat.?","additional threat.?","problem","impact.? population"))))

PotentialThreat_TradeKeywords <- c(paste(sapply(Trade_core,paste,PotentialThreat_suffix)),
                                   paste(sapply(c(PotentialThreat_suffix,PotentialThreat_prefix), paste, c(Trade_core,"over.?harvest", "over.?exploit"))))


#####################################################################################################################################################
#####################################################################################################################################################


# set additional objects #

# threat codes ------
threatcodes.animals <- c("5.1.1","5.1.4","5.4.1","5.4.2","5.4.4","5.4.6")
threatcodes.plants <- c("5.2.1","5.2.4","5.3.1","5.3.2","5.3.5")

# key column names
cn <- c("threats","rationale","useTrade")
usetrade <- c("Subsistence","National","International")


#####################################################################################################################################################
#####################################################################################################################################################


## Remove threatcodes that are not relevant to animals ##

rla$ThreatCodes <- gsub(paste(c(threatcodes.plants),collapse="|"), "", rla$ThreatCodes)
rla$ThreatCodes <- gsub("^; |; $| ; ;", "", rla$ThreatCodes) # remove leading/ trailing ;
rla$ThreatCodes[rla$ThreatCodes == ""] <- NA # if no threat codes remain, make NA


#####################################################################################################################################################
#####################################################################################################################################################


# the below hashed code is to be applied if only running this code on new or updated assessments #


# ## Restrict to new assessments only ##
# # retain just the assessments that were not included in the last run 
# # species with updated assessments will be retained 
# 
# prev <- read.csv(paste0(inputlocation, ""))
# 
# prev.assID <- prev$assessmentid
# 
# rla.unchanged <- rla[rla$assessmentId %in% prev.assID,] # store those with unchanged assessments for later
# rla <- rla[!rla$assessmentId %in% prev.assID,] # categorise only assessmnents that were not included in the last run


#####################################################################################################################################################
#####################################################################################################################################################


## Pre- decision tree ##

rla$Score <- NA

# "Use and Trade" field contains keywords indicating that use and trade are 
  # (a) unlikely to be a threat (score "U") or 
  # (b) there is insufficient information (score "I") 
rla$Score[which(grepl(paste(c(NoTrade_Keywords),collapse="|"),rla$useTrade) & is.na(rla$International))] <- "U"
rla$Score[which(grepl(paste(c(UnknownTrade_Keywords),collapse="|"),rla$useTrade))] <- "I"


# "International trade is a significant threat" field is selected (score "L")
# excluding timing = "Past, unlikely to return"
rla$Score[rla$internationalTrade=="Yes"] <- "L"


# indicate basis of the score
rla$BasisOfScore <- NA
rla$BasisOfScore[which(rla$Score %in% c("I", "U"))] <- "PreDT_TradeAndUse_keywords"
rla$BasisOfScore[rla$internationalTrade=="Yes"] <- "PreDT_IntTradeThreat"


#####################################################################################################################################################
#####################################################################################################################################################

## Decision tree ##


#####################################################################################################################################################


# 1. Is there evidence that use and/or trade takes place? -----------
# (a) No/past/future/potential/possible
# (b) Yes/probable 
# if yes/probably keywords = 1(b) ELSE 1(a)

# evidence of use/trade
# i. subsistence, national or international > 0
# ii. keywords for use/trade in rationale, threat or use/trade
# iii. threat from BRU (excluding Past, unlikely to return)

rla$DT1[is.na(rla$Score)] <-"1a.no" # default = no

# perform rules on subset of rows that meet the entry criteria for 1 (no score already)
sub <- rla[which(rla$DT1 == "1a.no"),]

sub$DT1 <- apply(sub[,c(usetrade)],MARGIN=1, FUN=function(x) {ifelse(any(!is.na(x)),"1b.yes",sub$DT1)}) # (i)

sub$DT1[grepl(paste(c(TradeKeywords,UnknownTrade_Keywords),collapse="|"),sub$cn) & !grepl(paste(NoTrade_Keywords,collapse="|"),sub$cn)]<-"1b.yes" # (ii)
sub$DT1[(grepl(paste(threatcodes.animals,collapse="|"),sub$ThreatCodes))] <- "1b.yes" # (iii)

rla$DT1 <- sub$DT1[match(rla$internalTaxonId, sub$internalTaxonId)]


#####################################################################################################################################################


# 2a. IF 1(a) THEN is there evidence that use and/or trade is a potential future threat? -----------
# (a) No == U1
# (b) Yes == I3

rla$DT2a[rla$DT1=="1a.no"]<-"2aa.no" # default = no

# perform rules on subset of rows that meet the entry criteria for 2a (DT1=="1a.no")
sub <- rla[which(rla$DT1 == "1a.no"),]
sub$DT2a[which(grepl(paste(FutureKeywords,collapse="|"), sub$cn))] <- "2ab.yes" #(ii)


# add DT2a to trade
rla$DT2a <- sub$DT2a[match(rla$internalTaxonId, sub$internalTaxonId)]


# where there is no score already, assign score and basis of score
rla$Score[is.na(rla$Score) & rla$DT2a=="2aa.no"] <- "U"
rla$Score[is.na(rla$Score) & rla$DT2a=="2ab.yes"] <- "I"

rla$BasisOfScore[is.na(rla$BasisOfScore) & rla$DT2a=="2aa.no"] <- "U1"
rla$BasisOfScore[is.na(rla$BasisOfScore) & rla$DT2a=="2ab.yes"] <- "I3"


#####################################################################################################################################################


# 2b. IF 1(b) THEN is there evidence that use and/or trade is NOT international -----------
# (a) No
# (b) Yes == U2
# if 2b(b) ELSE 2b(a)
# 2b(b) = international is not ticked but national/subsistance is,  use/trade NOT international keywords

# evidence that use/trade is not international
# i. International_EndUses = NA AND subsistence|national > 0 
# ii. NoInt_TradeKeywords

rla$DT2b[rla$DT1=="1b.yes"]<-"2ba.no" # default = no


# perform rules on subset of rows that meet the entry criteria for 2b (DT1=="1b.yes")
sub <- rla[which(rla$DT1 == "1b.yes"),]

sub$DT2b[is.na(sub$International_EndUses) & (!is.na(sub$Subsistence)|!is.na(sub$National))]<-"2bb.yes" #(i)
sub$DT2b[grepl(paste(NoInt_TradeKeywords,collapse="|"), sub$cn)] <- "2bb.yes" #(ii)


# add DT2b to trade
rla$DT2b <- sub$DT2b[match(rla$internalTaxonId, sub$internalTaxonId)]


# where there is no score already, assign score and basis of score
rla$Score[is.na(rla$Score) & rla$DT2b=="2bb.yes"] <- "U"
rla$BasisOfScore[is.na(rla$BasisOfScore) & rla$DT2b=="2bb.yes"] <- "U2"


#####################################################################################################################################################


# 3. IF 2b(a) THEN is there evidence that use/trade is NOT a threat? -----------
# (a) No 
# (b) Yes == U3
# if 3(b) ELSE 3(a)
# 3(b) = threat codes OTHER THAN use threat codes ticked (or only "Past, unlikely to return"), use/trade NO threat keywords

# evidence that use/trade is not a threat
# i. NoThreat_TradeKeywords

rla$DT3[rla$DT2b=="2ba.no"]<-"3a.no" # default = no


# perform rules on subset of rows that meet the entry criteria for 2b (DT2b=="2ba.no")
sub <- rla[which(rla$DT2b=="2ba.no"),]

sub$DT3[grepl(paste(NoThreat_TradeKeywords,collapse="|"), sub$cn)] <- "3b.yes" #(i)


# add DT3 to trade
rla$DT3 <- sub$DT3[match(rla$internalTaxonId, sub$internalTaxonId)]


# where there is no score already, assign score and basis of score
rla$Score[is.na(rla$Score) & rla$DT3=="3b.yes"] <- "U"
rla$BasisOfScore[is.na(rla$BasisOfScore) & rla$DT3=="3b.yes"] <- "U3"


#####################################################################################################################################################


# 4. IF 3(a) THEN is there evidence that use/trade IS a threat? -----------
# (a) No/past/future/potential/possible = I2
# (b) Yes/probable
# if 4(b) ELSE 4(a)
# 4(b) = use-related threat code selected, use/trade as threat keywords

# evidence that use/trade is a threat
# i. intentional large-scale use-related threat code (5.1.1, 5.4.1 and 5.4.2 for animals) selected (that is NOT coded up as "Future" or "Past unlikely to return") AND only international end use
      # allowing for 5.1.1 only being found for mainly terrestrial classes and 5.4s for marine
# ii. Threat_TradeKeywords

rla$DT4[rla$DT3=="3a.no"]<-"4a.no" # default = no 


# perform rules on subset of rows that meet the entry criteria for 3 (DT3=="3a.no")
sub <- rla[which(rla$DT3=="3a.no"),]


# (b) yes/probable
sub$DT4[grepl("5\\.1\\.1|5\\.4\\.1|5\\.4\\.2", sub$ThreatCodes) & !is.na(sub$International) & is.na(sub$Subsistence) & is.na(sub$National)] <- "4b.yes" #(i)

sub$DT4[grepl(paste(c(Threat_TradeKeywordsPref),collapse="|"), sub$cn)] <- "4b.yes" #(ii)
sub$DT4[grepl(paste(Threat_TradeKeywordsSuff,collapse="|"), sub$cn)] <- "4b.yes" #(ii)

sub$DT4[grepl(paste(TradeKeywords,collapse="|"),sub$threats)] <- "4b.yes" #(ii) # test what happens when adding tradekeywords in threats without other threat text


# (a) potential/future threat
# inc. unknown
sub$DT4[grepl(paste(PotentialThreat_TradeKeywords,collapse="|"), sub$cn)] <- "4a.no" #(ii)


# (a) past threat
# no current threat codes (in ThreatCodes field) AND relevant threats listed as "Past, unlikely to return"
sub$DT4[is.na(sub$ThreatCodes) & (grepl(paste(threatcodes.animals,collapse="|"),sub$ThreatCodes_PastUnlikely))] <- "4a.no" #(ii)


# add DT4 to trade
rla$DT4 <- sub$DT4[match(rla$internalTaxonId, sub$internalTaxonId)]


# where there is no score already, assign score and basis of score
rla$Score[is.na(rla$Score) & rla$DT4=="4a.no"] <- "I"
rla$BasisOfScore[is.na(rla$BasisOfScore) & rla$DT4=="4a.no"] <- "I2"


#####################################################################################################################################################


# 5. IF 4(b) THEN is there evidence that use/trade is international? -----------
# (a) yes/probably = L2
# (b) No/past/future/potential/possible = I1

# evidence that the use/trade considered a threat is international
  # i. where there is evidence of trade = threat (DT4) evidence of int. trade (Int_TradeKeywords OR only end uses are international)
  # ii.Trade = threat in free text AND that kind of trade is in International_EndUses #(e.g. "pet trade is a threat" and Pets/display animals is in International_EndUses) (all species whether or not scored)
  # iii. Trade in just threats free text AND that kind of trade is in International_EndUses

rla$DT5 <- NA
rla$DT5[rla$DT4=="4b.yes"]<-"5b.no" # default = no


# meets international keywords 
rla$DT5[which(rla$DT4=="4b.yes" & grepl(paste(Int_TradeKeywords,collapse="|"), rla$cn))] <- "5a.yes" #(i) 

# only end uses are international
rla$DT5[which(rla$DT4=="4b.yes" & !is.na(rla$International) &
                  is.na(rla$National) & is.na(rla$Subsistence))] <- "5a.yes" #(i)


################################################################

# keywords for specific end uses #
# consider (a) end use AND (b) related text in use and trade, rationale, and threats. (trade keywords in threats, trade + threat keywords in other three)
# for use and trade, and rationale, also consider (c) threat code (text in threats is assumed to indicate threat)

# THREATS 

# pets #
Pets <- c("ornamental","pet","aquari","bird","falcon", "egg", "zoo")

Threat_TradeKeywords_Pets <- paste(c(Threat_TradeKeywordsPref[grepl(paste(Pets,collapse="|"),Threat_TradeKeywordsPref)],
                                     Threat_TradeKeywordsSuff[grepl(paste(Pets,collapse="|"),Threat_TradeKeywordsSuff)]))

TradeKeywords_Pets <- c(TradeKeywords[grepl(paste(Pets,collapse="|"),TradeKeywords)],
                        "over.?harvest","collect.?.?.? export","harvest trade","ornamental","aquari.?.?")


# relevant threat trade keywords in any of the free text fields AND international end use
rla$DT5[which(grepl(paste(Threat_TradeKeywords_Pets,collapse="|"),rla$cn) &
                  grepl("Pets",rla$International_EndUses))] <- "5a.yes"


# relevant trade keywords in threat AND international end use
rla$DT5[which(grepl(paste(TradeKeywords_Pets,collapse="|"),rla$threats) &
                  grepl("Pets",rla$International_EndUses))] <- "5a.yes"


##############################

# food #
Food <- c("fish","food", "egg", "fin")

Threat_TradeKeywords_Food <- paste(c(Threat_TradeKeywordsPref[grepl(paste(Food,collapse="|"),Threat_TradeKeywordsPref)],
                                     Threat_TradeKeywordsSuff[grepl(paste(Food,collapse="|"),Threat_TradeKeywordsSuff)],
                                     "over.?fish","over.?harvest","exploit.?.?.?.?.? line.?fish"))

TradeKeywords_Food <- c(TradeKeywords[grepl(paste(Food,collapse="|"),TradeKeywords)],
                        "over.?fish","over.?harvest","exploit.?.?.?.?.? line.?fish","trade food", "bush.?meat", "human predat.?.?.?")


# relevant threat trade keywords in any of the free text fields AND international end use
rla$DT5[which(grepl(paste(Threat_TradeKeywords_Food,collapse="|"),rla$cn) &
                  grepl("Food",rla$International_EndUses))] <- "5a.yes"


# relevant trade keywords in threat AND international end use
rla$DT5[which(grepl(paste(TradeKeywords_Food,collapse="|"),rla$threats) &
                  grepl("Food",rla$International_EndUses))] <- "5a.yes"


##############################

# Medicine #
Medicine <- c("medicin.?.?")

Threat_TradeKeywords_Medicine <- paste(c(Threat_TradeKeywordsPref[grepl(paste(Medicine,collapse="|"),Threat_TradeKeywordsPref)],
                                         Threat_TradeKeywordsSuff[grepl(paste(Medicine,collapse="|"),Threat_TradeKeywordsSuff)])) #,"medicinal use"

TradeKeywords_Medicine <- c(TradeKeywords[grepl(paste(Medicine,collapse="|"),TradeKeywords)],
                            "traditional asian medicine", "traditional chinese medicine")


# relevant threat trade keywords in any of the free text fields AND international end use
rla$DT5[which(grepl(paste(Threat_TradeKeywords_Medicine,collapse="|"),rla$cn) &
                  grepl("Medicine",rla$International_EndUses))] <- "5a.yes"


# relevant trade keywords in threat AND international end use
rla$DT5[which(grepl(paste(TradeKeywords_Medicine,collapse="|"),rla$threats) &
                  grepl("Medicine",rla$International_EndUses))] <- "5a.yes"


##############################

# Handicrafts, jewellery, etc. #
Handicraft <- c("curio","cosmetic", "shell", "skin", "butterfl")

Threat_TradeKeywords_Handicraft <- paste(c(Threat_TradeKeywordsPref[grepl(paste(Handicraft,collapse="|"),Threat_TradeKeywordsPref)],
                                           Threat_TradeKeywordsSuff[grepl(paste(Handicraft,collapse="|"),Threat_TradeKeywordsSuff)])) 

TradeKeywords_Handicraft <- c(TradeKeywords[grepl(paste(Handicraft,collapse="|"),TradeKeywords)])


# relevant threat trade keywords in any of the free text fields AND international end use
rla$DT5[which(grepl(paste(Threat_TradeKeywords_Handicraft,collapse="|"),rla$cn) &
                  grepl("Handicraft",rla$International_EndUses))] <- "5a.yes"


# relevant trade keywords in threat AND international end use
rla$DT5[which(grepl(paste(TradeKeywords_Handicraft,collapse="|"),rla$threats) &
                  grepl("Handicraft",rla$International_EndUses))] <- "5a.yes"


##############################

# apparel #
apparel <- c("fur", "skin")

Threat_TradeKeywords_apparel <- paste(c(Threat_TradeKeywordsPref[grepl(paste(apparel,collapse="|"),Threat_TradeKeywordsPref)],
                                     Threat_TradeKeywordsSuff[grepl(paste(apparel,collapse="|"),Threat_TradeKeywordsSuff)]))

TradeKeywords_apparel <- c(TradeKeywords[grepl(paste(apparel,collapse="|"),TradeKeywords)])


# relevant threat trade keywords in any of the free text fields AND international end use
rla$DT5[which(grepl(paste(Threat_TradeKeywords_apparel,collapse="|"),rla$cn) &
                  grepl("apparel",rla$International_EndUses))] <- "5a.yes"


# relevant trade keywords in threat AND international end use
rla$DT5[which(grepl(paste(TradeKeywords_apparel,collapse="|"),rla$threats) &
                  grepl("apparel",rla$International_EndUses))] <- "5a.yes"


##############################

# Sport hunting/specimen collecting #
Hunting <- c("sport", "troph.?.?.?", "hunt", "shell", "specimen", "scien", "butterfl") 

Threat_TradeKeywords_Hunting <- paste(c(Threat_TradeKeywordsPref[grepl(paste(Hunting,collapse="|"),Threat_TradeKeywordsPref)],
                                        Threat_TradeKeywordsSuff[grepl(paste(Hunting,collapse="|"),Threat_TradeKeywordsSuff)])) 

TradeKeywords_Hunting <- c(TradeKeywords[grepl(paste(Hunting,collapse="|"),TradeKeywords)], "hunt.?.?.? part.?.?.?")


# relevant threat trade keywords in any of the free text fields AND international end use
rla$DT5[which(grepl(paste(Threat_TradeKeywords_Hunting,collapse="|"),rla$cn) &
                  grepl("hunting",rla$International_EndUses))] <- "5a.yes"


# relevant trade keywords in threat AND international end use
rla$DT5[which(grepl(paste(TradeKeywords_Hunting,collapse="|"),rla$threats) &
                  grepl("hunting",rla$International_EndUses))] <- "5a.yes"


################################################################


# # add DT5 from sub to trade 

# where there is no score already, assign score and basis of score
rla$Score[which(rla$DT5=="5a.yes" & !rla$BasisOfScore %in% c("PreDT_IntTradeThreat", "PreDT_TradeAndUse_keywords"))] <- "L"
rla$BasisOfScore[which(rla$DT5=="5a.yes" & !rla$BasisOfScore %in% c("PreDT_IntTradeThreat", "PreDT_TradeAndUse_keywords"))] <- "L2"

rla$Score[which(is.na(rla$Score) & rla$DT5=="5b.no")]<-"I"
rla$BasisOfScore[which(is.na(rla$BasisOfScore) & rla$DT5=="5b.no")]<-"I1"


#####################################################################################################################################################
#####################################################################################################################################################


# the below hashed code is to be applied if only running this code on new or updated assessments #

# ## add unchanged assessments to new/updated assessments  ##
# 
# # add previous scores to unchanged assessments -----------
# rla.unchanged$Score <- prev$Final.category[match(rla.unchanged$assessmentId, prev$assessmentid)]
# rla.unchanged$BasisOfScore <- prev$Final.category_detail[match(rla.unchanged$assessmentId, prev$assessmentid)]
# 
# # add field indicating whether scoring was new or not -----------
# rla.unchanged$NewScore <- "N"
# rla$NewScore <- "Y"
# 
# # and add to rla (key fields only) -----------
# rla.cnames <- colnames(rla[c(1:20, 23, 24, 31)])
# rla <- rbind(rla[colnames(rla) %in% rla.cnames],
#                    rla.unchanged[colnames(rla.unchanged) %in% rla.cnames])


#####################################################################################################################################################
#####################################################################################################################################################

write.csv(rla, paste0(outputlocation,"Allanimals_", Sys.Date(), ".csv"), row.names = F)

