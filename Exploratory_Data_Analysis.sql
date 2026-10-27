-- Exploratory Data Analysis (EDA)
-- Purpose: examine reported layoffs by company, industry, country, funding stage, and time.
-- Dataset fields include company, location, industry, total_laid_off, percentage_laid_off, date, stage, country, and funds_raised_millions.
-- Preview the cleaned dataset before running the analysis.
SELECT *
FROM layoffs_staging2;

-- Identify the maximum number of employees laid off in a single reported record.
SELECT MAX(total_laid_off)
FROM layoffs_staging2;

-- Identify records where 100% of employees were reported as laid off. These records may indicate company closures or complete workforce reductions.
-- The query returns 116 records in which the reported layoff percentage is 100%. The United States has the largest overall layoff total in this dataset.
SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY total_laid_off DESC;

-- Sort 100%-layoff records by reported funding to compare the funding amounts associated with these cases.
-- Britishvolt appears at the top of this funding-sorted result, with reported funding of 2,400 million and 206 employees laid off.
SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;

-- Aggregate reported layoffs by company to identify companies with the highest cumulative totals.
-- Companies with high reported totals include Amazon, Google, Meta, Salesforce, Microsoft, Philips, Ericsson, Uber, Dell, Cisco, Carvana, Twitter, and IBM.
SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

-- Check the date range covered by the dataset. The observed period is 2020-03-11 through 2023-03-06.
SELECT MIN(`date`), MAX(`date`)
FROM layoffs_staging2;

-- Aggregate reported layoffs by industry to compare the industries with the highest totals.
-- In this analysis, Consumer, Retail, Other, Transportation, Finance, Healthcare, and Food are among the industries with the highest reported totals.
SELECT industry, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;

-- Aggregate reported layoffs by country to identify where the largest totals appear in the dataset.
-- The United States has the highest reported total, followed by India, the Netherlands, Sweden, Brazil, Germany, the United Kingdom, and Canada.
SELECT country, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY country
ORDER BY 2 DESC;

-- Compare reported layoffs by year. Note that 2023 is a partial year because the dataset ends on 2023-03-06.
SELECT YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY YEAR(`date`)
ORDER BY 1 DESC;

-- Aggregate reported layoffs by company funding stage. Post-IPO has the highest total in the current dataset.
SELECT stage, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY stage
ORDER BY 2 DESC;

-- Exploratory metric: sum the reported layoff percentages by company. Interpret cautiously because percentages across records are not generally additive.
--
SELECT company, SUM(percentage_laid_off) 
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

-- Calculate a cumulative total of reported layoffs over time.
-- First, calculate the monthly total; then use a window function to calculate the cumulative total.
-- Monthly totals fluctuate over the period; the query below returns one total per month.
-- The following CTE uses these monthly totals to calculate a cumulative sum.
SELECT SUBSTRING(`date`, 1, 7) AS `MONTH`, SUM(total_laid_off) AS layoffs
FROM layoffs_staging2
WHERE SUBSTRING(`date`, 1, 7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1;


-- Calculate a running cumulative total from the monthly layoff totals.
WITH Rolling_Total AS
(
SELECT SUBSTRING(`date`, 1, 7) AS `MONTH`, SUM(total_laid_off) AS layoffs
FROM layoffs_staging2
WHERE SUBSTRING(`date`, 1, 7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1
)
SELECT `MONTH`, layoffs, SUM(layoffs) OVER(ORDER BY `MONTH`) AS rolling_total
FROM Rolling_Total;

-- Aggregate reported layoffs by company and year to identify the largest company-year totals.
/*
Reference query used during the initial analysis:
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
ORDER BY 3 DESC;

This aggregation compares reported layoff totals for each company-year combination.
*/



WITH Company_year (company, years, total_laid_off) AS
(
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
), Company_year_rank  AS
(
SELECT *,
DENSE_RANK() OVER(PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking
FROM Company_year
)
SELECT *
FROM Company_year_rank
WHERE Ranking <= 5 AND years  IS NOT NULL;

/* The result set identifies the five highest-ranked companies for each year. Ties may produce more than five rows per year. */