# Start clean slate
rm(list=ls())

# Load necessary packages
library(sqldf)
library(tidyverse)
library(knitr)
library(kableExtra)
library(stringr)
library(rvest)


# Load downloaded UniPRot data from CSV
UP_df <- read.csv("UniProt_download.csv", stringsAsFactors = F)
colnames(UP_df)[1] <- "UniProt_ID"

str(UP_df)


# Split data into separate tables

# Table for Tissue_specificity
Tissue_specificity <- UP_df %>%
  select(UniProt_ID, Tissue_specificity) %>%
  mutate(Tissue_specificity = str_replace_all(Tissue_specificity, "[(]PubMed:.*[)]", "")) %>%
  filter(str_detect(Tissue_specificity, "ECO", negate=T), 
         Tissue_specificity != "") %>% 
  na.omit()


# Table for Function_overview
Function_overview <- UP_df %>%  
  select(UniProt_ID, Function) %>%  
  mutate(Function = str_split(Function, "[.] ")) %>%  
  unnest(Function) %>%  
  mutate(Function = str_replace_all(Function, "[(]PubMed:.*[)]", "")) %>%  
  filter(Function != "") %>%  
  filter(str_detect(Function, "ECO", negate=T),
         Function != "")

# Table for KEGG IDs
UniProt_KEGG <- UP_df %>%  
  select(UniProt_ID, KEGG_ID)  

# Table for all Gene Ontology Biological Processes
GO_BP_Full <- UP_df %>%
  select(UniProt_ID, GO_BP) %>%  
  mutate(GO_BP = str_split(GO_BP, "; ")) %>%  
  unnest(GO_BP) %>%  
  filter(GO_BP != "") %>%  
  separate(GO_BP, into=c("Biological_process", "GO_ID"), sep=" \\[") %>%  
  mutate(GO_ID = str_replace(GO_ID, "\\]", ""))

# Table for all Gene Ontology Cellular Components
GO_CC_Full <- UP_df %>%
  select(UniProt_ID, GO_CC) %>%  
  mutate(GO_CC = str_split(GO_CC, "; ")) %>%  
  unnest(GO_CC) %>%  
  filter(GO_CC != "") %>%  
  separate(GO_CC, into=c("Cellular_component", "GO_ID"), sep=" \\[") %>%  
  mutate(GO_ID = str_replace(GO_ID, "\\]", ""))

# Table for all Gene Ontology Molecular Functions
GO_MF_Full <- UP_df %>%  
  select(UniProt_ID, GO_MF) %>%  
  mutate(GO_MF = str_split(GO_MF, "; ")) %>%  
  unnest(GO_MF) %>%  
  filter(GO_MF != "") %>%  
  separate(GO_MF, into=c("Molecular_function", "GO_ID"), sep=" \\[") %>%  
  mutate(GO_ID = str_replace(GO_ID, "\\]", ""))



# Web Scraping ------------------------------------------------------------

# Load UniProt IDs and protein names
proteins <- read.csv("Protein_UniProt_List.csv")

# Create matrix of UniProt_IDs
UniProt_IDs <- as.matrix(proteins$Uniprot_ID)

# Base URL
uniprot_url <- "https://www.uniprot.org/uniprot/%s"

# Helper functions:

# Function to extract diseases from UniProt page for a given UniProt ID
extract_diseases <- function(page) {
  page %>%
    html_node(".diseaseAnnotation") %>%  
    html_nodes(xpath="//a[contains(@href, '/diseases/')]") %>%  
    html_text() %>%  
    as.data.frame() 
}


