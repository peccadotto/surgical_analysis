# SURGICAL ANALYSIS PROJECT

This project provides a **comprehensive statistical analysis of personal surgical procedures** performed since 2012; it automates the workflow from raw data processing to the generation of a professional, interactive HTML report.

## 1 - Project Overview

The analysis focuses on three main pillars:
* **PERFORMED PROCEDURES** = analysis of the total amount of procedures performed per year (plus running total)
* **PROCEDURES AS LEAD SURGEON** = analysis of the percentage of procedures performed as lead surgeon
* **TOP 15 PROCEDURES** = analysis of the top 15 procedures (ICD-9 classification)

## 2 - Repository Structure

* `surgical_analysis.R` = main R script for data cleaning, transformation, and statistical processing. It exports the data for the report.
* `surgical_analysis.Rmd` = Markdown template used to generate the final interactive HTML report (using the `robobook` format).
* `data/` = directory for source CSV files (e.g., `surgical_data_YYYY.csv` and `icd9_procedures.csv`).
* `surgical_analysis.Rproj` = RStudio project file.

## 3 - Getting Started

### Prerequisites
The project requires the following R packages:
* `tidyverse` (dplyr, ggplot2, lubridate, etc.)
* `kableExtra`
* `rmdformats`

The `surgical_analysis.R` script includes a routine to automatically check for and install any missing packages upon execution.

### Usage Instructions
1. **Data Setup** - Ensure your surgical data files are in the `data/` folder following the naming convention `surgical_data_YYYY.csv`.
2. **Data Processing** - Run `surgical_analysis.R`. This script will process the raw data and save the workspace as `surgical_analysis.RData`.
3. **Generate Report** - Open `surgical_analysis.Rmd` in RStudio and click the **Knit** button to produce the final `surgical_analysis.html` report.

---
**Developed for clinical activity monitoring and academic performance tracking**
