--Đề bài: Tính RETURN RATE của từng sản phẩm trong năm 2016 & 2017
--B1: Gộp bảng sales của năm 2016 và 2017
--B2: Tính total order quantity
--B3: Tính total return quantity
--B4: Gộp kết quả của bước 2 & 3 với bảng Products để lấy tên sản phẩm tương ứng
--B5: Tính RETURN RATE = total return quantity / total order quantity theo từng sản phầm

Select *
From sales2016

Select *
From sales2017

Select *
From Products

Select *
From Returns

--Show sale data table & order by date

Select * From sales2016
Order by 1,2

-- union with Sale 2017

Select * From sales2016
Union
Select * From sales2017
Order by 1,2

-- Looking at number of order by productkey

Select ProductKey, TerritoryKey, Sum(orderquantity) as order_number
From
(Select * From sales2016
	Union
		Select * From sales2017) as sales
Group by sales.ProductKey, sales.TerritoryKey
Order by 1,2

-- Looking at number of return by productkey

Select ProductKey, TerritoryKey, Sum(returnquantity) as return_number
From Returns re
Group by re.ProductKey, re.TerritoryKey
Order by 1,2

--Group order_number va return_number by ProductKey & TerritoryKey
Select sales_table.*, return_table.return_number
From
(Select ProductKey, TerritoryKey, Sum(orderquantity) as order_number
From
(Select * From sales2016
	Union
		Select * From sales2017) as sales
Group by sales.ProductKey, sales.TerritoryKey) as sales_table
Left Join
(Select ProductKey, TerritoryKey, Sum(returnquantity) as return_number
From Returns re
Group by re.ProductKey, re.TerritoryKey) as return_table
On sales_table.productkey = return_table.ProductKey
And sales_table.TerritoryKey = return_table.TerritoryKey

-- Calculate return rate by ProductKey & TerritoryKey

Select gr_orders_returns.*, return_number / order_number * 100 as return_rate, productSKU, productname, modelname, productcost, productprice
From 
(
Select sales_table.*, return_table.return_number
From
(Select ProductKey, TerritoryKey, Sum(orderquantity) as order_number
From
(Select * From sales2016
	Union
		Select * From sales2017) as sales
Group by sales.ProductKey, sales.TerritoryKey) as sales_table
Left Join
(Select ProductKey, TerritoryKey, Sum(returnquantity) as return_number
From Returns re
Group by re.ProductKey, re.TerritoryKey) as return_table
On sales_table.productkey = return_table.ProductKey
And sales_table.TerritoryKey = return_table.TerritoryKey
) as gr_orders_returns
Left join products p
On gr_orders_returns.ProductKey = p.ProductKey
Order by 1 desc

--Replace "NULL" with "0" (using CASE WHEN)

With ProductSummary As
(
Select gr_orders_returns.*, return_number / order_number * 100 as return_rate, productSKU, productname, modelname, productcost, productprice
From 
(
Select sales_table.*, return_table.return_number
From
(Select ProductKey, TerritoryKey, Sum(orderquantity) as order_number
From
(Select * From sales2016
	Union
		Select * From sales2017) as sales
Group by sales.ProductKey, sales.TerritoryKey) as sales_table
Left Join
(Select ProductKey, TerritoryKey, Sum(returnquantity) as return_number
From Returns re
Group by re.ProductKey, re.TerritoryKey) as return_table
On sales_table.productkey = return_table.ProductKey
And sales_table.TerritoryKey = return_table.TerritoryKey
) as gr_orders_returns
Left join products p
On gr_orders_returns.ProductKey = p.ProductKey
)
Select ProductKey, TerritoryKey, order_number as total_orders,
case when return_number > 0 Then return_number else 0 end as total_returns,
case when return_rate > 0 Then return_rate else 0 end as returnrate,
ProductSKU, ProductName, ModelName, productcost, ProductPrice
From ProductSummary
Order by 1 desc