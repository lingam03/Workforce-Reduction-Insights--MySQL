--          EXPLORATARY DATA ANALYSIS
-- TARGETS / TASK 
--   1.FIND MAXIMUM TOTAL LAID OFF AND PERCETAGE LAID OFF
--   2.FIND LAID OFF START AND END DATA FROM DATASET MONTLY AND YEARLY
--   3.FIND SUM OF TOTAL LAID OFF BASED ON COMPANY,INDUSTRY
--   4.FIND MONTLY AND YEARLY WISE ADD ASCENDING OR DECSENDING TOO
--   5.TRY TO APPLY ROLL BACK TOO
--   6.RANK THE COMPANY OR INDUSRT BASED ON TOTAL LAID OFF BY YEARLY OR MONTLY


SELECT *
FROM layoffs_staging2;

SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_staging2;

SELECT MIN(`date`), MAX(`date`)
FROM layoffs_staging2;

SELECT company,industry,SUM(total_laid_off) as sum_off
FROM layoffs_staging2
GROUP BY company,industry
ORDER BY 3 DESC ;

SELECT SUBSTRING(`date`,1,7) as sub, SUM(total_laid_off)   #here in sub column null will be appered too
FROM layoffs_staging2
GROUP BY sub 
;
 
SELECT SUBSTRING(`date`,1,7) as sub , SUM(total_laid_off)   #here in sub column null will not be appered 
FROM layoffs_staging2                               # in where clause always use orginal lable from select line
WHERE SUBSTRING(`date`,1,7)  IS NOT NULL
GROUP BY sub
order by 2 desc ;

WITH ROLL_TOTAL AS
(
SELECT SUBSTRING(`date`,1,7) as sub , SUM(total_laid_off) as total_off  
FROM layoffs_staging2                              
WHERE SUBSTRING(`date`,1,7)  IS NOT NULL
GROUP BY sub
order by 2 desc
)
SELECT sub,total_off, 
SUM(total_off) over( ORDER BY sub) AS rolling_total
FROM ROLL_TOTAL
 ;

SELECT company,year(`date`) , SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company,year(`date`)
order by 3 desc;

WITH Company_Year(company,year,total_laid_off) AS
(
SELECT company,year(`date`) , SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company,year(`date`)
), Company_Year_Rank AS(
SELECT * ,
DENSE_RANK() OVER(PARTITION BY year ORDER BY total_laid_off desc) as ranking
FROM Company_Year
WHERE year is not null)
SELECT * 
FROM Company_Year_Rank
WHERE ranking <=5                    #( option line)
;

SELECT *
FROM layoffs_staging2;


--                 EXPLORATORY DATA ANALYSIS COMPLETED  




