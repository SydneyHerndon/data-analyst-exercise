-- \l - list on databases
-- \c - connect to a database 
--\dt - displays tables
-- \q -quit psql

CREATE DATABASE world_geography; -- all parameters are default 

CREATE TABLE continent_map (
    id SERIAL Not NULL PRIMARY KEY , -- generating primary keys for each table to ensure uniqueness 
    country_code varchar(5), -- under assumption country code is max 3 letters 
    continent_code varchar(5)-- under assumption continent code is max 2 letters 
);
Create Table continents (
    id Not NULL SERIAL PRIMARY KEY,
    continent_code varchar(5), -- under assumption continent code is max 2 letters 
    continent_name varchar(250)
);
Create Table countries (
    id Not NULL SERIAL PRIMARY KEY,
    country_code varchar(5), -- under assumption country code is max 3 letters 
    country_name varchar(250)
);
Create Table country_gdp ( -- under assumption country code is max 3 letters 
    id Not NULL SERIAL PRIMARY KEY,
    country_code varchar(50);
    year smallint, -- could convert to int(2) if resources are limited; 
    gdp_per_capita numeric -- numeric best used for monitary values
);

-- Load CSV into Table 
copy continent_map(country_code,continent_code) 
FROM '/Users/sydneyherndon/Documents/data-analyst-exercise/sql_challenge/data/continent_map.csv' 
DELIMITER ',' CSV HEADER;

copy continents(continent_code,continent_name) 
FROM '/Users/sydneyherndon/Documents/data-analyst-exercise/sql_challenge/data/continents.csv' 
DELIMITER ',' CSV HEADER;

copy countries(country_code,country_name) 
FROM '/Users/sydneyherndon/Documents/data-analyst-exercise/sql_challenge/data/countries.csv' 
DELIMITER ',' CSV HEADER;

copy country_gdp(country_code,year, gdp_per_capita) 
FROM '/Users/sydneyherndon/Documents/data-analyst-exercise/sql_challenge/data/per_capita.csv' 
DELIMITER ',' CSV HEADER;