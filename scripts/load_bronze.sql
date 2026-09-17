/*
Este script cria a stored procedure responsável pela carga dos dados brutos provenientes dos sistemas CRM e ERP na camada Bronze.

Etapas executadas:
	1. Cria ou atualiza a stored procedure "bronze.load_bronze".
	2. Limpa os dados existentes nas tabelas da camada Bronze.
	3. Carrega os arquivos CSV do sistema CRM e ERP em suas respectivas tabelas.

ATENÇÃO:
Ao executar a procedure, todos os dados existentes nas tabelas serão removidos antes da realização de uma nova carga.
*/

CREATE OR REPLACE PROCEDURE bronze.load_bronze()
LANGUAGE plpgsql
AS $$
BEGIN
	
	TRUNCATE bronze.crm_cust_info;
	
	COPY bronze.crm_cust_info
	FROM 'C:/Users/2992529/Documents/dev_env/dwh-bootcamp/datasets/source_crm/cust_info.csv'
	WITH (
		FORMAT CSV,
		HEADER,
		DELIMITER ','
	);
	
	TRUNCATE bronze.crm_prd_info;
	
	COPY bronze.crm_prd_info
	FROM 'C:/Users/2992529/Documents/dev_env/dwh-bootcamp/datasets/source_crm/prd_info.csv'
	WITH (
		FORMAT CSV,
		HEADER,
		DELIMITER ','
	);
	
	TRUNCATE bronze.crm_sales_details;
	
	COPY bronze.crm_sales_details
	FROM 'C:/Users/2992529/Documents/dev_env/dwh-bootcamp/datasets/source_crm/sales_details.csv'
	WITH (
		FORMAT CSV,
		HEADER,
		DELIMITER ','
	);
	
	TRUNCATE bronze.erp_cust_az12;
	
	COPY bronze.erp_cust_az12
	FROM 'C:/Users/2992529/Documents/dev_env/dwh-bootcamp/datasets/source_erp/CUST_AZ12.csv'
	WITH (
		FORMAT CSV,
		HEADER,
		DELIMITER ','
	);
	
	TRUNCATE bronze.erp_loc_a101;
	
	COPY bronze.erp_loc_a101
	FROM 'C:/Users/2992529/Documents/dev_env/dwh-bootcamp/datasets/source_erp/LOC_A101.csv'
	WITH (
		FORMAT CSV,
		HEADER,
		DELIMITER ','
	);
	
	TRUNCATE bronze.erp_px_cat_g1v2;
	
	COPY bronze.erp_px_cat_g1v2
	FROM 'C:/Users/2992529/Documents/dev_env/dwh-bootcamp/datasets/source_erp/PX_CAT_G1V2.csv'
	WITH (
		FORMAT CSV,
		HEADER,
		DELIMITER ','
	);

END;
$$;

CALL bronze.load_bronze();