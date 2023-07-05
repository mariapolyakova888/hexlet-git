-- 4-й шаг проекта:
 -- Подсчет общего количества покупателей

select
    count(customer_id) as customers_count
from customers;

-- 5-й шаг проекта:
-- Отчет о десятке лучших продавцов, выполнивших наибольшую выручку.Отсортирован по убыванию выручки

select
    concat(e.first_name, ' ', e.last_name) as name,
    count(s.sales_id) as operations, 
    sum(s.quantity * p.price) as income
from sales s
inner join employees e
on s.sales_person_id = e.employee_id
inner join products p
on s.product_id = p.product_id
group by 1
order by 3 desc
limit 10
;

-- 2. Отчет о продавцах, чья средняя выручка за сделку меньше средней выручки за сделку по всем продавцам.
--Отсортирован по возрастанию выручки

with tab as (
    select
        concat(e.first_name, ' ', e.last_name) as name,
        count(s.sales_id) as operations, 
        sum(s.quantity * p.price) as income,
        round(avg(s.quantity * p.price), 0) as average_income
    from sales s
    inner join employees e
    on s.sales_person_id = e.employee_id
    inner join products p
    on s.product_id = p.product_id
    group by 1
) 
select
    tab.name,
    tab.average_income
from tab
group by tab.name, tab.average_income
having tab.average_income < (select
                                  round(avg(s.quantity * p.price), 0) as average_income
                              from sales s
                              inner join employees e
                              on s.sales_person_id = e.employee_id
                              inner join products p
                              on s.product_id = p.product_id
                              )
order by tab.average_income asc
limit 10
;

--3. Отчет о выручке по дням недели, отсортированный по порядковому номеру дня недели

with tab as (
    select
        to_char(s.sale_date, 'id') as num_weekday,
        to_char(date(s.sale_date), 'day') as weekday,
        concat(e.first_name, ' ', e.last_name) as name,
        round(sum(s.quantity*p.price), 0) as income
    from sales s
    left join employees e
    on s.sales_person_id = e.employee_id
    left join products p
    on s.product_id = p.product_id
    group by 1, 2, 3
    order by 1, 3
)
select
    tab.name,
    tab.weekday,
    tab.income
from tab
group by tab.name, tab.weekday, tab.num_weekday, tab.income
order by tab.name, tab.num_weekday asc
;

-- 6-й шаг проекта:
  
  -- 1. Отчет о количестве покупателей в разных возрастных группах

select
    case
        when age >= 16 and age <= 25 then '16-25'
    	when age >= 26 and age <= 40 then '26-40'
    	when age >= 41 then '40+'
    end as age_category,
    count(customer_id) as count
from customers
group by 1
order by 1
;

 -- 2. Количество уникальных покупателей и выручка, которую они принесли

select distinct to_char(s.sale_date, 'YYYY-MM') as date,
       count(distinct s.customer_id) as total_customers,
       sum(s.quantity * p.price) as income
from sales s
inner join products p
on s.product_id = p.product_id
group by date
;

-- 3. Отчет о покупателях, 1-ая покупка которых совершена в ходе проведения акций (акционные товары равны 0)

with tab as (
    select distinct
        c.customer_id,
        concat(c.first_name, ' ', c.last_name) as customer,
        s.sale_date,
        concat(e.first_name, ' ', e.last_name) as seller,
        p.price
from sales s
inner join customers c
on s.customer_id = c.customer_id
inner join employees e
on s.sales_person_id = e.employee_id
inner join products p
on s.product_id = p.product_id
where price = 0
order by c.customer_id
)
select distinct on (tab.customer)
    tab.customer,
    tab.sale_date,
    tab.seller
from tab
order by tab.customer
;