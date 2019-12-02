Annie Bryant
------------

DA5020 Final Project
--------------------

### Project Overview

For my final project, I chose to curate a database of protein-specific
information acquired from the UniProt Knowledge Base(“UniProt: A
Worldwide Hub of Protein Knowledge” 2019). I wanted the R script to read
in a list of UniProt IDs from a CSV file and output R and SQL dataframes
containing relevant information corresponding to each UniProt entry,
including molecular function, biological process, Reactome pathway, and
disease involvement. This involves querying the UniProt webpage for each
ID using rvest(“Rvest: Easily Harvest (Scrape) Web Pages” 2019),
cleaning the data within R using dplyr(“Dplyr: A Grammar of Data
Manipulation” 2019), and organizing the data into a SQL database with
normalized tables using sqldf(“Sqldf: Manipulate R Data Frames Using
SQL” 2017).

My motivation for this project comes from my work as a Research
Technician in the lab of Dr. Brad Hyman at Massachusetts General
Hospital, a lab focused on studying Alzheimer’s Disease (AD). I joined a
project over the summer in which plasma samples were collected from
cognitively impaired patients at two or three time points over several
years to measure protein expression. Specifically, expression levels for
414 different proteins were measured using a highly-sensitive
transcription-based amplification technology from Olink Proteomics,
yielding normalized relative protein expression values for each plasma
sample. In total, for 414 proteins and 123 patients with plasma from
multiple time points (2 or 3), this data amounts to 145,314 data points.
One predominant goal of this project is to identify biomarkers that
either predict or correlate with cognitive decline, since both protein
expression and cognitive status were measured at each visit for each
patient.

Multiple groups in the lab are analyzing this resulting dataset with
other various goals, focusing on different subsets of the 414 proteins
assayed. My group is particularly interested in the dynamics of cerebral
vasculature with AD pathogenesis and progression(Bennett et al. 2018).
As such, we have focused on a smaller subset of 21 vasculature-related
proteins. I came across the R package Time-course Gene Set Analysis
(TcGSA) package which is designed to analyze longitudinal RNA-Seq data
by grouping individual genes into gene sets, *a priori*, which are known
to share common biological functions and/or expression patterns(Hejblum,
Skinner, and Thiébaut 2015). While I wasn’t able to get this package to
work with my protein data, it inspired me to approach our longitudinal
protein expression data analysis from a similar perspective.

I realized it would be tremendously helpful to have functional
information about each protein in addition to the expression data, in
order to potentially identify overarching trends in protein
networks.Hopefully, the SQL database created in this project will
provide further insight into the relationship between protein expression
change and cognitive decline going forward.

### About the UniProt Data Involved

In this longitudinal study, expression levels were measured for 414
different proteins. One particularly useful collection of information I
used comes from the **Gene Ontology**(Ashburner et al. 2000;
The Gene Ontology Consortium 2019), which is an online consortium
integrating structural and functional information about genes and gene
products from numerous sources. I used UniProt’s Retrieve/ID Mapping
tool to download the following information about each of these proteins:

-   **Gene Ontology (GO) Biological Process**: Broader biological
    processes achieved via several molecular activities, from DNA repair
    to lipid transporter activity.
-   **Gene Ontology Cellular Component**: Intracellular component(s) in
    which a gene product executes a particular function – for example,
    ribosome or Golgi apparatus.
-   **Gene Ontology Molecular Function**: Activities performed at the
    molecular level by one or more gene products, including transporter
    activity and Toll-like receptor binding.
-   **Tissue specificity**: Organ(s) or organ system(s) in which the
    protein is expressed throughout the body.
-   **Function overview**: Higher-level information about the general
    function(s) of the protein.
-   **KEGG ID**: ID linking the UniProt entry to the corrresponding
    entry in the Kyoto Encyclopedia of Genes and Genomes, or KEGG
    (Kanehisa 2000; Minoru Kanehisa et al. 2019; Minoru Kanehisa 2019).

To hone in on specific information I wanted, I also used rvest to scrape
the following information about each protein:

-   **Biological Process keyword**: One or two primary GO biological
    processes.
-   **Molecular Function keyword**: One or two primary GO molecular
    functions.
-   **Associated diseases**: Any disease(s) associated with genetic
    variations in the protein.
-   **Subcellular location**: The location and the topology of the
    mature protein in the cell.
-   **Reactome Pathway**: The ID and description associated with a
    Reactome Pathway, an expansive collection of biological pathways and
    processes.(Fabregat et al. 2018)

### Summary of Collected Project Data

