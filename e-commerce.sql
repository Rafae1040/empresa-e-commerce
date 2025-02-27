-- 1. Criação do banco de dados
CREATE DATABASE empresa_e_commerce;
USE empresa_e_commerce;

-- 2. Criação das tabelas

-- Tabela de Departamentos
CREATE TABLE departamentos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    gerente_id INT
);

-- Tabela de Empregados
CREATE TABLE empregados (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    departamento_id INT,
    localidade VARCHAR(100),
    gerente BOOLEAN DEFAULT FALSE,
    projeto_id INT,
    FOREIGN KEY (departamento_id) REFERENCES departamentos(id)
);

-- Tabela de Dependentes
CREATE TABLE dependentes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100),
    empregado_id INT,
    FOREIGN KEY (empregado_id) REFERENCES empregados(id)
);

-- Tabela de Projetos
CREATE TABLE projetos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    departamento_id INT,
    FOREIGN KEY (departamento_id) REFERENCES departamentos(id)
);

-- Tabela de Colaboradores (para e-commerce)
CREATE TABLE colaboradores (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    salario_base DECIMAL(10, 2)
);

-- Tabela de Usuários (para e-commerce)
CREATE TABLE usuarios (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    senha VARCHAR(100) NOT NULL
);

-- Tabela de Usuários Removidos (para armazenar quando um usuário for excluído)
CREATE TABLE usuarios_removidos (
    usuario_id INT,
    nome VARCHAR(100),
    data_remocao DATETIME,
    PRIMARY KEY (usuario_id),
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id)
);

-- Tabela de Histórico de Salários
CREATE TABLE historico_salarios (
    colaborador_id INT,
    salario_antigo DECIMAL(10, 2),
    salario_novo DECIMAL(10, 2),
    data_atualizacao DATETIME,
    FOREIGN KEY (colaborador_id) REFERENCES colaboradores(id)
);

-- 3. Inserindo dados nas tabelas

-- Inserindo dados na tabela de Departamentos
INSERT INTO departamentos (nome, gerente_id) VALUES 
('TI', 1),
('Recursos Humanos', 2),
('Marketing', 3);

-- Inserindo dados na tabela de Empregados
INSERT INTO empregados (nome, departamento_id, localidade, gerente, projeto_id) VALUES 
('Carlos Silva', 1, 'São Paulo', TRUE, 1),
('Maria Oliveira', 1, 'Rio de Janeiro', FALSE, 2),
('João Souza', 2, 'São Paulo', TRUE, 3),
('Patrícia Almeida', 2, 'Rio de Janeiro', FALSE, 4),
('Lucas Lima', 3, 'São Paulo', FALSE, 5);

-- Inserindo dados na tabela de Dependentes
INSERT INTO dependentes (nome, empregado_id) VALUES 
('Lucas Silva', 1),
('Ana Silva', 1),
('Pedro Oliveira', 2);

-- Inserindo dados na tabela de Projetos
INSERT INTO projetos (nome, departamento_id) VALUES 
('Sistema de Gestão', 1),
('Recrutamento e Seleção', 2),
('Campanha de Publicidade', 3);

-- Inserindo dados na tabela de Colaboradores (para e-commerce)
INSERT INTO colaboradores (nome, salario_base) VALUES 
('Fernanda Costa', 2500.00),
('Ricardo Santos', 3200.00);

-- Inserindo dados na tabela de Usuários (para e-commerce)
INSERT INTO usuarios (nome, email, senha) VALUES 
('Fernanda Costa', 'fernanda@empresa.com', 'senha_forte'),
('Ricardo Santos', 'ricardo@empresa.com', 'senha_forte');

-- Inserindo dados na tabela de Usuários Removidos (para testes de trigger)
INSERT INTO usuarios_removidos (usuario_id, nome, data_remocao) VALUES 
(1, 'Fernanda Costa', NOW());

