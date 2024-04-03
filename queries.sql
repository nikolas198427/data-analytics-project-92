--считает количество пользователей в таблице

select count(customer_id) as customers_count
from customers;


--seller — имя и фамилия продавца
--operations - количество проведенных сделок
--income — суммарная выручка продавца за все время
--Подготовьте в файл top_10_total_income.csv отчет с продавцами у которых наибольшая выручка

select first_name ||' ' ||   last_name  seller
, count(sale_date) as operations
, round(sum(sales.quantity*products.price), 0) as income
from sales
inner join employees
on sales_person_id = employee_id
inner join products
on sales.product_id  = products.product_id 
group by seller
order by income
limit 10;

--Второй отчет содержит информацию о продавцах, чья средняя выручка за сделку меньше средней выручки за сделку по всем продавцам. 
--Таблица отсортирована по выручке по возрастанию.
--
--seller — имя и фамилия продавца
--average_income — средняя выручка продавца за сделку с округлением до целого

with num1 as (
select first_name || ' ' ||   last_name seller
--, count(sale_date) as operations
, avg(sales.quantity*products.price) as average_income
--, avg (income) over ()
from sales
inner join employees
on sales_person_id = employee_id
inner join products
on sales.product_id  = products.product_id 
group by seller
order by average_income 
), num2 as (select *
, avg (average_income) over ()
from num1
)
select seller, round(average_income, 0) as average_income
from num2
where average_income<avg
order by average_income;

--Третий отчет содержит информацию о выручке по дням недели. Каждая запись содержит имя и фамилию продавца, день недели и суммарную выручку. 
--Отсортируйте данные по порядковому номеру дня недели и seller
--
--seller — имя и фамилия продавца
--day_of_week — название дня недели на английском языке
--income — суммарная выручка продавца в определенный день недели, округленная до целого числа

with num1 as (
select first_name ||' ' ||   last_name as seller
, to_char(sale_date,'DAY') as day_of_week
, round(sum(price), 0) as income
, EXTRACT(ISODOW FROM sale_date) as num_day
--, to_char(sale_date,'D') as num_day
from sales
inner join employees
on sales_person_id = employee_id
inner join products
on sales.product_id  = products.product_id 
group by seller, day_of_week, num_day
)
select seller, day_of_week, income
from num1
order by num_day, seller;


--Первый отчет - количество покупателей в разных возрастных группах: 16-25, 26-40 и 40+. 
--Итоговая таблица должна быть отсортирована по возрастным группам и содержать следующие поля:
--
--age_category - возрастная группа
--count - количество человек в группе

select 
  case 
    when  age between  16 and  25 then  '16-25'
    when  age between  26 and  40 then  '26-40'
    else  '40+'
  end  as  age_category,
  count( * ) as  count
from 
  customers
group  by age_category
order  by age_category;


--Во втором отчете предоставьте данные по количеству уникальных покупателей и выручке, которую они принесли. 
--Сгруппируйте данные по дате, которая представлена в числовом виде ГОД-МЕСЯЦ. 
--Итоговая таблица должна быть отсортирована по дате по возрастанию и содержать следующие поля:
--
--date - дата в указанном формате
--total_customers - количество покупателей
--income - принесенная выручка

select to_char(sale_date, 'yyyy-mm') as date,  count(distinct customer_id) as total_customers, round(sum(price), 0) as income
from sales
inner join products
on sales.product_id  = products.product_id 
group by date
order by date

--Третий отчет следует составить о покупателях, первая покупка которых была в ходе проведения акций (акционные товары отпускали со стоимостью равной 0). 
--Итоговая таблица должна быть отсортирована по id покупателя. Таблица состоит из следующих полей:
--
--customer - имя и фамилия покупателя
--sale_date - дата покупки
--seller - имя и фамилия продавца

with tab1 as (
select  customers.first_name ||' '||   customers.last_name as customer
, sale_date
, ROW_NUMBER() OVER (PARTITION BY sales_person_id order by sale_date ) AS sale_number
, price
, employees.first_name ||' '||   employees.last_name as seller
from sales
inner join products
on sales.product_id  = products.product_id 
inner join customers
on sales.customer_id = customers.customer_id
inner join employees
on sales_person_id = employee_id
order by sales_person_id
)
select customer, sale_date, seller
--, sale_number , price
from tab1
where sale_number=1 and price = 0

