Library

- Trade
-- Trade_core: core trade words/phrases to be combined with trade_prefix or trade_suffix. all strings refer to both animals and plants
-- Trade_prefix: first part of text string, combined with Trade_core strings. some strings are taxon specific
-- Trade_suffix: second part of text string, combined with Trade_core strings. some strings are taxon specific

Trade_Keywords generated in code from ----- Trade_prefix + Trade_core AND Trade_core + Trade_suffix


- No trade: indicating that trade and/or use is not known to occur
-- NoTrade_core: full text strings. some strings are taxon specific
-- NoTrade_prefix: first part of text string, combined with trade strings.  
-- NoTrade_suffix: second part of text string, combined with trade strings

NoTrade_Keywords generated in code from ----- NoTrade_core AND NoTrade_prefix + TradeKeywords AND TradeKeywords + NoTrade_suffix


- Unknown trade
-- UnknownTrade_core: full text strings indicating presence of trade is unknown. all strings refer to both animals and plants


- Scope
-- Future_scope: partial strings to combine before and after trade keywords. all strings refer to both animals and plants
-- International_scope:  all strings refer to both animals and plants

FutureKeywords generated in code from ---- trade keywords + Future_scope AND Future_scope + trade keywords

Int_TradeKeywords generated in code from ----- International_scope + trade keywords AND trade_core + International_scope
NoInt_TradeKeywords generated in code from ----- Int_TradeKeywords with "no" keywords (short, direct in code) 


- Threat
-- Threat_prefix: first part of text string, combined with trade_core. all strings refer to both animals and plants


-- PotentialThreat_prefix_suffix: partial text strings to combine before and after threat keywords to generate PotentialThreat_suffix and PotentialThreat_prefix strings (with additional elements for text strings added directly in the code). all strings refer to both animals and plants

Threat_TradeKeywords generated in code from 
NoThreat_TradeKeywords generated in code from in-code elements only
PotentialThreat_TradeKeywords generated in code from elements built from PotentialThreat_prefix_suffix



Some library files contain strings that refer to just animals or just plants. In these cases, an additional column for "coverage" is included with the following information:
- All: both animals and plants
- A: animals only
- P: plants only