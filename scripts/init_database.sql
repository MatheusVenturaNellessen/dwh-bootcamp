/*
Este script prepara a estrutura inicial do Data Warehouse.
Etapas executadas:
	1. Remove o database "DataWarehouse", caso ele já exista.
	2. Cria um novo database chamado "DataWarehouse".
	3. Define "DataWarehouse" como o database ativo.
	4. Cria as três camadas da arquitetura de dados: Bronze; Silver; e Gold.
ATENÇÃO:
A execução deste script remove completamente o database "DataWarehouse" existente, incluindo seus dados e objetos.
*/

DROP DATABASE IF EXISTS DataWarehouse;

CREATE DATABASE DataWarehouse;

USE DataWarehouse;

CREATE SCHEMA bronze;

CREATE SCHEMA silver;

CREATE SCHEMA gold;