--BÀI TẬP 1: INSERT dữ liệu
/*a.  Insert  dữ liệu vào bảng KhachHang trong QLBH  với dữ liệu nguồn là 
bảng Customers trong NorthWind.*/
	use QLBH
	insert into QLBH.dbo.KhachHang (MaKh,TenKH)
	select CustomerID, ContactName
	from Northwind.dbo.Customers

	select * from QLBH.dbo.KhachHang

/*b.  Insert dữ liệu vào  bảng Sanpham trong QLBH. Dữ liệu nguồn là các sản 
phẩm có SupplierID từ 4 đến 29 trong bảng Northwind.dbo.Products */
	insert into QLBH.dbo.Sanpham (MaSP, TenSP)
	select p.ProductID, p.ProductName
	from Northwind.dbo.Suppliers s join Northwind.dbo.Products p
	on s.SupplierID=p.SupplierID
	where s.SupplierID>=4 and s.SupplierID<=29

	select * from qlbh.dbo.sanpham

/*c.  Insert dữ liệu vào  bảng HoaDon  trong QLBH. Dữ liệu nguồn là  các hoá 
đơn  có  OrderID  nằm  trong  khoảng  10248  đến  10350  trong
NorthWind.dbo.[Orders]*/
	insert into QLBH.dbo.hoadon (mahd, makh,noichuyen)
	select OrderID,CustomerID,ShipAddress
	from Northwind.dbo.Orders
	where OrderID>=10248 and OrderID<=10350  
	select * from qlbh.dbo.hoadon

/*d.  Insert dữ liệu vào  bảng CT_HoaDon  trong QLBH. Dữ liệu nguồn là  các 
chi tiết hoá đơn có OderID nằm trong khoảng 10248 đến 10350 trong 
NorthWind.dbo.[Order Detail]*/
	insert into QLBH.dbo.ct_hoadon (mahd,masp,soluong,dongia,chietkhau)
	select OrderID,ProductID, Quantity, UnitPrice, Discount
	from NorthWind.dbo.[Order Details] 
	where OrderID>=10248 and OrderID<=10350
	and ProductID IN (
    select Masp
    from QLBH.dbo.SanPham)

	select * from QLBH.dbo.ct_hoadon
 --BÀI TẬP 2: LỆNH UPDATE
/*1. Cập nhật chiết khấu 0.1 cho các mặt hàng trong các hóa đơn xuất bán vào
ngày ‘1/1/1997’*/
	update [Order Details]
	set Discount=0.1
	from [Order Details] od join orders o on od.OrderID=o.OrderID
	where day(OrderDate)=1 and month(orderdate)=1 and year(orderdate)= 1997

	select od.* from [Order Details] od, orders o
	where od.orderid=o.orderid
	and day(OrderDate)=1 and month(orderdate)=1 and year(orderdate)= 1997

/*2. Cập nhật đơn giá bán 17.5 cho mặt hàng có mã 11 trong các hóa đơn xuất
bán vào tháng 2 năm 1997*/
	update [Order Details]
	set UnitPrice=17.5
	from Orders
	where ProductID = 11 and month(orderdate)=2 and year(orderdate) = 1997

	select od.*
	from  Orders o, [Order Details] od
	where o.OrderID=od.OrderID 
	and ProductID=11 and month(orderdate)=2 and year(orderdate) = 1997

/*3. Cập nhật giá bán các sản phẩm trong bảng [Order Details] bằng với đơn
giá mua trong bảng [Products] của các sản phẩm được cung cấp từ nhà
cung cấp có mã là 4 hay 7 và xuất bán trong tháng 4 năm 1997*/
	update [Order Details] 
	set UnitPrice=p.UnitPrice
	from [Order Details] od join Products p
	on od.ProductID=p.ProductID
	join Orders o on o.OrderID=od.OrderID
	where SupplierID in (4,7) and month(orderdate)=4 and year(orderdate)=1997

	select p.*
	from [Order Details] od join Products p
	on od.ProductID=p.ProductID
	join Orders o on o.OrderID=od.OrderID
	where SupplierID in (4,7) and month(orderdate)=4 and year(orderdate)=1997

/*4. Cập nhật tăng phí vận chuyển (Freight) lên 20% cho những hóa đơn có
tổng trị giá hóa đơn >= 10000 và xuất bán trong tháng 1/1997*/
	update Orders
	set Freight=Freight*1.2
	from Orders o join [Order Details] od
	on o.OrderID=od.OrderID
	where (Quantity*UnitPrice) >= 10000 and month(orderdate)=1 and year(orderdate)=1997

	select o.*
	from Orders o join [Order Details] od
	on o.OrderID=od.OrderID
	where (Quantity*UnitPrice) >= 10000 and month(orderdate)=1 and year(orderdate)=1997

/*5. Thêm 1 cột vào bảng Customers lưu thông tin về loại thành viên :
Member97 varchar(3) . Cập nhật cột Member97 là ‘VIP’ cho những
khách hàng có tổng trị giá các đơn hàng trong năm 1997 từ 50000 trở lên.*/
	alter table customers add Member97 varchar(3)

	UPDATE Customers
	SET Member97 = 'VIP'
	WHERE CustomerID IN (SELECT o.CustomerID
    FROM orders o join [Order Details] od
	on o.OrderID=od.OrderID
    WHERE YEAR(OrderDate) = 1997
    GROUP BY o.CustomerID
    HAVING SUM(od.UnitPrice * od.Quantity) >= 50000)
/*BÀI TẬP 3: LỆNH DELETE
1. Xóa các dòng trong [Order Details] có ProductID 24, là “chi tiết của
hóa đơn” xuất bán cho khách hàng có mã ‘SANTG’*/
	DELETE FROM [Order Details]
	WHERE ProductID = 24
	AND OrderID IN (SELECT OrderID FROM Orders WHERE CustomerID = 'SANTG');
	
/*2. Xóa các dòng trong [Order Details] có ProductID 35, là “chi tiết của
hóa đơn” xuất bán trong năm 1998 cho khách hàng có mã ‘SANTG’*/
	delete from [Order Details]
	where ProductID =35
	and OrderID in (select OrderID
	from Orders 
	where CustomerID = 'SANTG' and year(orderdate)=1998)

/*3. Thực hiện xóa tất cả các dòng trong [Order Details] là “chi tiết của các
hóa đơn” bán cho khách hàng có mã ‘SANTG’*/
	delete from [Order Details]
	from [Order Details] od join Orders o
	on od.OrderID=o.OrderID
	where o.CustomerID='SANTG'

	select * from [Order Details] od join Orders o
	on od.OrderID = o.OrderID
	where CustomerID = 'SANTG'