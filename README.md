# Employee Layoffs: SQL Data Cleaning & Exploratory Analysis

## Overview
This project uses MySQL to prepare and explore an employee-layoffs dataset. It demonstrates practical data-cleaning techniques and SQL analysis for comparing reported layoffs across companies, industries, countries, funding stages, and time periods.

## Project files
- `01_data_cleaning.sql` — creates a working copy, identifies and removes duplicate records, standardizes selected text fields, converts dates, handles selected missing values, and runs validation checks.
- `02_exploratory_data_analysis.sql` — explores layoff totals and patterns using aggregations, common table expressions (CTEs), date functions, window functions, and ranking.

## Tools and SQL concepts
- MySQL 8.0+
- `GROUP BY`, aggregate functions, filtering, and sorting
- `ROW_NUMBER()` for duplicate identification
- `JOIN` for filling missing industry values when another record for the same company has a known value
- Date conversion and date grouping
- CTEs and window functions
- `DENSE_RANK()` for annual company rankings
- Cumulative totals using a windowed `SUM()`

## How to run
1. Use MySQL 8.0 or a compatible MySQL environment.
2. Load the source dataset into a table named `layoffs`. The table should contain the fields referenced in the SQL scripts: `company`, `location`, `industry`, `total_laid_off`, `percentage_laid_off`, `date`, `stage`, `country`, and `funds_raised_millions`.
3. Review the cleaning script before running it. It drops and recreates tables named `layoffs_staging` and `layoffs_staging2`; it does not intentionally modify the raw `layoffs` table.
4. Run `01_data_cleaning.sql`.
5. Run `02_exploratory_data_analysis.sql`.

## Questions explored
- Which companies and industries have the largest reported layoff totals?
- Which countries have the largest reported layoff totals?
- Which records report 100% of employees laid off?
- How do layoff totals vary by year and month?
- What does the cumulative monthly total look like?
- Which companies rank highest by annual reported layoffs?

## Important interpretation notes
- The dataset examined in the original analysis spans 2020-03-11 through 2023-03-06. The 2023 figures therefore represent only a partial year.
- The `percentage_laid_off` field is treated as a fraction in which `1` means 100%. Confirm this matches the source dataset before interpreting the results.
- Company and industry totals are sums of the reported `total_laid_off` values. Missing layoff counts are ignored by `SUM()`.
- Filling a missing industry from another row assumes the company's industry label is consistent across its records. This assumption should be reviewed if the dataset contains conflicting industry labels.
- The original source table is preserved; analysis is performed on the cleaned staging table.

## Key findings from the initial analysis
The initial exploration identified large reported layoff totals for companies such as Amazon, Google, Meta, Salesforce, and Microsoft. Consumer, Retail, Transportation, Finance, and Healthcare were among the industries with high reported totals. The United States had the largest country total in the explored dataset. Monthly totals varied considerably, including large reported totals in late 2022 and early 2023.

These findings are descriptive and depend on the dataset and its coverage; they should not be interpreted as a complete measure of all layoffs worldwide.

## Next improvements
- Add a source citation and dataset license before publishing the dataset itself.
- Capture selected query outputs as tables or charts to make the findings easier to review.
- If desired, add a dashboard built from the cleaned data.
