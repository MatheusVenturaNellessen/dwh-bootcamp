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
DECLARE
	start_time TIMESTAMP;
	batch_start_time TIMESTAMP;
	end_time TIMESTAMP;
	batch_end_time TIMESTAMP;
	current_table TEXT;
BEGIN

	batch_start_time := CLOCK_TIMESTAMP();

	RAISE NOTICE 'Loading Bronze Layer';

	RAISE NOTICE 'Loading CRM Tables';

	-- Table bronze.crm_cust_info	

	current_table := 'bronze.crm_cust_info';

	RAISE NOTICE 'Truncating Table: %', current_table;

	start_time := CLOCK_TIMESTAMP();
	
	TRUNCATE bronze.crm_cust_info;
	
	RAISE NOTICE 'Inserting Data Into Table: %', current_table;
	
	COPY bronze.crm_cust_info
	FROM 'C:/Users/2992529/Documents/dev_env/dwh-bootcamp/datasets/source_crm/cust_info.csv'
	WITH (
		FORMAT CSV,
		HEADER,
		DELIMITER ','
	);

	end_time := CLOCK_TIMESTAMP();

	RAISE NOTICE 'Load Duration in Table: % -> % second(s)', current_table, EXTRACT(EPOCH FROM (end_time - start_time));

	-- Table bronze.crm_prd_info

	current_table := 'bronze.crm_prd_info';

	RAISE NOTICE 'Truncating Table: %', current_table;

	start_time := CLOCK_TIMESTAMP();
	
	TRUNCATE bronze.crm_prd_info;
	
	RAISE NOTICE 'Inserting Data Into Table: %', current_table;

	COPY bronze.crm_prd_info
	FROM 'C:/Users/2992529/Documents/dev_env/dwh-bootcamp/datasets/source_crm/prd_info.csv'
	WITH (
		FORMAT CSV,
		HEADER,
		DELIMITER ','
	);

	end_time := CLOCK_TIMESTAMP();

	RAISE NOTICE 'Load Duration in Table: % -> % second(s)', current_table, EXTRACT(EPOCH FROM (end_time - start_time));

	-- Table bronze.crm_sales_details

	current_table := 'bronze.crm_sales_details';

	RAISE NOTICE 'Truncating Table: %', current_table;
	
	start_time := CLOCK_TIMESTAMP();

	TRUNCATE bronze.crm_sales_details;
	
	RAISE NOTICE 'Inserting Data Into Table: %', current_table;

	COPY bronze.crm_sales_details
	FROM 'C:/Users/2992529/Documents/dev_env/dwh-bootcamp/datasets/source_crm/sales_details.csv'
	WITH (
		FORMAT CSV,
		HEADER,
		DELIMITER ','
	);

	end_time := CLOCK_TIMESTAMP();

	RAISE NOTICE 'Load Duration in Table: % -> % second(s)', current_table, EXTRACT(EPOCH FROM (end_time - start_time));
	
	RAISE NOTICE 'Loading ERP Tables';

	-- Table bronze.erp_cust_az12

	current_table := 'bronze.erp_cust_az12';

	RAISE NOTICE 'Truncating Table: %', current_table;

	start_time := CLOCK_TIMESTAMP();

	TRUNCATE bronze.erp_cust_az12;
	
	RAISE NOTICE 'Inserting Data Into Table: %', current_table;

	COPY bronze.erp_cust_az12
	FROM 'C:/Users/2992529/Documents/dev_env/dwh-bootcamp/datasets/source_erp/CUST_AZ12.csv'
	WITH (
		FORMAT CSV,
		HEADER,
		DELIMITER ','
	);

	end_time := CLOCK_TIMESTAMP();

	RAISE NOTICE 'Load Duration in Table: % -> % second(s)', current_table, EXTRACT(EPOCH FROM (end_time - start_time));

	-- Tabela bronze.erp_loc_a101

	current_table := 'bronze.erp_loc_a101';

	RAISE NOTICE 'Truncating Table: %', current_table;
	
	start_time := CLOCK_TIMESTAMP();
	
	TRUNCATE bronze.erp_loc_a101;

	RAISE NOTICE 'Inserting Data Into Table: %', current_table;
	
	COPY bronze.erp_loc_a101
	FROM 'C:/Users/2992529/Documents/dev_env/dwh-bootcamp/datasets/source_erp/LOC_A101.csv'
	WITH (
		FORMAT CSV,
		HEADER,
		DELIMITER ','
	);

	end_time := CLOCK_TIMESTAMP();

	RAISE NOTICE 'Load Duration in Table: % -> % second(s)', current_table, EXTRACT(EPOCH FROM (end_time - start_time));

	-- Tabela bronze.erp_px_cat_g1v2

	current_table := 'bronze.erp_px_cat_g1v2';
	
	RAISE NOTICE 'Truncating Table: %', current_table;

	start_time := CLOCK_TIMESTAMP();
	
	TRUNCATE bronze.erp_px_cat_g1v2;
	
	RAISE NOTICE 'Inserting Data Into Table: %', current_table;

	COPY bronze.erp_px_cat_g1v2
	FROM 'C:/Users/2992529/Documents/dev_env/dwh-bootcamp/datasets/source_erp/PX_CAT_G1V2.csv'
	WITH (
		FORMAT CSV,
		HEADER,
		DELIMITER ','
	);

	end_time := CLOCK_TIMESTAMP();

	RAISE NOTICE 'Load Duration in the Table: % -> % second(s)', current_table, EXTRACT(EPOCH FROM (end_time - start_time));

	batch_end_time := CLOCK_TIMESTAMP();

	RAISE NOTICE '===========================================================================';
	RAISE NOTICE 'Load Bronze Layer Successful Completed -> Full Duration: % second(s)', EXTRACT(EPOCH FROM (batch_end_time - batch_start_time));
	RAISE NOTICE '===========================================================================';

EXCEPTION

	WHEN OTHERS THEN
		RAISE EXCEPTION 
			'Bronze Layer Load Failed | Table: % | SQLSTATE: % | Error: %',
			current_table,
			SQLSTATE,
			SQLERRM	;
END;
$$;

CALL bronze.load_bronze();