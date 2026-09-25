-- ==========================================================================================
-- Tabela bronze.crm_cst_info
-- ==========================================================================================

-- Verificar se há valores duplicados ou nulos na chave primária
-- Expectativa: Não encontrá-los
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
	SELECT	*,
        	ROW_NUMBER() OVER (
            	PARTITION BY cst_id
            	ORDER BY cst_create_date DESC
        	) AS flag
    FROM 	bronze.crm_cust_info
)
SELECT	*
FROM 	cte
WHERE 	flag = 1;

-- Verificar espaços indesejados em bronze.crm_cst_info.cst_firstname, bronze.crm_cst_info.cst_lastname, bronze.crm_cst_info.cst_marital_status e bronze.crm_cst_info.cst_gndr
-- Expectativa: Não encontrá-los
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

-- Padronização e consistência dos dados, ex.: M -> Male
SELECT 	DISTINCT cst_gndr
FROM 	bronze.crm_cust_info;

SELECT 	DISTINCT cst_marital_status
FROM 	bronze.crm_cust_info;

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

-- ==========================================================================================
-- Tabela bronze.crm_prd_info
-- ==========================================================================================

-- Verificar se há valores duplicados ou nulos na chave primária
-- Expectativa: Não encontrá-los
SELECT	 prd_id,
		 COUNT(*)
FROM 	 bronze.crm_prd_info
GROUP BY prd_id
HAVING 	 COUNT(*) > 1
	OR 	 prd_id IS NULL;

-- Extrair de bronze.crm_prd_info.prd_key o ID da categoria e a Chave do Produto
SELECT	prd_key,
		REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,
		SUBSTRING(prd_key, 7, LENGTH(prd_key))      AS prd_key
FROM 	bronze.crm_prd_info;

-- Verificar espaços indesejados em bronze.crm_prd_info.prd_nm e bronze.crm_prd_info.prd_line
-- Expectativa: Não encontrá-los
SELECT 	prd_nm
FROM	bronze.crm_prd_info
WHERE	prd_nm <> TRIM(prd_nm);

SELECT	prd_line
FROM 	bronze.crm_prd_info
WHERE	prd_line <> TRIM(prd_line);

-- Solução: Aplicar a função TRIM()
SELECT	TRIM(prd_line) AS prd_line
FROM 	bronze.crm_prd_info;


-- Verificar a integridade dos valores numéricos
-- Expectativa: Não encontrar valores negativos ou nulos
SELECT	prd_cost
FROM 	bronze.crm_prd_info
WHERE	prd_cost IS NULL
	OR	prd_cost < 0;

-- Solução: Se o valor for nulo, transformá-lo em zero
SELECT  COALESCE(prd_cost, 0) AS prd_cost
FROM 	bronze.crm_prd_info;

-- Padronização e consistência dos dados, ex.: M -> Mountain
SELECT 	DISTINCT prd_line
FROM 	bronze.crm_prd_info;

-- Solução
SELECT
	CASE UPPER(TRIM(prd_line))
		WHEN 'M' THEN 'Mountain'
		WHEN 'R' THEN 'Road'
		WHEN 'S' THEN 'Other Sales'
		WHEN 'T' THEN 'Touring'
		ELSE 'n/a'
	END AS prd_line
FROM	bronze.crm_prd_info;

-- Verificar integridade dos campos de data
SELECT	prd_start_dt,
		prd_end_dt
FROM 	bronze.crm_prd_info
WHERE 	prd_end_dt < prd_start_dt;

-- Solução
SELECT	 prd_id,
		 prd_key,
		 prd_nm,
		 prd_cost,
		 prd_line,
		 prd_start_dt,
		 LEAD(prd_start_dt, 1, NULL) OVER(
		 	PARTITION BY prd_key
		 	ORDER BY prd_start_dt
		 ) -1 AS prd_end_dt
FROM 	 bronze.crm_prd_info
ORDER BY 1;

-- ==========================================================================================
-- Tabela bronze.crm_sales_details
-- ==========================================================================================

-- Verificar espaços indesejados em bronze.crm_sales_details.sls_ord_num
-- Expectativa: Não encontrá-los
SELECT 	sls_ord_num
FROM 	bronze.crm_sales_details
WHERE 	sls_ord_num <> TRIM(sls_ord_num);

