----- FOR THE SQL DATA CLEANING PROJECT -----

The SQL code provided outlines a detailed data cleaning process for a layoff dataset (contains details of companies and number of employees laidoff within some years), aimed at preparing the data for further analysis. Here’s a summary of the key steps involved:

	1.	Initial Setup and Staging:
	•	A new staging table (layoffs2_staging) is created as a copy of the original layoffs2 table. This table is used to avoid directly modifying the raw data.
	2.	Duplicate Removal:
	•	The code checks for duplicate rows based on fields like company, location, industry, total_laid_off, percentage_laid_off, and others. Duplicates are identified using ROW_NUMBER() to partition data by these fields and mark duplicates.
	•	After identifying duplicates, the code deletes the duplicate rows, ensuring only one instance of each unique record remains.
	3.	Data Standardization:
	•	Company Names: Leading and trailing spaces in company names are removed using the TRIM() function.
	•	Industry Names: Inconsistent industry names (e.g., variations of “Crypto”) are standardized to a single format.
	•	Country Names: Variations of country names like “United States” and “United States.” are corrected by removing trailing periods.
	4.	Date Handling:
	•	Dates stored as text are converted to a proper date format using the STR_TO_DATE() function, and the data type of the date column is changed to DATE.
	5.	Null Value Handling:
	•	Rows with missing or null values in important fields (like total_laid_off and percentage_laid_off) are handled. Rows where both of these fields are null are deleted, as they do not provide useful information.
	•	Missing industry values are updated by looking for other records with the same company name but non-null industry data.
	6.	Final Cleanup:
	•	After data transformations and cleaning, unnecessary columns such as the row_num (used to track duplicates) are dropped from the table.
	•	The final cleaned dataset is reviewed to ensure it is free from duplicates, formatting inconsistencies, and irrelevant or null data.

The process involves creating and working on staging tables, checking for duplicates, correcting inconsistent data, handling nulls, and ensuring the dataset is cleaned and properly structured for analysis.


----- FOR SQL EXPLORATORY DATA ANALYSIS (EDA) ON A LAYOFF DATASET -----

The SQL code you provided is designed to perform Exploratory Data Analysis (EDA) on a layoff dataset that has already gone through the data cleaning process. The goal is to summarize the dataset and gain insights into the layoff patterns across different companies, industries, and time periods. Here’s a summary of the key actions performed:

1. Basic Data Inspection:

	•	The code starts by viewing the data in the cleaned table (layoffs2_staging2) to check the overall progress.

2. Maximum Values:

	•	It retrieves the maximum values of total_laid_off and percentage_laid_off to understand the highest number of layoffs and the companies that laid off 100% of their employees.

3. Detailed Queries:

	•	The dataset is queried to:
	•	List companies that laid off all employees (percentage_laid_off = 100%), sorted by total_laid_off and funds_raised_millions.
	•	Summarize total layoffs by company, industry, country, and year to understand which companies, industries, and countries were affected most and during what time periods.
	•	Identify company stages (e.g., early, growth) and calculate how layoffs impacted companies at different stages.

4. Date Range and Layoff Trends:

	•	The code extracts the earliest and latest dates in the dataset to understand the time span of the layoffs.
	•	It groups layoffs by month and calculates a rolling sum of layoffs over time, allowing the detection of any time-based trends in layoffs.

5. Company-Specific Analysis:

	•	It calculates the total number of layoffs per company for each year and ranks the years with the highest layoffs for each company.
	•	It uses DENSE_RANK() to rank companies by layoffs for each year and filters the dataset to show the top 5 companies with the highest layoffs per year.

6. Aggregating and Ranking:

	•	Layoffs are summarized and ranked using Common Table Expressions (CTEs) to create rankings by company and year. The dataset is filtered to exclude records with NULL values, ensuring only relevant data is included in the analysis.

7. Final Data Review:

	•	The final dataset is reviewed after all the queries and transformations to ensure the cleaned and summarized data is ready for further analysis or reporting.

Key Insights Derived:

	•	The maximum number of layoffs and the percentage of layoffs per company.
	•	Layoff trends across different industries, countries, and time periods.
	•	The identification of companies and sectors most severely impacted by layoffs.
	•	Ranking of companies by layoffs per year, along with trends over time.

This EDA process helps to uncover patterns and provides valuable summaries for understanding the layoff trends across various dimensions in the dataset.


----- FOR THE EXCEL PROJECT ON DASHBOARD CREATION TO ANALYZE BIKE SALES -----
The dashboard is designed to provide insights into:

	1.	Customer Profiles: Understanding the demographics of customers who purchased bikes, such as marital status, income, and region.
	2.	Purchase Behavior: Analyzing the relationship between factors like income, age, education, and bike purchases.
	3.	Regional Insights: Visualizing how bike purchases vary across different regions.
	4.	Commute Patterns: Correlating commute distance and car ownership with the likelihood of purchasing a bike.

----- FOR TABLEAU AIRBNB PROJECT -----
Open the AirBnB Project 2024.twbx file with Tableau Reader software to interact with visualizations built with Tableau.
