USE PortfolioProject

--Porcentaje de Mortalidad en Republica Dominicana 
SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 AS [Porcentaje de Muertes]
FROM PortfolioProject..CovidMuertes
WHERE location = 'Dominican Republic' AND continent IS NOT NULL
ORDER BY 1,2;

--Total de Casos Vs Poblacion
--Muestra el porcentaje de la poblacion que ha tenido COVID
SELECT location,date,total_cases,population,(total_cases/population)*100 AS [Porcentaje de Personas Contagiadas]
FROM PortfolioProject..CovidMuertes
WHERE location = 'Dominican Republic' AND continent IS NOT NULL
ORDER BY 1,2;

--Paises con alta tasa de Casos vs Poblacion
SELECT location, population, MAX(total_cases) AS [Cantidad Maxima de Casos], MAX(total_cases/population)*100 AS [Porcentaje de Personas Contagiadas]
FROM PortfolioProject..CovidMuertes
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY 4 DESC;

--Paises con alta tasa de Muertes vs Poblacion
SELECT location, MAX(CAST(total_deaths as int)) AS [Cantidad Maxima de Muertes], MAX(CAST(total_deaths as int)/population)*100 AS [Porcentaje de Personas Fallecidas] 
FROM PortfolioProject..CovidMuertes
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY 2 DESC;

--Ver por continentes
--Muertes por Continente
SELECT continent, MAX(CAST(total_deaths AS int)) AS [Cantidad Maxima de Muertes]
FROM PortfolioProject..CovidMuertes
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY [Cantidad Maxima de Muertes] DESC;

--Numeros Globales
SELECT /*date,*/ SUM(new_cases) AS [Casos], SUM(CAST(new_deaths as int)) AS [Muertes], SUM(CAST(new_deaths as int)) / SUM(new_cases) *100 AS [Tasa de Mortalidad]
FROM PortfolioProject..CovidMuertes
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1;

--Total de Poblacion vs Vacunados
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.location, dea.date) AS [Acumulado]
FROM PortfolioProject..CovidMuertes dea
JOIN PortfolioProject..CovidVacunacion vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3;

--USAR CTE
WITH PopvsVac(Continent, location,date,population,new_vaccinations,Acumulado)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.location, dea.date) AS [Acumulado]
FROM PortfolioProject..CovidMuertes dea
JOIN PortfolioProject..CovidVacunacion vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *, (Acumulado/population)*100 /2
FROM PopvsVac

--CREAR VISTA
--Para visualizar en TableaU

CREATE VIEW PoblacionVacunada
AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.location, dea.date) AS [Acumulado]
FROM PortfolioProject..CovidMuertes dea
JOIN PortfolioProject..CovidVacunacion vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