-- Verificar os relacionamentos das tabelas:
-- 1. bronze.crm_sales_details.sls_prd_key com silver.crm_cst_info.prd_key
-- 2. bronze.crm_sales_details.sls_cust_id com silver.crm_prd_info.cst_id
-- Expectativa: Não encontrar valores divergentes
SELECT 	*
FROM 	bronze.crm_sales_details
WHERE	sls_prd_key NOT IN (SELECT prd_key FROM silver.crm_prd_info);

SELECT	*
FROM 	bronze.crm_sales_details
WHERE 	sls_cust_id NOT IN (SELECT cst_id FROM silver.crm_cust_info);

-- Verificar datas inválidas (datas nulas, datas <= 0, datas com comprimento diferente de 8 dígitos ou datas extrapoladas)
-- Expectativas: Não encontrá-las
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

-- Solução: Anular àquelas datas que ferem a integridade
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

-- Aplicar as Regras de Negócios nos campos bronze.crm_sales_details.sls_sales, bronze.crm_sales_details.sls_quantity e bronze.crm_sales_details.sls_price
-- Regras de Negócios:
-- 1. Sales = Quantity * Price
-- 2. Os valores destes campos não podem ser iguais a zero, negativos ou nulos
SELECT	 sls_sales,
		 sls_quantity,
		 sls_price
FROM	 bronze.crm_sales_details
WHERE 	 sls_sales <> sls_quantity * sls_price
   	OR 	 sls_sales <= 0 OR sls_quantity <= 0 OR sls_price <= 0
	OR	 sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
ORDER BY 1, 2, 3;

-- Para solucionar, será aplicado as seguintes Regras de Negócio:
-- 1. Se o campo Sales for igual a zero, negativo ou nulo, o seu cálculo será: Quantity * ABS(Price)
-- 2. Se o campo Price for igual a zero ou nulo, o seu cálculo será: Sales / IFNULL(Quantity, 0)
-- 3. Se o campo Price for negativo, o mesmo será convertido para positivo
SELECT	 sls_sales AS old_sls_sales,
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
FROM	 bronze.crm_sales_details
WHERE 	 sls_sales <> sls_quantity * sls_price
   	OR 	 sls_sales <= 0 OR sls_quantity <= 0 OR sls_price <= 0
	OR	 sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
ORDER BY 1, 2, 3;

-- ==========================================================================================
-- Tabela bronze.erp_cust_az12
-- ==========================================================================================

-- Verificar o relacionamento entre as tabelas bronze.erp_cust_az12.cid com silver.crm_cst_info.cst_key 
-- Expectativa: Não encontrar valores divergentes
SELECT	*
FROM	silver.crm_cust_info
WHERE 	cst_key NOT IN (
	SELECT
	CASE
		WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LENGTH(cid))
		ELSE cid
	END AS cid
FROM	bronze.erp_cust_az12);

-- Solução: Remover, quando existir, o perfixo "NAS"
SELECT
	CASE
		WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LENGTH(cid))
		ELSE cid
	END AS cid
FROM 	bronze.erp_cust_az12;

-- Verificar integridade dos campos de data
-- Expectativa: Não encontrar datas extrapoladas (menor que 1926-01-01) ou que estejam no futuro
SELECT	 *
FROM	 bronze.erp_cust_az12
WHERE	 bdate < '1926-01-01'
	OR 	 bdate > CURRENT_DATE
ORDER BY bdate;

-- Solução: Anular as datas que estiverem no futuro
SELECT
	CASE
		WHEN bdate > CURRENT_DATE THEN NULL
		ELSE bdate
	END AS bdate
FROM 	bronze.erp_cust_az12;

-- Padronização e consistência dos dados, ex.: F -> Female
SELECT 	DISTINCT gen
FROM 	bronze.erp_cust_az12;

-- Solução
SELECT
	CASE
		WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
		WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
		ELSE 'n/a'
	END AS gen
FROM 	bronze.erp_cust_az12;

