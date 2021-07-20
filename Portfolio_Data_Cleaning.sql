DROP TABLE IF EXISTS PropertySales_Clean
GO

CREATE TABLE PropertySales_Clean (
	[Region/Country Code] nvarchar(255),
	[Region/Country name] nvarchar(255),
	[County/UA name] nvarchar(255),
	[Date] date,
	[Sales] nvarchar(255)
)

GO

-- 1. Unpivot and clean ONS "Residential property sales" dataset.
-- 2. INSERT cleaned data to new table

INSERT INTO PropertySales_Clean ([Region/Country Code], [Region/Country name], [County/UA name], [Date], [Sales])

SELECT
[Region/Country Code],
[Region/Country name],
[County/UA name],
CONVERT(date,RIGHT([Year], 8)) AS [Year], --Extract only Month and Year
[Sales]


FROM PortfolioProject..EnglandWalesPropertySales

UNPIVOT (
	[Sales] FOR [Year]
	IN ([Year ending Dec 1995],
		[Year ending Mar 1996],
		[Year ending Jun 1996],
		[Year ending Sep 1996],
		[Year ending Dec 1996],
		[Year ending Mar 1997],
		[Year ending Jun 1997],
		[Year ending Sep 1997],
		[Year ending Dec 1997],
		[Year ending Mar 1998],
		[Year ending Jun 1998],
		[Year ending Sep 1998],
		[Year ending Dec 1998],
		[Year ending Mar 1999],
		[Year ending Jun 1999],
		[Year ending Sep 1999],
		[Year ending Dec 1999],
		[Year ending Mar 2000],
		[Year ending Jun 2000],
		[Year ending Sep 2000],
		[Year ending Dec 2000],
		[Year ending Mar 2001],
		[Year ending Jun 2001],
		[Year ending Sep 2001],
		[Year ending Dec 2001],
		[Year ending Mar 2002],
		[Year ending Jun 2002],
		[Year ending Sep 2002],
		[Year ending Dec 2002],
		[Year ending Mar 2003],
		[Year ending Jun 2003],
		[Year ending Sep 2003],
		[Year ending Dec 2003],
		[Year ending Mar 2004],
		[Year ending Jun 2004],
		[Year ending Sep 2004],
		[Year ending Dec 2004],
		[Year ending Mar 2005],
		[Year ending Jun 2005],
		[Year ending Sep 2005],
		[Year ending Dec 2005],
		[Year ending Mar 2006],
		[Year ending Jun 2006],
		[Year ending Sep 2006],
		[Year ending Dec 2006],
		[Year ending Mar 2007],
		[Year ending Jun 2007],
		[Year ending Sep 2007],
		[Year ending Dec 2007],
		[Year ending Mar 2008],
		[Year ending Jun 2008],
		[Year ending Sep 2008],
		[Year ending Dec 2008],
		[Year ending Mar 2009],
		[Year ending Jun 2009],
		[Year ending Sep 2009],
		[Year ending Dec 2009],
		[Year ending Mar 2010],
		[Year ending Jun 2010],
		[Year ending Sep 2010],
		[Year ending Dec 2010],
		[Year ending Mar 2011],
		[Year ending Jun 2011],
		[Year ending Sep 2011],
		[Year ending Dec 2011],
		[Year ending Mar 2012],
		[Year ending Jun 2012],
		[Year ending Sep 2012],
		[Year ending Dec 2012],
		[Year ending Mar 2013],
		[Year ending Jun 2013],
		[Year ending Sep 2013],
		[Year ending Dec 2013],
		[Year ending Mar 2014],
		[Year ending Jun 2014],
		[Year ending Sep 2014],
		[Year ending Dec 2014],
		[Year ending Mar 2015],
		[Year ending Jun 2015],
		[Year ending Sep 2015],
		[Year ending Dec 2015],
		[Year ending Mar 2016],
		[Year ending Jun 2016],
		[Year ending Sep 2016],
		[Year ending Dec 2016],
		[Year ending Mar 2017],
		[Year ending Jun 2017],
		[Year ending Sep 2017],
		[Year ending Dec 2017],
		[Year ending Mar 2018],
		[Year ending Jun 2018],
		[Year ending Sep 2018],
		[Year ending Dec 2018],
		[Year ending Mar 2019],
		[Year ending Jun 2019],
		[Year ending Sep 2019],
		[Year ending Dec 2019],
		[Year ending Mar 2020],
		[Year ending Jun 2020],
		[Year ending Sep 2020],
		[Year ending Dec 2020])
		
) AS [Unpivot Table]

GO

-- 3. Select newly created table with cleaned data

SELECT * FROM PropertySales_Clean

GO