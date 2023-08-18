-- Данный запрос выводит общее количество покупателей из таблицы customers

select
    COUNT(customer_id) as customers_count
from customers;



-- Данный запрос выводит 10 лучших продавцов с их суммарной вырочкой и количеством проведенных сделок

select
    e.first_name || ' ' || e.last_name as name,
    COUNT(*) as operations,
    ROUND(SUM(p.price * s.quantity), 0) as income
from sales s
join employees e
    on s.sales_person_id = e.employee_id
join products p
    using(product_id)
group by 1
order by 3 desc
limit 10;



-- Данный запрос выводит продавцов, чья средняя выручка за сделку меньше средней выручки за сделку по всем продавцам

select
    e.first_name || ' ' || e.last_name as name,
    ROUND(AVG(p.price * s.quantity)) as average_income
from sales s
join employees e
    on s.sales_person_id = e.employee_id
join products p
    using(product_id)
group by 1
having AVG(p.price * s.quantity) < (
    select
        AVG(p.price * s.quantity)
    from sales s
    join products p
        using(product_id)
)
order by 2;



-- Данный запрос выводит информацию о выручке продавцов по дням недели

select
    e.first_name || ' ' || e.last_name as name,
    TO_CHAR(s.sale_date, 'day') as weekday,
    ROUND(SUM(s.quantity*p.price)) as income
from sales s
join products p
    using (product_id)
join employees e
    on s.sales_person_id = e.employee_id
group by 1, 2, EXTRACT(ISODOW from s.sale_date)
order by EXTRACT(ISODOW from s.sale_date), 1;



-- Данный отчет выводит количество покупателей в разных возрастных группах: 16-25, 26-40 и 40+

select
    case when age between 16 and 25
             then '16-25'
         when age between 26 and 40
             then '26-40'
         else '40+' end as age_category,
    COUNT(*) as count
from customers
group by 1
order by 1;



-- Данный запрос выводит количество уникальных покупателей и выручку, которую они принесли

select
    TO_CHAR(s.sale_date, 'YYYY-MM') as date,
    COUNT(distinct(s.customer_id)) as total_customer,
    ROUND(SUM(p.price*s.quantity), 0) as income
from sales s
join products p
    USING(product_id)
group by 1
order by 1;



-- Данный запрос выводит покупателей, первая покупка которых была в ходе проведения акций

with table1 as (
    select DISTINCT
        c.customer_id, 
        c.first_name || ' ' || c.last_name as customer,
        first_value (s.sale_date) over (partition by s.customer_id order by s.sale_date) as sale_date,
        e.first_name || ' ' || e.last_name as seller
    from sales s
    join products p using (product_id)
    join customers c using (customer_id)
    join employees e on s.sales_person_id = e.employee_id
    where p.price = 0
)
select
   customer,
   sale_date,
   seller
from table1
order by customer_id;