-- Encontrar apenas os valores: "Female", "Male" e "n/a"
SELECT 	DISTINCT gen AS old_gen,
		CASE
			WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
			WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
			ELSE 'n/a'
		END AS gen
FROM 	bronze.erp_cust_az12;

-- ==========================================================================================
-- Tabela bronze.erp_loc_a101
-- ==========================================================================================

-- Verificar o relacionamento entre as tabelas bronze.erp_loc_a101.cid com silver.crm_cst_info.cst_key 
-- Expectativa: Não encontrar valores divergentes
SELECT  cid
FROM	bronze.erp_loc_a101
WHERE 	REPLACE(cid, '-', '') NOT IN (
	SELECT cst_key FROM silver.crm_cust_info);

-- Solução: Substituir "-" por "" em bronze.erp_loc_a101.cid
SELECT	REPLACE(cid, '-', '') AS cid
FROM 	bronze.erp_loc_a101;

-- Padronização e consistência dos dados, ex.: United States, US, USA -> United States
SELECT 	 DISTINCT cntry
FROM	 bronze.erp_loc_a101
ORDER BY 1;

-- Solução
SELECT CASE
			WHEN UPPER(TRIM(cntry)) = 'DE' THEN 'Germany'
			WHEN UPPER(TRIM(cntry)) IN ('US', 'USA') THEN 'United States'
			WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'n/a'
			ELSE cntry
		END AS cntry
FROM	bronze.erp_loc_a101;

-- Verificação
SELECT	DISTINCT cntry AS old_cntry,
		CASE
			WHEN UPPER(TRIM(cntry)) = 'DE' THEN 'Germany'
			WHEN UPPER(TRIM(cntry)) IN ('US', 'USA') THEN 'United States'
			WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'n/a'
			ELSE cntry
		END AS cntry
FROM	bronze.erp_loc_a101;

-- ==========================================================================================
-- Tabela bronze.erp_px_cat_g1v2
-- ==========================================================================================

-- Verificar o relacionamento entre as tabelas bronze.erp_px_cat_g1v2.id com silver.crm_prd_info.cat_id 
-- Expectativa: Não encontrar valores divergentes
-- Quais categorias não são utilizadas por nenhum produto?
SELECT	*
FROM	bronze.erp_px_cat_g1v2
WHERE	id NOT IN (SELECT cat_id FROM silver.crm_prd_info);

-- Quais produtos apontam para uma categoria que não existe?
SELECT	*
FROM 	silver.crm_prd_info
WHERE	cat_id NOT IN (SELECT id FROM bronze.erp_px_cat_g1v2);

SELECT	*
FROM	bronze.erp_px_cat_g1v2 
WHERE 	id LIKE 'CO_P%';

SELECT	*
FROM	silver.crm_prd_info
WHERE 	cat_id LIKE 'CO_P%';

-- Solução
SELECT	CASE 
			WHEN id = 'CO_PD' THEN 'CO_PE'
			ELSE id
		END AS id
FROM	bronze.erp_px_cat_g1v2;

-- Validação
WITH cte AS (
	SELECT	CASE 
				WHEN id = 'CO_PD' THEN 'CO_PE'
				ELSE id
			END AS id,
			cat,
			subcat,
			maintenance
	FROM	bronze.erp_px_cat_g1v2
)
SELECT 	*
FROM 	cte
WHERE 	id NOT IN (SELECT cat_id FROM silver.crm_prd_info);

-- Verificar espaços indesejados em bronze.erp_px_cat_g1v2.cat, bronze.erp_px_cat_g1v2.subat e bronze.erp_px_cat_g1v2.maintenance
-- Expectativa: Não encontrá-los
SELECT	*
FROM	bronze.erp_px_cat_g1v2
WHERE	cat <> TRIM(cat)
	OR	subcat <> TRIM(subcat)
	OR	maintenance <> TRIM(maintenance);

-- Padronização e consistência dos dados
SELECT	DISTINCT cat
FROM	bronze.erp_px_cat_g1v2;

SELECT	DISTINCT cat,
				 subcat
FROM	bronze.erp_px_cat_g1v2
ORDER BY 1, 2;

SELECT	DISTINCT maintenance
FROM	bronze.erp_px_cat_g1v2;