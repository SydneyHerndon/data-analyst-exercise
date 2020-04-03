-- This is where the concise answers can be find. See the question specfic files for how I approached it/broke each part down. 

-- Question 1
select COALESCE(country_code, 'N/A') as country_code
from continent_map
group by country_code
having count(*) > 1
ORDER BY case when COALESCE(country_code, 'N/A')  = 'N/A' then 1 
         else 2
         end, 
         country_code; 

-- Question 2
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

-- Question 3
Select North_America, Europe, Rest_of_the_World
From crosstab ($$ 
                Select distinct year, region, round( (sum(gdp_per_capita) over (partition by year, region)) / 
                                                (sum(gdp_per_capita) over (partition by year)) * 100) as percent_of_total
                from (Select  gdp.*, case when continent_code = 'NA' then 'North America'
                                    when continent_code = 'EU' then 'Europe'
                                    Else 'Rest of the World' 
                                    end as region
                    from country_gdp as gdp
                    left join continent_map cm on cm.country_code = gdp.country_code) t1
                order by year, region;
                $$)
As final_result(year smallint, North_America numeric, Europe numeric, Rest_of_the_World numeric)
where year = 2012; 

-- Question 4
Select  distinct year,  continent_name, round(avg(gdp_per_capita) over(partition by year, continent_name order by year, continent_name)) as avg_gdp
from country_gdp 
left join continent_map cm on cm.country_code = country_gdp.country_code
left join continents cn on cn.continent_code = cm.continent_code
where continent_name is not null 
order by year, continent_name; -- excluding null continents 

-- Question 5 
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

