/*
Purpose:DataWrangling for the DSC640_AviationData Project

	Creates the following AviationFatalitiesDetails Fields
		FlightDate
		FlightOperator
		PlaneAge

	Cleaned YOM

*/

-- Create Backup
-- select * into AviationFatalitiesDetails_Backup_20200921 from AviationFatalitiesDetails (nolock) 
-- sp_spaceused
/*
database_name                                                                                                                    database_size      unallocated space
-------------------------------------------------------------------------------------------------------------------------------- ------------------ ------------------
DSC640_AviationData                                                                                                              1033.31 MB         948.99 MB

reserved           data               index_size         unused
------------------ ------------------ ------------------ ------------------
52232 KB           50112 KB           1296 KB            824 KB


*/

-- Review FlightDate
select top 10 
	charindex(' ta ', reverse([Date & Time]))
	,cast(
		rtrim(substring([Date & Time], 1, len([Date & Time])- case when charindex(' ta ', reverse([Date & Time])) > 0 then charindex(' ta ', reverse([Date & Time]))+ 3 else charindex(' ta ', reverse([Date & Time])) end))
		as date)
	,* 
from AviationFatalitiesDetails (nolock) 

-- Add FlightDate Column
alter table AviationFatalitiesDetails add FlightDate date

-- Update the FlightDate values
update a set a.FlightDate = 
	cast(
		rtrim(substring([Date & Time], 1, len([Date & Time])- case when charindex(' ta ', reverse([Date & Time])) > 0 then charindex(' ta ', reverse([Date & Time]))+ 3 else charindex(' ta ', reverse([Date & Time])) end))
		as date)
from AviationFatalitiesDetails a 
-- (26970 rows affected)

-- Verify FlightDate for nulls
select * from AviationFatalitiesDetails a where FlightDate is null
-- 0 rows

select * from AviationFatalitiesDetails a 

select top 10 
	charindex('(', reverse([Operator]))
	,rtrim(substring([Operator], 1, len([Operator])- case when charindex('(', reverse([Operator])) > 0 then charindex('(', reverse([Operator]))+1 else charindex('(', reverse([Operator])) end))
	,len(rtrim(substring([Operator], 1, len([Operator])- case when charindex('(', reverse([Operator])) > 0 then charindex('(', reverse([Operator]))+1 else charindex('(', reverse([Operator])) end)))
	,* 
from AviationFatalitiesDetails (nolock) 

select
	max(len(rtrim(substring([Operator], 1, len([Operator])- case when charindex('(', reverse([Operator])) > 0 then charindex('(', reverse([Operator]))+1 else charindex('(', reverse([Operator])) end))))
from AviationFatalitiesDetails (nolock) 
-- 90

-- Add FlightOperator Column
alter table AviationFatalitiesDetails add FlightOperator varchar(255)

-- Update FlightOperator Column
update a set a.FlightOperator = 
	rtrim(substring([Operator], 1, len([Operator])- case when charindex('(', reverse([Operator])) > 0 then charindex('(', reverse([Operator]))+1 else charindex('(', reverse([Operator])) end))
from AviationFatalitiesDetails a 
-- (26970 rows affected)

select top 10 * from AviationFatalitiesDetails a 



-- Cleanup YOM -- Using the min year of the type of craft
select *
from AviationFatalitiesDetails a 
where len([YOM]) < 4
-- 933

select distinct [Type of aircraft] 
from AviationFatalitiesDetails a 
where len([YOM]) < 4
-- 286

select [Type of aircraft] , min([YOM])
from AviationFatalitiesDetails a 
	where [Type of aircraft] in (
			select distinct [Type of aircraft] 
			from AviationFatalitiesDetails a 
			where len([YOM]) < 4
		)
	and len([YOM]) = 4
	group by [Type of aircraft] 

select distinct [Type of aircraft] 
from AviationFatalitiesDetails a 
where len([YOM]) < 4


select b.min_YOM, a.[YOM], a.* 
from AviationFatalitiesDetails a 
	join (
		select [Type of aircraft] , min([YOM]) min_YOM
		from AviationFatalitiesDetails a 
			where [Type of aircraft] in (
					select distinct [Type of aircraft] 
					from AviationFatalitiesDetails a 
					where len([YOM]) < 4
				)
			and len([YOM]) = 4
			group by [Type of aircraft] 
		) b
	on a.[Type of aircraft] = b.[Type of aircraft]
where len([YOM]) < 4

