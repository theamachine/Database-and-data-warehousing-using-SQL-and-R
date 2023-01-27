USE VRG
GO
-- Part A:
-- (A)

SELECT * FROM TRANS
where TRANS.DateSold is null

SELECT * FROM TRANS
where TRANS.DateSold is not null


-- (B)

SELECT WorkID, Title, Medium, WORK.ArtistID, CONCAT (ARTIST.FirstName,' ',ARTIST.LastName) as FullName FROM WORK
INNER JOIN ARTIST on ARTIST.ArtistID = WORK.ArtistID
WHERE 
    (WORK.Title like '%Yellow%' or WORK.Title like '%Blue%' or WORK.Title like '%White%')

-- (C)

SELECT  DATEPART(YEAR , TRANS.DateSold) as Year, CUSTOMER_ARTIST_INT.ArtistID, SUM(TRANS.SalesPrice) as SumOfSubTotal, AVG (TRANS.SalesPrice) as AverageOfSubTotal
from TRANS
Inner join CUSTOMER_ARTIST_INT on CUSTOMER_ARTIST_INT.CustomerID = TRANS.CustomerID
group by ArtistID ,  DATEPART(YEAR , TRANS.DateSold) 

-- (D)

SELECT WORK.ArtistID , CUSTOMER.FirstName, CUSTOMER.LastName ,TRANS.WorkID, WORK.Title from WORK
inner join TRANS on  TRANS.WorkID = WORK.WorkID 
inner join CUSTOMER on CUSTOMER.CustomerID = TRANS.CustomerID

WHERE TRANS.SalesPrice > (SELECT AVG(TRANS.SalesPrice) FROM TRANS)

-- (E)

UPDATE CUSTOMER 
set EmailAddress = 'Johnson.lynda@somewhere.com' ,EncryptedPassword = 'aax1xbB'
WHERE FirstName='Lynda' and LastName='Johnson'  

SELECT FirstName, LastName, EmailAddress, EncryptedPassword FROM CUSTOMER

-- (F)
select *, DATEDIFF(day,x.DateSold,x.next_purchase) as Days_Difference from 
(Select CUSTOMER.*, TRANS.DateSold , lead(TRANS.DateSold,1,Null) over (PARTITION BY CUSTOMER.CustomerID ORDER BY TRANS.DateSold) as next_purchase 
from CUSTOMER
inner join TRANS on CUSTOMER.CustomerID = TRANS.CustomerID) x
where x.next_purchase is not Null

-- (G)

CREATE VIEW CustomerTransactionSummaryView AS

SELECT top 100 CONCAT(CUSTOMER.FirstName ,' ' ,CUSTOMER.LastName) as FullName, WORK.Title ,TRANS.DateAcquired , TRANS.DateSold ,(TRANS.SalesPrice - TRANS.AcquisitionPrice) as Profit
from CUSTOMER
inner join TRANS on TRANS.CustomerID = CUSTOMER.CustomerID
inner join WORK on WORK.WorkID = TRANS.WorkID
where TRANS.AskingPrice > 20000
order by AskingPrice Desc 

SELECT * from CustomerTransactionSummaryView 

-- (H)

with Purchase(CustomerID,mindate,maxdate)as
(
select TRANS.CustomerID , min(TRANS.DateAcquired) as min_date ,max(TRANS.DateAcquired) as max_date from TRANS 
group by TRANS.CustomerID
)

SELECT TRANS.TransactionID ,TRANS.DateAcquired , TRANS.CustomerID , CUSTOMER.FirstName ,
CUSTOMER.LastName ,Purchase.maxdate, Purchase.mindate, WORK.Medium,
CASE
    WHEN WORK.Medium ='High Quality Limited Print' THEN 1
	WHEN WORK.Medium ='Color Aquatint' THEN 2
    WHEN WORK.Medium = 'Water Color and Ink' THEN 3
    WHEN WORK.Medium = 'Oil and Collage' THEN 4
    ELSE 5
END as Medium_encode
--INTO #Purchase
From TRANS
inner join CUSTOMER on CUSTOMER.CustomerID = TRANS.CustomerID
inner join WORK on TRANS.WorkID = WORK.WorkID
inner join Purchase on Purchase.CustomerID = CUSTOMER.CustomerID

Where TRANS.DateAcquired between '2015-01-01' AND '2017-12-31'