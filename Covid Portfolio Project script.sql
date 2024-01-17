SELECT TOP (1000) [iso_code]
      ,[continent]
      ,[location]
      ,[date]
      ,[new_tests]
      ,[total_tests]
      ,[total_tests_per_thousand]
      ,[new_tests_per_thousand]
      ,[new_tests_smoothed]
      ,[new_tests_smoothed_per_thousand]
      ,[positive_rate]
      ,[tests_per_case]
      ,[tests_units]
      ,[total_vaccinations]
      ,[people_vaccinated]
      ,[people_fully_vaccinated]
      ,[new_vaccinations]
      ,[new_vaccinations_smoothed]
      ,[total_vaccinations_per_hundred]
      ,[people_vaccinated_per_hundred]
      ,[people_fully_vaccinated_per_hundred]
      ,[new_vaccinations_smoothed_per_million]
      ,[stringency_index]
      ,[population_density]
      ,[median_age]
      ,[aged_65_older]
      ,[aged_70_older]
      ,[gdp_per_capita]
      ,[extreme_poverty]
      ,[cardiovasc_death_rate]
      ,[diabetes_prevalence]
      ,[female_smokers]
      ,[male_smokers]
      ,[handwashing_facilities]
      ,[hospital_beds_per_thousand]
      ,[life_expectancy]
      ,[human_development_index]
  FROM [PortfolioProject].[dbo].[CovidVaccinations]


  select* from coviddeaths
  order by 3,4;

 --  select* from CovidVaccinations
 -- order by 3,4;

 --select data that we are going to be using

 select location,date ,total_cases,new_cases,total_deaths,population
 from coviddeaths
 order by 1,2;

-- Looking at total cases vs total deaths
--show the likelihood of dying if you contrACT COVID
--using the 'cast'command to convert ints into floats 

 select location,date ,total_cases,total_deaths,
 (cast (total_deaths as float)/cast( total_cases as float))*100 as DeathPercentage
 from coviddeaths
 where location like '%states%'
 order by 1,2;


 --looking at total case vs population 
 -- show percentage of taotal population got covid

 select location,date ,total_cases,population,
 (cast (total_cases as float)/cast( population as float))* 100 as DeathPercentage
 from coviddeaths
 where location like '%states%'
 order by 1,2;


 --what countries has the highest covid infection rates compared to populations 


 select location,population, MAX(total_cases)as HighestInfectionCount,
 Max((cast (total_cases as float))/cast( population as float))* 100 as percentofpoopulationinfected
 from coviddeaths
group by location, population
 order by percentofpoopulationinfected desc;

 -- showing the countries with tthe Highest death count per population 

 
 select location, MAX(cast(total_deaths as float))as totaldeathcount
 from coviddeaths
 where continent is not null
group by location
 order by totaldeathcount desc;


 --Lets break things down by contient 

 
 

 --showing the contients with the highest death count per population

 select continent, MAX(cast(total_deaths as float))as totaldeathcount
 from coviddeaths
 where continent is not null
group by continent
 order by totaldeathcount desc;

 --Global Numbers percentage wise

 select sum(new_cases) as total_cases, sum(cast(new_deaths as float)) as total_deaths, sum(cast(new_deaths as float))/sum(new_cases)*100 as deathpercentage
 from coviddeaths
 where continent is not null
-- group by date
 order by 1,2;

 -- Looking at total popuulation vs vaccinations
 --using CTE

  with  PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
  as
  (
 select d.continent,d.location,d.date, d.population ,v.new_vaccinations
 ,sum(convert(int,v.new_vaccinations)) over (partition by d.location order by d.location,d.date)
 as RollingPeopleVaccinated
 --,(RollingPeopleVaccinated/population)*100
 from Coviddeaths d
 join CovidVaccinations v on d.location = v.location and d.date =v.date
 where d.continent is not null
-- order by 2,3
 )
 select * , (RollingPeopleVaccinated/Population)*100
 from PopvsVac


 --temp table
drop table if exist #PercentPopulationVaccinated
 create table #PercentPopulationVaccinated
 (
 continent nvarchar(255),
 location nvarchar(255),
 date datetime,
 population numeric,
 new_vaccinations numeric,
 rollingpeoplevaccinated numeric
 )

 insert into #PercentPopulationVaccinated

  select d.continent,d.location,d.date, d.population ,v.new_vaccinations
 ,sum(cast(v.new_vaccinations as int)) over (partition by d.location order by d.location,d.date)
 as RollingPeopleVaccinated
 --,(RollingPeopleVaccinated/population)*100
 from Coviddeaths d
 join CovidVaccinations v on d.location = v.location and d.date =v.date
 where d.continent is not null
-- order by 2,3

select *,(RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated



-- creating view to store data for later visualization 

create view PercentPopulationVaccinated as
select d.continent,d.location,d.date, d.population ,v.new_vaccinations
 ,sum(convert(int,v.new_vaccinations)) over (partition by d.location order by d.location,d.date)
 as RollingPeopleVaccinated
 --,(RollingPeopleVaccinated/population)*100
 from Coviddeaths d
 join CovidVaccinations v on d.location = v.location and d.date =v.date
 where d.continent is not null
 --order by 2,3