-- Cleanup 
update a set a.YOM = b.min_YOM
from AviationFatalitiesDetails a 
	join (
		select [Type of aircraft] , min([YOM]) min_YOM
		from AviationFatalitiesDetails a 
			where [Type of aircraft] in (
					select distinct [Type of aircraft] 
					from AviationFatalitiesDetails a 
					where len([YOM]) < 4
				)
			and len([YOM]) = 4
			group by [Type of aircraft] 
		) b
	on a.[Type of aircraft] = b.[Type of aircraft]
where len([YOM]) < 4
-- 888 of 933 rows affected

select *
from AviationFatalitiesDetails a 
where len([YOM]) < 4
-- 45 rows left

select distinct [Type of aircraft] 
from AviationFatalitiesDetails a 
where len([YOM]) < 4
-- 36 types 


select *
from AviationFatalitiesDetails a 
where [Type of aircraft] like '%Vega%'
Lockheed 2 Vega

-- Google research to get the dates for these planes.
if object_id('tempdb..#temp') is not null drop table #temp
create table #temp (plane varchar(255), yr varchar(4))
insert into #temp (plane, yr) select 'Fairey Long Range','1928'
insert into #temp (plane, yr) select 'De Havilland DH.6','1916'
insert into #temp (plane, yr) select 'Fokker C2','1927'
insert into #temp (plane, yr) select 'Stinson SM-2 Junior','1928'
insert into #temp (plane, yr) select 'SNCASE SE.1010','1948'
insert into #temp (plane, yr) select 'Hamilton H-47','1928'
insert into #temp (plane, yr) select 'Dornier DO.12 Libelle','1921'
insert into #temp (plane, yr) select 'Sopwith Gnu','1913'
insert into #temp (plane, yr) select 'Short S.33 Empire Flying Boat','1936'
insert into #temp (plane, yr) select 'CANT 10','1920'
insert into #temp (plane, yr) select 'Caudron C.81','1921'
insert into #temp (plane, yr) select 'Caudron C.59','1921'
insert into #temp (plane, yr) select 'Kalinin K-7','1933'
insert into #temp (plane, yr) select 'FVM S.21','1922'
insert into #temp (plane, yr) select 'CAMS 51','1926'
insert into #temp (plane, yr) select 'Blackburn Iris','1929'
insert into #temp (plane, yr) select 'Aero DH.50','1923'
insert into #temp (plane, yr) select 'Aleksandrov-Kalinin AK-1','1924'
insert into #temp (plane, yr) select 'Petlyakov Pe-8','1936'
insert into #temp (plane, yr) select 'Dornier DO.15 Wal','1922'
insert into #temp (plane, yr) select 'Dewoitine D.33','1930'
insert into #temp (plane, yr) select 'Lockheed 2 Vega','1927'
insert into #temp (plane, yr) select 'Baade 152','1958'
insert into #temp (plane, yr) select 'Polikarpov U-1','1937'
insert into #temp (plane, yr) select 'Curtiss Robin C-1','1928'
insert into #temp (plane, yr) select 'Grigorovich P.L.1','1925'
insert into #temp (plane, yr) select 'SNCASE SE.200','1942'
insert into #temp (plane, yr) select 'Dornier Do A Libelle I','1921'
insert into #temp (plane, yr) select 'Bl�riot 155','1925'
insert into #temp (plane, yr) select 'Dornier Komet II','1922'
insert into #temp (plane, yr) select 'Loening C-W Air Yacht','1921'
insert into #temp (plane, yr) select 'LVG V.13 Strehla','1923'
insert into #temp (plane, yr) select 'ACAZ T.1','1924'
insert into #temp (plane, yr) select 'Ilyushin II-96','1988'
insert into #temp (plane, yr) select 'Avia BH.25','1926'
insert into #temp (plane, yr) select 'Ryan B-5 Brougham','1927'


select * from #temp

select distinct a.[Type of aircraft], a.[YOM], b.plane, b.yr
	from AviationFatalitiesDetails a 
		join #temp b on a.[Type of aircraft] = b.plane
	where len(a.[YOM]) < 4



update a set a.YOM = b.yr
	from AviationFatalitiesDetails a 
		join #temp b 
			on a.[Type of aircraft] = b.plane
		where len(a.[YOM]) < 4
	


