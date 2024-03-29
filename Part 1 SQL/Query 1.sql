---1. Top 5 most popular pieces of content consumed this week. --

--Logic : 
--find the ids of contents which are played in this week from page impressions table.
--group by above by content id and count number of times the content is consumed.
--order the result in descending order and limit by 5 to get 5 most popular content.
--Join this content ids with content metadata table to get the details of the content 
with this_week_contents as (
Select Content_id, COUNT(Content_id) as Number_of_times_consumed
from Page_Impression
where datediff(day,CAST(_Timestamp as DATE),CAST(getdate() as Date))<7
group by Content_id
order by Number_of_times_consumed desc
limit 5
)
Select c.Content_Id,c.Content_type,C.Body,C.Author
from Content_Metadata c join this_week_contents cte 
on c.Content_Id=cte.Content_Id
