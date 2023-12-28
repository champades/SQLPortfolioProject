Select * 
From CovidDeaths
Where continent is not null
Order by 3,4

--Select Data we are going to Use
Select location, date, total_cases, new_cases, total_deaths, population 
From CovidDeaths
Where continent is not null
Order by 1,2

-- Looking at Total Cases vs Total Deaths
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidDeaths
Where location like '%nigeria%' and
Where continent is not null
Order by 1, 2

--Looking at the Total Cases vs Population
Select location, date, Population, total_cases, (total_cases/population)*100 as CasePercentage
From CovidDeaths
--Where location like '%nigeria%'
Order by 1, 2


--Looking at countries with highest infection rates cmpared to their population
Select location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as CasePercentage
From CovidDeaths
--Where location like '%nigeria%'
Group by Location, Population
Order by CasePercentage desc


--Looking at countries with highest death count by population
---Changing the datatype of total_deaths from nvarchar to int using the cast function
Select location, MAX(cast(Total_Deaths as int)) as TotalDeathCount
From CovidDeaths
Where continent is not null
--Where location like '%nigeria%'
Group by Location
Order by TotalDeathCount desc

--Querying by continents
--Continents with the highest death count
Select Continent, MAX(cast(Total_Deaths as int)) as TotalDeathCount
From CovidDeaths
Where continent is not null
--Where location like '%nigeria%'
Group by continent
Order by TotalDeathCount desc

-- Global Numbers Query

---Changing the datatype of new_deaths from nvarchar to int using the cast function
Select date, SUM(new_cases)as Total_cases, SUM(cast(new_deaths as int)) as Total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From CovidDeaths
--Where location like '%nigeria%' and
Where continent is not null
Group by date 
Order by 1, 2

Select SUM(new_cases) as Total_cases, SUM(cast(new_deaths as int)) as Total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From CovidDeaths
--Where location like '%nigeria%' and
Where continent is not null
Order by 1, 2


--Looking at Total Population vs Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
	--, (RollingPeopleVaccinated/population)*100
From CovidDeaths dea
Join CovidVaccinations vac
	 on dea.location = vac.location 
	 and dea.date = vac.date 
	 where dea.continent is not null
order by 2,3

-- USING CTE
With PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
	--, (RollingPeopleVaccinated/population)*100
From CovidDeaths dea
Join CovidVaccinations vac
	 on dea.location = vac.location 
	 and dea.date = vac.date 
	 where dea.continent is not null
--order by 2,3
)
Select *, RollingPeopleVaccinated/population *100
From PopvsVac

-- Using Temp Table
Drop table if exists #PercentPopulationVaccinated
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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
	--, (RollingPeopleVaccinated/population)*100
From CovidDeaths dea
Join CovidVaccinations vac
	 on dea.location = vac.location 
	 and dea.date = vac.date 
	 where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating Views to Store for later visualizations
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
	--, (RollingPeopleVaccinated/population)*100
From CovidDeaths dea
Join CovidVaccinations vac
	 on dea.location = vac.location 
	 and dea.date = vac.date 
	 where dea.continent is not null
--order by 2,3