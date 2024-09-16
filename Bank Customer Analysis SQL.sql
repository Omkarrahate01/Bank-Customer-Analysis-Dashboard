Create database Newton;
use newton;

create table customerinfo(
CustomerId int,
Surname varchar(50),
Age int,
GendeCategory varchar(50),
EstimatedSalary decimal(10,2),
GeographyLocation varchar(50),
BankDOJ date );

select * from customerinfo;

create table bankchurn(
CustomerId int,
CreditScore	int,
Tenure	int,
Balance decimal(10,2),
NumOfProducts int,
CardHoldingStatus varchar(50),
MemberStatus varchar(50),
ExitStatus varchar(50) );

select * from bankchurn;

-- 1.What is the distribution of account balances across different regions?
select c.GeographyLocation,round(SUM(bc.Balance)) AS account_balances
FROM customerinfo c
JOIN bankchurn bc
ON c.CustomerId=bc.CustomerID
group by GeographyLocation;

-- 2.Identify the top 5 customers with the highest Estimated Salary in the last quarter of the year. (SQL)
select Surname, Sum(EstimatedSalary) as Highest_salary
from customerinfo
where month(BankDOJ) in(10,11,12) 
group by Surname
order by  Highest_salary desc
limit 5;

-- 3.Calculate the average number of products used by customers who have a credit card. (SQL)
select c.Surname, Avg(bs.NumofProducts) as Product_avg
from bankchurn bs
join customerinfo c
on c.CustomerId = bs.CustomerID
where CardHoldingStatus = 'Credit Card Holder'
group by c.Surname;

-- 4.Determine the churn rate by gender for the most recent year in the dataset.
with CTE as(
select c.GendeCategory,count(c.CustomerId) as Churn
	from customerinfo c 
    join bankchurn bc 
    on c.CustomerId=bc.CustomerId
	where ExitStatus = 'Exit' and 
    year(BankDOJ)=(select max(year(BankDOJ)) from customerinfo) GROUP BY c.GendeCategory
),totalCTE as
(select GendeCategory, count(*) as 'total'
	FROM customerinfo
    group by GendeCategory)
select a.GendeCategory, ROUND(Churn/total,2)*100 as `churn rate`
from CTE a
join totalCTE b
on a.GendeCategory=b.GendeCategory
group by a.GendeCategory;

-- 5.Compare the average credit score of customers who have exited and those who remain. (SQL)
Select ExitStatus, Avg(CreditScore)
from bankchurn
group by ExitStatus;

-- 6.Which gender has a higher average estimated salary, and how does it relate to the number of active accounts? (SQL)
select c.GendeCategory, Avg(c.EstimatedSalary) as Highest_salary, count(bc.MemberStatus) as Active_Accounts
From customerinfo c
Join bankchurn bc
ON c.CustomerId = bc.CustomerId
where bc.MemberStatus = 'Active Member'
group by c.GendeCategory
Limit 1;

-- 7.Segment the customers based on their credit score and identify the segment with the highest exit rate. (SQL)
select case  
when CreditScore between 300 and 400 then '300-400'
when CreditScore between 400 and 500 then '400-500'
when CreditScore between 500 and 600 then '500-600'
when CreditScore between 600 and 700 then '600-700'
Else '700-800' end as CreditScoreRange,
count(CustomerId) as Highest_Exit_Rate
from bankchurn
where ExitStatus ='Exit'
Group by CreditScoreRange
Order by Highest_Exit_Rate Desc;

-- 8.Find out which geographic region has the highest number of active customers with a tenure greater than 5 years. (SQL)
select c.GeographyLocation, Count(bc.CustomerID) as 'Active_Member'
from  customerinfo c
join bankchurn bc
on c.CustomerID = bc.CustomerID
where bc.MemberStatus = 'Active Member' and bc.Tenure>5
group by GeographyLocation
order by Active_Member desc
limit 1;

-- 9.What is the impact of having a credit card on customer churn, based on the available data?
select CardHoldingStatus, ExitStatus, Count(CustomerID) as Customer_Count
from bankchurn
where CardHoldingStatus = 'Credit Card Holder'
group by ExitStatus;

-- 10.For customers who have exited, what is the most common number of products they have used?-- 
select NumOfProducts, Count(CustomerID) as Custmer_Count
from bankchurn
where ExitStatus = 'Exit'
group by NumOfProducts
order by Custmer_Count desc ;


-- 11.Examine the trend of customer exits over time and identify any seasonal patterns (yearly or monthly). Prepare the data through SQL and then visualize it.
select year(c.BankDOJ) as 'Years', count(c.CustomerID) as Customer_Exits
from customerinfo c
join bankchurn bc
on c.CustomerID = bc.CustomerID
where ExitStatus = 'Exit'
group by Years
order by Customer_Exits desc;

-- 12.Analyse the relationship between the number of products and the account balance for customers who have exited.
select NumOfProducts, Round(Avg(Balance),0) as Avg_balance
from bankchurn 
where ExitStatus = 'Exit'
group by NumOfProducts;

-- 13.Identify any potential outliers in terms of balance among customers who have remained with the bank-- 
select c.Surname, Sum(bc.Balance) as Acc_balance
from customerinfo c
join bankchurn bc
on c.CustomerId = bc.CustomerId
where bc.ExitStatus = 'Retain'
group by c.Surname
order by Acc_balance desc;

