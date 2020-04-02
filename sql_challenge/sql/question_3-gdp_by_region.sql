-- For the year 2012, compare the percentage share of GDP Per Capita 
-- for the following regions: North America (NA), Europe (EU), and the Rest of the World. 


-- creating regions
Select  case when continent_name = 'North America' then 'North America'
            when continent_name = 'Europe' then 'Europe'
            else 'Rest of World'
            end as region, 
        round(sum(gdp_per_capita)) as total_gdp 
from country_gdp as gdp
left join countries c on  c.country_code = gdp.country_code
left join continent_map cm on cm.country_code = gdp.country_code
left join continents cont on cont.continent_code = cm.continent_code
group by case when continent_name = 'North America' then 'North America'
            when continent_name = 'Europe' then 'Europe'
            else 'Rest of World'
            end;


-- Adding percentage share  
select total_gdp/sum(total_gdp)
from (
      Select  case when continent_name = 'North America' then 'North America'
              when continent_name = 'Europe' then 'Europe'
              else 'Rest of World'
              end as region, 
              round(sum(gdp_per_capita)) as total_gdp 
      from country_gdp as gdp
      left join countries c on  c.country_code = gdp.country_code
      left join continent_map cm on cm.country_code = gdp.country_code
      left join continents cont on cont.continent_code = cm.continent_code
      group by case when continent_name = 'North America' then 'North America'
                    when continent_name = 'Europe' then 'Europe'
                    else 'Rest of World'
                    end
      ) test;

-- Windows Functions
-- simple 
Select  gdp.*, case when continent_code = 'NA' then 'NA'
                    when continent_code = 'EU' then 'EU'
                    Else 'RoW' 
                    end as region
from country_gdp as gdp
left join continent_map cm on cm.country_code = gdp.country_code
where year = 2012;

-- Combining together 
Select distinct region, 
       sum(gdp_per_capita) over (partition by region) as total_region, 
       round((sum(gdp_per_capita) over (partition by region)) / (sum(gdp_per_capita) over ()) * 100) as percent_of_total
from (Select  gdp.*, case when continent_code = 'NA' then 'NA'
                    when continent_code = 'EU' then 'EU'
                    Else 'RoW' 
                    end as region
      from country_gdp as gdp
      left join continent_map cm on cm.country_code = gdp.country_code
      where year = 2012) t1
order by region;

-- formating 
qSelect distinct region, 
       concat(
           cast(
               round(
                   (sum(gdp_per_capita) over (partition by region)) / 
                   (sum(gdp_per_capita) over ()) 
                   * 100
                   ) 
            as varchar(5)
           ), 
        '%') 
        as percent_of_total
from (Select  gdp.*, case when continent_code = 'NA' then 'North America'
                    when continent_code = 'EU' then 'Europe'
                    Else 'Rest of the World' 
                    end as region
      from country_gdp as gdp
      left join continent_map cm on cm.country_code = gdp.country_code
      where year = 2012) t1
order by region;

-- HOW TO TRANSPOSE COLUMNS AND ROWS??
Select * 
From crosstab($$Select year, 
        case when continent_name = 'South America' then 'Rest of the World'
             when continent_name = 'North America' then 'North_America'
             when continent_name = 'Europe' then 'Europe'
             when continent_name = 'Oceania' then 'Rest of the World'
             when continent_name = 'Africa' then 'Rest of the World'
             when continent_name = 'Asia' then 'Rest of the World'
             when continent_name = 'Antarctica' then 'Antarctica'
             else 'not_known'
             end as continent_name,
        sum(gdp_per_capita) as gdp
      From country_gdp as gdp 
      left join continent_map cm on cm.country_code = gdp.country_code
      left join continents cn on cn.continent_code = cm.continent_code
      group by year, continent_name
      order by 1,2 $$)
As final_result(year smallint, South_America numeric, North_America numeric,
                 Europe numeric, Oceania numeric, Africa numeric, 
                 Asia numeric, not_known numeric
                )
where year = 2012 ;     

-- Grouping continents into Rest of World: 
Select *
From crosstab($$Select year, 
        case when continent_name = 'North America' then 'North_America'
             when continent_name = 'Europe' then 'Europe'
             else 'Rest_of_the_World'
             end as continent_name,
        sum(gdp_per_capita) as gdp
      From country_gdp as gdp 
      left join continent_map cm on cm.country_code = gdp.country_code
      left join continents cn on cn.continent_code = cm.continent_code
      group by year, continent_name
      order by 1,2 $$)
As final_result(year smallint, North_America numeric,
                 Europe numeric, Rest_of_the_World numeric
                )
where year = 2012 ; 


-- Putting it all together 
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
