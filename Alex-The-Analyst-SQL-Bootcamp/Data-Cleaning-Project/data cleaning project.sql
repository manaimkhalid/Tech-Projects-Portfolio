-- data cleaning

select * from layoffs;

-- 1. remove duplicates.
-- 2. standardize the data.
-- 3. Null values or blank values.alter
-- 4. Remove Any columns ( which are irrelevant )

create table layoffs_staging -- 45 years old
like layoffs;

select * from layoffs_staging; -- it has all columns of layoffs

insert layoffs_staging
select * from layoffs;

select *,
row_number() over(
partition by company, industry, total_laid_off, percentage_laid_off, `date`) as row_num
 from layoffs_staging; -- it is supposed to return 2 or 3 as row number if they have same combination of rows but there is no same combo si it returns as 1 to all rows -

with duplicate_cte as 
(
select *,
row_number() over(
partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country , funds_raised_millions) as row_num
 from layoffs_staging )
 select * 
 from duplicate_cte 
 where row_num >1;
 
 select * from 
 layoffs_staging
 where company = 'Casper'; -- that's exact duplicate row
 
 with duplicate_cte as 
(
select *,
row_number() over(
partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country , funds_raised_millions) as row_num
 from layoffs_staging )
delete
 from duplicate_cte 
 where row_num >1; -- that direct deleteion is not working so we are creating a new table from layoff_staging
 
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

select * from layoffs_staging2;

insert into layoffs_staging2
select *,
row_number() over(
partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, 
stage, country , funds_raised_millions) as row_num
 from layoffs_staging ;

 delete 
 from layoffs_staging2
 where row_num > 
 1;
 
 select *
 from layoffs_staging2
 where row_num > 1 ;
 
 -- standardizing data
 
 select distinct(company)
 from layoffs_staging2; 
 
 select company, TRIM(company)
 from layoffs_staging2;
 
 update layoffs_staging2
 set company = trim(company) ; -- trim just remove the white spaces
 
 select distinct industry 
 from layoffs_staging2
 order by 1; -- cryptocurrency and crypto currency are same w ehave to remove that 
 
 select * from layoffs_staging2
 where industry like 'crypto%';
 
 update layoffs_staging2
 set industry = 'crypto' 
 where industry like 'crypto%';
 
 select distinct industry
  from layoffs_staging2
  order by 1;
  
  select distinct location from layoffs_staging2 
  order by 1;
  
  select distinct country from layoffs_staging2 
  order by 1;
  
   select * from layoffs_staging2 
   where country like 'United States%'
  order by 1;
  
  select distinct country, trim(trailing '.' from country) -- it removed the . after united states
  from layoffs_staging2 
  order by 1;
 
 update layoffs_staging2 
 set country = trim(trailing '.' from country)
 where country like ' United States%';
 
 select `date`
  from layoffs_staging2 ;
  
SET SQL_SAFE_UPDATES = 0;
UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');
SELECT `date`
FROM layoffs_staging2
LIMIT 10;
SET SQL_SAFE_UPDATES = 1;

alter table layoffs_staging2
modify column `date` date;  -- this will change date's type from text to date  

select * from layoffs_staging2
where total_laid_off is null
and percentage_laid_off is null;

select * from 
layoffs_staging2
where industry is null 
or industry = '';

select * 
from layoffs_staging2
where company = 'airbnb';-- indusrtry and perc laid offf both are null here
  
SELECT t1.company, t1.industry, t2.industry
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
    ON t1.company = t2.company
WHERE (t1.industry IS NULL OR t1.industry = '')
  AND t2.industry IS NOT NULL
  AND t2.industry <> '';    -- <> this shows not equal to....- '' represents an empty string. So, this condition means: only include rows where t2.industry is not empty.We use it because IS NOT NULL alone doesn't exclude empty strings. An empty string is different from NULL in SQL.

SET SQL_SAFE_UPDATES = 0;
update layoffs_staging2 t1
join layoffs_staging2 t2
	on t1.company = t2.company
set t1.industry = t2.industry
where (t1.industry IS NULL OR t1.industry = '')
  AND t2.industry IS NOT NULL
  AND t2.industry <> '';
  SET SQL_SAFE_UPDATES = 1;

  select * 
from layoffs_staging2
where company like 'Bally%';

select * from layoffs_staging2 
where total_laid_off is null 
and percentage_laid_off is null;

SET SQL_SAFE_UPDATES = 0;
delete from layoffs_staging2 
where total_laid_off is null 
and percentage_laid_off is null;
 SET SQL_SAFE_UPDATES = 1;

SET SQL_SAFE_UPDATES = 0;
alter table layoffs_staging2
drop column row_num;
SET SQL_SAFE_UPDATES = 1;
