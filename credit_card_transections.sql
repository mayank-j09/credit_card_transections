
1- write a query to print top 5 cities with highest spends and their percentage contribution of total credit card spends 

select top 5 city,sum(amount) total_spend,(sum(amount)/(select sum(amount) from credit_card_transections))*100 perc_contribution from credit_card_transections
group by city
order by total_spend desc

2- write a query to print highest spend month and amount spent in that month for each card type
with cte as (select *,row_number() over(partition by card_type order by highest_spend_in_this_month desc) rnk from (
select card_type,datepart(month,date) month_,sum(amount) highest_spend_in_this_month from credit_card_transections
group by card_type,datepart(month,date)) a )

select card_type,month_,highest_spend_in_this_month from cte
where rnk='1'

3- write a query to print the transaction details(all columns from the table) for each card type when
it reaches a cumulative of 1000000 total spends(We should have 4 rows in the o/p one for each card type)
with cte as (
select *,rank() over(partition by card_type order by cumulative_spend asc) rnk from (
select *,sum(amount) over(partition by card_type order by amount asc) cumulative_spend from credit_card_transections) a
where cumulative_spend>100000)
select * from cte
where rnk=1

4- write a query to find city which had lowest percentage spend for gold card type

select top 1 city from credit_card_transections
where card_type='Gold'
order by amount asc

5- write a query to print 3 columns:  city, highest_expense_type , lowest_expense_type (example format : Delhi , bills, Fuel)
with cte as (
select *,rank() over(partition by city order by amount desc) max_expense ,
rank() over(partition by city order by amount asc) min_expense from credit_card_transections)
select city,case when max_expense=1 then exp_type else null end,case when min_expense=1 then exp_type else null end from cte
group by city

 
6- write a query to find percentage contribution of spends by females for each expense type

select exp_type,(sum(case when gender='F' then amount else null end)/sum(amount))*100 female_perc_contribution from credit_card_transections
group by exp_type


7- which card and expense type combination saw highest month over month growth in Jan-2014
with cte as (select card_type,exp_type,datepart(year,date) year_,datepart(month,date) month_,sum(amount) exp_ from credit_card_transections
group by card_type,exp_type,datepart(year,date),datepart(month,date)),
cte_1 as (select *,max(exp_) over(order by exp_ rows between unbounded preceding and unbounded following) max_ from cte
where year_=2014 and month_=1)

select card_type,exp_type from cte_1
where max_=exp_

9- during weekends which city has highest total spend to total no of transcations ratio 

with cte as (select * from (
select *,datename(WEEKDAY,date) weekday_ from credit_card_transections) s
where weekday_='Saturday' or weekday_='Sunday')

select top 1 city,sum(amount)/count(amount) as ratio from cte
group by city
order by ratio desc

10- which city took least number of days to reach its 500th transaction after the first transaction in that city
with cte as (select city as city_1,date as date_1 from (
select *,row_number() over(partition by city order by date asc) rnk from credit_card_transections) a
where rnk =1),cte_1 as (

select city as city_500,date as date_500 from (
select *,row_number() over(partition by city order by date asc) rnk from credit_card_transections) a
where rnk =500),cte_2 as (
select * from cte inner join cte_1 on cte.city_1=cte_1.city_500)

select top 1 city_1 from (
select *,datediff(day,date_1,date_500) date_diff from cte_2) a
order by date_diff asc



