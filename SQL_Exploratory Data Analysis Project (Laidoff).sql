-- Exploratory Data Analysis (EDA): understand the data by summarizing its main characteristics.

-- Check the progress of the current data cleaning and processing
SELECT *
FROM layoffs2_staging2; -- RUN to view all data in layoffs2_staging2 table

-- Get the maximum values of total_laid_off and percentage_laid_off columns
SELECT MAX(total_laid_off), MAX(percentage_laid_off) -- Find the highest values; for example, one company laid off 12,000 employees
FROM layoffs2_staging2; -- RUN to see the max values in the table

-- Retrieve all rows where percentage_laid_off is 100% (i.e., 1) and sort by total_laid_off
SELECT *
FROM layoffs2_staging2
WHERE percentage_laid_off = 1 -- Find companies that laid off all their employees
ORDER BY total_laid_off DESC; -- Sort the results in descending order by total_laid_off

-- Retrieve rows where percentage_laid_off is 100% and sort by funds_raised_millions
SELECT *
FROM layoffs2_staging2
WHERE percentage_laid_off = 1 -- Companies with 100% layoffs
ORDER BY funds_raised_millions DESC; -- Sort by funds raised in descending order

-- Sum the total_laid_off for each company and sort the results by the second column (total laid off)
SELECT company, SUM(total_laid_off) -- Show each company and the total number of employees laid off
FROM layoffs2_staging2
GROUP BY company -- Group results by company
ORDER BY 2 DESC; -- Sort by total_laid_off (the second column) in descending order

-- Get the earliest and latest dates in the dataset
SELECT MIN(`date`), MAX(`date`)
FROM layoffs2_staging2; -- RUN to see the range of dates in the dataset

-- Sum the total_laid_off for each industry and sort to see which industries were hit hardest
SELECT industry, SUM(total_laid_off) -- Show industry and the total number of employees laid off in each
FROM layoffs2_staging2
GROUP BY industry -- Group results by industry
ORDER BY 2 DESC; -- Sort by total_laid_off (the second column) in descending order

-- Sum the total_laid_off for each country and sort to see which countries were hit hardest
SELECT country, SUM(total_laid_off) -- Show country and the total number of employees laid off in each
FROM layoffs2_staging2
GROUP BY country -- Group results by country
ORDER BY 2 DESC; -- Sort by total_laid_off in descending order

-- Sum the total_laid_off for each year and sort to see the layoffs per year
SELECT YEAR(`date`), SUM(total_laid_off) -- Show the year and the total number of layoffs in that year
FROM layoffs2_staging2
GROUP BY YEAR(`date`) -- Group results by year
ORDER BY 1 DESC; -- Sort by year in descending order

-- Sum the total_laid_off for each company stage and sort to see which stages were hit hardest
SELECT stage, SUM(total_laid_off) -- Show the company stage and the total number of layoffs at each stage
FROM layoffs2_staging2
GROUP BY stage -- Group results by company stage
ORDER BY 1 DESC; -- Sort by stage in descending order

-- Another way to sum the total_laid_off for each company stage and sort by the number of layoffs
SELECT stage, SUM(total_laid_off) -- Show the company stage and the total number of layoffs
FROM layoffs2_staging2
GROUP BY stage -- Group results by stage
ORDER BY 2 DESC; -- Sort by total_laid_off in descending order

-- Calculate the average percentage_laid_off for each company and sort by the highest percentages
SELECT company, AVG(percentage_laid_off) -- Show company and the average percentage laid off
FROM layoffs2_staging2
GROUP BY company -- Group by company
ORDER BY 2 DESC; -- Sort by average percentage_laid_off in descending order

-- Summarize layoffs by month and show the total laid off each month
SELECT SUBSTRING(`date`,1,7) AS `MONTH`, SUM(total_laid_off) -- Extract the year and month, sum the layoffs for each month
FROM layoffs2_staging2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL -- Only include rows where the date is not NULL
GROUP BY `MONTH` -- Group by month
ORDER BY 1 ASC; -- Sort by month in ascending order