# Function to extract subcellular location
extract_location <- function(page) {
  page %>%
    html_nodes(xpath="//*[@class='namespace-uniprot']/
               main[@id='content']/
               div[@class='main-aside']/
               div[@class='content entry_view_content up_entry swissprot']/
               div[@id='subcellular_location']/
               span/a") %>%  
    html_text() %>%
    as.data.frame()
}

# Function to extract Reactome pathway
extract_pathway <- function(page) {
  page %>%
    html_nodes(".databaseTable :contains(ReactomeiR)") %>%  
    html_text() %>%  
    # Only keep the second text entry
    .[2] %>%  
    as.data.frame()
}


# Initialize empty dataframes to append results from helper functions:
keyword_df <- data.frame(X1=character(0), X2=character(0), 
                         UniProt_ID=character(0))
disease_df <- location_df <- pathway_df <- data.frame(.=character(0), 
                                                      UniProt_ID=character(0))


# Extract_all is the function which will load a UniProt URL, read and parse the associated html content, and call each of the helper functions to extract all of the desired information.

# Given a UniProt ID, apply all the above functions to extract relevant info
extract_all <- function(id) {
  Sys.sleep(0.5)
  
  #Try the given URL and return NA if there is a 404 error
  try(
    page <- sprintf(uniprot_url, URLencode(id)) %>%
      read_html(),
    silent=T
  )
  
  # Keywords
  kw <- extract_keywords(page) %>%
    mutate(UniProt_ID = id) %>%
    distinct()
  keyword_df <<- rbind(keyword_df, kw)
  
  # Associated diseases
  disease <- extract_diseases(page) %>%
    mutate(UniProt_ID = id) %>%
    distinct()
  disease_df <<- rbind(disease_df, disease)
  
  # Subcellular location
  location <- extract_location(page) %>%
    mutate(UniProt_ID = id) %>%
    distinct()
  location_df <<- rbind(location_df, location)
  
  # Pathway
  pathway <- extract_pathway(page) %>%
    mutate(UniProt_ID = id) %>%
    distinct()
  pathway_df <<- rbind(pathway_df, pathway)
}

# Calling invisible() to suppress console output
invisible(apply(UniProt_IDs, 1, extract_all))


# Clean scraped data -----------------------------------------------------------


# Rename DF columnes
colnames(location_df) <- c("Subcellular_location", "UniProt_ID")
colnames(disease_df) <- c("Disease_association", "UniProt_ID")


# Create dataframe to hold Biological Process and Molecular Function keywords
BP_MF <- keyword_df %>%  
  # Only interested in Biological Process or 
  # Molecular Function keywords  
  filter(str_detect(X1, 
                    "<p>|Ligand|Reactome|SABIO-RK|SignaLink|SIGNOR|MEROPS|Error", 
                    negate=T)) %>%
  spread(key=X1, value=X2)


# Create one dataframe for biological processes
BP <- BP_MF %>%
  select(UniProt_ID, `Biological process`) %>%  
  rename(Biological_Process = `Biological process`) %>%  
  mutate(Biological_Process = str_split(Biological_Process, ", ")) %>%  
  unnest(Biological_Process) %>%
  na.omit()

# Create one dataframe for molecular functions
MF <- BP_MF %>%
  select(UniProt_ID, `Molecular function`) %>%  
  rename(Molecular_Function = `Molecular function`) %>%  
  mutate(Molecular_Function = str_split(Molecular_Function, ", ")) %>%  
  unnest(Molecular_Function) %>%  
  na.omit()


# Many UniProt proteins are mapped to several Reactome Pathways,
# This code splits multiple pathway entries into distinct rows
colnames(pathway_df) <- c("Path", "UniProt_ID")
pathway_df <- pathway_df %>%
  rowwise() %>%  
  mutate(Path = str_replace(Path, "Reactomei", "")) %>%  
  # Split by the R-HSA- string
  mutate(Path= str_split(Path, "R-HSA-", n=Inf)) %>%  
  
  # Un-list
  unnest(Path) %>%  
  
  # Remove empty strings that reflect non-existent pathways
  filter(Path != "") %>%  
  
  # Split into R-HSA IDs and pathway descriptions
  mutate(Path = str_split(Path, " ", n=2)) %>%  
  purrr::quietly(unnest_wider)(Path) %>%
  
  # only keep Results of purrr::quietly()
  .[[1]] %>%  
  rowwise() %>%  
  mutate(`...1` = paste("R-HSA-", `...1`, sep="", collapse=""))

colnames(pathway_df) <- c("Reactome_ID", "Pathway_Description", "UniProt_ID")



# Add data to SQL Database ------------------------------------------------

# Connect to SQLite
db <- dbConnect(SQLite(), dbname="UniProt.sqlite")

dbWriteTable(conn = db, name = "Biological_Process", value=BP, 
             row.names=FALSE, header=TRUE, overwrite=T)

dbWriteTable(conn = db, name = "Biological_Process_Full", value=GO_BP_Full,  
             row.names=F, header=T, overwrite=T)

dbWriteTable(conn = db, name = "Cellular_Component_Full", value=GO_CC_Full,  
             row.names=F, header=T, overwrite=T)

dbWriteTable(conn = db, name = "Disease_Associations", value=disease_df,   
             row.names=FALSE, header=TRUE, overwrite=T)

dbWriteTable(conn = db, name = "Function_Overview", value=Function_overview,   
             row.names=FALSE, header=TRUE, overwrite=T)  

dbWriteTable(conn = db, name = "Molecular_Function", value=MF,   
             row.names=FALSE, header=TRUE, overwrite=T)

dbWriteTable(conn = db, name = "Molecular_Function_Full", value=GO_MF_Full, 
             row.names=F, header=T, overwrite=T)

dbWriteTable(conn = db, name = "Protein_Names", value = proteins,   
             row.names = FALSE, header = TRUE, overwrite=T)

dbWriteTable(conn = db, name = "Pathways", value=pathway_df,   
             row.names=FALSE, header=TRUE, overwrite=T)

dbWriteTable(conn = db, name = "Subcellular_Location", value=location_df,   
             row.names=FALSE, header=TRUE, overwrite=T)

dbWriteTable(conn = db, name = "Tissue_Specificity", value=Tissue_specificity,  
             row.names=F, header=T, overwrite=T)

dbWriteTable(conn = db, name = "KEGG_IDs", value=UniProt_KEGG,   
             row.names=F, header=T, overwrite=T)



# Demonstrate efficacy of SQL queries for data by querying most frequent values for some of the data tables

## Biological Process Keywords:
dbGetQuery(db, "SELECT Biological_Process, COUNT(*) AS 'Count'
           FROM Biological_Process
           GROUP BY Biological_Process
           ORDER BY COUNT(*) DESC")

## Biological Process, Full:
dbGetQuery(db, "SELECT Biological_process, COUNT(*) AS 'Count'
                            FROM Biological_Process_Full
                            GROUP BY Biological_process
                            ORDER BY COUNT(*) DESC")

## Molecular Function Keywords:
dbGetQuery(db, "SELECT Molecular_Function, COUNT(*) as 'Count' 
           FROM Molecular_Function
           GROUP BY Molecular_Function
           ORDER BY COUNT(*) DESC")

## Molecular Function, Full:
dbGetQuery(db, "SELECT Molecular_function, COUNT(*) as 'Count' 
           FROM Molecular_Function_Full
           GROUP BY Molecular_function
           ORDER BY COUNT(*) DESC")

## Disease Association:
dbGetQuery(db, "SELECT Disease_association, COUNT(*) as 'Count'
            FROM Disease_Associations
            GROUP BY Disease_association
            ORDER BY COUNT(*) DESC")

## Function Overview:
dbGetQuery(db, "SELECT Function, COUNT(*) as 'Count'
            FROM Function_Overview
            GROUP BY Function
            ORDER BY COUNT(*) DESC")

## Subcellular Location:
dbGetQuery(db, "SELECT Subcellular_location AS 'Subcellular Location', 
            COUNT(*) as 'Count'
            FROM Subcellular_Location
            GROUP BY Subcellular_location
            ORDER BY COUNT(*) DESC")

## Cellular Compartment, Full:
dbGetQuery(db, "SELECT Cellular_component, COUNT(*) as 'Count'
            FROM Cellular_Component_Full
            GROUP BY Cellular_component
            ORDER BY COUNT(*) DESC")

## Reactome Pathways:
dbGetQuery(db, "SELECT Reactome_ID, 
            Pathway_Description AS 'Pathway Description', COUNT(*) as 'Count'
            FROM Pathways
            GROUP BY Reactome_ID
            ORDER BY COUNT(*) DESC")