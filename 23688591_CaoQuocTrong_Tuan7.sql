/*1.	Liệt kê danh sách các orders ứng với tổng tiền của từng hóa đơn. 
Thông tin bao gồm OrderID, OrderDate, Total. 
Trong đó Total là Sum của Quantity * Unitprice, kết nhóm theo OrderID. */
	select o.orderid, o.OrderDate, sum(Quantity*UnitPrice) as 'Total'
	from  [Order Details] od join Orders o on od.OrderID=o.OrderID 
	group by o.OrderID, o.OrderDate

/* 2.	Liệt kê danh sách các orders mà địa chỉ nhận hàng ở thành phố  ‘Madrid’ (Shipcity).
 Thông tin bao gồm OrderID, OrderDate, Total. 
 Trong đó Total là tổng trị giá hóa đơn, kết nhóm theo OrderID. */

	 select o.OrderID, o.ShipCity, sum(Quantity*UnitPrice) as 'Total'
	 from [Order Details] od join Orders o on od.OrderID=o.OrderID
	 where o.ShipCity='Madrid'
	 group by o.OrderID, o.ShipCity

/*3.	Viết các truy vấn để thống kê số lượng các hóa đơn  : */

 --	Trong mỗi năm. Thông tin hiển thị : Year , CoutOfOrders ?
	select year(OrderDate) as Year, count(*) as 'CoutOfOrders'
	from Orders
	group by year(orderdate)

--	Trong mỗi tháng/năm . Thông tin hiển thị : Year , Month,  CoutOfOrders ?
	select year(OrderDate) as 'Year', month(orderdate) as 'Month', count(*) as 'CoutOfOrders'
	from Orders
	group by year(orderdate),month(OrderDate)

--	Trong mỗi tháng/năm và ứng với mỗi nhân viên. Thông tin hiển thị : Year, Month, EmployeeID,  CoutOfOrders ?
	select year(OrderDate) as 'Year', month(orderdate) as 'Month', e.EmployeeID, count(*) as 'CoutOfOrders'
	from orders o join Employees e on o.EmployeeID=e.EmployeeID 
	group by year(orderdate),month(OrderDate), e.EmployeeID

/*4.	Cho biết mỗi Employee đã lập bao nhiêu hóa đơn.
 Thông tin gồm EmployeeID, EmployeeName, CountOfOrder. 
 Trong đó  CountOfOrder là tổng số hóa đơn của từng employee.
  EmployeeName được ghép từ LastName và FirstName.*/
	select e.EmployeeID, e.LastName+ ' '+e.FirstName as EmployeeName, count(*) as CountOfOrder
	from Employees e join Orders o on e.EmployeeID=o.EmployeeID
	group by e.EmployeeID, e.LastName+ ' '+e.FirstName

/*5.	Cho biết mỗi Employee đã lập được bao nhiêu hóa đơn, ứng với tổng tiền các hóa đơn tương ứng.
 Thông tin gồm EmployeeID, EmployeeName, CountOfOrder , Total.*/
	select e.EmployeeID, e.LastName+ ' '+e.FirstName as EmployeeName, count(*) as CountOfOrder, sum(quantity*unitprice) as Total
	from Employees e, orders o, [Order Details] od
	where e.EmployeeID=o.EmployeeID and o.OrderID=od.OrderID
	group by e.EmployeeID, e.LastName+ ' '+e.FirstName 

/*6.	Liệt kê bảng lương của mỗi Employee theo từng tháng trong năm 1996 
gồm EmployeeID, EmployName, Month_Salary, Salary = sum(quantity*unitprice)*10%. 
Được sắp xếp theo Month_Salary, cùmg Month_Salary thì sắp xếp theo Salary giảm dần.*/
	select e.EmployeeID, e.LastName+ ' '+e.FirstName as EmployeeName, month(OrderDate) as Month_Salary, sum((quantity*unitprice)*0.1) as Salary
	from Employees e, Orders o, [Order Details] od
	where e.EmployeeID=o.EmployeeID and o.OrderID=od.OrderID and year(OrderDate)=1996
	group by e.EmployeeID, e.LastName+ ' '+e.FirstName, month(OrderDate)
	order by MONTH(orderdate), Salary desc

/*7. Tính tổng số hóa đơn và tổng tiền các hóa đơn của mỗi nhân viên đã bán
trong tháng 3/1997, có tổng tiền >4000. Thông tin gồm EmployeeID,
LastName, FirstName, CountofOrder, Total.*/
	select e.EmployeeID, LastName+' '+ FirstName as EmployeeName, count(*) as CountofOrder, sum(quantity*unitprice) as Total
	from Employees e join orders o on e.EmployeeID=o.EmployeeID
	join [Order Details] od on o.OrderID = od.OrderID
	where month(OrderDate)=3 and year(orderdate)=1997 
	group by  e.EmployeeID, LastName+' '+ FirstName 
	having sum(quantity*unitprice) >4000

