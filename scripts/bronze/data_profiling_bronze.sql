/************************
* Tabela "crm_cst_info" *
************************/

-- Verificar se há valores duplicados ou nulos nas chaves primárias / candidatas
-- Expectativa: Não encontrar valores duplicados ou nulos em "cst_id" e "cst_key"

SELECT	 cst_id,
		 COUNT(*)
FROM	 bronze.crm_cust_info
GROUP BY cst_id
HAVING 	 COUNT(*) > 1
	OR	 cst_id IS NULL;

SELECT 	 cst_key,
		 COUNT(*)
FROM	 bronze.crm_cust_info
GROUP BY cst_key
HAVING 	 COUNT(*) > 1
	OR	 cst_key IS NULL;

-- Solução
WITH cte AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY cst_id
            ORDER BY cst_create_date DESC
        ) AS flag
    FROM bronze.crm_cust_info
)
SELECT	*
FROM 	cte
WHERE 	flag = 1;

-- Verificar espaços no começo ou fim das valores textuais (strings)
-- Expectativa: Não encontrar espaços indesejados em "cst_firstname", "cst_lastname", "cst_marital_status" e "cst_gndr"

SELECT	cst_firstname
FROM 	bronze.crm_cust_info
WHERE 	cst_firstname <> TRIM(cst_firstname);

SELECT	cst_lastname
FROM 	bronze.crm_cust_info
WHERE 	cst_lastname <> TRIM(cst_lastname);

SELECT	cst_marital_status
FROM 	bronze.crm_cust_info
WHERE 	cst_marital_status <> TRIM(cst_marital_status);

SELECT	cst_gndr
FROM 	bronze.crm_cust_info
WHERE 	cst_gndr <> TRIM(cst_gndr);

-- Solução
SELECT	cst_id,
		cst_key,
		TRIM(cst_firstname) AS cst_firstname,
		TRIM(cst_lastname)  AS cst_lastname,
		cst_marital_status,
		cst_gndr,
		cst_create_date
FROM 	bronze.crm_cust_info;

-- Padronização e consistência dos dados
-- Expectativa: Desabreviar os valores, ex.: M -> Male

SELECT DISTINCT cst_gndr
FROM			bronze.crm_cust_info;

SELECT DISTINCT cst_marital_status
FROM			bronze.crm_cust_info;

-- Solução
SELECT	cst_id,
		cst_key,
		cst_firstname,
		cst_lastname,
		CASE
			WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
			WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
			ELSE 'n/a'
		END AS cst_marital_status,	
		CASE
			WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
			WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
			ELSE 'n/a'
		END AS cst_gndr,
		cst_create_date
FROM 	bronze.crm_cust_info;


/************************
* Tabela "crm_prd_info" *
************************/

-- Verificar se há valores duplicados ou nulos nas chaves primárias / candidatas
-- Expectativa: Não encontrar valores duplicados ou nulos em "prd_id" e "prd_key"

SELECT	 prd_id,
		 COUNT(*)
FROM 	 bronze.crm_prd_info
GROUP BY prd_id
HAVING 	 COUNT(*) > 1
	OR 	 prd_id IS NULL;

-- Verificar coluna "prd_key"

SELECT	prd_key,
		REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,
		SUBSTRING(prd_key, 7, LENGTH(prd_key))      AS prd_key
FROM 	bronze.crm_prd_info
-- WHERE	REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') NOT IN (SELECT DISTINCT id FROM bronze.erp_px_cat_g1v2)
-- WHERE 	SUBSTRING(prd_key, 7, LENGTH(prd_key)) /*NOT*/ IN (SELECT DISTINCT sls_prd_key FROM bronze.crm_sales_details) 
;

-- Verificar espaços no começo ou fim das valores textuais (strings)
-- Expectativa: Não encontrar espaços indesejados em "prd_nm" e "prd_line"

SELECT 	prd_nm
FROM	bronze.crm_prd_info
WHERE	prd_nm <> TRIM(prd_nm);

SELECT	prd_line
FROM 	bronze.crm_prd_info
WHERE	prd_line <> TRIM(prd_line);

-- Solução
SELECT	TRIM(prd_line) AS prd_line
FROM 	bronze.crm_prd_info;

-- Verificar integridade dos valores numéricos
-- Expectativa: Não encontrar valores nulos ou negativos em "prd_cost"

SELECT	prd_cost
FROM 	bronze.crm_prd_info
WHERE	prd_cost IS NULL
	OR	prd_cost < 0;

-- Solução
SELECT  COALESCE(prd_cost, 0) AS prd_cost
FROM 	bronze.crm_prd_info;

-- Padronização e consistência dos dados
-- Expectativa: Desabreviar os valores, ex.: M -> Mountain

SELECT DISTINCT prd_line
FROM 			bronze.crm_prd_info;

-- Solução
SELECT
	CASE UPPER(TRIM(prd_line))
		WHEN 'M' THEN 'Mountain'
		WHEN 'R' THEN 'Road'
		WHEN 'S' THEN 'Other Sales'
		WHEN 'T' THEN 'Touring'
		ELSE 'n/a'
	END AS prd_line
FROM bronze.crm_prd_info;

-- Verificar integridade dos campos de data

SELECT	prd_start_dt,
		prd_end_dt
FROM 	bronze.crm_prd_info
WHERE 	prd_end_dt < prd_start_dt;

