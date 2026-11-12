USE [PY_2]
GO
SET NOCOUNT ON;
SELECT N'Tablak' AS ObjectType, COUNT(*) AS ActualCount, 42 AS ExpectedCount FROM sys.tables WHERE schema_id = SCHEMA_ID(N'dbo')
UNION ALL
SELECT N'Tarolt eljarasok', COUNT(*), 105 FROM sys.procedures WHERE schema_id = SCHEMA_ID(N'dbo');
GO
SELECT N'AbsenceType' AS TableName, COUNT_BIG(*) AS ActualRows, CAST(7 AS bigint) AS ExpectedRows FROM [dbo].[AbsenceType]
UNION ALL
SELECT N'App' AS TableName, COUNT_BIG(*) AS ActualRows, CAST(11 AS bigint) AS ExpectedRows FROM [dbo].[App]
UNION ALL
SELECT N'AppToRole' AS TableName, COUNT_BIG(*) AS ActualRows, CAST(28 AS bigint) AS ExpectedRows FROM [dbo].[AppToRole]
UNION ALL
SELECT N'Company' AS TableName, COUNT_BIG(*) AS ActualRows, CAST(4 AS bigint) AS ExpectedRows FROM [dbo].[Company]
UNION ALL
SELECT N'Constant' AS TableName, COUNT_BIG(*) AS ActualRows, CAST(9 AS bigint) AS ExpectedRows FROM [dbo].[Constant]
UNION ALL
SELECT N'DayType' AS TableName, COUNT_BIG(*) AS ActualRows, CAST(6 AS bigint) AS ExpectedRows FROM [dbo].[DayType]
UNION ALL
SELECT N'Dependent' AS TableName, COUNT_BIG(*) AS ActualRows, CAST(7 AS bigint) AS ExpectedRows FROM [dbo].[Dependent]
UNION ALL
SELECT N'Employee' AS TableName, COUNT_BIG(*) AS ActualRows, CAST(9 AS bigint) AS ExpectedRows FROM [dbo].[Employee]
UNION ALL
SELECT N'EmployeeAbsence' AS TableName, COUNT_BIG(*) AS ActualRows, CAST(5 AS bigint) AS ExpectedRows FROM [dbo].[EmployeeAbsence]
UNION ALL
SELECT N'EmployeeBankAccount' AS TableName, COUNT_BIG(*) AS ActualRows, CAST(4 AS bigint) AS ExpectedRows FROM [dbo].[EmployeeBankAccount]
UNION ALL
SELECT N'EmployeeDependent' AS TableName, COUNT_BIG(*) AS ActualRows, CAST(7 AS bigint) AS ExpectedRows FROM [dbo].[EmployeeDependent]
UNION ALL
SELECT N'EmployeeFieldValue' AS TableName, COUNT_BIG(*) AS ActualRows, CAST(7 AS bigint) AS ExpectedRows FROM [dbo].[EmployeeFieldValue]
UNION ALL
SELECT N'Employment' AS TableName, COUNT_BIG(*) AS ActualRows, CAST(9 AS bigint) AS ExpectedRows FROM [dbo].[Employment]
UNION ALL
SELECT N'EmploymentPayrollElement' AS TableName, COUNT_BIG(*) AS ActualRows, CAST(9 AS bigint) AS ExpectedRows FROM [dbo].[EmploymentPayrollElement]
UNION ALL
SELECT N'EmploymentWorkSchedule' AS TableName, COUNT_BIG(*) AS ActualRows, CAST(8 AS bigint) AS ExpectedRows FROM [dbo].[EmploymentWorkSchedule]
UNION ALL
SELECT N'FieldType' AS TableName, COUNT_BIG(*) AS ActualRows, CAST(5 AS bigint) AS ExpectedRows FROM [dbo].[FieldType]
UNION ALL
SELECT N'MasterDataField' AS TableName, COUNT_BIG(*) AS ActualRows, CAST(10 AS bigint) AS ExpectedRows FROM [dbo].[MasterDataField]
UNION ALL
SELECT N'MasterDataFieldOption' AS TableName, COUNT_BIG(*) AS ActualRows, CAST(10 AS bigint) AS ExpectedRows FROM [dbo].[MasterDataFieldOption]
UNION ALL
SELECT N'MasterDataGroup' AS TableName, COUNT_BIG(*) AS ActualRows, CAST(7 AS bigint) AS ExpectedRows FROM [dbo].[MasterDataGroup]
UNION ALL
SELECT N'MDGToRole' AS TableName, COUNT_BIG(*) AS ActualRows, CAST(9 AS bigint) AS ExpectedRows FROM [dbo].[MDGToRole]
UNION ALL
SELECT N'PayrollElement' AS TableName, COUNT_BIG(*) AS ActualRows, CAST(31 AS bigint) AS ExpectedRows FROM [dbo].[PayrollElement]
UNION ALL
SELECT N'PayrollElementFieldValue' AS TableName, COUNT_BIG(*) AS ActualRows, CAST(14 AS bigint) AS ExpectedRows FROM [dbo].[PayrollElementFieldValue]
UNION ALL
SELECT N'PayrollResult' AS TableName, COUNT_BIG(*) AS ActualRows, CAST(15 AS bigint) AS ExpectedRows FROM [dbo].[PayrollResult]
UNION ALL
SELECT N'RelationshipType' AS TableName, COUNT_BIG(*) AS ActualRows, CAST(1 AS bigint) AS ExpectedRows FROM [dbo].[RelationshipType]
UNION ALL
SELECT N'Role' AS TableName, COUNT_BIG(*) AS ActualRows, CAST(6 AS bigint) AS ExpectedRows FROM [dbo].[Role]
UNION ALL
SELECT N'RoleToUser' AS TableName, COUNT_BIG(*) AS ActualRows, CAST(3 AS bigint) AS ExpectedRows FROM [dbo].[RoleToUser]
UNION ALL
SELECT N'User' AS TableName, COUNT_BIG(*) AS ActualRows, CAST(7 AS bigint) AS ExpectedRows FROM [dbo].[User]
UNION ALL
SELECT N'WorkSchedule' AS TableName, COUNT_BIG(*) AS ActualRows, CAST(6 AS bigint) AS ExpectedRows FROM [dbo].[WorkSchedule]
UNION ALL
SELECT N'WorkScheduleDay' AS TableName, COUNT_BIG(*) AS ActualRows, CAST(86 AS bigint) AS ExpectedRows FROM [dbo].[WorkScheduleDay];
GO