-- Google research to get the dates for these planes.
if object_id('tempdb..#temp') is not null drop table #temp
create table #temp (plane varchar(255), yr varchar(4))
insert into #temp (plane, yr) select 'Caudron C.280 Phal�ne','1932'
insert into #temp (plane, yr) select 'Short S.7 Mussel','1926'
insert into #temp (plane, yr) select 'Fokker F8','1927'
insert into #temp (plane, yr) select 'Dornier Komet III','1955'
insert into #temp (plane, yr) select 'Canadian Vickers Vedette','1911'
insert into #temp (plane, yr) select 'Stearman 4','1927'
insert into #temp (plane, yr) select 'Dornier DO J Wal','1923'
insert into #temp (plane, yr) select 'Bl�riot 115','1923'
insert into #temp (plane, yr) select 'Pander EC-60','1926'
insert into #temp (plane, yr) select 'Stinson Model U','1932'
insert into #temp (plane, yr) select 'Tupolev ANT-20','1934'
insert into #temp (plane, yr) select 'Beriev Be-12','1960'
insert into #temp (plane, yr) select 'Caudron C.74','1922'
insert into #temp (plane, yr) select 'Polikarpov U-1','1937'
insert into #temp (plane, yr) select 'Dornier Komet III','1921'


update a set a.YOM = b.yr
	from AviationFatalitiesDetails a 
		join #temp b 
			on a.[Type of aircraft] = b.plane
		where a.planeage < 0


Vickers Viscount
1957
Fairchild C-119 Flying Boxcar
1925
De Havilland DH.60 Moth
1925

select yom, * 
-- update a set a.YOM = '1957'
	from AviationFatalitiesDetails a 
		where len(yom) > 4
			and a.[Type of aircraft] = 'Vickers Viscount'

select yom, * 
-- update a set a.YOM = '1925'
	from AviationFatalitiesDetails a 
		where len(yom) > 4
			and a.[Type of aircraft] = 'Fairchild C-119 Flying Boxcar'

select yom, * 
-- update a set a.YOM = '1925'
	from AviationFatalitiesDetails a 
		where len(yom) > 4
			and a.[Type of aircraft] = 'De Havilland DH.60 Moth'

update a set a.YOM = b.min_YOM
	from AviationFatalitiesDetails a 
	join
		(
		select min(YOM) min_YOM, 'Douglas C-47 Skytrain (DC-3)' PLANE
			from AviationFatalitiesDetails a 
				where [Type of aircraft] = 'Douglas C-47 Skytrain (DC-3)'
					and YOM <> '1645'
		)b
		on a.[Type of aircraft] = b.PLANE
	where [Type of aircraft] = 'Douglas C-47 Skytrain (DC-3)'
			and YOM = '1645'


update a set a.YOM = b.min_YOM
	from AviationFatalitiesDetails a 
	join
		(
		select min(YOM) min_YOM, 'Beechcraft 1900C' PLANE
			from AviationFatalitiesDetails a 
				where [Type of aircraft] = 'Beechcraft 1900C'
					and YOM <> '1900'
		)b
		on a.[Type of aircraft] = b.PLANE
	where [Type of aircraft] = 'Beechcraft 1900C'
			and YOM = '1900'

update a set a.YOM = b.min_YOM
	from AviationFatalitiesDetails a 
	join
		(
		select min(YOM) min_YOM, 'Rockwell Aero Commander 500' PLANE
			from AviationFatalitiesDetails a 
				where [Type of aircraft] = 'Rockwell Aero Commander 500'
					and YOM <> '1673'
		)b
		on a.[Type of aircraft] = b.PLANE
	where [Type of aircraft] = 'Rockwell Aero Commander 500'
			and YOM = '1673'

update a set a.YOM = b.min_YOM
	from AviationFatalitiesDetails a 
	join
		(
		select min(YOM) min_YOM, 'Boeing KC-97 Stratotanker' PLANE
			from AviationFatalitiesDetails a 
				where [Type of aircraft] = 'Boeing KC-97 Stratotanker'
					and YOM <> '1651'
		)b
		on a.[Type of aircraft] = b.PLANE
	where [Type of aircraft] = 'Boeing KC-97 Stratotanker'
			and YOM = '1651'


-- Fix incorrect YOM due to YOM being newer than flightdate uses same planes with YOM
-- select a.YOM, b.min_YOM, a.[Type of aircraft]
update a set a.YOM = b.min_YOM
	from AviationFatalitiesDetails a 
	join
		(
		select min(YOM) min_YOM, a.[Type of aircraft] PLANE
			from AviationFatalitiesDetails a 
				where a.planeage > 0
				group by a.[Type of aircraft]
		)b
		on a.[Type of aircraft] = b.PLANE
	where a.planeage < 0