-- Calculate the rolling sum of layoffs across months
WITH Rolling_Total AS
(
  SELECT SUBSTRING(`date`,1,7) AS `MONTH`, SUM(total_laid_off) AS total_off -- Calculate monthly layoffs
  FROM layoffs2_staging2
  WHERE SUBSTRING(`date`,1,7) IS NOT NULL -- Ignore NULL dates
  GROUP BY `MONTH` -- Group by month
  ORDER BY 1 ASC -- Sort by month in ascending order
)
SELECT `MONTH`, total_off, SUM(total_off) OVER (ORDER BY `MONTH`) AS rolling_total -- Calculate rolling sum over months
FROM Rolling_Total; -- Get the monthly layoffs and rolling total

-- Calculate the total number of people laid off per company per year
SELECT company, YEAR(`date`), SUM(total_laid_off) -- Show company, year, and total layoffs
FROM layoffs2_staging2
GROUP BY company, YEAR(`date`) -- Group by company and year
ORDER BY company ASC; -- Sort alphabetically by company name

-- Rank the year with the highest layoffs per company
SELECT company, YEAR(`date`), SUM(total_laid_off) -- Show company, year, and total layoffs
FROM layoffs2_staging2
GROUP BY company, YEAR(`date`) -- Group by company and year
ORDER BY 3 DESC; -- Sort by the total number of layoffs in descending order

-- Use CTE to summarize layoffs per company per year
WITH Company_Year (company, years, total_laid_off) AS
(
  SELECT company, YEAR(`date`), SUM(total_laid_off) -- Show company, year, and total layoffs
  FROM layoffs2_staging2
  GROUP BY company, YEAR(`date`) -- Group by company and year
)
SELECT *
FROM Company_Year; -- Select and show the summarized results

-- Rank the layoffs per company per year and show the ranking
WITH Company_Year (company, years, total_laid_off) AS
(
  SELECT company, YEAR(`date`), SUM(total_laid_off) -- Show company, year, and total layoffs
  FROM layoffs2_staging2
  GROUP BY company, YEAR(`date`) -- Group by company and year
)
SELECT *, DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) -- Rank the companies by layoffs each year
FROM Company_Year; -- Show the results with rankings

-- Filter out rows where total_laid_off is NULL and rank the layoffs per company per year
WITH Company_Year (company, years, total_laid_off) AS
(
  SELECT company, YEAR(`date`), SUM(total_laid_off) -- Show company, year, and total layoffs
  FROM layoffs2_staging2
  GROUP BY company, YEAR(`date`) -- Group by company and year
)
SELECT *, DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) -- Rank the companies by layoffs
FROM Company_Year
WHERE total_laid_off IS NOT NULL; -- Only include rows where total_laid_off is not NULL

-- Rank the companies by layoffs per year and sort the results in ascending order by ranking
WITH Company_Year (company, years, total_laid_off) AS
(
  SELECT company, YEAR(`date`), SUM(total_laid_off) -- Show company, year, and total layoffs
  FROM layoffs2_staging2
  GROUP BY company, YEAR(`date`) -- Group by company and year
)
SELECT *, DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking -- Rank the results
FROM Company_Year
WHERE years IS NOT NULL -- Exclude rows where the year is NULL
ORDER BY Ranking ASC; -- Sort by ranking in ascending order

-- Filter the ranking to show the top 5 companies with the highest layoffs per year
WITH Company_Year (company, years, total_laid_off) AS
(
  SELECT company, YEAR(`date`), SUM(total_laid_off) -- Show company, year, and total layoffs
  FROM layoffs2_staging2
  GROUP BY company, YEAR(`date`) -- Group by company and year
), Company_Year_rank AS
(
  SELECT *, DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking -- Rank the companies by layoffs
  FROM Company_Year
  WHERE years IS NOT NULL -- Exclude rows where the year is NULL
)
SELECT *
FROM Company_Year_rank
WHERE Ranking <= 5; -- Only show companies with a ranking of 5 or better

-- Check the progress by viewing the final cleaned dataset
SELECT *
FROM layoffs2_staging2; -- RUN to view the final dataset

-- Final check on the dataset
SELECT *
FROM layoffs2_staging2; -- RUN to view all data in the final cleaned table