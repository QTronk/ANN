use Northwind
--1
select a.OrderID, OrderDate, CustomerID, a.EmployeeID, ProductID, b.Quantity, b.UnitPrice, b.Discount 
from Orders A join [Order Details] B on A.OrderID=B.OrderID
where B.OrderID='10248'

--2
select c.CustomerID, CompanyName,Address, OrderID, OrderDate 
from Customers c join Orders o on c.CustomerID=o.CustomerID
where year(OrderDate) = 1997 and ( month(OrderDate)=7 or month(OrderDate)=9)
order by CustomerID desc, OrderDate desc
 
 --3
 select od.ProductID, p.ProductID, o.OrderID, o.OrderDate, od.Quantity
 from orders o join [Order Details] od on o.OrderID=od.OrderID
 join Products p on od.ProductID=p.ProductID
 where year(OrderDate)=1996 and month(orderdate)=7 and day(orderdate)=19

 --4
 select p.ProductID, p.ProductName,s.SupplierID, od.OrderID,od.Quantity, o.OrderDate
 from products p join [Order Details] od on p.ProductID=od.ProductID
 join Suppliers s on p.ProductID=s.SupplierID
 join Orders o on o.OrderID=od.OrderID
 where s.SupplierID in (1,3,6) and year(OrderDate)=1997 and datepart(quarter,orderdate)=2
 order by s.SupplierID asc, p.ProductID asc

 --5
 select p.*
 from Products p join [Order Details] od on p.ProductID=od.ProductID
 where p.UnitPrice=od.UnitPrice

 --6
 select p.ProductID, p.ProductName, o.OrderID, o.OrderDate, o.CustomerID, p.UnitPrice, od.Quantity, quantity*od.UnitPrice as ToTal
 from Products p join [Order Details] od on p.ProductID= od.ProductID
 join orders o on od.OrderID = o.OrderID
 where datepart(weekday, orderdate) in (1,7) and month(orderdate)=12 and year(OrderDate)=1996 
 order by p.ProductID, quantity desc

 --7
 select e.EmployeeID, e.LastName+' '+e.FirstName as EmployeeName, o.OrderID, o.OrderDate
 from Employees e join Orders o on e.EmployeeID = o.EmployeeID
 where month(orderdate)=7 and  year(orderdate)=1996

 --8
 select o.OrderID, o.OrderDate, od.ProductID, od.Quantity, od.UnitPrice
 from Employees e join orders o on e.EmployeeID=o.EmployeeID
 join [Order Details] od on od.OrderID=o.OrderID
 where e.LastName ='Fuller'

 --9
 select e.EmployeeID,e.LastName+' '+e.FirstName as EmployeeName, o.OrderID, o.OrderDate, od.ProductID, Quantity, UnitPrice, quantity*UnitPrice as ToTalLine
 from Employees e join orders o on e.EmployeeID=o.EmployeeID
 join [Order Details] od on od.OrderID=o.OrderID
 where year(OrderDate)=1996

--10
select *
from Orders
where  month(RequiredDate)=12 and year(RequiredDate)=1996 and DATEPART(weekday,RequiredDate)=7 

--cau 11
SELECT e.EmployeeID, e.LastName + ' '+ e.FirstName as EmployeeName
FROM Employees e
LEFT JOIN Orders o ON e.EmployeeID = o.EmployeeID
WHERE o.OrderID IS NULL;

--cau 12
select p.ProductID, p.ProductName
from Products p left join [Order Details] od on p.ProductID=od.ProductID
where od.OrderID is null

--cau 13
select c.CustomerID, c.ContactName
from Customers c left join orders o on c.CustomerID=o.CustomerID
where o.OrderID is null




