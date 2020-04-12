# OTRS-Custom-SQL-Statistic
- Built for OTRS v6.0.x
- OTRS custom statistic module based on SQL

1. Sometime, there is a need to execute your own predefined SQL query to get the report that you need.  
2. However, by default only admin being able to execute the sql statement.  
3. Here are example of custom SQL query that being build into Statistic module so every agent with correct permission can access it.  

a) Example of statistic param  

[![download-1.png](https://i.postimg.cc/QxLzhk21/download-1.png)](https://postimg.cc/vDzhv9HZ)  

b) Example of result  

[![download2.png](https://i.postimg.cc/ryv5HfBX/download2.png)](https://postimg.cc/V5WSrWsD)  


4. Additionally, you can also do the SQL query on based CMDB Config Item.
*SQL NOT ATTACHED HERE*
The idea is :

a) CREATE TEMPORARY TABLE configitem_own_data  
b) GET DATA FROM CONFIG ITEM API BASED ON SEARCH PARAM  
c) PUT INTO MYSQL TABLE  
d) PUT DATA FROM MYSQL TO EXCEL  
e) So in sql statement, we can do group by, count data easily, etc.  
c) Example of statistic param  
[![download-2.png](https://i.postimg.cc/HkVqYNF6/download-2.png)](https://postimg.cc/SnbTVgS9)  

d) Example of result  
[![download3.png](https://i.postimg.cc/J4G80tk3/download3.png)](https://postimg.cc/hfW63DMh)  