-- select a.YOM, b.min_YOM, a.[Type of aircraft], a.flightdate
update a set a.YOM = b.min_YOM
	from AviationFatalitiesDetails a 
	join
		(
		select min(YOM) min_YOM, a.[Type of aircraft] PLANE
			from AviationFatalitiesDetails a 
				where a.FlightDate > cast('1/1/'+a.YOM as date)
				group by a.[Type of aircraft]
		)b
		on a.[Type of aircraft] = b.PLANE
	where a.planeage < 0

			

select a.planeage, a.yom, a.FlightDate, a.[Type of aircraft]
	from AviationFatalitiesDetails a 
		where a.planeage < 0
		order by a.planeage desc
-- 1



select *
-- update a set a.YOM = '1921'
from AviationFatalitiesDetails a 
	where  a.[Type of aircraft]='Dornier Komet III'

-- The date of crash is before date of YOM - Deleting this one row.
-- delete a from AviationFatalitiesDetails a where  a.[Type of aircraft]='Polikarpov U-1'


-- Check for any more invalid YOM date values
select *
	from AviationFatalitiesDetails a 
	where len(a.[YOM]) < 4
-- 0 
select *
	from AviationFatalitiesDetails a 
	where len(a.[YOM]) > 4
-- 0 


-- Age of Plane YOM to 
select 
	 datediff(yy, cast('01/01/'+rtrim([YOM]) as date), FlightDate)
	,FlightDate
	,cast('01/01/'+rtrim([YOM]) as date)
from AviationFatalitiesDetails a 

select yom, * 
	from AviationFatalitiesDetails a 
		where len(yom) > 4

-- Add FlightOperator Column
--alter table AviationFatalitiesDetails drop column PlaneAge 
alter table AviationFatalitiesDetails add PlaneAge int

-- Update FlightOperator Column
update a set a.PlaneAge = datediff(yy, cast('01/01/'+rtrim(a.[YOM]) as date), a.FlightDate)
from AviationFatalitiesDetails a 
-- (26970 rows affected)

select a.PlaneAge, * from AviationFatalitiesDetails a where a.[Type of aircraft] = 'Douglas C-47 Skytrain (DC-3)' order by a.PlaneAge desc

select datediff(yy, cast('01/01/'+rtrim(a.[YOM]) as date), a.FlightDate)
	,a.[YOM]
	,a.FlightDate
	, *
from AviationFatalitiesDetails a 
	where a.PlaneAge <> datediff(yy, cast('01/01/'+rtrim(a.[YOM]) as date), a.FlightDate) 
order by datediff(yy, cast('01/01/'+rtrim(a.[YOM]) as date), a.FlightDate) desc

select max(planeage)
	from AviationFatalitiesDetails a 

select * 
	from AviationFatalitiesDetails a 
		where planeage > 95
-- 0


select a.planeage, a.yom, a.FlightDate, * 
	from AviationFatalitiesDetails a 
		where a.planeage < 0
		order by a.planeage desc
-- 39

select min(YOM) min_YOM, 'Piper PA-31-350 Navajo Chieftain' PLANE
			from AviationFatalitiesDetails a 
				where [Type of aircraft] = 'Piper PA-31-350 Navajo Chieftain'

select min(YOM) min_YOM, 'Piper PA-31-350 Navajo Chieftain' PLANE from AviationFatalitiesDetails a 	where [Type of aircraft] = 'Piper PA-31-350 Navajo Chieftain'

			

	select distinct a.[Type of aircraft]
		from AviationFatalitiesDetails a 
			where a.planeage < 0
	-- 14


select a.planeage, a.yom, a.FlightDate, a.[Type of aircraft]
	from AviationFatalitiesDetails a 
		where a.planeage < 0
		order by a.planeage desc
-- 0



---=================================== 


use DSC640_AviationData
go
select 
	sum(cast(a.[Total Fatalities] as int))
	, a.[Type of aircraft]

from AviationFatalitiesDetails a (nolock)
group by a.[Type of aircraft]
order by sum(cast(a.[Total Fatalities] as int)) desc



-- Age of plane
use DSC640_AviationData
go
select 
	sum(cast(a.[Total Fatalities] as int))
	, a.[YOM]

from AviationFatalitiesDetails a (nolock)
group by a.[YOM]
order by sum(cast(a.[Total Fatalities] as int)) desc


-- PlaneAge
use DSC640_AviationData
go
select 
	sum(cast(a.[Total Fatalities] as int))
	, a.[PlaneAge]

from AviationFatalitiesDetails a (nolock)
group by a.[PlaneAge]
order by sum(cast(a.[Total Fatalities] as int)) desc





