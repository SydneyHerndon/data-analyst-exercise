-- Alphabetically list all the country codes in the continent map table that appear more than once.
select country_code , count(*)
from continent_map
group by country_code
having count(*) > 1
order by country_code;

-- For countries with no country code make them display as "N/A" and display them first in the list.
select COALESCE(country_code, 'N/A'), count(*)
from continent_map
where country_code is null
group by country_code;

-- Combining together
select COALESCE(country_code, 'N/A'), count(*)
from continent_map
group by country_code
having count(*) > 1
order by country_code;

-- Getting N/A to display first 
select COALESCE(country_code, 'N/A') as country_code, count(*)
from continent_map
group by country_code
having count(*) > 1
ORDER BY case when COALESCE(country_code, 'N/A')  = 'N/A' then 1 else 2 end, country_code; 

-- It is unclear whether the output needs the count of country codes. 
-- Here is an option if you only want the names. 
select COALESCE(country_code, 'N/A') as country_code
from continent_map
group by country_code
having count(*) > 1
ORDER BY case when COALESCE(country_code, 'N/A')  = 'N/A' then 1 
         else 2
         end, 
         country_code; 