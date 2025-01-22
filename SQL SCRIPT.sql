SELECT distinct(p.product_name),b.base_price FROM retail_events_db.dim_products p
left  join retail_events_db.fact_events b on b.product_code=p.product_code
where b.base_price>500 and b.promo_type="BOGOF"

 SELECT count(Store_id) as number_of_store,city FROM retail_events_db.dim_stores
group by city 
order by number_of_store desc


SELECT 
    c.campaign_name,
    CONCAT(CAST(SUM(f.base_price * f.before_Promo) / 1000000 AS CHAR), ' Millions') AS Total_Revenue_Before_Promotion,
    CONCAT(CAST(SUM(f.base_price * f.After_Promo) / 1000000 AS CHAR), ' Millions') AS Total_Revenue_After_Promotion
FROM 
    retail_events_db.dim_campaigns c
INNER JOIN 
    retail_events_db.fact_events f 
ON 
    c.campaign_id = f.campaign_id
GROUP BY 
    c.campaign_name;

with cte as (
select c.campaign_name as campaign_name,round(sum(before_promo)/sum(After_Promo),2)*100 as incrementsoldpercentage 
from retail_events_db.fact_events f
inner join retail_events_db.dim_campaigns c on  f.campaign_id=c.campaign_id
group by c.campaign_name
)
select  campaign_name,incrementsoldpercentage,rank() over(order by incrementsoldpercentage desc) as ranks from cte


WITH cte AS (
    SELECT 
        p.product_name AS product_name,
        p.category AS category,
        (SUM(before_promo) - SUM(after_promo)) / SUM(before_promo) AS increment_revenue
    FROM retail_events_db.dim_products p
    INNER JOIN retail_events_db.fact_events f 
        ON p.product_code = f.product_code
    GROUP BY p.product_name, p.category
)
SELECT 
    product_name,
    category,
    RANK() OVER (ORDER BY increment_revenue DESC) AS rank_position -- New alias
FROM cte;

