/*
Este script cria as tabelas da camada Bronze responsáveis pelo armazenamento dos dados brutos provenientes do sistema CRM.
Etapas executadas:
	1. Cria a tabela "crm_cust_info" para armazenar os dados dos clientes.
	2. Cria a tabela "crm_prd_info" para armazenar os dados dos produtos.
	3. Cria a tabela "crm_sales_details" para armazenar os dados das vendas.
Convenção de nomenclatura:
	- Todas as tabelas da camada Bronze devem seguir o padrão "<source_system>_<entity>".
*/

CREATE TABLE bronze.crm_cust_info (
	cst_id INT,
	cst_key VARCHAR(100),
	cst_firstname VARCHAR(100),
	cst_lastname VARCHAR(100),
	cst_marital_status VARCHAR(100),
	cst_gndr VARCHAR(100),
	cst_create_date DATE
);

CREATE TABLE bronze.crm_prd_info (
	prd_id INT,
	prd_key VARCHAR(100),
	prd_nm VARCHAR(100),
	prd_cost INT,
	prd_line VARCHAR(100),
	prd_start_dt DATE,
	prd_end_dt DATE
);

CREATE TABLE bronze.crm_sales_details (
	sls_ord_num VARCHAR(100),
	sls_prd_key VARCHAR(100),
	sls_cust_id INT,
	sls_order_dt DATE,
	sls_ship_dt DATE,
	sls_due_dt DATE,
	sls_sales INT,
	sls_quantity INT,
	sls_price INT
);