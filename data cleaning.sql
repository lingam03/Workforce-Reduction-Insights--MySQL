                                           --         DATA CLEANING          --

-- NOTE 
-- 1. HERE FIRST WE HAVE RAW DB (layoffs)
-- 2. NEXT WE ARE COPYING RAW TO NEW DB(layoffs_staging)
-- 3. TO FIND MULTIPLE COUNT OF DATA WE CREATED "CTE'S " DUPLICATE DB TABLE and CTE'S ARE AN tempory table ( non-pysical table) 
--    and in " CTE " we can not delete the data but we can use "drop" option
-- 4. "layoffs_staging2 " table helps to delete duplicate or multiple data 

# Raw database

SELECT *
FROM layoffs;

# Creating an COPY / DUPLICATE DATABASE similar to the raw database...

CREATE TABLE layoffs_staging
LIKE layoffs;

# TO check the new copy database and this show all column heading...

SELECT *
FROM layoffs_staging;

# NOW we are inserting all THE data from raw to new COPY/DUPLICATE 

INSERT layoffs_staging
SELECT *
FROM layoffs;

                               --            REMOVING DUPLICATES         --


# Assign row numbers to avoid multpil data repeting by using ROW_NUMBER() and OVER() is used to mention on what data we want to applying with patition method

SELECT *,
ROW_NUMBER() OVER(
PARTITION BY  company, industry, total_laid_off, percentage_laid_off, `date`, stage, funds_raised_millions)
AS row_num
FROM layoffs_staging;


# HERE we create an " CTE's "  table to store and finding row-num > 1 in duplicate_cte

WITH duplicate_cte AS (
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY  company, industry, total_laid_off, percentage_laid_off, `date`, stage, funds_raised_millions
)
AS row_num
FROM layoffs_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;

# To check company that repeated

SELECT *
FROM layoffs_staging
WHERE company = 'Yahoo';

# layoffs_staging -> send clipboard -> create statement
# this help us to delete duplicates from the table
# remember remove "delete' from code 

CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


#now check "ls2"

SELECT *
FROM layoffs_staging2
;

# Now insert all data into ls2 file from ls

INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY  company, industry, total_laid_off, percentage_laid_off, `date`, stage, funds_raised_millions
)
AS row_num
FROM layoffs_staging;

#check table

SELECT * 
FROM layoffs_staging2
WHERE row_num >1;


# NOTE : here we are seting sql safe update disable(0)
SET SQL_SAFE_UPDATES = 0;


#now remove or delete it

DELETE 
FROM layoffs_staging2
WHERE row_num > 1;

# now check does duplicate removed or not 

SELECT * 
FROM layoffs_staging2;

# It's an optional to set sql safe update to enable
SET SQL_SAFE_UPDATES = 1;

                                  --       DUPLICATE REMOVING IS completed           --
                                  
                                  --                STANDING DATA                    --
                                  
# Stadizing DATA:  In simple fixing issues in it...

# Here we now update database and trim it to remove white space in it on specific column

SELECT *
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET company = TRIM(company);

# Now we are order in alphabetical order with distinct data and here we can order in company based order

SELECT DISTINCT *
FROM layoffs_staging2
ORDER BY 1;

# It's time to change similar laables from database
# Here we can check any column based but better understanding we need to check all databased cloumn too sometimes

SELECT *
FROM layoffs_staging2
WHERE industry LIKE '%Crypto% ';  # Zero data found

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%,CroptoCurrency';    # Here we changed crypto names completly into only crypto

# If " . " present we will remove it from data 

SELECT DISTINCT country ,                                  #here we found few country with "luxembo..." after this query it is " luxembo" only
TRIM(TRAILING '.' FROM country)  as new_country               #TRAILING helps to remove "." from database
FROM layoffs_staging2 
ORDER BY 1;        


#now edit "usa" too and update it

UPDATE layoffs_staging2
SET country = TRIM(TRAILING "." FROM country)
WHERE country LIKE ' United States%';

Select *
from layoffs_staging2;

# Now change "date " into "date" form
# Date form is  " %m/%d/%Y "
# we can use below sql query

/*
select `date`,
STR_TO_DATE(`date`, '%m/%d/%Y')
from layoffs_staging2;
*/


SELECT `date`
FROM layoffs_staging2;

#THIS QUERY CHNAGE THE `date` into  DATE FORMAT

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

--            STANDARDIZING OF DATA COMPLETED  

--            NULL AND BLANK FIXING 

# TO CHECK NULL AND BLACK IN DATA

SELECT *
FROM layoffs_staging2
WHERE  total_laid_off is null and percentage_laid_off IS NULL
;

SELECT *
FROM layoffs_staging2
WHERE industry IS NULL OR industry = ' ' ;

#for specific industry or company

SELECT * 
FROM layoffs_staging2
WHERE company='Airbnd';

# to check and verify 
SELECT *
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
	on t1.company = t2.company
where (t1.industry is null or t1.industry = ' ')
and t2.industry is not null;

#on above query we can say that there is no null in company of t1 and t2

#now change blankspace in null

UPDATE layoffs_staging2
set industry = null
WHERE industry = ' ';

#to complete the null and black check process

SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS null
AND percentage_laid_off is null;

DELETE 
FROM layoffs_staging2
WHERE total_laid_off is null
AND percentage_laid_off is null;

SELECT*
FROM layoffs_staging2;

# to remove unneccessary colun or rows

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

# TO COMPLETE DATA check table

SELECT MAX(`date`) , min(`date`)
FROM layoffs_staging2;

SELECT *
FROM layoffs_staging2;

--               SUCCESSFULLY DATA CLEANING IS COMPLETED 




