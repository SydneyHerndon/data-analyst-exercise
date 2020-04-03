-- For years 2004 through 2012, calculate the median GDP Per Capita for every continent for every year. The median in this case is defined as The value at which half of the samples for a continent are higher and half are lower

-- The final product should include columns for:
-- Year
-- Continent
-- Median GDP Per Capita

-- Averages 
Select  distinct year,  continent_name, round(avg(gdp_per_capita) over(partition by year, continent_name order by year, continent_name)) as avg_gdp
from country_gdp 
left join continent_map cm on cm.country_code = country_gdp.country_code
left join continents cn on cn.continent_code = cm.continent_code
where continent_name is not null 
order by year, continent_name; -- excluding null continents 

--- taking average of all gdp, not considering year or continent.
with test as (
    select 
        gdp_per_capita, 
        row_number() over (order by gdp_per_capita) as row_id,
        (select count(1) from (select year, continent_name, gdp_per_capita
                            from country_gdp 
                            left join continent_map cm on cm.country_code = country_gdp.country_code
                            left join continents cn on cn.continent_code = cm.continent_code
                            where continent_name is not null ) all_gdp ) as ct
    From (
            select year, continent_name, gdp_per_capita
            from country_gdp 
            left join continent_map cm on cm.country_code = country_gdp.country_code
            left join continents cn on cn.continent_code = cm.continent_code
            where continent_name is not null 
        ) all_gdp
)

select avg(gdp_per_capita) as median
from test
where row_id between ct/2.0 and ct/2.0 + 1;

-- Partitioning by Year/Continent
with test as (
    select 
        year, 
        continent_name, 
        gdp_per_capita, 
        row_number() over (partition by year, continent_name order by gdp_per_capita) as row_id,
        count(*) over (partition by year, continent_name) as ct
    From (
            select year, continent_name, gdp_per_capita
            from country_gdp 
            left join continent_map cm on cm.country_code = country_gdp.country_code
            left join continents cn on cn.continent_code = cm.continent_code
            where continent_name is
            not null 
        ) all_gdp
)

select  year, continent_name, avg(gdp_per_capita) as median
from test
where row_id between ct/2.0 and ct/2.0 + 1 
group by year, continent_name;