For in-depth explanation of the data scraping and cleaning process,
please refer to the Project\_Writeup.pdf included in this project. In
brief, all cleaned data pertaining to the 414 proteins included in this
study are included in the CSV Files folder of this project. All data can
be re-created using the Project\_Code.R script, and the R environment
data can be loaded with Project\_Data.RData. The Project\_Writeup.pdf
file was created by knitting Project\_Writeup.RMD to PDF using RStudio.

In total, I have compiled eleven distinct data tables that encompass
protein function, cellular location, and protein pathways for the 414
proteins in our study. More specifically, I have amassed the following
distinct counts of values across the respective tables:

-   Biological Process, Keywords: 81
-   Biological Process, Full: 2825
-   Cellular Compartment, Full: 335
-   Disease Associations: 200
-   Function overview: 1763
-   Molecular Function, Keywords: 67
-   Molecular Function, Full: 580
-   Subcellular Location: 41
-   Reactome Pathway: 583
-   Tissue Specificity: 638
-   KEGG IDs: 414

As described, the purpose for this project is to obtain more information
about the proteins studied in the longitudinal Alzheimer’s Disease
plasma study so that we can examine trends among protein pathways and
across functional domains. While I cannot share any of the actual data
or analysis for this project due to confidentiality, I am excited about
how these datasets will facilitate new discoveries for our project going
forward. I have thus far only focused on acquiring and organizing the
data, as per the project guidelines, but the next phase of project
implementation will be to perform statistical analyses (e.g. T-Tests,
Logistic Regression, PCA) with biological process and Reactome pathway
as categorical variables.

### References

Ashburner, M., C. A. Ball, J. A. Blake, D. Botstein, H. Butler, J. M.
Cherry, A. P. Davis, et al. 2000. “Gene Ontology: Tool for the
Unification of Biology. The Gene Ontology Consortium.” *Nature Genetics*
25 (1): 25–29. <https://doi.org/10.1038/75556>.

Bennett, Rachel E., Ashley B. Robbins, Miwei Hu, Xinrui Cao, Rebecca A.
Betensky, Tim Clark, Sudeshna Das, and Bradley T. Hyman. 2018. “Tau
Induces Blood Vessel Abnormalities and Angiogenesis-Related Gene
Expression in P301L Transgenic Mice and Human Alzheimer’s Disease.”
*Proceedings of the National Academy of Sciences of the United States of
America* 115 (6): E1289–E1298.
<https://doi.org/10.1073/pnas.1710329115>.

“Dplyr: A Grammar of Data Manipulation.” 2019.
<https://CRAN.R-project.org/package=dplyr>.

Fabregat, Antonio, Steven Jupe, Lisa Matthews, Konstantinos
Sidiropoulos, Marc Gillespie, Phani Garapati, Robin Haw, et al. 2018.
“The Reactome Pathway Knowledgebase.” *Nucleic Acids Research* 46 (D1):
D649–D655. <https://doi.org/10.1093/nar/gkx1132>.

Hejblum, Boris P., Jason Skinner, and Rodolphe Thiébaut. 2015.
“Time-Course Gene Set Analysis for Longitudinal Gene Expression Data.”
*PLoS Computational Biology* 11 (6): e1004310.
<https://doi.org/10.1371/journal.pcbi.1004310>.

Kanehisa, M. 2000. “KEGG: Kyoto Encyclopedia of Genes and Genomes.”
*Nucleic Acids Research* 28 (1): 27–30.
<https://doi.org/10.1093/nar/28.1.27>.

Kanehisa, Minoru. 2019. “Toward Understanding the Origin and Evolution
of Cellular Organisms.” *Protein Science: A Publication of the Protein
Society* 28 (11): 1947–51. <https://doi.org/10.1002/pro.3715>.

Kanehisa, Minoru, Yoko Sato, Miho Furumichi, Kanae Morishima, and Mao
Tanabe. 2019. “New Approach for Understanding Genome Variations in
KEGG.” *Nucleic Acids Research* 47 (D1): D590–D595.
<https://doi.org/10.1093/nar/gky962>.

“Rvest: Easily Harvest (Scrape) Web Pages.” 2019.
<https://CRAN.R-project.org/package=rvest>.

“Sqldf: Manipulate R Data Frames Using SQL.” 2017.
<https://CRAN.R-project.org/package=sqldf>.

The Gene Ontology Consortium. 2019. “The Gene Ontology Resource: 20
Years and Still GOing Strong.” *Nucleic Acids Research* 47 (D1):
D330–D338. <https://doi.org/10.1093/nar/gky1055>.

“UniProt: A Worldwide Hub of Protein Knowledge.” 2019. *Nucleic Acids
Research* 47 (D1): D506–D515. <https://doi.org/10.1093/nar/gky1049>.
