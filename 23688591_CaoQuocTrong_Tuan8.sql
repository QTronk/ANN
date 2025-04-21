/*1.  Liệt kê  các product  có đơn giá  mua  lớn hơn đơn giá  mua  trung bình  của 
tất cả các product.*/
	select *
	from Products
	where UnitPrice > (select avg(unitprice) from products)

/*2.  Liệt kê các product có đơn giá mua lớn hơn đơn giá mua nhỏ nhất của tất 
cả các product.*/
	select *
	from Products
	where UnitPrice > (select min(unitprice) from Products)

/*3.  Liệt kê các product có đơn giá bán lớn hơn đơn giá bán trung bình của các 
product.  Thông  tin  gồm  ProductID,  ProductName,  OrderID,  Orderdate, 
Unitprice .*/
	select p.ProductID, p.ProductName, o.OrderID, o.OrderDate, od.UnitPrice
	from products p, [Order Details] od,  Orders o
	where p.ProductID=od.ProductID and od.OrderID=o.OrderID and od.UnitPrice > (select avg(unitprice)
	from [Order Details])

/*4.  Liệt kê các product có đơn giá bán lớn hơn đơn giá bán trung bình của các 
product có ProductName bắt đầu là ‘N’.*/
	select p.*
	from Products p, [Order Details] od
	where p.ProductID=od.ProductID and od.UnitPrice > (select avg(od.UnitPrice)
	from Products p join [Order Details] od on p.ProductID=od.ProductID and p.ProductName like 'N%')

/*5.  Cho biết  những sản phẩm có tên  bắt đầu bằng  ‘T’  và  có  đơn giá bán  lớn 
hơn đơn giá bán của (tất cả) những sản phẩm có tên bắt đầu bằng chữ ‘V’.*/
	select distinct p. *
	from Products p join [Order Details] od on p.ProductID=od.ProductID 
	where p.ProductName like 'T%' 
	and od.UnitPrice> all(select od.unitprice
	from Products p join [Order Details] od on p.ProductID=od.ProductID where p.ProductName like 'V%')
	
	select max(od.unitprice)
	from Products p join [Order Details] od on p.ProductID=od.ProductID where p.ProductName like 'V%'

/*6.  Cho biết sản phẩm nào có đơn giá bán cao nhất trong số những sản phẩm 
có đơn vị tính có chứa chữ ‘box’ .*/
	select distinct p.*, od.UnitPrice
	from Products p join [Order Details] od 
	on p.ProductID=od.ProductID
	where p.QuantityPerUnit like '%box%'
	and od.UnitPrice >= all(select od.UnitPrice 
	from Products p join [Order Details] od 
	on p.ProductID=od.ProductID 
	where p.QuantityPerUnit like '%box%')

/*7.  Liệt kê các product  có  tổng  số lượng bán  (Quantity)  trong năm 1998  lớn 
hơn tổng số lượng bán trong năm 1998 của mặt hàng có mã 71*/
	select p.*, od.Quantity
	from Products p ,[Order Details] od, orders o 
	where p.ProductID=od.ProductID and od.OrderID=o.OrderID
	and year(OrderDate)=1998
	and od.Quantity>all(select od.Quantity from Products p, [Order Details] od, Orders o
	where p.ProductID=od.ProductID and od.OrderID=o.OrderID
	and p.ProductID = 71 and year(OrderDate)=1998 )

/*8. Thực hiện :
- Thống kê tổng số lượng bán ứng với mỗi mặt hàng thuộc nhóm
hàng có CategoryID là 4. Thông tin : ProductID, QuantityTotal (tập A)*/
	select p.ProductID, sum(od.Quantity) as 'QuantityTotal (tập A)'
	from Products p join Categories ct on p.CategoryID=ct.CategoryID
	join [Order Details] od on od.ProductID=p.ProductID
	where p.CategoryID='4'
	group by p.ProductID

/*- Thống kê tổng số lượng bán ứng với mỗi mặt hàng thuộc nhóm
hàng khác 4 . Thông tin : ProductID, QuantityTotal (tập B)*/
	select p.ProductID, sum(od.Quantity) as 'QuantityTotal (tập B)'
	from Products p join Categories ct on p.CategoryID=ct.CategoryID
	join [Order Details] od on od.ProductID=p.ProductID
	where p.CategoryID<>'4'
	group by p.ProductID	

/*- Dựa vào 2 truy vấn trên : Liệt kê danh sách các mặt hàng trong tập
A có QuantityTotal lớn hơn tất cả QuantityTotal của tập B*/
	select p.ProductID, sum(od.Quantity) as 'QuantityTotal (tập A)'
	from Products p join Categories ct on p.CategoryID=ct.CategoryID
	join [Order Details] od on od.ProductID=p.ProductID
	where p.CategoryID='4'
	group by p.ProductID
	having sum(od.Quantity) > all(select  sum(od.Quantity)
	from Products p join Categories ct on p.CategoryID=ct.CategoryID
	join [Order Details] od on od.ProductID=p.ProductID
	where p.CategoryID<>'4'
	group by p.ProductID)

