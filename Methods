## 1. Create working Red List document
This script processes and combines the following files downloaded from the IUCN Red List website: 'Assessment', 'Taxonomy', 'Threats' and 'UseTrade'.
Note that it does not use the IUCN Red List API to avoid excessive calls and maximise accessibility, however this code could be adapted to work with the API.

### Data processing steps ----
**Step 1.** Species are retained for analysis if they:<br/>

* (A) Species is assigned one of the following Red List categories: Critically Endangered (CR), Endangered (EN), Vulnerable (VU), Near Threatened (NT), Low Risk/near threatened (LR/nt) or Low Risk/conservation dependent (LR/cd); and
* (B)  meet at least one of the following
  - include one or more of 55 text strings in rationale, threats, and/or use and trade
  - include one or more of 11 biological resource use threat codes (5.1.1, 5.1.4, 5.2.1, 5.2.4, 5.3.1, 5.3.2, 5.3.5, 5.4.1, 5.4.2, 5.4.4, 5.4.6)
  - is considered to have one or more "International" end uses
  - has "International trade is a significant driver of threat" selected. <br/><br/>


**Step 2** Free text fields in retained species assessments are prepared and standardised by standardising case, removing special characters and punctuation, and removing stopwords


## 2a. Animal Autoclassification and 2b. Plant Autoclassification
Using the data file created above, both scripts score relevant species as either 'unlikely threatened by international trade' (U), 'likely threatened by international trade' (L), or 'insufficient information' (I). 

These methods are aligned with those published in [Challender *et al.* 2023](https://www.nature.com/articles/s41559-023-02115-8) with modifications necessary for standardised 'rules' rather than manual decision-making. They use a combination of categorical and free-text fields and are summarised, as implemented in the code, visually in the 'methods_visual' file and below as a two-step process. Keyword string searches in free text fields 

 Animals/fungi and plants follow the same method, but with some differences in keywords.

### Pre-decision tree ---
Species are classified as U, L or I without the need for a more comprehensive assessment if they meet one of the following:
* 'International trade is a significant threat' field is selected (**score 'L'**) note that this field is not a requirement for Red List assessors and so is not used consistently
* The 'Use and Trade' free text field include keyword strings that state either
  - trade does not occur/ is unlikely to be a threat (**score 'U'**) or
  - there is insufficient information on whether trade occurs/ is a threat (**score 'I'**)


### Decision tree ---
All species not scored in the pre-decision tree step are then put through a decision tree process (see Figure 5 in Challender et al 2023 for a summary of this tree). 

**1. Is there evidence that use and/or trade takes place?**<br>
	(a) No/past/future/potential/possible: Default <br>
	(b) Yes/probable <br>

*Evidence of use and/or trade taking place -*
* there is at least one end use specified (at subsistence, national or international level)
* there are keywords in 'useTrade', 'rationale' or 'threats' that indicate that use and/or trade occurs and/or
* there is at least one relevant threat code indicating that the species is considered threatened by biological resource use (excluding those considered 'past, unlikely to return')
<br>

**2a. If 1(a) THEN is there evidence that use and/or trade is a potential future threat?** <br>
	(a) No == **score 'U'** (U1): Default <br>
	(b) Yes == **score 'I'** (I3) <br>

*Evidence of use and/or trade as a potential future threat -*
* there are keywords in 'useTrade', 'rationale' or 'threats' that indicate that use and/or trade may occur in the future
<br>

**2b. If 1(b) THEN is there evidence that use and/or trade is NOT international? <br>**
	(a) No: Default <br>
	(b) Yes == **score 'U'** (U2) <br>

*Evidence that use and/or trade is NOT international -*
* species has end uses defined at subsistence and/or national scale, but none at international scale
* there are keywords in 'useTrade', 'rationale' or 'threats' that indicate that use and/or trade is NOT international 
<br>

**3. If 2b(a) THEN is there evidence that use/trade is NOT a threat?** <br>
	(a) No: Default <br>
	(b) Yes == **score 'U'** (U3) <br>

*Evidence that use and/or trade is NOT a threat -*
* there are keywords in 'useTrade', 'rationale' or 'threats' that indicate that use and/or trade is NOT a threat 
<br>

**4. IF 3(a) THEN is there evidence that use/trade IS a threat?** <br>
	(a) No/past/future/potential/possible == **score 'I'** (I2): Default <br>
	(b) Yes/probable <br>

*Evidence that use/trade is a threat -*
* species has ONLY international scale end uses and at least one relevant threat code (5.1.1, 5.4.1 and 5.4.2 for animals and 5.2.1, 5.3.1 and 5.3.2 for plants). This excludes threat codes that are only coded up as "Future" or "Past unlikely to return"
* there are keywords in 'useTrade', 'rationale' or 'threats' that indicate that use and/or trade IS a threat 
<br>

**5. IF 4(b) THEN is there evidence that use/trade is international?** <br>
	(a) yes/probably == **score 'L'** (L2) <br>
	(b) No/past/future/potential/possible == **score 'I'** (I1) <br>

*Evidence that the use/trade considered a threat is international -*
* there are keywords in 'useTrade', 'rationale' or 'threats' that indicate that use and/or trade is at the international scale
* all end uses have international scale ONLY 
* there are keywords in 'useTrade', 'rationale' or 'threats' that indicate that use and/or trade in a specific type of end use is a threat AND that end use occurs at international scale (NB this is not applied sequentially)
* there are keywords in 'threats' that indicate that use and/or trade occurs AND that end use occurs at international scale (NB this is not applied sequentially)
<br><br>

# Validation

The methods and keyword library were build on a randomly selected 80% of the Red List assessments included in Challender et al. (2023) and then tested against the remaining 20% to determine whether the automated methods categorised taxa the same as the manual scoring. Automated and manual approaches categorised 85.1% of the test animals and 81.5% of test plants the same. Overall, across all Red List assessments included in Challender et al. (2023) (using version 2020-1 of the Red List), the automated methods categorised 84.7% of animals and 80.1% of plants the same as the manual scoring. Interrater reliability was also tested using Fleiss’ Kappa, which found agreement between the automated approach and four individual manual assessors to be significantly higher than expected by chance and indicated substantial agreement (n = 100, k = 0.75, p <0.0001). 
