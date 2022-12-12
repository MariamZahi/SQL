Select *
From SQLPORTFOLIO..CovidDeaths
Where continent is not null
order by 3,4

--Select *
--From SQLPORTFOLIO..CovidVaccination
--order by 3,4

--Select data we use

Select location, date, total_cases, new_cases, total_deaths, population
From SQLPORTFOLIO..CovidDeaths
order by 1,2

-- Look at total cases vs total deaths
-- Shows likelihood  of contracting Covid
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From SQLPORTFOLIO..CovidDeaths
Where location like '%canada%'
order by 1,2

--Looking at total cases VS population
--Shows how many got Covid

Select location, date, total_cases, population, (total_cases/population)*100 as CasesPercentage
From SQLPORTFOLIO..CovidDeaths
Where location like '%canada%'
order by 1,2

--Looking at countries with highest infection compared with population
Select location, population, MAX(total_cases) as HighestInfectionCount
From SQLPORTFOLIO..CovidDeaths
--Where location like '%canada%'
Group by location, population
order by HighestInfectionCount desc

--Countries with highest DeathCount
Select location, population, MAX(cast(total_deaths as int)) as HighestDeathCount
From SQLPORTFOLIO..CovidDeaths
--Where location like '%canada%'
Where continent is not null
Group by population, location
order by HighestDeathCount desc

--Breaking global stats
Select date, SUM(new_cases), SUM(cast(new_deaths as int)) 
From SQLPORTFOLIO..CovidDeaths
--Where location like '%canada%'
where continent is not null
Group by date
order by 1,2

--Inspection two sets
Select *
From SQLPORTFOLIO..CovidDeaths dea
Join SQLPORTFOLIO..CovidVaccination vac
 On dea.location = vac.location
 and dea.date = vac.date

 --Rollingover

Select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
dea.Date) as RollingPeopleVaccinated
From SQLPORTFOLIO..CovidDeaths dea
Join SQLPORTFOLIO..CovidVaccination vac
 On dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
 order by 1,2,3

 --use CTE

 With PopvsVac (Continent,Location, Date, Population, new_vaccinations, 
 RollingPeopleVaccinated )
 as
 (
 Select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From SQLPORTFOLIO..CovidDeaths dea
Join SQLPORTFOLIO..CovidVaccination vac
 On dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
 --order by 2,3
 )
 Select *
 From PopvsVac


 --TEMP TABLE
 Drop Table if exists #PercentPopulationVaccinated
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

  Select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From SQLPORTFOLIO..CovidDeaths dea
Join SQLPORTFOLIO..CovidVaccination vac
 On dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
 --order by 2,3
  Select *
 From #PercentPopulationVaccinated

 --Creating Views
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From SQLPORTFOLIO..CovidDeaths dea
Join SQLPORTFOLIO..CovidVaccination vac
 On dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