/*9. Danh sách các Product có tổng số lượng bán được lớn nhất trong năm 1998
Lưu ý : Có nhiều phương án thực hiện các truy vấn sau (dùng JOIN hoặc
subquery ). Hãy đưa ra phương án sử dụng subquery.*/
	select p.ProductID, p.ProductName, sum(od.quantity) as Higest_Quantity
	from Products p join [Order Details] od on p.ProductID=od.ProductID
	join Orders o on o.OrderID=od.OrderID
	where year(OrderDate)=1998 
	group by p.ProductID, p.ProductName
	having sum(od.quantity) >= all(select sum(od.quantity)
	from Products p join [Order Details] od on p.ProductID=od.ProductID
	join Orders o on o.OrderID=od.OrderID
	where year(OrderDate)=1998 
	group by p.ProductID)

/*10.Danh sách các products đã có khách hàng mua hàng (tức là ProductID có
trong [Order Details]). Thông tin bao gồm ProductID, ProductName, Unitprice*/
	select ProductID, ProductName, UnitPrice
	from Products 
	where ProductID = any(select ProductID from [Order Details])

/*11.Danh sách các hóa đơn của những khách hàng ở thành phố LonDon và Madrid.*/
	select *
	from Orders
	where CustomerID = any(select CustomerID
	from Customers where City in ('London', 'Madrid'))

/*12.Liệt kê các sản phẩm có trên 20 đơn hàng trong quí 3 năm 1998, thông tin
gồm ProductID, ProductName.*/
	select *
	from Products 
	where ProductID = any(select od.ProductID
	from Orders o join [Order Details] od on o.OrderID=od.OrderID
	where year(OrderDate)=1998 and DATEPART(quarter,OrderDate)=3
	group by od.ProductID
	having count(*) >20)

/*13.Liệt kê danh sách các sản phẩm chưa bán được trong tháng 6 năm 1996*/
	select *
	from Products
	where ProductID <> all(select ProductID
	from [Order Details] od join Orders o on od.OrderID=o.OrderID
	where month(OrderDate)=6 and year(OrderDate)=1996)

/*14.Liệt kê danh sách các Employes không lập hóa đơn vào ngày hôm nay*/
	select *
	from Employees
	where EmployeeID <> all(select EmployeeID
	from Orders
	where OrderDate = GETDATE())

/*15.Liệt kê danh sách các Customers chưa mua hàng trong năm 1997*/
	select *
	from Customers
	where CustomerID <> all(select CustomerID
	from Orders where year(OrderDate)=1997)

/*16.Tìm tất cả các Customers mua các sản phẩm có tên bắt đầu bằng chữ T
trong tháng 7 năm 1997*/
	select *
	from Customers
	where ContactName like 'T%' and CustomerID = any(select CustomerID
	from orders where month(OrderDate)=7 and year(orderdate)=1997)

/*17.Liệt kê danh sách các khách hàng mua các hóa đơn mà các hóa đơn này
chỉ mua những sản phẩm có mã >=3*/
	select *
	from Customers
	where CustomerID = any(select CustomerID
	from Products p join [Order Details] od on p.ProductID=od.ProductID
	join orders o on od.OrderID=o.OrderID
	where p.ProductID >= 3) 
	and CustomerID <> all(select CustomerID
	from Products p join [Order Details] od on p.ProductID=od.ProductID
	join orders o on od.OrderID=o.OrderID
	where p.ProductID < 3) 

/*18.Tìm các Customer chưa từng lập hóa đơn (viết bằng ba cách: dùng NOT
EXISTS, dùng LEFT JOIN, dùng NOT IN )*/
--not exists
	SELECT *
	FROM Customers c
	where not exists (select *
	from orders o where c.CustomerID=o.CustomerID)

--left join
	select *
	from Customers c left join Orders o on c.CustomerID=o.CustomerID
	where o.OrderID is null
	
-- not in 
	select *
	from Customers
	where CustomerID not in (select CustomerID from Orders)

--19.Bạn hãy mô tả kết quả của các câu truy vấn sau ?
	Select ProductID, ProductName, UnitPrice From [Products]
	Where Unitprice>ALL (Select Unitprice from [Products] where
	ProductName like 'N%')
--Hiện những sản phẩm có giá mua lớn hơn giả mua của tất cả sản phẩm có tên bắt đầu bằng từ N

	Select ProductId, ProductName, UnitPrice From [Products]
	Where Unitprice>ANY (Select Unitprice from [Products] where
	ProductName like 'N%')
--Hiện những sản phẩm có giá mua lớn hơn giá mua thấp nhất của những sản phẩm có tên bắt đầu bằng từ N

	Select ProductId, ProductName, UnitPrice from [Products]
	Where Unitprice=ANY (Select Unitprice from [Products] where
	ProductName like 'N%')
--Hiện những sản phẩm có giá mua bằng giá mua bất kỳ của một sản phẩm có tên bắt đầu bằng từ N

	Select ProductId, ProductName, UnitPrice from [Products]
	Where ProductName like 'N%' and
	Unitprice>=ALL (Select Unitprice from [Products] where
	ProductName like 'N%')
--Hiện những sản phẩm có giá mua cao nhất trong những sản phẩm có tên bắt đầu bằng từ N