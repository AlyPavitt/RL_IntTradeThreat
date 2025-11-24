# Likelihood of species threat from international trade
Categorises species as either ‘likely’ (L) or ‘unlikely’ (U) to be threatened by international trade, or as having insufficient information to determine the likelihood of this threat (I) based on the species’ global IUCN Red List assessment.

# Methods
These methods apply a systematic and automated approach to the decision tree developed and published in [Challender *et al.* 2023](https://www.nature.com/articles/s41559-023-02115-8) to categorise the likelihood of a species being threatened by international trade. The approach is a substantive advancement on the initial proof of concept script tested in Challender *et al.* on two test classes (Amphibia and Actinopterygii), and is applicable to all animals, plants and fungi with IUCN Red List assessments. 

The process is structured into three scripts and a 'library' of keywords that are combined to search the free text fields of the Red List assessments. Methods and validation are summarised in [methods](https://github.com/AlyPavitt/RL_IntTradeThreat/blob/main/Methods.md).

# Related work and dataset
Data outputs are accessible via [Zenodo](https://zenodo.org/records/17582808) 

Methods and results based on version 2025.2 of the IUCN Red List are published at CITES [CoP20 Inf. Doc. 53](https://cites.org/sites/default/files/documents/E-CoP20-Inf-053.pdf)

# Citation
Pavitt A. (2025). Likelihood of species threat from international trade [R script]. Version 1.0. UNEP-WCMC. DOI: 10.5281/zenodo.17591184. *Developed from:* Challender *et al.* (2023). Identifying species likely threatened by international trade on the IUCN Red List can inform CITES trade measures. Nat Ecol Evol 7, 1211–1220. DOI: 10.1038/s41559-023-02115-8