-- Operator
use DSC640_AviationData
go
select 
	sum(cast(a.[Total Fatalities] as int))
	, a.[Operator]

from AviationFatalitiesDetails a (nolock)
group by a.[Operator]
order by sum(cast(a.[Total Fatalities] as int)) desc







-- Flight Phase
use DSC640_AviationData
go
select 
	sum(cast(a.[Total Fatalities] as int))
	, a.[Flight Phase]

from AviationFatalitiesDetails a (nolock)
group by a.[Flight Phase]
order by sum(cast(a.[Total Fatalities] as int)) desc






-- Flight Phase
use DSC640_AviationData
go
select 
	sum(cast(a.[Total Fatalities] as int))
	, a.[Survivors]

from AviationFatalitiesDetails a (nolock)
group by a.[Survivors]
order by sum(cast(a.[Total Fatalities] as int)) desc






-- Flight [Survivors]
use DSC640_AviationData
go
select 
	sum(cast(a.[Total Fatalities] as int))
	, a.[Survivors]

from AviationFatalitiesDetails a (nolock)
group by a.[Survivors]
order by sum(cast(a.[Total Fatalities] as int)) desc

select 113490.0 / 43111.0
-- 38% chance of survival


-- Flight Phase
use DSC640_AviationData
go
select 
	sum(cast(a.[Total Fatalities] as int))
	, a.[Survivors]

from AviationFatalitiesDetails a (nolock)
group by a.[Survivors]
order by sum(cast(a.[Total Fatalities] as int)) desc





-- Flight [Survivors]
use DSC640_AviationData
go
select 
	sum(cast(a.[Total Fatalities] as int))
	,a.[Survivors]
	,a.[Type of aircraft]
from AviationFatalitiesDetails a (nolock)
	where a.[Survivors] =  'No'
group by a.[Survivors], a.[Type of aircraft]
order by sum(cast(a.[Total Fatalities] as int)) desc


-- Flight [Survivors]
use DSC640_AviationData
go
select 
	sum(cast(a.[Total Fatalities] as int))
	,a.[Survivors]
	,a.[Type of aircraft]
from AviationFatalitiesDetails a (nolock)
	where a.[Survivors] =  'Yes'
group by a.[Survivors], a.[Type of aircraft]
order by sum(cast(a.[Total Fatalities] as int)) desc




-- Flight [Survivors]
use DSC640_AviationData
go

select  
	 suba.[Total Fatalities] Flights_Fatalities_with_no_survivors
	,subb.[Total Fatalities] Flights_Fatalities_with_survivors
	,(suba.[Total Fatalities] / case when subb.[Total Fatalities] = 0 then 1 else subb.[Total Fatalities] end ) Chances_Of_Not_Survival
	,(subb.[Total Fatalities] / case when suba.[Total Fatalities] = 0 then 1 else suba.[Total Fatalities] end ) Chances_Of_Survival
	,suba.[Type of aircraft]
	from (
		select 
			sum(cast(a.[Total Fatalities] as int)) [Total Fatalities]
			,a.[Survivors]
			,a.[Type of aircraft]
		from AviationFatalitiesDetails a (nolock)
			where a.[Survivors] =  'No'
		group by a.[Survivors], a.[Type of aircraft]
		) 
			suba join 
		(
		select 
			sum(cast(a.[Total Fatalities] as int)) [Total Fatalities]
			,a.[Survivors]
			,a.[Type of aircraft]
		from AviationFatalitiesDetails a (nolock)
			where a.[Survivors] =  'Yes'
		group by a.[Survivors], a.[Type of aircraft]
		) subb on 
			suba.[Type of aircraft] =  subb.[Type of aircraft]
	order by --suba.[Total Fatalities] desc
		(suba.[Total Fatalities] / case when subb.[Total Fatalities] = 0 then 1 else subb.[Total Fatalities] end )
		desc


select a.[Crew on board]
	,a.[Pax on board]
	,a.[Crew fatalities]
	,a.[Pax fatalities]
	
	,cast(a.[Crew on board] as int) + cast(a.[Pax on board] as int) [Number On Board]
	,cast(a.[Total fatalities] as int) [Total fatalities]
	,cast(a.[Crew on board] as int) + cast(a.[Pax on board] as int) - cast(a.[Total fatalities] as int) [Number of Survivors]
	,a.[Type of aircraft]
	,a.[Flight Type]
	,a.[Survivors]
	,a.[PlaneAge]
		from AviationFatalitiesDetails a (nolock)

