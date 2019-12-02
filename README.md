## Annie Bryant
## DA5020 Final Project

### Project Overview

For my final project, I chose to curate a database of protein-specific information acquired from the UniProt Knowledge Base[1]. I wanted the R script to read in a list of UniProt IDs from a CSV file and output R and SQL dataframes containing relevant information corresponding to each UniProt entry, including molecular function, biological process, Reactome pathway, and disease involvement. This involves querying the UniProt webpage for each ID using rvest[2], cleaning the data within R using dplyr[3], and organizing the data into a SQL database with normalized tables using sqldf[4].  

My motivation for this project comes from my work as a Research Technician in the lab of Dr. Brad Hyman at Massachusetts General Hospital. I joined a project over the summer in which plasma samples were collected from cognitively impaired patients at two or three time points over several years to measure protein expression. Specifically, expression levels for 414 different proteins were measured using a highly-sensitive transcription-based amplification technology from Olink Proteomics, yielding normalized relative protein expression values for each plasma sample. In total, for 414 proteins and 123 patients with plasma from multiple time points (2 or 3), this data amounts to 145,314 data points. One predominant goal of this project is to identify biomarkers that either predict or correlate with cognitive decline, since both protein expression and cognitive status were measured at each visit for each patient.

Multiple groups in the lab are analyzing this resulting dataset with other various goals, focusing on different subsets of the 414 proteins assayed. My group is particularly interested in the dynamics of cerebral vasculature with AD pathogenesis and progression[5]. As such, we have focused on a smaller subset of 21 vasculature-related proteins. I came across the R package Time-course Gene Set Analysis (TcGSA) package which is designed to analyze longitudinal RNA-Seq data by grouping individual genes into gene sets, *a priori*, which are known to share common biological functions and/or expression patterns^6^. While I wasn't able to get this package to work with my protein data, it inspired me to approach our longitudinal protein expression data analysis from a similar perspective. 

I realized it would be tremendously helpful to have functional information about each protein in addition to the expression data, in order to potentially identify overarching trends in protein networks.Hopefully, the SQL database created in this project will provide further insight into the relationship between protein expression change and cognitive decline going forward.  


### About the UniProt Data Involved

In this longitudinal study, expression levels were measured for 414 different proteins. One particularly useful collection of information I used comes from the **Gene Ontology**[7,8], which is an online consortium integrating structural and functional information about genes and gene products from numerous sources. I used UniProt's Retrieve/ID Mapping tool to download the following information about each of these proteins:  


* **Gene Ontology (GO) Biological Process**: Broader biological processes achieved via several molecular activities, from DNA repair to lipid transporter activity.
* **Gene Ontology Cellular Component**: Intracellular component(s) in which a gene product executes a particular function -- for example, ribosome or Golgi apparatus.
* **Gene Ontology Molecular Function**: Activities performed at the molecular level by one or more gene products, including transporter activity and Toll-like receptor binding.
* **Tissue specificity**: Organ(s) or organ system(s) in which the protein is expressed throughout the body.
* **Function overview**: Higher-level information about the general function(s) of the protein.
* **KEGG ID**: ID linking the UniProt entry to the corrresponding entry in the Kyoto Encyclopedia of Genes and Genomes (KEGG)[9,10,11]


To hone in on specific information I wanted, I also used rvest to scrape the following information about each protein:   

* **Biological Process keyword**: One or two primary GO biological processes.
* **Molecular Function keyword**: One or two primary GO molecular functions. 
* **Associated diseases**: Any disease(s) associated with genetic variations in the protein.
* **Subcellular location**: The location and the topology of the mature protein in the cell.
* **Reactome Pathway**: The ID and description associated with a Reactome Pathway, an expansive collection of biological pathways and processes.[12]  


### Summary of Collected Project Data
For in-depth explanation of the data scraping and cleaning process, please refer to the Project_Writeup.pdf included in this project. In brief, all cleaned data pertaining to the 414 proteins included in this study are included in the CSV Files folder of this project. All data can be re-created using the Project_Code.R script, and the R environment data can be loaded with Project_Data.RData. The Project_Writeup.pdf file was created by knitting Project_Writeup.RMD to PDF using RStudio.

In total, I have compiled eleven distinct data tables that encompass protein function, cellular location, and protein pathways for the 414 proteins in our study. More specifically, I have amassed the following distinct counts of values across the respective tables:  

* Biological Process, Keywords: 81
* Biological Process, Full: 2825
* Cellular Compartment, Full: 335
* Disease Associations: 200
* Function overview: 1763
* Molecular Function, Keywords: 67
* Molecular Function, Full: 580
* Subcellular Location: 41
* Reactome Pathway: 583
* Tissue Specificity: 638
* KEGG IDs: 414

As described, the purpose for this project is to obtain more information about the proteins studied in the longitudinal Alzheimer's Disease plasma study so that we can examine trends among protein pathways and across functional domains. While I cannot share any of the actual data or analysis for this project due to confidentiality, I am excited about how these datasets will facilitate new discoveries for our project going forward. I have thus far only focused on acquiring and organizing the data, as per the project guidelines, but the next phase of project implementation will be to perform statistical analyses (e.g. T-Tests, Logistic Regression, PCA) with biological process and Reactome pathway as categorical variables.

### References

1. UniProt Consortium. (2018). UniProt: a worldwide hub of protein knowledge. Nucleic acids research, 47(D1), D506-D515.
2. Hadley Wickham (2019). rvest: Easily Harvest (Scrape) Web Pages. R package version 0.3.5. https://CRAN.R-project.org/package=rvest
3. Hadley Wickham, Romain François, Lionel Henry and Kirill Müller (2018). dplyr: A Grammar of Data Manipulation. R package version 0.7.6. https://CRAN.R-project.org/package=dplyr
4. G. Grothendieck (2017). sqldf: Manipulate R Data Frames Using SQL. R package version 0.4-11. https://CRAN.R-project.org/package=sqldf
5. Bennett, R. E., Robbins, A. B., Hu, M., Cao, X., Betensky, R. A., Clark, T., ... & Hyman, B. T. (2018). Tau induces blood vessel abnormalities and angiogenesis-related gene expression in P301L transgenic mice and human Alzheimer’s disease. Proceedings of the National Academy of Sciences, 115(6), E1289-E1298.
6. Hejblum BP, Skinner J, and Thiebaut R (2015) Time-Course Gene Set Analysis for Longitudinal Gene Expression Data. PLoS Comput Biol 11(6): e1004310.<doi:10.1371/journal.pcbi.1004310
7. Ashburner et al. Gene ontology: tool for the unification of biology. Nat Genet. May 2000;25(1):25-9.
8. The Gene Ontology Consortium. The Gene Ontology Resource: 20 years and still GOing strong. Nucleic Acids Res. Jan 2019;47(D1):D330-D338. 
9. Kanehisa, M. and Goto, S.; KEGG: Kyoto Encyclopedia of Genes and Genomes. Nucleic Acids Res. 28, 27-30 (2000). 
10. Kanehisa, M., Sato, Y., Furumichi, M., Morishima, K., and Tanabe, M.; New approach for understanding genome variations in KEGG. Nucleic Acids Res. 47, D590-D595 (2019).
11. Kanehisa, M; Toward understanding the origin and evolution of cellular organisms. Protein Sci. (2019)
12. Fabregat, A., Jupe, S., Matthews, L., Sidiropoulos, K., Gillespie, M., Garapati, P., ... & Milacic, M. (2017). The reactome pathway knowledgebase. Nucleic acids research, 46(D1), D649-D655.
