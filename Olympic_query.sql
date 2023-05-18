create database olympics;
use olympics;
select * from noc_regions;
select * from athlete_events;
select count(*) from athlete_events;

-- 1.How many olympics games have been held?
select count(distinct Games)
 from athlete_events;

-- 2.List down all Olympics games held so far.
select distinct(year),season,City from athlete_events;

-- 3.Mention the total no of nations who participated in each olympics game?
select a.games,count(distinct b.region) as nation from athlete_events a join noc_regions b on a.noc=b.noc group by a.games;

-- 4.Which year saw the highest and lowest no of countries participating in olympics?

select distinct (concat(first_value(d.games) over(order by d.total_countries),'-',
						first_value(d.total_countries) over (order by d.total_countries)))
						as lowest_countries,
                
		(concat(first_value(d.games) over(order by d.total_countries desc),'-',
                first_value(d.total_countries) over(order by d.total_countries desc))) as highest_countries
from
( select c.games,count(c.region) total_countries 
from (select a.games,b.region from athlete_events a join noc_regions b on a.noc=b.noc group by a.games,b.region)as c 
	group by c.games)as d;
    
 -- 5.Which nation has participated in all of the olympic games?   
select d.region,d.total_games as total_participated_games
from
(select c.*,dense_rank() over(order by c.total_games desc) as ranks
from
(select b.region,count(distinct a.games) as total_games from athlete_events a join noc_regions b on a.noc=b.noc group by b.region) as c)as d 
where d.ranks=1;

-- 6.Identify the sport which was played in all summer olympics.
with t1 as (select count(distinct games) as total_games 
from athlete_events 
where season='Summer'),
	
	t2 as
	(select sport,count(distinct games) as no_of_games
	from athlete_events
	where season='Summer'
	group by sport)

select *
from t2 join t1 on t2.no_of_games=t1.total_games;

-- 7. Which Sports were just played only once in the olympics

 select b.*
 from
 (select a.sport, count(*) as no_of_games, a.games from
 (select distinct games, sport from athlete_events) as a
 group by a.sport) as b
 where no_of_games=1
 order by  b.sport;
 
 -- 8. Fetch the total no of sports played in each olympic games.
 
 select games, count(distinct sport) as no_of_sports 
 from athlete_events
 group by games
 order by 2 desc;
 
 -- 9. Fetch oldest athletes to win a gold medal
 
select name,sex, age, team, games,city,sport,event,medal
from
( select *, dense_rank() over(order by age desc) as ran_win
 from athlete_events
 where medal = 'Gold')
 as a
 where a.ran_win=1;
 
 -- 10.Find the ratio of male and Female athlete participathed in all olympic games.
 
 with t1 as
(
select *,dense_rank() over(order by cou desc) as ran_cou
from (select sex,count(*) as cou
from athlete_events
group by sex)as a
),
t2 as
(
select cou as max_cou from t1 where ran_cou=1  
 
),
 t3 as
(
select cou as min_cou from t1 where ran_cou=2      
)
select concat('1 :',round(min_cou/max_cou,2)) as ratio
from t2,t3;

-- 11.Fetch the top 5 athelete who have won the most gold medals.alter

select b.name,b.team,b.count_gold
from
(
select a.*, dense_rank() over(order by a.count_gold desc) as rank_gold
from
(
select name,team,count(*) as count_gold
from athlete_events
where medal='Gold'
group by name
order by 3 desc
)as a
)as b ;

-- 12. Fetch the top 5 athletes who have won the most medals(gold/silver/bronze).

select b.name,b.team,b.count_medals
from
(
select a.*, dense_rank() over(order by a.count_medals desc) as rank_medals
from
(
select name,team,count(*) as count_medals
from athlete_events
where medal in ('Gold','Silver','Bronze')
group by name
order by 3 desc
 ) as a
 ) as b;
 
 -- 13. Fetch the top 5 most successful countries in olympics. Success is define by no. of medals won.
 
 select b.*
 from
 (
 select a.*, dense_rank() over(order by a.count_medal desc) as rank_medal
 from
 (
 select b.region,count(*) as count_medal
 from athlete_events a join noc_regions b on a.noc = b.noc
 where medal in('Gold','Silver','Bronze')
 group by b.region
 order by 2 desc
 )as a
 )as b
 where b.rank_medal<=5;
 
 -- 14. List down total gold,silver,bronze medals won by each country.
 
 select b.region as country,
 count(case when medal='Gold' then medal else null end) as Gold,
 count(case when medal='Silver' then medal else null end ) as Silver,
 count(case when medal='Bronze' then medal else null end) as bronze
 from athlete_events a join noc_regions b on a.noc = b.noc
 where medal in ('Gold','Silver','Bronze')
 group by 1
 order by 2 desc;
 
 -- 15.List down total gold,silver and bronze medals won by each country corresponding to each olympics games.
 
 select a.games, b.region as country,
 count(case when medal='Gold' then medal else null end) as Gold,
 count(case when medal='Silver' then medal else null end ) as Silver,
 count(case when medal='Bronze' then medal else null end) as bronze
 from athlete_events a join noc_regions b on a.noc = b.noc
 where medal in ('Gold','Silver','Bronze')
 group by 1,2
 order by 1;
 
 -- 16.Identify which country won the  most gold,most silver and most bronze medals in each olympic games.

