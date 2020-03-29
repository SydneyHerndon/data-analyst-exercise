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
