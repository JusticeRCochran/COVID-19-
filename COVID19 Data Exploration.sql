--SELECT *
--FROM ProtfolioProject.dbo.CovidVaccinations
--order by 3,4

SELECT *
FROM ProtfolioProject.dbo.CovidDeaths
where continent is not NUll
order by 3,4

-- Select Data that we are going to be starting with

Select location,date,total_cases, new_cases, total_deaths, population
from ProtfolioProject..CovidDeaths
Where continent is not null 
order by 1,2


-- Looking at Total Cases Vs Total Deaths 
-- Shows Likelihood od dying if you contract covid in your country 

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Deathpercentge
from ProtfolioProject..CovidDeaths
where location like '%state%' 
and continent is not null
order by 1,2

-- Looking at Total Cases Vs Population 
-- Shows what percentage of population infected with Covid

Select location, date, population, total_cases, (total_deaths/population)*100 as PercentPopulationInfected
from ProtfolioProject..CovidDeaths
--where location like '%state%' 
order by 1,2


--Countries with Highest Infection Rate compared to Population 

Select location, population, Max(total_cases) AS HighestInfectionCount, Max((total_deaths/population))*100 AS PercentPopulationInfected
from ProtfolioProject..CovidDeaths
--where location like '%state%' 
Group By location, Population 
Order by PercentPopulationInfected Desc


--Countries with Highest Death Count per population 

Select location, Max(cast(total_deaths AS int)) AS TotalDeathCount
from ProtfolioProject..CovidDeaths
--where location like '%state%'
Where continent is not null
Group By location
Order by TotalDeathCount Desc

-- Breaking Things Down by Continent 
--Showing contintents with the Highest Death Count per Population 

SELECT continent, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM ProtfolioProject..CovidDeaths
--WHERE location like '%state%'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC 


--Global Numbers

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
