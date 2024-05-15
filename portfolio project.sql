select*
From ProjectPortfolio..CovidDeaths
Where continent is not NULL
order by 3,4


--select*
--From ProjectPortfolio..CovidVaccinations
--order by 3,4

--Select Data that  we are going to be using

Select location, date, total_cases, new_cases,total_deaths, population
From ProjectPortfolio..CovidDeaths
order by 1,2

--Looking at total cases vs Total deaths
--Show likelihood of dying if you contract covid in your country


Select location, date, total_cases, total_deaths, (Total_deaths/Total_cases)*100 as DeathPercentage
From ProjectPortfolio..CovidDeaths
Where location like '%states%'
order by 1,2


--Looking at total cases vs population
--Shows what percentage of population got covid


Select location, date, total_cases, population, (Total_cases/population)*100 as PercentagePopulationinfected
From ProjectPortfolio..CovidDeaths
--Where location like '%states%'
order by 1,2



--Looking at countrie with highest infection rate compared to population


Select location, population, MAX(total_cases)as HighestInfrctiousCount, Max((total_cases/population))*100 as Percentagepopulationinfected
From ProjectPortfolio..CovidDeaths
--Where location like '%states%'
Where continent is not NULL
Group by location, population
order by Percentagepopulationinfected desc

--Showing countries with highest death count per population


Select location,MAX(cast(total_deaths as int))  as TotalDeathCount
From ProjectPortfolio..CovidDeaths
--Where location like '%states%'
Where continent is  NULL
Group by location
order by TotalDeathCount desc

--LET'S break things down by continent 




Select continent, MAX(cast(total_deaths as int))  as TotalDeathCount
From ProjectPortfolio..CovidDeaths
--Where location like '%states%'
Where continent is not NULL
Group by continent
order by TotalDeathCount desc


-- Showing continents with highest death count per population

Select continent, MAX(cast(total_deaths as int))  as TotalDeathCount
From ProjectPortfolio..CovidDeaths
--Where location like '%states%'
Where continent is not NULL
Group by continent
order by TotalDeathCount desc



--GLobal Numbers


Select  SUM(new_cases) as totalcases, SUM(cast(new_deaths as int)) as totaldeaths,SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From ProjectPortfolio..CovidDeaths
--Where location like '%states%'
where continent is not null
--Group by date
order by 1,2


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date)as RollingPeopleVaccinated
From ProjectPortfolio..CovidDeaths dea
Join ProjectPortfolio..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3




With popvsvac(continent, location, date, population,new_vaccinations, RollingPeopleVaccinated)
as
(Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date)as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From ProjectPortfolio..CovidDeaths dea
Join ProjectPortfolio..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *,(RollingpeopleVaccinated/population)*100
From popvsvac

DROP TABLE If exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date)as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From ProjectPortfolio..CovidDeaths dea
Join ProjectPortfolio..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select *,(RollingpeopleVaccinated/population)*100
From #PercentPopulationVaccinated


--creating view to storte data for visualisations



Create view PercentagePopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location,
dea.date)as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From ProjectPortfolio..CovidDeaths dea
Join ProjectPortfolio..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
