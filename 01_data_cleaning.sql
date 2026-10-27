/*
Project: Employee Layoffs Data Cleaning
Database: MySQL 8.0+
Input table: layoffs
Output table: layoffs_staging2

Purpose:
Create a cleaned working table while preserving the original `layoffs` table.
Run this script before running 02_exploratory_data_analysis.sql.

Important:
- This script recreates the staging tables each time it is run.
- Back up any existing tables named `layoffs_staging` or `layoffs_staging2`
  before running this script if they contain work you need to keep.
*/

-- 1. Create a working copy so the raw source table remains unchanged.
DROP TABLE IF EXISTS layoffs_staging2;
DROP TABLE IF EXISTS layoffs_staging;

CREATE TABLE layoffs_staging LIKE layoffs;

INSERT INTO layoffs_staging
SELECT *
FROM layoffs;


-- 2. Identify duplicate records.
-- Rows that match across all listed fields are treated as duplicates.
WITH Duplicate_Check AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY
                company,
                location,
                industry,
                total_laid_off,
                percentage_laid_off,
                `date`,
                stage,
                country,
                funds_raised_millions
            ORDER BY company
        ) AS row_num
    FROM layoffs_staging
)
SELECT *
FROM Duplicate_Check
WHERE row_num > 1;


-- 3. Create a staging table with a row number for duplicate removal.
CREATE TABLE layoffs_staging2 AS
WITH Duplicate_Check AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY
                company,
                location,
                industry,
                total_laid_off,
                percentage_laid_off,
                `date`,
                stage,
                country,
                funds_raised_millions
            ORDER BY company
        ) AS row_num
    FROM layoffs_staging
)
SELECT *
FROM Duplicate_Check
WHERE row_num > 1;

-- Remove duplicate rows, keeping one row from each identical group.
DELETE FROM layoffs_staging2
WHERE row_num > 1;

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

DROP TABLE layoffs_staging;


-- 4. Standardize text fields.
-- Remove leading/trailing spaces from company names.
UPDATE layoffs_staging2
SET company = TRIM(company);

-- Normalize industry labels that begin with "Crypto" to one category.
UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

-- Remove a trailing period from country values beginning with "United States".
UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';


-- 5. Convert date strings to a DATE value.
-- This assumes source dates are stored as MM/DD/YYYY strings.
UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y')
WHERE `date` IS NOT NULL
  AND `date` <> '';

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;


-- 6. Inspect missing values before deciding how to handle them.
SELECT *
FROM layoffs_staging2
WHERE industry IS NULL
   OR TRIM(industry) = '';

-- Blank industry labels are represented consistently as NULL.
UPDATE layoffs_staging2
SET industry = NULL
WHERE TRIM(COALESCE(industry, '')) = '';

-- Fill a missing industry only when another record for the same company
-- has a known industry. This assumes a company's industry is consistent.
UPDATE layoffs_staging2 AS target
JOIN layoffs_staging2 AS source
    ON target.company = source.company
SET target.industry = source.industry
WHERE target.industry IS NULL
  AND source.industry IS NOT NULL;

-- Review rows where both layoff measures are missing.
SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
  AND percentage_laid_off IS NULL;

-- Remove rows that contain neither a layoff count nor a layoff percentage.
DELETE FROM layoffs_staging2
WHERE total_laid_off IS NULL
  AND percentage_laid_off IS NULL;


-- 7. Final validation checks.
SELECT COUNT(*) AS cleaned_row_count
FROM layoffs_staging2;

SELECT *
FROM layoffs_staging2
WHERE company IS NULL
   OR TRIM(company) = '';

SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY industry;

SELECT MIN(`date`) AS earliest_date,
       MAX(`date`) AS latest_date
FROM layoffs_staging2;

-- The original `layoffs` table is left unchanged.
