select * from layoffs_staging2;

select max(total_laid_off), max(percentage_laid_off)
from layoffs_staging2; -- 1 means 100 in the result

select * from 
layoffs_staging2
where percentage_laid_off =1
order by total_laid_off desc
;

select * from 
layoffs_staging2
where percentage_laid_off =1
order by funds_raised_millions desc
;

select company, sum(total_laid_off)
from layoffs_staging2
group by company
order by 2 desc;

 select min(`date`) , max(`date`)
 from layoffs_staging2;
 
 select industry, sum(total_laid_off)
from layoffs_staging2
group by industry
order by 2 desc;

select country, sum(total_laid_off)
from layoffs_staging2
group by country
order by 2 desc;

select `date`, sum(total_laid_off)
from layoffs_staging2
group by`date`
order by 1 desc;

select stage, sum(total_laid_off)
from layoffs_staging2
group by stage
order by 2 desc;


select year(`date`), sum(total_laid_off)
from layoffs_staging2
group by year(`date`)
order by 2 desc;

select company, sum(percentage_laid_off)
from layoffs_staging2
group by company
order by 2 desc;

select company, avg(percentage_laid_off)
from layoffs_staging2
group by company
order by 2 desc;

select substring(`date`,6,2) as month  -- we use 6 because we wanted to use 6th position from date which is 0 in 1st row and we add two because we need only 2 chracters which is 07 in 1st row.
 from layoffs_staging2;
 
 select substring(`date`,6,2) as month , sum(total_laid_off)
 from layoffs_staging2
 group by substring(`date` ,6,2) ;
 
 select * from layoffs_staging2;
 
 select substring(`date`,1,7) as month , sum(total_laid_off)
 from layoffs_staging2
 where substring(`date`,1,7) is not null
 group by substring(`date` ,1,7)
 order by 1 asc
 ;
 
 select * from layoffs_staging2;
 
 with rolling_total as
 (
 select substring(`date`,1,7) as `month` , sum(total_laid_off) as total_off
 from layoffs_staging2
 where substring(`date`,1,7) is not null
 group by `month`
 order by 1 asc
 )
 select `month`, total_off,
 sum(total_off) over(order by  `month`) as rolling_total
 from rolling_total;  -- First SUM: Calculates the total layoffs for each individual month.
-- GROUP BY month ensures that layoffs are grouped month-wise.

-- Second SUM: Adds the monthly totals progressively to calculate
-- the cumulative layoffs from the first month up to the current month.
-- OVER(ORDER BY month) ensures the calculation follows chronological order.


select company, year(`date`), sum(total_laid_off)
from layoffs_staging2
group by company, year(`date`);

with company_year( company,years,total_laid_off) as 
(
select company, year(`date`), sum(total_laid_off)
from layoffs_staging2
group by company, year(`date`)
)
select *, dense_rank() over ( partition by years order by total_laid_off desc) as ranking  -- DENSE_RANK() assigns a rank to each company based on total layoffs. -- PARTITION BY years restarts the ranking for each year.
-- ORDER BY total_laid_off DESC ranks companies from highest to lowest layoffs.
-- DENSE_RANK() does not skip rank numbers when companies have equal layoffs.
from company_year
where year is not null
order by ranking asc; 

with company_year( company,years,total_laid_off) as 
(
select company, year(`date`), sum(total_laid_off)
from layoffs_staging2
group by company, year(`date`)
), company_year_rank as
(select *,
 dense_rank() over ( partition by years order by total_laid_off desc) as ranking  
from company_year
where years is not null
)
select * from company_year_rank 
where ranking <=5;
 