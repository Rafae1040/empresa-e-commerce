# 🛒 **Projeto de Banco de Dados para E-Commerce**

Este repositório contém o esquema de banco de dados para uma **empresa de e-commerce**, projetado para gerenciar informações sobre **departamentos**, **empregados**, **projetos**, **colaboradores**, **usuários** e **histórico de salários**. O banco de dados também inclui funcionalidades para a remoção de usuários e o registro de dependentes.

## 📚 **Estrutura do Banco de Dados**

A estrutura do banco de dados foi criada para cobrir tanto a parte administrativa da empresa (departamentos, empregados, projetos) quanto o lado e-commerce (colaboradores, usuários, histórico de salários, remoções de usuários). Abaixo estão os detalhes do banco de dados.

---

## 🏢 **Tabela: Departamentos**

A tabela **departamentos** armazena os departamentos da empresa. Cada departamento tem um nome e um gerente.

```sql
CREATE TABLE departamentos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    gerente_id INT
);
```

Colunas:
id: Identificador único do departamento.
nome: Nome do departamento (ex: TI, Marketing, Recursos Humanos).
gerente_id: ID do gerente responsável pelo departamento, referenciando a tabela empregados.


