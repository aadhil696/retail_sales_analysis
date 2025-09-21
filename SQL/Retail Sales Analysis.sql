--Find top 10 highest revenue generating products
select product_id, category, sub_category, sum(sale_price * quantity) as total_revenue
from df_orders
group by product_id, category, sub_category
order by total_revenue desc
fetch first 10 rows only;


-- Find top 5 highest selling products in each reqion
select *
from(
    select product_id, region, sum(sale_price * quantity) as top_revenue,
    row_number() over (partition by region order by sum(sale_price * quantity) desc) as rn
    from df_orders
    group by product_id, region
    ) t
    where rn <= 5
    order by region, top_revenue desc;
    
    
-- Find month over month growth comparison for 2022 and 2023 sales(eg: Jan 2022 vs Jan 2023)    
select 
    to_char(order_date, 'YYYY') as year,
    to_char(order_date, 'MON') as month,
    sum(sale_price * quantity) as total_sales
from df_orders
where to_char(order_date, 'YYYY') IN ('2022', '2023')
group by to_char(order_date, 'YYYY'), to_char(order_date, 'MON'), to_char(order_date, 'MM')
order by to_char(order_date, 'MM'), year;

select
    to_char(order_date, 'MM') as month_no,
    to_char(order_date, 'MON') as month,
    sum(case when to_char(order_date, 'YYYY') = '2022' then sale_price * quantity end) as sales_2022,
    sum(case when to_char(order_date, 'YYYY') = '2023' then sale_price * quantity end) as sales_2023,
    round(
    ((sum(case when to_char(order_date, 'YYYY') = '2023' then sale_price * quantity end))-
    (sum(case when to_char(order_date, 'YYYY') = '2022' then sale_price * quantity end))
    )/nullif(sum(case when to_char(order_date, 'YYYY') = '2022' then sale_price * quantity end),0)
    * 100, 2
    ) as growth_rate
from df_orders
where to_char(order_date, 'YYYY') in ('2022', '2023')
group by to_char(order_date, 'MM'), to_char(order_date, 'MON')
order by month_no;

--For each category which month had highest sales
select *
from(
    select category,
    to_char(order_date, 'MON') as month,
    sum(sale_price * quantity) as total_revenue,
    row_number() over (partition by category order by sum(sale_price * quantity)) as rank
    from df_orders
    group by category, to_char(order_date, 'MON')
    ) t
    where rank = 1
    order by total_revenue desc;
    
-- Which sub category had highest growth by profit in 2023 compare to 2022
with highest_profit as (
select sub_category,
sum(case when to_char(order_date, 'yyyy') = '2022' then profit end) as profit_2022,
sum(case when to_char(order_date, 'yyyy') = '2023' then profit end) as profit_2023,
round(
    ((sum(case when to_char(order_date, 'yyyy') = '2023' then profit end)) -
    (sum(case when to_char(order_date, 'yyyy') = '2022' then profit end))
    )/
    nullif(sum(case when to_char(order_date, 'yyyy') = '2022' then profit end), 0)
    *100, 2
    ) as profit_growth
    from df_orders
    group by sub_category
    )
    select *
    from highest_profit
    order by profit_growth desc
    fetch first 3 row only;
