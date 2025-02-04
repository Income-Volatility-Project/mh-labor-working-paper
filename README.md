# Mental Health and Labor - Working Paper

## Overview

Replication Package for the working paper on mental health and its impact on labor. The package includes the code, data and external scripts needed to replicate all results. Please set the global variable `mh_root` in the file `code/main.do` to the path in which you stored the replication package. Then, simply run `code/main.do`

## Data Availability

- [x] No data can be made publicly available.

Please contact the one of the authors of the paper for access to the data:

- Leandro Carvalho
- Damien de Walque
- Crick Lund
- Heather Schofield,
- Vincent Somville
- Jingyao Wei

### Data Sources

We use experimentally collected data for this project. Data was collected as part of an ongoing RCT.

- **data/generated/Pilot_3_Census_Reshaped_Analysis**
- **data/generated/Pilot_3_MH_Census_Study**

### Statement about Rights

- [x] I certify that the author(s) of the manuscript have legitimate access to and permission to use the data used in this manuscript.
- [x] I certify that the author(s) of the manuscript have documented permission to redistribute/publish the data contained within this replication package. Appropriate permission are documented in the LICENSE.txt file.

## Instructions for Replicators

New users should follow these steps to run the package successfully:

- Users must first have access to all data files if they are not included in the reproducibility package. They should place them in the `data/generated` with the file names listed above folder.

- Update the following files with your directory paths

  - `code/main.do`
    - Update the global variable `mh_root` with the path to the directory in which this replication package is saved

- Run the `main.do` file.

## List of Exhibits

- [x] All tables and figures in the paper

| Exhibit Name                                                                                         | Output filename                                | Script                                                 | Note                                     |
| ---------------------------------------------------------------------------------------------------- | ---------------------------------------------- | ------------------------------------------------------ | ---------------------------------------- |
| Figure 1. Phase 1 Sample                                                                             | --                                             | --                                                     | A latex diagram found inside the diagram |
| Figure 2. Phase 2 Sample and Randomization                                                           | --                                             | --                                                     | A latex diagram found inside the diagram |
| Figure 3. Distribution of Mental Health Scores Among Female Participants                             | plot/fig.1.2.mh_distribution_preview.pdf       | code/figures/fig_1.2_mh_distribution_all.do            |                                          |
| Figure 4. Mental Health and Work Offer Refusal Rates                                                 | plot/refuse_work_sem.pdf                       | code/figures/fig_3_refuse_work.do                      | Found in manuscript/plot                 |
| Figure 5. Willingness to Work and Total Earnings during the Study                                    | plot/figure_2_imputed_scatter.pdf              | code/figures/fig_2_work_earning.do                     | Found in manuscript/plot                 |
| Table 1. Summary Statistics – Phase 1                                                                | table/updated/table_g.1_mh_hh_summary          | code/tables/tables_g_summary_stats_census.do           | Found in manuscript/table/updated        |
| Table 2. Summary Statistics – Phase 2                                                                | table/updated/table_i.1_mh_hh_summary          | code/tables/tables_i_summary_stats_study.do            | Found in manuscript/table/updated        |
| Table 3. Correlation between Mental Health and Willingness to Work                                   | table/updated/table_a.5_mh_signup              | code/tables/tables_a_mental_health_and_offer_accept.do | Found in manuscript/table/updated        |
| Table 4. Association between Depression and Reasons for Work Refusal                                 | table/updated/table_b.3_mh_signup_reason       | code/tables/tables_b_refusal_reason_controls.do        | Found in manuscript/table/updated        |
| Table 5. Work Offers, Labor Supply, Income and Mental Health                                         | table/updated/table_c.1_mh_work_bl             | code/tables/tables_c_work_mh_bl.do                     | Found in manuscript/table/updated        |
| Table 6. Association between Baseline Mental Health and Quit Rate                                    | table/updated/table_h.0_mh_quit                | code/tables/tables_h_mh_quit.do                        | Found in manuscript/table/updated        |
| Table 7. Association between Mental Health and Work Offer Acceptance for Others                      | table/updated/table_a.6_mh_signup_others       | code/tables/tables_a_mental_health_and_offer_accept.do | Found in manuscript/table/updated        |
| Table 8. Association between Depression and Reasons for Work Refusal for Others                      | table/updated/table_b.4_mh_signup_reason_other | code/tables/tables_b_refusal_reason_controls.do        | Found in manuscript/table/updated        |
| Table A.1 Association between Alternate Mental Health Measures and Work Offer Acceptance             | table/updated/table_a.3_mh_signup              | code/tables/tables_a_mental_health_and_offer_accept.do | Found in manuscript/table/updated        |
| Table A.2. Correlation between Mental Health and Willingness to Work (without additional controls)   | table/updated/table_a.1_mh_signup              | code/tables/tables_a_mental_health_and_offer_accept.do | Found in manuscript/table/updated        |
| Table A.3. Work Offers, Labor Supply, Income and Alternate Mental Health Measures                    | table/updated/table_c.2_mh_work_bl             | code/tables/tables_c_work_mh_bl.do                     | Found in manuscript/table/updated        |
| Table A.4. Work Offers, Labor Supply, Income and Full-Length Mental Health Measures                  | table/updated/table_c.5_mh_work_bl             | code/tables/tables_c_work_mh_bl.do                     | Found in manuscript/table/updated        |
| Table A.5. Work Offers, Labor Supply, Income and Mental Health (without additional controls)         | table/updated/table_c.4_mh_work_bl             | code/tables/tables_c_work_mh_bl.do                     | Found in manuscript/table/updated        |
| Table A.6. Association between Alternate Mental Health Measures and Work Offer Acceptance for Others | table/updated/table_a.4_mh_signup_others       | code/tables/tables_a_mental_health_and_offer_accept.do | Found in manuscript/table/updated        |

## Requirements

## Computational Requirements

No special instructions are required. Please ensure Stata is installed, the data is available and run `code/main.do` as instructed above

### Software Requirements

- **Stata version 17**
  - estout
  - reghdfe
  - fstools
  - egenmore
  - grc1leg2
  - blindschemes

> Note: all requriements are included in this replication package. Only Stata is required

### Memory and Runtime and Storage Requirements

The requirements needed to run code in this replication package are minimal. Most modern machines should work

- 25 Mb Disk space
- 8 GB RAM
- < 2 minutes run time (tested on M3 MacBook Pro)

## Code Description

- `code/main.do` sets up file paths, and runs all table and figure `.do` described below
- `code/tables/*.do` generates various tables included in the manuscript. See [List of Exhibits](index##List of Exhibits) for a full list
  - `code/tables/table_constants.do`: contains globals used be individual table scripts that make the tables. If running tables individually, make sure to run this `do` file at least once before.
- `code/figures/*.do` generates various figures included in the manuscript. See [List of Exhibits](index##List of Exhibits) for a full list

## Folder Structure

- `code`: contains all scripts.
  - `code/tables`: contains `.do` files that make tables
  - `code/figures.do`: contains `.do` files that make figures
- `external_scripts`: contains stata packages and custom code needed to generated the tables and figures
- `manuscript`: contains the manuscript `.tex` file
  - `manuscript/table/updated`: Contains output files generated by the table-related `.do` files
    - _empty until running table `.do` files_
  - `manuscript/plot`: Contains output files generated by the table-related `.do` files
    - _empty until running figure `.do` files_
