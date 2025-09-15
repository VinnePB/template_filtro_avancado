-- =====================================================
-- PARTE A — Fundamentos (Questões 1–5)
-- =====================================================

-- Criar banco de dados de exemplo
CREATE DATABASE IF NOT EXISTS vinicius_p_db;
USE vinicius_p_db;

-- Apagar tabelas antigas se existirem (pra não dar conflito)
DROP TABLE IF EXISTS Descontos, Vendas, ItensPedido, Produtos, Pedidos, Clientes, Funcionarios, Departamentos;

-- -----------------------------------------------------
-- 1) Tabelas e dados fictícios
-- -----------------------------------------------------

-- Departamentos
CREATE TABLE Departamentos (
  id INT AUTO_INCREMENT PRIMARY KEY,
  nome VARCHAR(100)
);

INSERT INTO Departamentos (nome) VALUES
('TI'),
('RH'),
('Financeiro');

-- Funcionários
CREATE TABLE Funcionarios (
  id INT AUTO_INCREMENT PRIMARY KEY,
  nome VARCHAR(100),
  salario DECIMAL(10,2),
  departamento_id INT,
  FOREIGN KEY (departamento_id) REFERENCES Departamentos(id)
);

INSERT INTO Funcionarios (nome, salario, departamento_id) VALUES
('Ana', 2500.00, 1),
('Bruno', 3200.00, 1),
('Carla', 4500.00, 2),
('Diego', 2800.00, 2),
('Eduarda', 5200.00, 3),
('Felipe', 6000.00, 3),
('Gabriela', 3100.00, 1);

-- Vendas
CREATE TABLE Vendas (
  id INT AUTO_INCREMENT PRIMARY KEY,
  produto VARCHAR(100),
  quantidade INT,
  valor_unitario DECIMAL(10,2)
);

INSERT INTO Vendas (produto, quantidade, valor_unitario) VALUES
('Notebook', 3, 2500.00),
('Teclado', 10, 150.00),
('Mouse', 15, 80.00),
('Monitor', 5, 900.00),
('Cadeira Gamer', 2, 1200.00);

-- -----------------------------------------------------
-- 2) WHERE vs HAVING
-- Departamentos com mais de 2 funcionários
SELECT departamento_id, COUNT(*) AS qtd_funcionarios
FROM Funcionarios
GROUP BY departamento_id
HAVING COUNT(*) > 2;

-- -----------------------------------------------------
-- 3) Consulta com filtro e ordenação
-- Funcionários que ganham mais de 3000, ordenados do maior salário para menor
SELECT nome, salario
FROM Funcionarios
WHERE salario > 3000
ORDER BY salario DESC;

-- -----------------------------------------------------
-- 4) Agregação e expressão
-- Faturamento total por produto
SELECT produto,
       SUM(quantidade * valor_unitario) AS faturamento_total
FROM Vendas
GROUP BY produto
ORDER BY faturamento_total DESC;

-- -----------------------------------------------------
-- 5) GROUP BY com HAVING
-- Produtos com faturamento acima de 5000
SELECT produto,
       SUM(quantidade * valor_unitario) AS faturamento_total
FROM Vendas
GROUP BY produto
HAVING SUM(quantidade * valor_unitario) > 5000;

-- =====================================================
-- PARTE B — JOINs (Questão 6)
-- =====================================================

-- Clientes
CREATE TABLE Clientes (
  id INT AUTO_INCREMENT PRIMARY KEY,
  nome VARCHAR(100)
);

INSERT INTO Clientes (nome) VALUES
('João'),
('Maria'),
('Pedro'),
('Larissa');

-- Pedidos
CREATE TABLE Pedidos (
  id INT AUTO_INCREMENT PRIMARY KEY,
  cliente_id INT,
  data_pedido DATE,
  total_pedido DECIMAL(10,2),
  FOREIGN KEY (cliente_id) REFERENCES Clientes(id)
);

INSERT INTO Pedidos (cliente_id, data_pedido, total_pedido) VALUES
(1, '2025-01-10', 5000.00),
(2, '2025-02-15', 3200.00),
(3, '2025-03-20', 1200.00),
(1, '2025-04-05', 2500.00);

-- -----------------------------------------------------
-- 6) INNER JOIN básico
-- Mostrar pedidos e o cliente que fez
SELECT p.id AS pedido_id,
       p.data_pedido,
       c.nome AS cliente_nome
FROM Pedidos p
INNER JOIN Clientes c ON p.cliente_id = c.id;
-- =====================================================
-- PARTE B — JOINs (Questões 7–15)
-- Continuação direta do script anterior
-- =====================================================

-- Produtos
CREATE TABLE Produtos (
  id INT AUTO_INCREMENT PRIMARY KEY,
  nome VARCHAR(100),
  preco DECIMAL(10,2)
);

INSERT INTO Produtos (nome, preco) VALUES
('Notebook', 2500.00),
('Teclado', 150.00),
('Mouse', 80.00),
('Monitor', 900.00),
('Cadeira Gamer', 1200.00);

-- ItensPedido
CREATE TABLE ItensPedido (
  id INT AUTO_INCREMENT PRIMARY KEY,
  pedido_id INT,
  produto_id INT,
  quantidade INT,
  preco_unitario DECIMAL(10,2),
  FOREIGN KEY (pedido_id) REFERENCES Pedidos(id),
  FOREIGN KEY (produto_id) REFERENCES Produtos(id)
);