-- 15.Using SQL, write a query to find out the gender-wise average income of males and females in each geography id. Also, rank the gender according to the average value. (SQL)
with CTE as
(select GendeCategory, GeographyLocation, round(avg(EstimatedSalary),0) as Avg_income
from customerinfo 
group by GendeCategory, GeographyLocation)
	select *,
    dense_rank() over (order by Avg_income DESC) as 'Rank'
    from CTE;
    
-- 16.Using SQL, write a query to find out the average tenure of the people who have exited in each age bracket (18-30, 30-50, 50+).
select case  
when Age between 18 and 30 then '18-30'
when Age between 30 and 50 then '30-50'
Else '50+' end as Age_Bracket, Avg(bc.Tenure) as Avg_Age
from customerinfo c
join bankchurn bc
on c.CustomerId = bc.CustomerId
where ExitStatus ='Exit'
group by Age_Bracket;
    
    
-- 17.Is there any direct correlation between salary and the balance of the customers? And is it different for people who have exited or not?
--     SOLVED IN Power BI
    
-- 18.	Is there any correlation between the salary and the Credit score of customers?
--    SOLVED IN Power BI
 
 19.Rank each bucket of credit score as per the number of customers who have churned the bank
select case  
when CreditScore between 300 and 400 then '300-400'
when CreditScore between 400 and 500 then '400-500'
when CreditScore between 500 and 600 then '500-600'
when CreditScore between 600 and 700 then '600-700'
Else '700-800' end as CreditScoreRange,
count(CustomerId) as Churned_Customer,
rank() over (order by count(CustomerId) desc) as Credit_Rank
from bankchurn
group by CreditScoreRange;

-- 20.	According to the age buckets find the number of customers who have a credit card. 
-- Also retrieve those buckets that have lesser than average number of credit cards per bucket.
with CreditCardCounts as(
select case 
when Age >= 18 and Age <= 30 then '18-30'
when Age >= 31 and Age <= 40 then '31-40'
when Age >= 41 and Age <= 50 then '41-50'
when Age >= 51 and Age <= 60 then '51-60'
when Age >= 61 and Age <= 70 then '61-70'
when Age >= 71 and Age <=80  then '71-80'
when Age >80 then '80+' end as AgeBucket,
SUM(case when bc.CardHoldingStatus = 'Credit Card Holder' THEN 1 ELSE 0 END) AS CreditCardCount
FROM customerinfo c
JOIN bankchurn bc 
on c.CustomerId = bc.CustomerId
group by AgeBucket)
select AgeBucket, CreditCardCount
from CreditCardCounts
where CreditCardCount < (select avg(CreditCardCount) FROM CreditCardCounts);

-- 21. Rank the Locations as per the number of people who have churned the bank and the average balance of the learners.
with AverageBalance as(
select c.GeographyLocation, count(c.CustomerId) as ChurnedCount, round(avg(bc.Balance),0) as AvgBalance
from customerinfo c
join bankchurn bc 
on c.CustomerId = bc.CustomerId
where ExitStatus = 'Exit'
group by GeographyLocation)
select GeographyLocation, ChurnedCount, AvgBalance,
rank() over (order by ChurnedCount desc, AvgBalance desc) as LocationRank
from AverageBalance;

-- 22.	As we can see that the “CustomerInfo” table has the CustomerID and Surname, 
-- now if we have to join it with a table where the primary key is also a combination of CustomerID and Surname, 
-- come up with a column where the format is “CustomerID_Surname”. 
select concat(CustomerId, '_', Surname) as CustomerID_Surname
from customerinfo;

-- 23.	Without using “Join”, can we get the “ExitCategory” from ExitCustomers table to Bank_Churn table? If yes do this using SQL.
-- we can do it using a Subquery  
select bc.CustomerId,
(select ExitCategory 
from ExitCustomers ec 
where ec.CustomerID = bc.CustomerID) as ExitCategory
from bankchurn bc;

-- 24.	Were there any missing values in the data, using which tool did you replace them and what are the ways to handle them?
To find missing values, we can use the IS NULL condition
also we can replace Missing Values with the Average/Median/Mode

-- 25.	Write the query to get the customer IDs, their last name, and whether they are active or not for the customers whose surname ends with “on”.
select c.CustomerId,c.Surname,bc.MemberStatus
from customerinfo c 
join bankchurn bc 
on c.CustomerId = bc.CustomerId
Where c.Surname like('%on');

-- ******** SUBJECTIVE QUESTIONS ***********
-- 9.	Utilize SQL queries to segment customers based on demographics and account details.
-- a) Segmenting by Age Group and Gender
select case 
when Age < 20 then 'Under 20'
when Age between 20 and 29 then '20-29'
when Age between 30 and 39 then '30-39'
when Age between 40 and 49 then '40-49'
when Age between 50 and 59 then '50-59'
else '60 and Above'
end as AgeGroup, GendeCategory, count(CustomerId) as CustomerCount
from customerinfo
group by case 
when Age < 20 then 'Under 20'
when Age between 20 and 29 then '20-29'
when Age between 30 and 39 then '30-39'
when Age between 40 and 49 then '40-49'
when Age between 50 and 59 then '50-59'
else '60 and Above'
END, GendeCategory
ORDER BY AgeGroup, GendeCategory;

-- b. Segmenting by Tenure and Active Membership Status
select Tenure, MemberStatus, Count(CustomerID) as CustomerCount
from bankchurn
group by Tenure, MemberStatus
order by Tenure, MemberStatus;