-- Solução
SELECT
	prd_id,
	prd_key,
	prd_nm,
	prd_cost,
	prd_line,
	prd_start_dt,
	LEAD(prd_start_dt, 1, NULL) OVER(
		PARTITION BY prd_key
		ORDER BY prd_start_dt
	) -1 AS prd_end_dt
FROM bronze.crm_prd_info
ORDER BY 1;

/*****************************
* Tabela "crm_sales_details" *
*****************************/

-- Verificar espaços no começo ou fim dos valores textuais (strings)
-- Expectativa: Não encontrar espaços indesejados em "sls_ord_num"

SELECT 	sls_ord_num
FROM 	bronze.crm_sales_details
WHERE 	sls_ord_num <> TRIM(sls_ord_num);

-- Verificar integridade dos relacionamentos entre tabelas
-- Expectativa: Não encontrar valores divergentes entre "bronze.crm_sales_details" com "silver.crm_cst_info" e "bronze.crm_sales_details" com "silver.crm_prd_info"

SELECT 	*
FROM 	bronze.crm_sales_details
WHERE	sls_prd_key NOT IN (SELECT prd_key FROM silver.crm_prd_info);

SELECT	*
FROM 	bronze.crm_sales_details
WHERE 	sls_cust_id NOT IN (SELECT cst_id FROM silver.crm_cust_info);

-- Verificar datas inválidas
-- Expectativa: Não encontrar valores nulou ou iguais a 0, valores com seu comprimento maior ou menos que 8 dígitos e valores extrapolados (1970-01-01 à 2050-01-01)

SELECT	sls_order_dt
FROM 	bronze.crm_sales_details
WHERE 	sls_order_dt <= 0
	OR 	LENGTH(CAST(sls_order_dt AS TEXT)) <> 8
	OR 	sls_order_dt > 20500101
	OR 	sls_order_dt < 19700101;

SELECT 	sls_ship_dt
FROM 	bronze.crm_sales_details
WHERE 	sls_ship_dt <= 0
	OR	LENGTH(CAST(sls_ship_dt AS TEXT)) <> 8
	OR 	sls_ship_dt > 20500101
	OR 	sls_ship_dt < 19700101;

SELECT	sls_due_dt
FROM	bronze.crm_sales_details
WHERE	sls_due_dt <= 0
	OR	LENGTH(CAST(sls_due_dt AS TEXT)) <> 8
	OR 	sls_due_dt > 20500101
	OR	sls_due_dt < 19700101;

SELECT 	*
FROM	bronze.crm_sales_details
WHERE 	sls_order_dt > sls_ship_dt 
	OR 	sls_order_dt > sls_due_dt;

-- Solução
SELECT
	CASE 
		WHEN sls_order_dt <= 0 OR LENGTH(CAST(sls_order_dt AS TEXT)) <> 8 THEN NULL
		ELSE CAST(CAST(sls_order_dt AS TEXT) AS DATE)
	END AS sls_order_dt,
	CASE
		WHEN sls_ship_dt <= 0 OR LENGTH(CAST(sls_ship_dt AS TEXT)) <> 8 THEN NULL
		ELSE CAST(CAST(sls_ship_dt AS TEXT) AS DATE)
	END AS sls_ship_dt,
	CASE 
		WHEN sls_due_dt <= 0 OR LENGTH(CAST(sls_due_dt AS TEXT)) <> 8 THEN NULL
		ELSE CAST(CAST(sls_due_dt AS TEXT) AS DATE)
	END AS sls_due_dt
FROM 	bronze.crm_sales_details;

-- Verificar a integridade dos campos "sls_sales", "sls_quantity" e "sls_price"
-- Regras de negócio:
--	1. sls_sales = sls_quantity * sls_price
--	2. Os valores destes campos não podem ser 0, negativos ou nulos

SELECT	sls_sales,
		sls_quantity,
		sls_price
FROM	bronze.crm_sales_details
WHERE 	sls_sales <> sls_quantity * sls_price
   	OR 	sls_sales <= 0 OR sls_quantity <= 0 OR sls_price <= 0
	OR	sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
ORDER BY 1, 2, 3;

-- Solução:
-- 1. Se o campo "sls_sales" for igual a 0, negativo ou nulo, o mesmo será derivado de "sls_quantity" e "sls_price"
-- 2. Se o campo "sls_price" for igual a 0 ou nulo, será derivado de "sls_sales" e "sls_quantity"
-- 3. Se o campo "sls_price" for negativo, será convertido para positivo

SELECT	sls_sales AS old_sls_sales,
		sls_quantity,
		sls_price AS old_sls_price,
		CASE WHEN sls_sales <= 0 OR sls_sales IS NULL OR sls_sales <> sls_quantity * ABS(sls_price)
			 THEN sls_quantity * ABS(sls_price)
			 ELSE sls_sales
		END AS sls_sales,
		CASE WHEN sls_price <= 0 OR sls_price IS NULL
			 THEN sls_sales / NULLIF(sls_quantity, 0)
			 ELSE sls_price
		END AS sls_price
FROM	bronze.crm_sales_details
WHERE 	sls_sales <> sls_quantity * sls_price
   	OR 	sls_sales <= 0 OR sls_quantity <= 0 OR sls_price <= 0
	OR	sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
ORDER BY 1, 2, 3;