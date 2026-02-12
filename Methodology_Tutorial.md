
This document explains the "why" behind every computational decision, threshold, and algorithm used in this pipeline to process the GSE279086 kidney dataset.

**About the Dataset: GSE279086**

**Tissue:** Human Kidney (Biopsy/Nephrectomy)

**Clinical Context:** In type 1 diabetes (T1D), impaired insulin sensitivity may contribute to the development of diabetic kidney disease (DKD) through alterations in kidney oxidative metabolism. Young adults with T1D and healthy controls underwent single-cell RNA sequencing, and spatial metabolomics to assess this relationship.

**Technology:** 10x Genomics Single-Cell RNA-seq.

**Challenge:**Kidney tissue is highly complex with significant technical variation between patients. Proper integration is required to distinguish disease-driven changes from patient-specific noise.

**Script-by-Script Rationale**

**1. 01_download.sh & 02_cleanup.sh**

**Why:** Manual downloads of 40+ samples are prone to error.

**Logic:** We used a mapping array to link GSM IDs to internal sample codes. The cleanup script is essential because GEO prefixes filenames with long strings that break Seurat's Read10X() function.

**Goal:** Standardizing files to matrix.mtx.gz, features.tsv.gz, and barcodes.tsv.gz ensures the R environment recognizes them as valid 10x Genomics outputs.

**2. 03_Data_Prep.Rmd (Individual QC)**

**Initial Filtering (min.features = 200):** Removes barcodes that captured only doublet RNA or empty droplets.

**Mitochondrial Percentage (< 15%):** High MT content is a biological proxy for cell stress or membrane rupture. In the kidney, cells are fragile; 15% is a standard threshold to exclude apoptotic cells while retaining metabolic-heavy cells.
**Ribosomal Percentage (percent.rb):** We track this to ensure we aren't seeing technical bias in protein synthesis machinery across different sequencing runs.

**3. 04_Downstream.R (Integration & Clustering)**

**Protein-Coding Filter:** We filtered the dataset to 16,442 protein-coding genes. This removes non-coding noise (lncRNAs, pseudogenes) that can interfere with the Principal Component Analysis (PCA).

**Mahalanobis Distance (Threshold 0.95):** Instead of a "hard" cutoff for RNA counts, we used this multivariate statistical method to detect and remove statistical outliers—cells that don't fit the expected distribution of the library.
Harmony Integration: Kidney samples often show "batch effects" where cells group by patient. Harmony was chosen to "align" these samples into a shared space so that a "Podocyte" from a Healthy patient matches a "Podocyte" from a DKD patient.

**Dimensionality Reduction (dims 1:50):** We used 50 PCs to capture subtle biological signals, as kidney tissue has many rare cell subtypes, but finally we considered 35 PCs, as total variance was caused by only 35 PCs.

**4. 05_Annotation.ipynb (Python / CellTypist)**

**Why Python-** We used CellTypist (a machine-learning model) because it is faster and more reproducible than manual marker-based annotation.

**Majority Voting:** This ensures that if the model is unsure about a single cell, it looks at the neighboring cells in the cluster to make a consensus call, leading to much more stable cell-type labels.

**Expression Filtering (Sum > 30):** We filter the plotting data so that only genes with a substantial biological presence are visualized in the final DotPlots.

**5. 06_DEGs_Pathways.Rmd **
**MAST Algorithm:** We chose the MAST (Model-based Analysis of Single-cell Transcriptomics) test. Unlike the standard Wilcoxon test, MAST handles the "hurdle" of single-cell data (the high frequency of zero counts) using a specialized regression model.

**Latent Variable Correction:** We corrected for nCount_RNA and percent.mt within the MAST model. This ensures that the genes we call "Differentially Expressed" are actually due to the disease (DKD) and not just because one cell was sequenced deeper than another.

**GSEA (Reactome):** We used Gene Set Enrichment Analysis on the entire ranked list of genes. This allows us to find biological pathways that are "coordinated" across many genes, even if individual genes have small fold changes.

**Cross-Platform Data Transfer (RDS ↔ SCE ↔ H5AD)**

A critical part of the workflow is the conversion between formats:

1. Seurat v5 (Assay5): Chosen for high-speed data handling in R. 

2. SingleCellExperiment (SCE): Used as a neutral "bridge" format.

3. H5AD (AnnData): The final export for Python.

**Rationale:** This multi-format approach ensures we can use the best tool for each job (Seurat for Integration, Python for Annotation, clusterProfiler for Pathways).

