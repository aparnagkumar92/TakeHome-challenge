--2. -	Number of weekly active users for the latest full week (Monday – Sunday)--
-- WAU is calculated by counting registered users with > 60 seconds dwell time between Monday-Sunday.--

SET DATEFIRST 1; 
--Here I am assuming that by default Sunday is the first date. This query will set Monday as first day of the week 
with interactions_ordered as (
Select OAuth_Id, Ads_user_id, CAST(_Timestamp as DATE) as InteractionDate,
DATEPART(Weekday,CAST(_Timestamp as DATE)) as InteractionWeek
from OAuth_Id_Service 
where Ads_user_id in (Select distinct Ads_User_Id from Ad_service_interaction_data where Dwell_Time>60)
),
--This CTE will return OAuth_Id, Ads_user_id ordered by latest dates and 
-- within the dates ordered by days starting from Monday 
Sunday as (
Select MAX(Latest)as  Latest_Sunday from (
Select DATEPART(week, InteractionDate),MAX(InteractionDate) as Latest 
from interactions_ordered 
GROUP BY DATEPART(week, InteractionDate)
HAVING COUNT(DISTINCT InteractionDate)=7
order by Latest desc
)
)
--In this CTE, records are grouped by interaction week and 
--filtered only those weeks which has 7 days in it. This ensures that only full week is counted.
--Then, Latest interaction date is returned. 
--In short, this CTE will return the latest date of a full week.

-- For example if this query is run on this Wednesday (06/23), 
--the second CTE subquery will filter out all records from Monday (06/21) to Wednesday (06/23) since number of days is less than 7.
--the second CTE subquery will return last day of each full week (i.e, Sunday of each full week)
--Then from this output get the latest Sunday-- this will be Sunday of latest full week

Select count(distinct OAuth_Id) from interactions_ordered 
where OAuth_Id in ( Select OAuth_Id from Registered_Users) and 
DATEDIFF(day,InteractionDate,(Select Latest_Sunday from Sunday))<7

-- This final query :
--Filter those records whose interaction date is within 7 days of Latest full week's Sunday
--Then counts number of unique registered users for that 7 days. 




