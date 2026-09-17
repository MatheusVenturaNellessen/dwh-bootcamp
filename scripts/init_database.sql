/*
Este script prepara a estrutura inicial do Data Warehouse.

Etapas executadas:
	1. Remove o database "data_warehouse", caso ele já exista.
	2. Cria um novo database chamado "data_warehouse".
	3. Define "data_warehouse" como o database ativo.
	4. Cria as três camadas da arquitetura Medallion: Bronze; Silver; e Gold.

ATENÇÃO:
A execução deste script remove completamente o database "data_warehouse" existente, incluindo seus dados e objetos.
*/

DROP DATABASE IF EXISTS data_warehouse;

CREATE DATABASE data_warehouse;

USE data_warehouse;

CREATE SCHEMA bronze;

CREATE SCHEMA silver;

CREATE SCHEMA gold;