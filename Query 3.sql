--3. -	Top 5 pieces of content from each content type consumed this week by 
-- only active users (using the above definition). 

--The statement 'This' week in the question is a bit ambigious. Hence I am going to assume that  
--the week need not be one full week since it is not explicitly called out. 
--That is, if I want to see the most popular contents on Wednesday, 
--with this query I will get the answer based on contents from Monday-Wednesday this week. (so, week!=7 days here)

SET DATEFIRST 1; --Assumption this week starts on Monday as stated in previous problem. 
--So changing default setting to set Monday as day 1.
with this_week_active_users as (
Select Ads_User_Id, _Timestamp
from (
Select Ads_User_Id, _Timestamp, DATEPART(Weekday,CAST(_Timestamp as DATE)) as interaction_week,
ROW_NUMBER() OVER(ORDER BY InteractionDate desc,DATEPART(Weekday,CAST(Timestamp as DATE))) as rn
from Ad_service_interaction_data 
where Dwell_Time>60 and DATEDIFF(CAST(Timestamp as DATE),getdate())<7 )t
where t.interaction_week=t.rn
),
--The inner query of this CTE will have Ads_userId, Day (number) when interaction happened, and a row number 
--The inner query filters out all records which are beyond 7 days 
--The filter in the outer query filters out all the records which are not in this week.
--For example, if the query is run on Wednesday, the row_number becomes equal to Weekday only for this week. 
--This will make sure that we are not counting from Wednesday last week to Wednesday this week.


contents_consumed_by_active_users as (
Select p.Content_Id,COUNT(p.Content_Id) as Number_of_Contents 
from Page_Impression p join this_week_active_users t 
on p.Ads_User_Id=t.Ads_User_Id and p._Timestamp=t._Timestamp
group by Content_Id
)
--count contents consumed by active users in this week
Select Content_type, Body from (
Select t2.Content_type,t1.Content_Id,t2.Body,t1.Number_of_Contents, 
DENSE_RANK() OVER(PARTITION BY t1.Content_type ORDER BY t1.Number_of_Contents DESC) as rnk
from contents_consumed_by_active_users t1 join Content_Metadata t2
on t1.Content_Id=t2.Content_Id
)t
where t.rnk<=5

--Count each content and rank based on the count. Finally return all the deatils of the top 5 content.

