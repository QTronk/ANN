/*1.  Sử dụng Select và Union để  “hợp”  tập dữ liệu lấy từ bảng  Customers  và 
Employees.  Thông  tin  gồm  CodeID,  Name,  Address,  Phone.  Trong  đó 
CodeID là CustomerID/EmployeeID, Name là Companyname/LastName 
+ FirstName, Phone là Homephone.*/
	select CustomerID, CompanyName, Address, Phone
	from Customers
	union
	select cast(EmployeeID as nchar), LastName+' '+FirstName AS Name, Address, HomePhone
	from Employees

/*2.  Dùng lệnh SELECT…INTO tạo bảng  HDKH_71997  chứa thông tin về 
các  khách  hàng  gồm  :  CustomerID,  CompanyName,  Address,  ToTal 
=sum(quantity*Unitprice) , với total là tổng tiền khách hàng đã mua trong 
tháng 7 năm 1997.*/
	select c.CustomerID, CompanyName, Address, sum(quantity*unitprice) as Total
	into HDKH_71997
	from Customers c, [Order Details] od, orders o 
	where c.CustomerID=o.CustomerID and o.OrderID=od.OrderID 
	and month(OrderDate)= 7 and year(OrderDate)=1997
	group by c.CustomerID, CompanyName, Address
	
	select * from HDKH_71997

/*3.  Dùng lệnh SELECT…INTO tạo bảng LuongNV chứa dữ liệu về nhân viên 
gổm  :  EmployeeID,  Name  =  LastName  +  FirstName,  Address,  ToTal 
=10%*sum(quantity*Unitprice)  , với Total là  tổng lương của nhân viên 
trong tháng 12 năm 1996.*/
	select e.EmployeeID, LastName+' '+FirstName as Name, Address, 0.1*(sum(quantity*Unitprice)) as Total
	into LuongNV
	from Employees e, orders o, [Order Details] od
	where e.EmployeeID=o.EmployeeID and o.OrderID=od.OrderID
	and month(OrderDate)=12 and year(orderdate)=1996
	group by  e.EmployeeID, LastName,FirstName, Address

	select * from LuongNV

/*4.  Dùng lệnh SELECT…INTO tạo bảng Ger_USA  chứa thông tin về các hóa 
đơn xuất bán trong quý 1 năm 1998 với địa chỉ nhận hàng thuộc các quốc 
gia (ShipCountry) là 'Germany' và 'USA', do công ty vận chuyển ‘Speedy 
Express’ thực hiện.*/
	select o.*
	into Ger_USA
	from orders o join Shippers s
	on o.ShipVia=s.ShipperID
	where o.ShipCountry in ('Germany', 'USA') and s.companyname='Speedy Express'

	select * from Ger_USA























