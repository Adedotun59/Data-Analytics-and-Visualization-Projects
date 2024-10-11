-- Data Cleaning Process (564 records vs 2500 recs)
-- Create a new database, and click on Schema to import the new layoff database, 
-- then double-click 'world_layoffs'.

-- 1. Remove duplicates
-- 2. Standardize the data (correct spellings, formats)
-- 3. Handle null values or blanks
-- 4. Remove unnecessary rows and columns, e.g., blank or irrelevant ones

-- Selecting all data from the layoffs2 table to review its content
SELECT * 
FROM layoffs2; -- Highlight this and RUN

-- Creating a staging table to work on a copy of the data. Do not work on raw data directly.
CREATE TABLE layoffs2_staging 
LIKE layoffs2; -- RUN to create an exact copy (structure only) of layoffs2

-- Copying the data from layoffs2 into layoffs2_staging.
INSERT INTO layoffs2_staging 
SELECT * 
FROM layoffs2; -- RUN to insert the data

-- Checking for duplicate records based on specific fields (company, industry, etc.)
SELECT *, 
ROW_NUMBER() OVER (
  PARTITION BY company, industry, total_laid_off, percentage_laid_off, `date`
) AS row_num -- Generates a row number for each partition, to identify duplicates
FROM layoffs2_staging; -- RUN to generate row numbers to identify duplicates

