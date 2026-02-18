-- Initializing to master database 
USE master
GO

-- Drop and create database population 
IF EXISTS(SELECT 1 FROM sys.databases WHERE name = 'population')
    BEGIN
        ALTER DATABASE population SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
        DROP DATABASE population;
    END
GO     

CREATE DATABASE population;
GO

-- Switching to population Database
USE population;
GO 

CREATE SCHEMA pop;