-- Inserindo dados na tabela de Histórico de Salários (para testes de trigger)
INSERT INTO historico_salarios (colaborador_id, salario_antigo, salario_novo, data_atualizacao) VALUES 
(1, 2300.00, 2500.00, NOW());

-- 4. Criação das views

-- Número de empregados por departamento e localidade
CREATE VIEW vw_empregados_por_departamento AS
SELECT 
    d.nome AS departamento,
    e.localidade,
    COUNT(e.id) AS numero_empregados
FROM 
    empregados e
JOIN 
    departamentos d ON e.departamento_id = d.id
GROUP BY 
    d.nome, e.localidade;

-- Lista de departamentos e seus gerentes
CREATE VIEW vw_departamentos_e_gerentes AS
SELECT 
    d.nome AS departamento,
    e.nome AS gerente
FROM 
    departamentos d
LEFT JOIN 
    empregados e ON d.gerente_id = e.id;

-- Projetos com maior número de empregados (ordenados de forma descendente)
CREATE VIEW vw_projetos_com_maior_numero_empregados AS
SELECT 
    p.nome AS projeto,
    COUNT(e.id) AS numero_empregados
FROM 
    projetos p
LEFT JOIN 
    empregados e ON p.id = e.projeto_id
GROUP BY 
    p.nome
ORDER BY 
    numero_empregados DESC;

-- Lista de projetos, departamentos e gerentes
CREATE VIEW vw_projetos_departamentos_gerentes AS
SELECT 
    p.nome AS projeto,
    d.nome AS departamento,
    e.nome AS gerente
FROM 
    projetos p
JOIN 
    departamentos d ON p.departamento_id = d.id
JOIN 
    empregados e ON d.gerente_id = e.id;

-- Empregados que possuem dependentes e se são gerentes
CREATE VIEW vw_empregados_com_dependentes AS
SELECT 
    e.nome AS empregado,
    CASE 
        WHEN e.gerente = 1 THEN 'Sim' 
        ELSE 'Não' 
    END AS is_gerente,
    COUNT(d.id) AS numero_dependentes
FROM 
    empregados e
LEFT JOIN 
    dependentes d ON e.id = d.empregado_id
GROUP BY 
    e.nome;

-- 5. Criação de usuários e definição de permissões

-- Criação do usuário gerente
CREATE USER 'gerente'@'localhost' IDENTIFIED BY 'senha_forte';

-- Permissões para o usuário gerente
GRANT SELECT ON vw_empregados_por_departamento TO 'gerente'@'localhost';
GRANT SELECT ON vw_departamentos_e_gerentes TO 'gerente'@'localhost';
GRANT SELECT ON vw_projetos_com_maior_numero_empregados TO 'gerente'@'localhost';
GRANT SELECT ON vw_projetos_departamentos_gerentes TO 'gerente'@'localhost';

-- Criação do usuário empregado
CREATE USER 'empregado'@'localhost' IDENTIFIED BY 'senha_forte_empregado';

-- Permissões para o usuário empregado
GRANT SELECT ON vw_empregados_com_dependentes TO 'empregado'@'localhost';

-- 6. Criação de triggers

-- Trigger para remoção de usuários
DELIMITER //
CREATE TRIGGER before_user_delete
BEFORE DELETE ON usuarios
FOR EACH ROW
BEGIN
    INSERT INTO usuarios_removidos (usuario_id, nome, data_remocao)
    VALUES (OLD.id, OLD.nome, NOW());
END;
//
DELIMITER ;

-- Trigger para atualização de salário base
DELIMITER //
CREATE TRIGGER before_salary_update
BEFORE UPDATE ON colaboradores
FOR EACH ROW
BEGIN
    IF OLD.salario_base <> NEW.salario_base THEN
        INSERT INTO historico_salarios (colaborador_id, salario_antigo, salario_novo, data_atualizacao)
        VALUES (OLD.id, OLD.salario_base, NEW.salario_base, NOW());
    END IF;
END;
//
DELIMITER ;