-- Creating a Common Table Expression (CTE) to find duplicate rows
WITH duplicate_cte AS (
  SELECT *, 
  ROW_NUMBER() OVER (
    PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions
  ) AS row_num -- Generates row numbers within the partitions, so duplicates can be found
  FROM layoffs2_staging
)
SELECT * 
FROM duplicate_cte
WHERE row_num > 1; -- RUN to show duplicate records (row_num > 1 means it's a duplicate)

-- Checking for specific duplicate companies, like 'Oyster', to review the data
SELECT * 
FROM layoffs2_staging
WHERE company = 'Oyster'; -- RUN to check all entries for 'Oyster'

-- Now, let's delete the duplicate records identified using the CTE
WITH duplicate_cte AS (
  SELECT *, 
  ROW_NUMBER() OVER (
    PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions
  ) AS row_num -- Generates row numbers for partitioned duplicates
  FROM layoffs2_staging
)
DELETE 
FROM duplicate_cte 
WHERE row_num > 1; -- RUN to delete duplicates

-- Creating a new staging table for further data manipulation
CREATE TABLE `layoffs2_staging2` ( 
  `company` text, -- Company name
  `location` text, -- Location of the company
  `industry` text, -- Industry the company belongs to
  `total_laid_off` int DEFAULT NULL, -- Total employees laid off
  `percentage_laid_off` text, -- Percentage of employees laid off
  `date` text, -- Date of the layoffs (will convert later)
  `stage` text, -- Company stage (early, growth, etc.)
  `country` text, -- Country of the company
  `funds_raised_millions` int DEFAULT NULL, -- Funds raised by the company (in millions)
  `row_num` INT -- Row number used to track duplicates
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci; -- Creating the table structure for layoffs2_staging2

-- Selecting all data from the new layoffs2_staging2 table
SELECT * 
FROM layoffs2_staging2; -- RUN to check the data in layoffs2_staging2

-- Inserting data with row numbers into layoffs2_staging2 from layoffs2_staging
INSERT INTO layoffs2_staging2 
SELECT *, 
ROW_NUMBER() OVER (
  PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions
) AS row_num -- Generates row numbers to identify duplicates
FROM layoffs2_staging; -- RUN to insert data into layoffs2_staging2

-- Deleting duplicate rows from layoffs2_staging2
DELETE 
FROM layoffs2_staging2 
WHERE row_num > 1; -- RUN to delete duplicate rows

-- Standardizing company names by trimming white spaces from the company field
SELECT company, TRIM(company) -- Shows company names with leading/trailing spaces removed
FROM layoffs2_staging2; -- RUN to check which company names have spaces

-- Updating company names in the table to remove leading/trailing spaces
UPDATE layoffs2_staging2 
SET company = TRIM(company); -- RUN to remove spaces from company names

-- Viewing distinct industries to check for inconsistent entries
SELECT DISTINCT industry 
FROM layoffs2_staging2 
ORDER BY 1; -- RUN to display distinct industry names, sorted alphabetically

-- Checking inconsistent industry names like 'Crypto' and 'Cryptocurrency'
SELECT * 
FROM layoffs2_staging2 
WHERE industry LIKE 'Crypto%'; -- RUN to view all rows with industry names starting with 'Crypto'

-- Standardizing all variations of 'Crypto' into a single value
UPDATE layoffs2_staging2 
SET industry = 'Crypto' 
WHERE industry LIKE 'Crypto%'; -- RUN to update all instances of 'Crypto%' to 'Crypto'

-- Checking distinct country names for inconsistencies
SELECT DISTINCT country 
FROM layoffs2_staging2 
ORDER BY 1; -- RUN to view distinct country names, sorted alphabetically

-- Finding and fixing inconsistent country names, like 'United States' vs 'United States.'
SELECT * 
FROM layoffs2_staging2 
WHERE country LIKE 'United States%'; -- RUN to view all variations of 'United States'

-- Removing trailing periods from country names
SELECT DISTINCT country, TRIM(TRAILING '.' FROM country) 
FROM layoffs2_staging2 
ORDER BY 1; -- RUN to check if the trailing periods have been fixed

-- Updating country names to remove trailing periods
UPDATE layoffs2_staging2 
SET country = TRIM(TRAILING '.' FROM country) 
WHERE country LIKE 'United States%'; -- RUN to update the country names

-- Checking and fixing date formats, converting text dates into proper date formats
SELECT `date`, STR_TO_DATE(`date`, '%m/%d/%Y') -- Converts text dates to actual date format
FROM layoffs2_staging2; -- RUN to preview the date conversion

-- Updating the date column to store actual date values
UPDATE layoffs2_staging2 
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y'); -- RUN to apply the date format conversion

-- Changing the data type of the date column from text to DATE type
ALTER TABLE layoffs2_staging2 
MODIFY COLUMN `date` DATE; -- RUN to modify the column's data type to DATE

-- Checking for NULL values in the 'total_laid_off' column
SELECT * 
FROM layoffs2_staging2 
WHERE total_laid_off IS NULL; -- RUN to view all rows with NULL in the 'total_laid_off' column

-- Checking for rows where both 'total_laid_off' and 'percentage_laid_off' are NULL
SELECT * 
FROM layoffs2_staging2 
WHERE total_laid_off IS NULL 
AND percentage_laid_off IS NULL; -- RUN to view rows with NULL in both columns

-- Updating the industry column to replace blank values with NULL
UPDATE layoffs2_staging2 
SET industry = NULL 
WHERE industry = ''; -- RUN to replace blank industry fields with NULL

-- Checking rows with NULL or blank values in the industry column
SELECT * 
FROM layoffs2_staging2 
WHERE industry IS NULL 
OR industry = ''; -- RUN to view rows where the industry column is NULL or blank

-- Checking company 'Airbnb' to populate missing industry data (e.g., should be 'Travel')
SELECT * 
FROM layoffs2_staging2 
WHERE company = 'Airbnb'; -- RUN to view all rows for 'Airbnb'

-- Finding rows with missing industry data and using other rows to fill it in
SELECT t1.industry, t1.industry 
FROM layoffs2_staging2 t1 
JOIN layoffs2_staging2 t2 
  ON t1.company = t2.company 
WHERE (t1.industry IS NULL OR t1.industry = '') 
AND t2.industry IS NOT NULL; -- RUN to find rows with missing industry values and match them to populated ones

-- Updating the industry values using the found matches
UPDATE layoffs2_staging2 t1 
JOIN layoffs2_staging2 t2 
  ON t1.company = t2.company 
SET t1.company = t2.company 
WHERE t1.industry IS NULL 
AND t2.industry IS NOT NULL; -- RUN to update missing industry values

-- Selecting all rows where 'total_laid_off' and 'percentage_laid_off' are NULL to clean the data
SELECT * 
FROM layoffs2_staging2 
WHERE total_laid_off IS NULL 
AND percentage_laid_off IS NULL; -- RUN to view rows where both fields are NULL

-- Deleting rows where both 'total_laid_off' and 'percentage_laid_off' are NULL
DELETE 
FROM layoffs2_staging2 
WHERE total_laid_off IS NULL 
AND percentage_laid_off IS NULL; -- RUN to delete those rows

-- Checking the remaining data after deletion
SELECT * 
FROM layoffs2_staging2; -- RUN to see the final cleaned dataset

-- Dropping the 'row_num' column since it's no longer needed
ALTER TABLE layoffs2_staging2 
DROP COLUMN row_num; -- RUN to remove the 'row_num' column

-- Checking the final cleaned dataset
SELECT * 
FROM layoffs2_staging2; -- RUN to view the cleaned data