select distinct c.games,
(concat(first_value(c.country) over(partition by c.games order by c.gold desc),'-',
first_value(c.gold) over(partition by c.games order by c.gold desc))) as max_gold,

(concat(first_value(c.country) over(partition by c.games order by c.silver desc),'-',
first_value(c.silver) over(partition by c.games order by c.silver desc))) as max_silver,

(concat(first_value(c.country) over(partition by c.games order by c.bronze desc),'-',
first_value(c.bronze) over(partition by c.games order by c.bronze desc))) as max_bronze

from
( 
select a.games, b.region as country,
 count(case when medal='Gold' then medal else null end) as Gold,
 count(case when medal='Silver' then medal else null end ) as Silver,
 count(case when medal='Bronze' then medal else null end) as bronze
 from athlete_events a join noc_regions b on a.noc = b.noc
 where medal in ('Gold','Silver','Bronze')
 group by 1,2
 order by 1
) as c;

-- 17. Identify which country won the most gold, most silver, most bronze and most medals in each olympic games.

select distinct c.games,
(concat(first_value(c.country) over(partition by c.games order by c.gold desc),'-',
first_value(c.gold) over(partition by c.games order by c.gold desc))) as max_gold,

(concat(first_value(c.country) over(partition by c.games order by c.silver desc),'-',
first_value(c.silver) over(partition by c.games order by c.silver desc))) as max_silver,

(concat(first_value(c.country) over(partition by c.games order by c.bronze desc),'-',
first_value(c.bronze) over(partition by c.games order by c.bronze desc))) as max_bronze,

(concat(first_value(c.country) over(partition by c.games order by c.all_medals desc),'-',
first_value(c.all_medals) over(partition by c.games order by c.all_medals desc))) as max_medals

from
(
select d.*,sum(d.gold)+sum(d.silver)+sum(bronze) as all_medals
from
( 
select a.games, b.region as country,
 count(case when medal='Gold' then medal else null end) as Gold,
 count(case when medal='Silver' then medal else null end ) as Silver,
 count(case when medal='Bronze' then medal else null end) as bronze
 from athlete_events a join noc_regions b on a.noc = b.noc
 where medal in ('Gold','Silver','Bronze')
 group by 1,2
 order by 1
)as d
group by d.games,d.country
)as c;
 
-- 18. which countries have never won gold medal but have won silver/bronze medals ?

select c.*
from
(
select b.region as country,
 count(case when medal='Gold' then medal else null end) as Gold,
 count(case when medal='Silver' then medal else null end ) as Silver,
 count(case when medal='Bronze' then medal else null end) as bronze
 from athlete_events a join noc_regions b on a.noc = b.noc
 where medal in ('Gold','Silver','Bronze')
 group by 1
 order by 3 desc, 4 desc
 ) as c
 where c.gold=0;
 
 -- 19. In which sport/event,India has won highest medals.
 
 select d.sport, d.total_medals
 from
 (
 select c.*,dense_rank() over(order by c.total_medals desc) as rank_medals
 from
 (
 select a.sport,count(a.medal) as total_medals
 from athlete_events a join noc_regions b on a.noc = b.noc
 where region= 'India'
 group by a.sport
 )as c
 )as d
 where d.rank_medals=1;
 
-- 20. Break down all olympic games where india won medal for Hockey and how many medal in each olympic games.
 
 select a.team,a.sport,a.games,count(a.medal) as total_medals
 from athlete_events a join noc_regions b on a.noc = b.noc
 where b.region= 'India' and a.sport= 'Hockey'
 group by 3
 order by  4 desc;
 
 
 