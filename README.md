# scRNA-tutorial
This repository contains a complete end-to-end bioinformatics pipeline for the preprocessing, quality control, and integration of single-cell RNA-sequencing (scRNA-seq) data. The pipeline is designed to handle multiple samples, perform rigorous QC, and integrate datasets using Harmony to remove batch effects across different clinical conditions and lastly find DEGs with pahthway analysis. It covers automated data retrieval, multi-sample R processing, Harmony integration, and Python-based automated cell typing.

**Dataset Summary**
**Study ID:** GSE279086

**Platform:** 10X Genomics

**Conditions:** AKI (Acute Kidney Injury), DKD (Diabetic Kidney Disease), HCKD (Hypertensive Chronic Kidney Disease), and Healthy Controls.

**Input:** Raw 10X count matrices.

**Output:** Integrated Seurat object & AnnData (.h5ad) for cross-platform analysis.

**Repository Structure & Workflow**

The analysis is divided into six logical stages:

**Stage 1**: Automated Data Retrieval (01_download.sh)
Technology: Bash / Wget

Description: A shell script that maps GSM IDs to specific sample codes. It automatically navigates the NCBI GEO FTP server structure to download raw matrix.mtx.gz, features.tsv.gz, and barcodes.tsv.gz for all 40+ samples in the GSE279086 dataset.

**Stage 2:** File Standardization (02_cleanup_geo_files.sh)
Technology: Bash

Description: Automates the "cleaning" of downloaded files. GEO downloads often include long, redundant prefixes. This script removes unprocessed files, renames processed matrices to a standard format (matrix.mtx.gz), and organizes them into a folder structure compatible with Seurat’s Read10X function.

**Stage 3:** Seurat Object Preparation (03_Data_Prep.R)

Technology: R / Seurat

Description: Iteratively loads individual sample directories into R.

Initializes Seurat objects with a baseline filter (min 3 cells / 200 features).

Calculates QC metrics (Mitochondrial and Ribosomal percentages).

Exports standardized .rds files for every individual sample to the input/ directory.

**Stage 4:** Integrated Downstream Analysis (04_Downstream.R)
Technology: R / Seurat / Harmony

Description:

Merging: Combines all samples into a unified global object.

Rigorous QC: Applies Mahalanobis distance-based outlier detection for total counts and hard thresholds for MT-DNA (<15%).

Harmony Integration: Corrects for batch effects across conditions (AKI, DKD, Healthy).

Dimensionality Reduction: Performs PCA and UMAP, determining optimal PC dimensions (95% variance) via Elbow plots.

Interoperability: Exports the data to .h5ad format for cross-platform use in Python. 

**Stage 5:** Automated Cell Typing & Visualization (05_Annotation.ipynb)
Technology: Python / Scanpy / CellTypist

Description:

CellTypist Annotation: Employs a Python-based machine learning model to predict cell identities using "Majority Voting."

Marker Gene Filtering: A custom logic to filter and plot genes where expression is high enough to be biologically significant (Max across groups ≥ 30).

Visual Validation: Generates high-resolution DotPlots and Cluster Marker plots to validate cell type assignments against known markers.

**Stage 6:** Differential Expression (DEGs) & Pathway Analysis
Technology: R / MAST / clusterProfiler

Description: The final analytical step identifying significant genes between disease states (e.g., DKD vs. Healthy) at a per-cell-type resolution.

MAST Algorithm: Utilizes a specialized regression model for scRNA-seq to account for stochastic dropouts while adjusting for latent variables like sequencing depth and mitochondrial content.

Functional Enrichment: Maps DEGs to the Reactome database using GSEA to identify disrupted biological pathways.

Visualization: Produces summary tables of up/downregulated genes and high-resolution NES (Normalized Enrichment Score) dot plots to illustrate the functional impact of disease across different kidney cell types.
