-- List the Top 10 Countries by year over year % GDP per capita growth between 2011 & 2012.
-- % year over year growth is defined as (GDP Per Capita in 2012 - GDP Per Capita in 2011) / (GDP Per Capita in 2011)

-- The final product should include columns for:

-- Rank
-- Country Name
-- Country Code
-- Continent
-- Growth Percent

CREATE EXTENSION IF NOT EXISTS tablefunc;

-- Getting gdp for year 2011/2012
select country_code, year, gdp_per_capita 
from country_gdp 
where year = 2011 or year = 2012;

-- pivoting 
Select * 
from crosstab(
    'select country_code, year, gdp_per_capita 
     from country_gdp 
     where year = 2011 or year = 2012
     order by 1,2
     ') as results("country_code" varchar(5), "2011" numeric, "2012" numeric);

-- Calculating GDP YoY
Select * , Case when "2011" != 0 then round((("2012"/"2011")-1) * 100, 0) else Null end as YoY_gdp
From 
(Select country_code , COALESCE("2011", 0) as "2011",  COALESCE("2012", 0) as "2012"
from crosstab(
    'select country_code, year, gdp_per_capita 
     from country_gdp 
     where year = 2011 or year = 2012
     order by 1,2
     ') as results("country_code" varchar(5), "2011" numeric, "2012" numeric)) yoy
where Case when "2011" != 0 then round((("2012"/"2011")-1) * 100, 0) else Null end is not null 
order by Case when "2011" != 0 then round((("2012"/"2011")-1) * 100, 0) else Null end desc
limit 10;

--- Adding in Country Name and Country Code 
-- checking joins 
Select c.country_name, cont.continent_name, yoy.country_code
from country_gdp as yoy
left join countries c on  c.country_code = yoy.country_code
left join continent_map cm on cm.country_code = yoy.country_code
left join continents cont on cont.continent_code = cm.continent_code;

--Putting it together 
Select c.country_name, yoy.country_code, cont.continent_name , 
       Case when "2011" != 0 then round((("2012"/"2011")-1) * 100, 0) else Null end as growth_percent
From (
    Select country_code , COALESCE("2011", 0) as "2011",  COALESCE("2012", 0) as "2012"
    from crosstab(
        'select country_code, year, gdp_per_capita 
        from country_gdp 
        where year = 2011 or year = 2012
        order by 1,2
        ') as results("country_code" varchar(5), "2011" numeric, "2012" numeric)) yoy
left join countries c on  c.country_code = yoy.country_code
left join continent_map cm on cm.country_code = yoy.country_code
left join continents cont on cont.continent_code = cm.continent_code
where Case when "2011" != 0 then round((("2012"/"2011")-1) * 100, 0) else Null end is not null 
order by Case when "2011" != 0 then round((("2012"/"2011")-1) * 100, 0) else Null end desc
limit 10;

-- Ranking  
Select Rank() over (order by Case when "2011" != 0 then round((("2012"/"2011")-1) * 100, 0) else Null end desc) rank ,
       c.country_name, yoy.country_code, cont.continent_name, 
       Case when "2011" != 0 then round((("2012"/"2011")-1) * 100, 0) else Null end as growth_percent
From (
    Select country_code , COALESCE("2011", 0) as "2011",  COALESCE("2012", 0) as "2012"
    from crosstab(
        'select country_code, year, gdp_per_capita 
        from country_gdp 
        where year = 2011 or year = 2012
        order by 1,2
        ') as results("country_code" varchar(5), "2011" numeric, "2012" numeric)) yoy
left join countries c on  c.country_code = yoy.country_code
left join continent_map cm on cm.country_code = yoy.country_code
left join continents cont on cont.continent_code = cm.continent_code
where Case when "2011" != 0 then round((("2012"/"2011")-1) * 100, 0) else Null end is not null 
order by Case when "2011" != 0 then round((("2012"/"2011")-1) * 100, 0) else Null end desc
limit 10;