INSERT INTO ItensPedido (pedido_id, produto_id, quantidade, preco_unitario) VALUES
(1, 1, 2, 2500.00),   -- João comprou 2 Notebooks
(1, 2, 1, 150.00),    -- João comprou 1 Teclado
(2, 3, 2, 80.00),     -- Maria comprou 2 Mouses
(3, 4, 1, 900.00),    -- Pedro comprou 1 Monitor
(4, 5, 1, 1200.00);   -- João comprou 1 Cadeira Gamer

-- -----------------------------------------------------
-- 7) INNER JOIN múltiplas tabelas
SELECT ip.pedido_id,
       p.data_pedido,
       c.nome AS nome_cliente,
       pr.nome AS nome_produto,
       ip.quantidade,
       (ip.quantidade * ip.preco_unitario) AS valor_total_linha
FROM ItensPedido ip
INNER JOIN Pedidos p   ON ip.pedido_id = p.id
INNER JOIN Clientes c  ON p.cliente_id = c.id
INNER JOIN Produtos pr ON ip.produto_id = pr.id;

-- -----------------------------------------------------
-- 8) LEFT JOIN — listar todos os clientes e último pedido
SELECT c.id AS cliente_id,
       c.nome,
       MAX(p.id) AS ultimo_pedido_id
FROM Clientes c
LEFT JOIN Pedidos p ON p.cliente_id = c.id
GROUP BY c.id, c.nome;

-- -----------------------------------------------------
-- 9) RIGHT JOIN — produtos e pedidos onde apareceram
-- MySQL não recomenda RIGHT, mas deixo os dois jeitos:
SELECT pr.id AS produto_id,
       pr.nome AS produto_nome,
       ip.pedido_id
FROM ItensPedido ip
RIGHT JOIN Produtos pr ON ip.produto_id = pr.id;

-- Versão equivalente com LEFT JOIN (mais usada):
SELECT pr.id AS produto_id,
       pr.nome AS produto_nome,
       ip.pedido_id
FROM Produtos pr
LEFT JOIN ItensPedido ip ON pr.id = ip.produto_id;

-- -----------------------------------------------------
-- 10) FULL OUTER JOIN (emulação no MySQL com UNION)
SELECT c.id AS cliente_id, c.nome AS cliente_nome, p.id AS pedido_id, p.data_pedido
FROM Clientes c
LEFT JOIN Pedidos p ON c.id = p.cliente_id

UNION ALL

SELECT c2.id AS cliente_id, c2.nome AS cliente_nome, p2.id AS pedido_id, p2.data_pedido
FROM Pedidos p2
LEFT JOIN Clientes c2 ON p2.cliente_id = c2.id
WHERE c2.id IS NULL;

-- -----------------------------------------------------
-- 11) JOIN com condições adicionais (descontos por período)
CREATE TABLE Descontos (
  id INT AUTO_INCREMENT PRIMARY KEY,
  produto_id INT,
  porcentagem DECIMAL(5,2),
  inicio DATE,
  fim DATE,
  FOREIGN KEY (produto_id) REFERENCES Produtos(id)
);

INSERT INTO Descontos (produto_id, porcentagem, inicio, fim) VALUES
(1, 10.00, '2025-01-01', '2025-03-31'),
(2, 15.00, '2025-02-01', '2025-02-28');

SELECT ip.id AS item_id,
       ip.pedido_id,
       p.data_pedido,
       ip.produto_id,
       d.porcentagem AS desconto_pct
FROM ItensPedido ip
JOIN Pedidos p ON ip.pedido_id = p.id
JOIN Descontos d
  ON ip.produto_id = d.produto_id
  AND p.data_pedido BETWEEN d.inicio AND d.fim;

-- -----------------------------------------------------
-- 12) Ambiguidade de colunas e aliases
SELECT c.id AS cliente_id,
       p.id AS pedido_id,
       c.nome
FROM Clientes c
JOIN Pedidos p ON p.cliente_id = c.id;

-- -----------------------------------------------------
-- 13) Agregação com JOIN — faturamento total por cliente
SELECT c.id AS cliente_id,
       c.nome,
       COALESCE(SUM(ip.quantidade * ip.preco_unitario), 0) AS faturamento_total_cliente
FROM Clientes c
LEFT JOIN Pedidos p ON p.cliente_id = c.id
LEFT JOIN ItensPedido ip ON ip.pedido_id = p.id
GROUP BY c.id, c.nome
ORDER BY faturamento_total_cliente DESC;

-- -----------------------------------------------------
-- 14) LEFT JOIN + COALESCE — total vendido por produto
SELECT pr.id,
       pr.nome,
       COALESCE(SUM(ip.quantidade), 0) AS total_vendido
FROM Produtos pr
LEFT JOIN ItensPedido ip ON pr.id = ip.produto_id
GROUP BY pr.id, pr.nome;

-- -----------------------------------------------------
-- 15) Filtro após JOIN + ordenação (período)
SELECT p.id AS pedido_id,
       p.data_pedido,
       c.nome AS cliente_nome,
       p.total_pedido
FROM Pedidos p
INNER JOIN Clientes c ON p.cliente_id = c.id
WHERE p.data_pedido BETWEEN '2025-01-01' AND '2025-06-30'
ORDER BY p.data_pedido ASC;