/*8. Liệt kê danh sách các customer ứng với tổng số hoá đơn, tổng tiền các hoá
đơn, mà các hóa đơn được lập từ 31/12/1996 đến 1/1/1998 và tổng tiền các
hóa đơn >20000. Thông tin được sắp xếp theo CustomerID, cùng mã thì sắp
xếp theo tổng tiền giảm dần.*/
	select c.CustomerID, c.contactname, count(*) CountofOrder, SUM(od.UnitPrice * od.Quantity) as Total
	from Customers c, Orders o, [Order Details] od
	where c.CustomerID=o.CustomerID and o.OrderID=od.OrderID and OrderDate between '1996/12/31' and '1998/1/1' 
	group by c.CustomerID,c.contactname
	having SUM(od.UnitPrice * od.Quantity) >20000
	order by c.CustomerID,  Total desc

/*9. Liệt kê danh sách các customer ứng với tổng tiền của các hóa đơn ở từng
tháng. Thông tin bao gồm CustomerID, CompanyName, Month_Year, Total.
Trong đó Month_year là tháng và năm lập hóa đơn, Total là tổng của
Unitprice* Quantity.*/
	select c.CustomerID, CompanyName, concat(month(orderdate),'_',year(orderdate)) as Month_year , sum(unitprice*quantity) as Total
	from Customers c, Orders o, [Order Details] od
	where c.CustomerID=o.CustomerID and o.OrderID=od.OrderID
	group by c.CustomerID, CompanyName, month(orderdate), year(orderdate)

/*10.Liệt kê danh sách các nhóm hàng (category) có tổng số lượng tồn
(UnitsInStock) lớn hơn 300, đơn giá trung bình nhỏ hơn 25. Thông tin bao
gồm CategoryID, CategoryName, Total_UnitsInStock, Average_Unitprice.*/
	select ct.CategoryID , ct.CategoryName , sum(p.UnitsInStock) as Total_UnitsInStock, avg(unitprice) as Average_Unitprice
	from Categories ct, Products p
	where ct.CategoryID=p.CategoryID
	group by ct.CategoryID , ct.CategoryName
	having sum(p.UnitsInStock)>300 and avg(unitprice)<25

/*11.Liệt kê danh sách các nhóm hàng (category) có tổng số mặt hàng (product)
nhỏ hớn 10. Thông tin kết quả bao gồm CategoryID, CategoryName,
CountOfProducts. Được sắp xếp theo CategoryName, cùng CategoryName
thì sắp theo CountOfProducts giảm dần.*/
	select ct.CategoryID, ct.CategoryName, count(*) as CountOfProducts
	from Categories ct, Products p
	where ct.CategoryID=p.CategoryID
	group by ct.CategoryID, ct.CategoryName
	having count(*)<10
	order by CategoryName , CountOfProducts desc

/*12.Liệt kê danh sách các Product bán trong quý 1 năm 1998 có tổng số lượng
bán ra >200, thông tin gồm [ProductID], [ProductName], SumofQuatity*/
	select p.ProductID, ProductName,sum(od.quantity) as SumofQuatity
	from Products p, [Order Details] od, orders o
	where p.ProductID=od.ProductID and od.OrderID=o.OrderID and year(OrderDate)=1998 and datepart(QUARTER,OrderDate)=1
	group by p.ProductID,ProductName
	having sum(od.quantity) >200

/*13.Cho biết Employee nào bán được nhiều tiền nhất trong tháng 7 năm 1997*/
	select  e.EmployeeID, LastName+' '+ FirstName as EmployeeName, sum(quantity*unitprice) as Total
	from Employees e, orders o, [Order Details] od
	where e.EmployeeID=o.EmployeeID and o.OrderID=od.OrderID and month(OrderDate)=7 and year(orderdate)=1997
	group by e.EmployeeID, LastName+' '+ FirstName
	order by total desc

/*14.Liệt kê danh sách 3 Customer có nhiều đơn hàng nhất của năm 1996.*/
	select top 3 c.CustomerID, c.ContactName, count(OrderID) as CountofOrders
	from customers c, Orders o 
	where c.CustomerID=o.CustomerID and year(OrderDate)=1996
	group by c.CustomerID,c.ContactName
	order by CountofOrders desc

/*15.Liệt kê danh sách các Products có tổng số lượng lập hóa đơn lớn nhất. Thông
tin gồm ProductID, ProductName, CountOfOrders.*/
	select p.ProductID, ProductName, count(*) as CountOfOrders
	from Products p, [Order Details] od
	where p.ProductID=od.ProductID
	group by p.ProductID, ProductName
	order by CountOfOrders desc