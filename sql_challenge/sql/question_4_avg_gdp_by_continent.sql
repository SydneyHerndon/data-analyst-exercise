-- For years 2004 through 2012, calculate the average GDP Per Capita for every continent for every year. 
-- The average in this case is defined as the Sum of GDP Per Capita for All Countries in the Continent / Number of Countries in the Continent
-- The final product should include columns for:
-- Year
-- Continent
-- Average GDP Per Capita

Select  distinct year,  continent_name, avg(gdp_per_capita) over(partition by year, continent_name order by year, continent_name) as avg_gdp
from country_gdp 
left join continent_map cm on cm.country_code = country_gdp.country_code
left join continents cn on cn.continent_code = cm.continent_code
where continent_name is not null 
order by year, continent_name; -- excluding null continents 