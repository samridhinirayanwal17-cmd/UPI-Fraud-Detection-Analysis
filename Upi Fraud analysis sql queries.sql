create table customers(customer_id varchar(100)	,
customer_name varchar(100),
age	int,
gender varchar(50),
city varchar(50),
kyc_verified varchar(50),
device_type	varchar(50),
account_open_date date,
Age_group varchar(100)
);

select* from customers;

create table transactions (transaction_id varchar(50) primary key,
customer_id varchar(100),
receiver_id varchar(100),	 
amount numeric(10,2) ,
transaction_date date,
transaction_time time,
device_type	varchar(50),
status	 varchar(50),
is_fraud int	,
day_type varchar(50)
);

select* from transactions;



create table receivers(receiver_id varchar(100) primary key,
receiver_name varchar(100),
receiver_type varchar(50),
receiver_city varchar(50),
receiver_bank varchar(50)
);

select * from receivers;



-- Overall Fraud rate
SELECT
	COUNT(*) AS TOTAL_TRANSACTIONS,
	SUM(IS_FRAUD) AS FRAUD_TRANSACTIONS,
	ROUND(100.0 * SUM(IS_FRAUD) / COUNT(*), 2) AS FRAUD_RATE
FROM
	TRANSACTIONS;

-- KYC verified vs unverified — fraud comparison
SELECT
	C.KYC_VERIFIED,
	COUNT(*) AS TOTAL_TXNS,
	SUM(T.IS_FRAUD) AS FRAUD_TXNS,
	ROUND(100.0 * SUM(T.IS_FRAUD) / COUNT(*), 2) AS FRAUD_RATE
FROM
	TRANSACTIONS T
	JOIN CUSTOMERS C ON T.CUSTOMER_ID = C.CUSTOMER_ID
GROUP BY
	C.KYC_VERIFIED;

 -- Fraud rate by device type
 SELECT
	DEVICE_TYPE,
	COUNT(*) AS TOTAL_TXNS,
	SUM(IS_FRAUD) AS FRAUD_TXNS,
	ROUND(100.0 * SUM(IS_FRAUD) / COUNT(*), 2) AS FRAUD_RATE
FROM
	TRANSACTIONS
GROUP BY
	DEVICE_TYPE
ORDER BY
	FRAUD_RATE DESC;

-- Top 5 receiver cities by fraud count
SELECT
	R.RECEIVER_CITY,
	COUNT(*) AS FRAUD_TXNS
FROM
	TRANSACTIONS T
	JOIN RECEIVERS R ON T.RECEIVER_ID = R.RECEIVER_ID
WHERE
	T.IS_FRAUD = 1
GROUP BY
	R.RECEIVER_CITY
ORDER BY
	FRAUD_TXNS DESC
LIMIT
	5;

-- Weekday vs weekend fraud pattern
SELECT
	DAY_TYPE,
	COUNT(*) AS TOTAL_TXNS,
	SUM(IS_FRAUD) AS FRAUD_TXNS,
	ROUND(100.0 * SUM(IS_FRAUD) / COUNT(*), 2) AS FRAUD_RATE
FROM
	TRANSACTIONS
GROUP BY
	DAY_TYPE;

-- Top 5 high-risk receivers (most fraud transactions received)
SELECT
	R.RECEIVER_ID,
	R.RECEIVER_NAME,
	R.RECEIVER_TYPE,
	COUNT(*) AS FRAUD_TXNS,
	SUM(T.AMOUNT) AS TOTAL_FRAUD_AMOUNT
FROM
	TRANSACTIONS T
	JOIN RECEIVERS R ON T.RECEIVER_ID = R.RECEIVER_ID
WHERE
	T.IS_FRAUD = 1
GROUP BY
	R.RECEIVER_ID,
	R.RECEIVER_NAME,
	R.RECEIVER_TYPE
ORDER BY
	FRAUD_TXNS DESC
LIMIT
	5;

-- Individual vs Merchant receiver — fraud comparison
SELECT
	R.RECEIVER_TYPE,
	COUNT(*) AS TOTAL_TXNS,
	SUM(T.IS_FRAUD) AS FRAUD_TXNS,
	ROUND(100.0 * SUM(T.IS_FRAUD) / COUNT(*), 2) AS FRAUD_RATE
FROM
	TRANSACTIONS T
	JOIN RECEIVERS R ON T.RECEIVER_ID = R.RECEIVER_ID
GROUP BY
	R.RECEIVER_TYPE;

-- Average transaction amount — fraud vs genuine
SELECT
	CASE
		WHEN IS_FRAUD = 1 THEN 'Fraud'
		ELSE 'Genuine'
	END AS TXN_TYPE,
	ROUND(AVG(AMOUNT), 2) AS AVG_AMOUNT,
	ROUND(MAX(AMOUNT), 2) AS MAX_AMOUNT
FROM
	TRANSACTIONS
GROUP BY
	IS_FRAUD;

-- Age group vs fraud rate
SELECT
	C.AGE_GROUP,
	COUNT(*) AS TOTAL_TXNS,
	SUM(T.IS_FRAUD) AS FRAUD_TXNS,
	ROUND(100.0 * SUM(T.IS_FRAUD) / COUNT(*), 2) AS FRAUD_RATE
FROM
	TRANSACTIONS T
	JOIN CUSTOMERS C ON T.CUSTOMER_ID = C.CUSTOMER_ID
GROUP BY
	AGE_GROUP
ORDER BY
	FRAUD_RATE DESC;

-- Failed transaction rate by device
SELECT 
    device_type,
    COUNT(*) AS total_txns,
    SUM(CASE WHEN status = 'FAILED' THEN 1 ELSE 0 END) AS failed_txns,
    ROUND(100.0 * SUM(CASE WHEN status = 'FAILED' THEN 1 ELSE 0 END) / COUNT(*), 2) 
	AS failed_rate_pct
FROM transactions
GROUP BY device_type
ORDER BY failed_rate_pct DESC;