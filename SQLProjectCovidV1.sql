select * 
from PortfolioProject..CovidDeaths$
order by 3,4 

--select *
--from PortfolioProject..CovidVaccinations$
--order by 3,4 
select Location ,date ,Total_cases, new_cases,total_deaths , population 
from PortfolioProject..CovidDeaths$ 
order by 1,2  
-- looking at total case  VS total deaths persentage and percentage deaths of all Porpulation
select Location ,date ,Total_cases,total_deaths , population ,(total_deaths / total_cases )* 100 as Percentage_death_Case, (total_deaths / population ) *100 as  Percentage_Porpu_death
from PortfolioProject..CovidDeaths$ 
where location like '%states%'
order by 1,2   
-- showing what Percentage of population got covid Max
select Location ,Max(Total_cases) as HighestInfectionCount, population , Max((total_cases/ population ))*100 as  Percentage_Porpu_Got_Covid
from PortfolioProject..CovidDeaths$ 
Group by location,population
order by Percentage_Porpu_Got_Covid desc;
-- Highest Death Cases and percentage 
select Location ,Max(cast(total_deaths as int)) as Total_deaths ,Max(total_deaths )/ Max(total_cases )* 100  as Percentage_death_Case
from PortfolioProject..CovidDeaths$ 
Where continent is not null 
Group by location
order by Total_deaths desc ; 
-- Lets see continent 
select location ,Max(cast(total_deaths as int)) as Total_deaths 
from PortfolioProject..CovidDeaths$ 
Where continent is null 
Group by location
order by Total_deaths desc ; 
-- golbal case 
select SUM(new_cases) as total_cases, SUM(CAST(total_deaths as int)) as total_deaths 
from PortfolioProject..CovidDeaths$ 
Where continent is null 
Group by date
order by 1,2 desc ;
--  look Total Population  vs Vacciantions 

select  dea.continent ,  dea.location , dea.date ,dea.population , vac.new_vaccinations 
,SUM(convert (int,vac.new_vaccinations )) OVER (Partition by dea.location Order by dea.location ,
dea.date) as Roling_people_Vaccinated
--,(Roling_people_Vaccinated/population) *100  
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	on dea.location = Vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

-- USE CTE 
with PopvsVac ( continent , location , date , population , new_vaccinations ,Roling_people_Vaccinated)
as 
(
select  dea.continent ,  dea.location , dea.date ,dea.population , vac.new_vaccinations 
,SUM(convert (int,vac.new_vaccinations )) OVER (Partition by dea.location Order by dea.location ,
dea.date) as Roling_people_Vaccinated
--,(Roling_people_Vaccinated/population) *100  
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	on dea.location = Vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)

select * ,(Roling_people_Vaccinated / population )*100 as percentVac
from PopvsVac 

-- TEMP TABLE 

Drop table if exists #PercentPeople_Vaccinated
CREATE TABLE #PercentPeople_Vaccinated
(
Contient nvarchar (255), 
Location nvarchar (255), 
Date datetime, 
population numeric ,
new_vaccinations numeric ,
Roling_people_Vaccinated numeric
)

INSERT INTO #PercentPeople_Vaccinated
select  dea.continent ,  dea.location , dea.date ,dea.population , vac.new_vaccinations 
,SUM(convert (int,vac.new_vaccinations )) OVER (Partition by dea.location Order by dea.location ,
dea.date) as Roling_people_Vaccinated
--,(Roling_people_Vaccinated/population) *100  
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	on dea.location = Vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3

select * ,(Roling_people_Vaccinated / population )*100 as percentVac
from #PercentPeople_Vaccinated

-- Create View store data for later visualizations \
DROP VIEW IF EXISTS PercentPeople_Vaccinated ;
GO 
Create view PercentPeople_Vaccinated as 
Select dea.continent ,  dea.location , dea.date ,dea.population , vac.new_vaccinations 
,SUM(convert (int,vac.new_vaccinations )) OVER (Partition by dea.location Order by dea.location ,
dea.date) as Roling_people_Vaccinated
--,(Roling_people_Vaccinated/population) *100  
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	on dea.location = Vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3


-- so i have a probleam with not shoing in view 
SELECT * FROM sys.objects 
WHERE name = 'PercentPeople_Vaccinated';
--
USE PortfolioProject ;  -- make sure this matches
GO

SELECT * FROM sys.objects 
WHERE name = 'PercentPeople_Vaccinated';