USE [PY_2]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET IDENTITY_INSERT [dbo].[AbsenceType] ON 

INSERT [dbo].[AbsenceType] ([AbsenceTypeId], [Code], [Name], [IsPaid], [IsActive]) VALUES (1, N'TESZT_TAVOLLET', N'Teszt távollét módosítva', 1, 0)
INSERT [dbo].[AbsenceType] ([AbsenceTypeId], [Code], [Name], [IsPaid], [IsActive]) VALUES (2, N'TESZT_TAVOLLET_AKTIV', N'Aktív teszt távollét2', 1, 0)
INSERT [dbo].[AbsenceType] ([AbsenceTypeId], [Code], [Name], [IsPaid], [IsActive]) VALUES (3, N'NEM_FIZETETT_TAVOLLET', N'Nem fizetett távollét', 0, 0)
INSERT [dbo].[AbsenceType] ([AbsenceTypeId], [Code], [Name], [IsPaid], [IsActive]) VALUES (4, N'1000-FIZSZAB', N'Fizetett szabadság', 1, 1)
INSERT [dbo].[AbsenceType] ([AbsenceTypeId], [Code], [Name], [IsPaid], [IsActive]) VALUES (5, N'1500-NFSZAB', N'Nem fizetett szabadság', 0, 1)
INSERT [dbo].[AbsenceType] ([AbsenceTypeId], [Code], [Name], [IsPaid], [IsActive]) VALUES (6, N'2000-TULO', N'Túlóra', 1, 1)
INSERT [dbo].[AbsenceType] ([AbsenceTypeId], [Code], [Name], [IsPaid], [IsActive]) VALUES (7, N'3000-HOME', N'Home OFFICE', 1, 1)
SET IDENTITY_INSERT [dbo].[AbsenceType] OFF
GO
SET IDENTITY_INSERT [dbo].[App] ON 

INSERT [dbo].[App] ([AppId], [Code], [AppName], [IsActive]) VALUES (1, N'USER_MAINTENANCE', N'User karbantartó alkalmazás', 1)
INSERT [dbo].[App] ([AppId], [Code], [AppName], [IsActive]) VALUES (2, N'MASTERDATA_MAINTENANCE', N'Törzsadat-karbantartó alkalmazás', 1)
INSERT [dbo].[App] ([AppId], [Code], [AppName], [IsActive]) VALUES (3, N'WORKSCHEDULE_CONFIG', N'Munkarend-konfiguráló alkalmazás', 1)
INSERT [dbo].[App] ([AppId], [Code], [AppName], [IsActive]) VALUES (4, N'ABSENCE_TYPE_MAINTENANCE', N'Távolléttípus-karbantartó alkalmazás', 1)
INSERT [dbo].[App] ([AppId], [Code], [AppName], [IsActive]) VALUES (5, N'MASTERDATA_TYPE_MAINTENANCE', N'Törzsadattípus-karbantartó alkalmazás', 1)
INSERT [dbo].[App] ([AppId], [Code], [AppName], [IsActive]) VALUES (6, N'PAYROLL_ELEMENT_MAINTENANCE', N'Bérelemek karbantartó alkalmazás', 1)
INSERT [dbo].[App] ([AppId], [Code], [AppName], [IsActive]) VALUES (7, N'CALCULATION_RULE_MAINTENANCE', N'Számítási szabály karbantartó alkalmazás', 1)
INSERT [dbo].[App] ([AppId], [Code], [AppName], [IsActive]) VALUES (8, N'PAYROLL_SCHEMA_MAINTENANCE', N'Séma-karbantartó alkalmazás', 1)
INSERT [dbo].[App] ([AppId], [Code], [AppName], [IsActive]) VALUES (9, N'PAYROLL_RUN', N'Számfejtő alkalmazás', 1)
INSERT [dbo].[App] ([AppId], [Code], [AppName], [IsActive]) VALUES (10, N'REPORT_BUILDER', N'Riportkészítő alkalmazás', 1)
INSERT [dbo].[App] ([AppId], [Code], [AppName], [IsActive]) VALUES (11, N'TEST_APP', N'Teszt alkalmazás módosítva', 1)
SET IDENTITY_INSERT [dbo].[App] OFF
GO
INSERT [dbo].[AppToRole] ([RoleId], [AppId]) VALUES (1, 1)
INSERT [dbo].[AppToRole] ([RoleId], [AppId]) VALUES (1, 2)
INSERT [dbo].[AppToRole] ([RoleId], [AppId]) VALUES (1, 3)
INSERT [dbo].[AppToRole] ([RoleId], [AppId]) VALUES (1, 4)
INSERT [dbo].[AppToRole] ([RoleId], [AppId]) VALUES (1, 5)
INSERT [dbo].[AppToRole] ([RoleId], [AppId]) VALUES (1, 6)
INSERT [dbo].[AppToRole] ([RoleId], [AppId]) VALUES (1, 7)
INSERT [dbo].[AppToRole] ([RoleId], [AppId]) VALUES (1, 8)
INSERT [dbo].[AppToRole] ([RoleId], [AppId]) VALUES (1, 9)
INSERT [dbo].[AppToRole] ([RoleId], [AppId]) VALUES (1, 10)
INSERT [dbo].[AppToRole] ([RoleId], [AppId]) VALUES (2, 1)
INSERT [dbo].[AppToRole] ([RoleId], [AppId]) VALUES (3, 2)
INSERT [dbo].[AppToRole] ([RoleId], [AppId]) VALUES (3, 3)
INSERT [dbo].[AppToRole] ([RoleId], [AppId]) VALUES (3, 4)
INSERT [dbo].[AppToRole] ([RoleId], [AppId]) VALUES (3, 5)
INSERT [dbo].[AppToRole] ([RoleId], [AppId]) VALUES (3, 6)
INSERT [dbo].[AppToRole] ([RoleId], [AppId]) VALUES (3, 7)
INSERT [dbo].[AppToRole] ([RoleId], [AppId]) VALUES (3, 8)
INSERT [dbo].[AppToRole] ([RoleId], [AppId]) VALUES (3, 9)
INSERT [dbo].[AppToRole] ([RoleId], [AppId]) VALUES (3, 10)
INSERT [dbo].[AppToRole] ([RoleId], [AppId]) VALUES (4, 2)
INSERT [dbo].[AppToRole] ([RoleId], [AppId]) VALUES (4, 3)
INSERT [dbo].[AppToRole] ([RoleId], [AppId]) VALUES (4, 4)
INSERT [dbo].[AppToRole] ([RoleId], [AppId]) VALUES (4, 5)
INSERT [dbo].[AppToRole] ([RoleId], [AppId]) VALUES (4, 6)
INSERT [dbo].[AppToRole] ([RoleId], [AppId]) VALUES (4, 10)
INSERT [dbo].[AppToRole] ([RoleId], [AppId]) VALUES (6, 6)
INSERT [dbo].[AppToRole] ([RoleId], [AppId]) VALUES (6, 9)
GO
SET IDENTITY_INSERT [dbo].[Company] ON 

INSERT [dbo].[Company] ([CompanyId], [CompanyName], [CompanyAddress], [BankAccountNumber], [TaxId], [PhoneNumber]) VALUES (1, N'Teszt Kft.', NULL, NULL, NULL, NULL)
INSERT [dbo].[Company] ([CompanyId], [CompanyName], [CompanyAddress], [BankAccountNumber], [TaxId], [PhoneNumber]) VALUES (2, N'Teszt Kft. - munkaviszonyváltás', NULL, NULL, NULL, NULL)
INSERT [dbo].[Company] ([CompanyId], [CompanyName], [CompanyAddress], [BankAccountNumber], [TaxId], [PhoneNumber]) VALUES (3, N'API teszt Kft. - módosított', N'Módosított teszt utca 2.', N'22222222-22222222-22222222', N'87654321-2-34', N'+362098765')
INSERT [dbo].[Company] ([CompanyId], [CompanyName], [CompanyAddress], [BankAccountNumber], [TaxId], [PhoneNumber]) VALUES (4, N'A legjobb cég', N'Budapest 2222222', N'2312312312', N'12121212121', N'+36201111111')
SET IDENTITY_INSERT [dbo].[Company] OFF
GO
INSERT [dbo].[Constant] ([ConstantId], [ConstantName], [Value], [ValidFrom], [ValidTo]) VALUES (N'15SZP', N'15 százalékos pótlék', CAST(0.150000 AS Decimal(18, 6)), CAST(N'2026-01-01' AS Date), NULL)
INSERT [dbo].[Constant] ([ConstantId], [ConstantName], [Value], [ValidFrom], [ValidTo]) VALUES (N'BAKER', N'Bruttó átlag kereset', CAST(740600.000000 AS Decimal(18, 6)), CAST(N'2026-01-01' AS Date), NULL)
INSERT [dbo].[Constant] ([ConstantId], [ConstantName], [Value], [ValidFrom], [ValidTo]) VALUES (N'BTAMO', N'Benzin támogatás', CAST(21.000000 AS Decimal(18, 6)), CAST(N'2026-01-01' AS Date), NULL)
INSERT [dbo].[Constant] ([ConstantId], [ConstantName], [Value], [ValidFrom], [ValidTo]) VALUES (N'JELBO', N'Jelenléti bónusz', CAST(0.200000 AS Decimal(18, 6)), CAST(N'2026-01-01' AS Date), NULL)
INSERT [dbo].[Constant] ([ConstantId], [ConstantName], [Value], [ValidFrom], [ValidTo]) VALUES (N'MIBER', N'Minimál bér', CAST(322800.000000 AS Decimal(18, 6)), CAST(N'2026-01-01' AS Date), NULL)
INSERT [dbo].[Constant] ([ConstantId], [ConstantName], [Value], [ValidFrom], [ValidTo]) VALUES (N'SZEPM', N'Szépkártya éves maximum', CAST(400000.000000 AS Decimal(18, 6)), CAST(N'2026-01-01' AS Date), NULL)
INSERT [dbo].[Constant] ([ConstantId], [ConstantName], [Value], [ValidFrom], [ValidTo]) VALUES (N'SZJAS', N'SZJA szátalék', CAST(0.150000 AS Decimal(18, 6)), CAST(N'2026-01-01' AS Date), NULL)
INSERT [dbo].[Constant] ([ConstantId], [ConstantName], [Value], [ValidFrom], [ValidTo]) VALUES (N'SZOCH', N'Szociális hozzájárulás', CAST(0.130000 AS Decimal(18, 6)), CAST(N'2026-01-01' AS Date), NULL)
INSERT [dbo].[Constant] ([ConstantId], [ConstantName], [Value], [ValidFrom], [ValidTo]) VALUES (N'TBHSZ', N'Tb hozzájárulás százalék', CAST(0.185000 AS Decimal(18, 6)), CAST(N'2026-01-01' AS Date), NULL)
GO
SET IDENTITY_INSERT [dbo].[DayType] ON 

INSERT [dbo].[DayType] ([DayTypeId], [Code], [Name], [IsWorkday], [StartTime], [EndTime], [BreakMinutes]) VALUES (1, N'WORKDAY_8H', N'8 órás munkanap', 1, CAST(N'08:00:00' AS Time), CAST(N'16:00:00' AS Time), 30)
INSERT [dbo].[DayType] ([DayTypeId], [Code], [Name], [IsWorkday], [StartTime], [EndTime], [BreakMinutes]) VALUES (2, N'SZABADSAG', N'SZABADSAG', 0, NULL, NULL, 0)
INSERT [dbo].[DayType] ([DayTypeId], [Code], [Name], [IsWorkday], [StartTime], [EndTime], [BreakMinutes]) VALUES (5, N'12h', N'12 órás', 1, CAST(N'06:00:00' AS Time), CAST(N'06:00:00' AS Time), 50)
INSERT [dbo].[DayType] ([DayTypeId], [Code], [Name], [IsWorkday], [StartTime], [EndTime], [BreakMinutes]) VALUES (6, N'3MSZ_8H_DE', N'8 órás délelöttös', 1, CAST(N'06:00:00' AS Time), CAST(N'14:00:00' AS Time), 30)
INSERT [dbo].[DayType] ([DayTypeId], [Code], [Name], [IsWorkday], [StartTime], [EndTime], [BreakMinutes]) VALUES (7, N'3MSZ_8H_Du', N'8 órás délutános', 1, CAST(N'14:00:00' AS Time), CAST(N'22:00:00' AS Time), 30)
INSERT [dbo].[DayType] ([DayTypeId], [Code], [Name], [IsWorkday], [StartTime], [EndTime], [BreakMinutes]) VALUES (8, N'3MSZ_8H_EJ', N'8 órás éjszaás', 1, CAST(N'22:00:00' AS Time), CAST(N'06:00:00' AS Time), 30)
SET IDENTITY_INSERT [dbo].[DayType] OFF
GO
SET IDENTITY_INSERT [dbo].[Dependent] ON 

INSERT [dbo].[Dependent] ([DependentId], [FirstName], [LastName], [BirthDate], [TaxId]) VALUES (1, N'elek', N'teszt', CAST(N'2020-10-04' AS Date), N'ewewewewe')
INSERT [dbo].[Dependent] ([DependentId], [FirstName], [LastName], [BirthDate], [TaxId]) VALUES (2, N'Béla', N'Wallace', CAST(N'2020-01-30' AS Date), N'1234569871')
INSERT [dbo].[Dependent] ([DependentId], [FirstName], [LastName], [BirthDate], [TaxId]) VALUES (3, N'Bill', N'Kill', CAST(N'2018-03-17' AS Date), N'1234567898')
INSERT [dbo].[Dependent] ([DependentId], [FirstName], [LastName], [BirthDate], [TaxId]) VALUES (4, N'Gyerek 1', N'Scully', CAST(N'2016-11-04' AS Date), NULL)
INSERT [dbo].[Dependent] ([DependentId], [FirstName], [LastName], [BirthDate], [TaxId]) VALUES (5, N'Gyerek 2', N'Scully', CAST(N'2018-04-13' AS Date), NULL)
INSERT [dbo].[Dependent] ([DependentId], [FirstName], [LastName], [BirthDate], [TaxId]) VALUES (6, N'Gyerek 3', N'Scully', CAST(N'2020-06-18' AS Date), NULL)
INSERT [dbo].[Dependent] ([DependentId], [FirstName], [LastName], [BirthDate], [TaxId]) VALUES (7, N'Gyerek 4', N'Syully', CAST(N'2024-01-19' AS Date), NULL)
SET IDENTITY_INSERT [dbo].[Dependent] OFF
GO
SET IDENTITY_INSERT [dbo].[Employee] ON 

INSERT [dbo].[Employee] ([EmployeeId], [FirstName], [LastName], [BirthDate], [IsActive], [PersonalId], [TaxId], [TAJId], [Address], [PayrollRunFrom], [JoinDate], [TerminationDate]) VALUES (1, N'Teszt3333', N'Módosított Dolgozó 566', CAST(N'1995-04-12' AS Date), 0, N'TEST-PERSONAL-001', N'TEST-TAX-001', N'TEST-TAJ-001', N'Módosított teszt utca 2.', NULL, CAST(N'2026-10-26' AS Date), CAST(N'2027-03-31' AS Date))
INSERT [dbo].[Employee] ([EmployeeId], [FirstName], [LastName], [BirthDate], [IsActive], [PersonalId], [TaxId], [TAJId], [Address], [PayrollRunFrom], [JoinDate], [TerminationDate]) VALUES (2, N'Dávid', N'Vajda Teszt', CAST(N'1999-11-23' AS Date), 1, N'111111', N'111111', N'11111', N'8446 kislőd', CAST(N'2026-10-26' AS Date), CAST(N'2026-10-26' AS Date), NULL)
INSERT [dbo].[Employee] ([EmployeeId], [FirstName], [LastName], [BirthDate], [IsActive], [PersonalId], [TaxId], [TAJId], [Address], [PayrollRunFrom], [JoinDate], [TerminationDate]) VALUES (3, N'Elek', N'Teszt', CAST(N'2000-01-01' AS Date), 1, N'231231231', N'120120201', N'210201202', N'120120120', CAST(N'2026-10-26' AS Date), CAST(N'2026-10-26' AS Date), NULL)
INSERT [dbo].[Employee] ([EmployeeId], [FirstName], [LastName], [BirthDate], [IsActive], [PersonalId], [TaxId], [TAJId], [Address], [PayrollRunFrom], [JoinDate], [TerminationDate]) VALUES (4, N'Elek', N'Könyv', CAST(N'2000-10-31' AS Date), 0, N'44324ke', N'232313213', N'3123123123', N'Ajka', CAST(N'2026-01-01' AS Date), CAST(N'2026-01-01' AS Date), NULL)
INSERT [dbo].[Employee] ([EmployeeId], [FirstName], [LastName], [BirthDate], [IsActive], [PersonalId], [TaxId], [TAJId], [Address], [PayrollRunFrom], [JoinDate], [TerminationDate]) VALUES (5, N'Béla', N'Béla', CAST(N'1999-11-23' AS Date), 1, N'344424234', N'3424234234', N'23423423423', N'234234234', CAST(N'2026-12-01' AS Date), CAST(N'2026-10-28' AS Date), NULL)
INSERT [dbo].[Employee] ([EmployeeId], [FirstName], [LastName], [BirthDate], [IsActive], [PersonalId], [TaxId], [TAJId], [Address], [PayrollRunFrom], [JoinDate], [TerminationDate]) VALUES (6, N'Mia', N'Wallace', CAST(N'1995-04-13' AS Date), 1, N'123456PF', N'1234567890', N'111-111-111', N'Mr. Wallace háza', CAST(N'2026-10-01' AS Date), CAST(N'2026-10-01' AS Date), NULL)
INSERT [dbo].[Employee] ([EmployeeId], [FirstName], [LastName], [BirthDate], [IsActive], [PersonalId], [TaxId], [TAJId], [Address], [PayrollRunFrom], [JoinDate], [TerminationDate]) VALUES (7, N'Vincent', N'Vega', CAST(N'1980-02-20' AS Date), 1, N'11111111', N'11111111', N'1111111111111', N'1111111111', CAST(N'2026-11-01' AS Date), CAST(N'2026-11-01' AS Date), NULL)
INSERT [dbo].[Employee] ([EmployeeId], [FirstName], [LastName], [BirthDate], [IsActive], [PersonalId], [TaxId], [TAJId], [Address], [PayrollRunFrom], [JoinDate], [TerminationDate]) VALUES (8, N'Django', N'Freeman', CAST(N'2005-11-10' AS Date), 1, N'123456DJ', N'2314567890', N'200-200-200', N'8200 Veszprém Sosehol utca 10', CAST(N'2026-10-01' AS Date), CAST(N'2026-10-01' AS Date), NULL)
INSERT [dbo].[Employee] ([EmployeeId], [FirstName], [LastName], [BirthDate], [IsActive], [PersonalId], [TaxId], [TAJId], [Address], [PayrollRunFrom], [JoinDate], [TerminationDate]) VALUES (9, N'Dana', N'Scully', CAST(N'1982-02-08' AS Date), 1, N'123456DS', N'1234567999', N'404-404-404', N'935, Pennsylvania, Washington, DC20535', CAST(N'2026-11-01' AS Date), CAST(N'2026-11-01' AS Date), NULL)
SET IDENTITY_INSERT [dbo].[Employee] OFF
GO
SET IDENTITY_INSERT [dbo].[EmployeeAbsence] ON 

INSERT [dbo].[EmployeeAbsence] ([AbsenceId], [EmploymentId], [AbsenceTypeId], [StartDate], [EndDate], [StartTime], [EndTime], [FullDay]) VALUES (8, 5, 3, CAST(N'2026-10-26' AS Date), CAST(N'2026-10-26' AS Date), NULL, NULL, 1)
INSERT [dbo].[EmployeeAbsence] ([AbsenceId], [EmploymentId], [AbsenceTypeId], [StartDate], [EndDate], [StartTime], [EndTime], [FullDay]) VALUES (9, 10, 4, CAST(N'2026-11-03' AS Date), CAST(N'2026-11-06' AS Date), NULL, NULL, 1)
INSERT [dbo].[EmployeeAbsence] ([AbsenceId], [EmploymentId], [AbsenceTypeId], [StartDate], [EndDate], [StartTime], [EndTime], [FullDay]) VALUES (10, 10, 5, CAST(N'2026-11-16' AS Date), CAST(N'2026-11-16' AS Date), NULL, NULL, 1)
INSERT [dbo].[EmployeeAbsence] ([AbsenceId], [EmploymentId], [AbsenceTypeId], [StartDate], [EndDate], [StartTime], [EndTime], [FullDay]) VALUES (11, 9, 7, CAST(N'2026-11-08' AS Date), CAST(N'2026-11-08' AS Date), NULL, NULL, 1)
INSERT [dbo].[EmployeeAbsence] ([AbsenceId], [EmploymentId], [AbsenceTypeId], [StartDate], [EndDate], [StartTime], [EndTime], [FullDay]) VALUES (12, 9, 4, CAST(N'2026-11-10' AS Date), CAST(N'2026-12-08' AS Date), NULL, NULL, 1)
SET IDENTITY_INSERT [dbo].[EmployeeAbsence] OFF
GO
SET IDENTITY_INSERT [dbo].[EmployeeBankAccount] ON 

INSERT [dbo].[EmployeeBankAccount] ([EmployeeBankAccountId], [EmployeeId], [AccountIdentifier], [ValidFrom], [ValidTo], [AccountType]) VALUES (6, 4, N'1-1-1-1', CAST(N'2026-01-01' AS Date), NULL, N'BANK_ACCOUNT')
INSERT [dbo].[EmployeeBankAccount] ([EmployeeBankAccountId], [EmployeeId], [AccountIdentifier], [ValidFrom], [ValidTo], [AccountType]) VALUES (7, 4, N'2-1-1-1', CAST(N'2026-10-26' AS Date), NULL, N'SZEP_CARD')
INSERT [dbo].[EmployeeBankAccount] ([EmployeeBankAccountId], [EmployeeId], [AccountIdentifier], [ValidFrom], [ValidTo], [AccountType]) VALUES (8, 6, N'11111111-88888888-99999999', CAST(N'2026-10-01' AS Date), NULL, N'BANK_ACCOUNT')
INSERT [dbo].[EmployeeBankAccount] ([EmployeeBankAccountId], [EmployeeId], [AccountIdentifier], [ValidFrom], [ValidTo], [AccountType]) VALUES (10, 6, N'22211111-88888888-99999999', CAST(N'2026-10-01' AS Date), NULL, N'SZEP_CARD')
SET IDENTITY_INSERT [dbo].[EmployeeBankAccount] OFF
GO
SET IDENTITY_INSERT [dbo].[EmployeeDependent] ON 

INSERT [dbo].[EmployeeDependent] ([EmployeeDependentId], [EmployeeId], [DependentId], [RelationshipTypeId], [ValidFrom], [ValidTo]) VALUES (1, 2, 1, 1, CAST(N'2020-10-04' AS Date), NULL)
INSERT [dbo].[EmployeeDependent] ([EmployeeDependentId], [EmployeeId], [DependentId], [RelationshipTypeId], [ValidFrom], [ValidTo]) VALUES (2, 6, 2, 1, CAST(N'2020-01-30' AS Date), NULL)
INSERT [dbo].[EmployeeDependent] ([EmployeeDependentId], [EmployeeId], [DependentId], [RelationshipTypeId], [ValidFrom], [ValidTo]) VALUES (3, 6, 3, 1, CAST(N'2018-03-17' AS Date), NULL)
INSERT [dbo].[EmployeeDependent] ([EmployeeDependentId], [EmployeeId], [DependentId], [RelationshipTypeId], [ValidFrom], [ValidTo]) VALUES (4, 9, 4, 1, CAST(N'2016-11-04' AS Date), NULL)
INSERT [dbo].[EmployeeDependent] ([EmployeeDependentId], [EmployeeId], [DependentId], [RelationshipTypeId], [ValidFrom], [ValidTo]) VALUES (5, 9, 5, 1, CAST(N'2018-04-13' AS Date), NULL)
INSERT [dbo].[EmployeeDependent] ([EmployeeDependentId], [EmployeeId], [DependentId], [RelationshipTypeId], [ValidFrom], [ValidTo]) VALUES (6, 9, 6, 1, CAST(N'2020-06-18' AS Date), NULL)
INSERT [dbo].[EmployeeDependent] ([EmployeeDependentId], [EmployeeId], [DependentId], [RelationshipTypeId], [ValidFrom], [ValidTo]) VALUES (7, 9, 7, 1, CAST(N'2024-01-19' AS Date), NULL)
SET IDENTITY_INSERT [dbo].[EmployeeDependent] OFF
GO
INSERT [dbo].[EmployeeFieldValue] ([EmployeeId], [FieldId], [FieldValue], [OptionId], [ValidFrom], [ValidTo]) VALUES (1, 2, N'ALMA', NULL, CAST(N'2026-10-26' AS Date), NULL)
INSERT [dbo].[EmployeeFieldValue] ([EmployeeId], [FieldId], [FieldValue], [OptionId], [ValidFrom], [ValidTo]) VALUES (6, 1, NULL, 1, CAST(N'2026-10-01' AS Date), NULL)
INSERT [dbo].[EmployeeFieldValue] ([EmployeeId], [FieldId], [FieldValue], [OptionId], [ValidFrom], [ValidTo]) VALUES (6, 6, NULL, 3, CAST(N'2026-10-01' AS Date), NULL)
INSERT [dbo].[EmployeeFieldValue] ([EmployeeId], [FieldId], [FieldValue], [OptionId], [ValidFrom], [ValidTo]) VALUES (6, 10, NULL, 8, CAST(N'2026-10-01' AS Date), NULL)
INSERT [dbo].[EmployeeFieldValue] ([EmployeeId], [FieldId], [FieldValue], [OptionId], [ValidFrom], [ValidTo]) VALUES (6, 12, N'50', NULL, CAST(N'2026-10-01' AS Date), NULL)
INSERT [dbo].[EmployeeFieldValue] ([EmployeeId], [FieldId], [FieldValue], [OptionId], [ValidFrom], [ValidTo]) VALUES (8, 10, NULL, 9, CAST(N'2026-10-01' AS Date), NULL)
INSERT [dbo].[EmployeeFieldValue] ([EmployeeId], [FieldId], [FieldValue], [OptionId], [ValidFrom], [ValidTo]) VALUES (9, 10, NULL, 8, CAST(N'2026-11-01' AS Date), NULL)
GO
SET IDENTITY_INSERT [dbo].[Employment] ON 

INSERT [dbo].[Employment] ([EmploymentId], [CompanyId], [EmployeeId], [ValidFrom], [ValidTo]) VALUES (5, 3, 1, CAST(N'2026-10-26' AS Date), NULL)
INSERT [dbo].[Employment] ([EmploymentId], [CompanyId], [EmployeeId], [ValidFrom], [ValidTo]) VALUES (6, 1, 2, CAST(N'2026-10-26' AS Date), NULL)
INSERT [dbo].[Employment] ([EmploymentId], [CompanyId], [EmployeeId], [ValidFrom], [ValidTo]) VALUES (7, 1, 3, CAST(N'2026-10-26' AS Date), NULL)
INSERT [dbo].[Employment] ([EmploymentId], [CompanyId], [EmployeeId], [ValidFrom], [ValidTo]) VALUES (8, 1, 4, CAST(N'2026-01-01' AS Date), NULL)
INSERT [dbo].[Employment] ([EmploymentId], [CompanyId], [EmployeeId], [ValidFrom], [ValidTo]) VALUES (9, 4, 5, CAST(N'2026-10-28' AS Date), NULL)
INSERT [dbo].[Employment] ([EmploymentId], [CompanyId], [EmployeeId], [ValidFrom], [ValidTo]) VALUES (10, 4, 6, CAST(N'2026-10-01' AS Date), NULL)
INSERT [dbo].[Employment] ([EmploymentId], [CompanyId], [EmployeeId], [ValidFrom], [ValidTo]) VALUES (11, 4, 7, CAST(N'2026-11-01' AS Date), NULL)
INSERT [dbo].[Employment] ([EmploymentId], [CompanyId], [EmployeeId], [ValidFrom], [ValidTo]) VALUES (12, 4, 8, CAST(N'2026-10-01' AS Date), NULL)
INSERT [dbo].[Employment] ([EmploymentId], [CompanyId], [EmployeeId], [ValidFrom], [ValidTo]) VALUES (13, 4, 9, CAST(N'2026-11-01' AS Date), NULL)
SET IDENTITY_INSERT [dbo].[Employment] OFF
GO
SET IDENTITY_INSERT [dbo].[EmploymentPayrollElement] ON 

INSERT [dbo].[EmploymentPayrollElement] ([EmploymentPayrollElementId], [EmploymentId], [PayrollElementId], [ValidFrom], [ValidTo], [Amount]) VALUES (5, 6, 1, CAST(N'2026-10-26' AS Date), NULL, CAST(1000000.00 AS Decimal(18, 2)))
INSERT [dbo].[EmploymentPayrollElement] ([EmploymentPayrollElementId], [EmploymentId], [PayrollElementId], [ValidFrom], [ValidTo], [Amount]) VALUES (6, 7, 1, CAST(N'2026-10-26' AS Date), NULL, CAST(10.00 AS Decimal(18, 2)))
INSERT [dbo].[EmploymentPayrollElement] ([EmploymentPayrollElementId], [EmploymentId], [PayrollElementId], [ValidFrom], [ValidTo], [Amount]) VALUES (7, 8, 2, CAST(N'2026-01-01' AS Date), CAST(N'2026-10-26' AS Date), CAST(100.00 AS Decimal(18, 2)))
INSERT [dbo].[EmploymentPayrollElement] ([EmploymentPayrollElementId], [EmploymentId], [PayrollElementId], [ValidFrom], [ValidTo], [Amount]) VALUES (8, 9, 1, CAST(N'2026-10-28' AS Date), NULL, CAST(100000.00 AS Decimal(18, 2)))
INSERT [dbo].[EmploymentPayrollElement] ([EmploymentPayrollElementId], [EmploymentId], [PayrollElementId], [ValidFrom], [ValidTo], [Amount]) VALUES (9, 10, 1, CAST(N'2026-10-01' AS Date), NULL, CAST(1000000.00 AS Decimal(18, 2)))
INSERT [dbo].[EmploymentPayrollElement] ([EmploymentPayrollElementId], [EmploymentId], [PayrollElementId], [ValidFrom], [ValidTo], [Amount]) VALUES (11, 11, 2, CAST(N'2026-11-01' AS Date), NULL, CAST(10000.00 AS Decimal(18, 2)))
INSERT [dbo].[EmploymentPayrollElement] ([EmploymentPayrollElementId], [EmploymentId], [PayrollElementId], [ValidFrom], [ValidTo], [Amount]) VALUES (12, 12, 1, CAST(N'2026-10-01' AS Date), NULL, CAST(1000000.00 AS Decimal(18, 2)))
INSERT [dbo].[EmploymentPayrollElement] ([EmploymentPayrollElementId], [EmploymentId], [PayrollElementId], [ValidFrom], [ValidTo], [Amount]) VALUES (13, 13, 1, CAST(N'2026-11-01' AS Date), NULL, CAST(2000000.00 AS Decimal(18, 2)))
INSERT [dbo].[EmploymentPayrollElement] ([EmploymentPayrollElementId], [EmploymentId], [PayrollElementId], [ValidFrom], [ValidTo], [Amount]) VALUES (14, 13, 23, CAST(N'2026-11-01' AS Date), NULL, CAST(450000.00 AS Decimal(18, 2)))
SET IDENTITY_INSERT [dbo].[EmploymentPayrollElement] OFF
GO
SET IDENTITY_INSERT [dbo].[EmploymentWorkSchedule] ON 

INSERT [dbo].[EmploymentWorkSchedule] ([EmploymentWorkScheduleId], [EmploymentId], [WorkScheduleId], [ValidFrom], [ValidTo], [CycleStartDate]) VALUES (7, 6, 1, CAST(N'2026-10-26' AS Date), NULL, CAST(N'2026-10-26' AS Date))
INSERT [dbo].[EmploymentWorkSchedule] ([EmploymentWorkScheduleId], [EmploymentId], [WorkScheduleId], [ValidFrom], [ValidTo], [CycleStartDate]) VALUES (8, 7, 1, CAST(N'2026-10-26' AS Date), NULL, CAST(N'2026-10-26' AS Date))
INSERT [dbo].[EmploymentWorkSchedule] ([EmploymentWorkScheduleId], [EmploymentId], [WorkScheduleId], [ValidFrom], [ValidTo], [CycleStartDate]) VALUES (9, 8, 1, CAST(N'2026-01-01' AS Date), NULL, CAST(N'2025-12-29' AS Date))
INSERT [dbo].[EmploymentWorkSchedule] ([EmploymentWorkScheduleId], [EmploymentId], [WorkScheduleId], [ValidFrom], [ValidTo], [CycleStartDate]) VALUES (10, 9, 5, CAST(N'2026-10-28' AS Date), NULL, CAST(N'2026-10-26' AS Date))
INSERT [dbo].[EmploymentWorkSchedule] ([EmploymentWorkScheduleId], [EmploymentId], [WorkScheduleId], [ValidFrom], [ValidTo], [CycleStartDate]) VALUES (11, 10, 5, CAST(N'2026-10-01' AS Date), NULL, CAST(N'2026-09-28' AS Date))
INSERT [dbo].[EmploymentWorkSchedule] ([EmploymentWorkScheduleId], [EmploymentId], [WorkScheduleId], [ValidFrom], [ValidTo], [CycleStartDate]) VALUES (12, 11, 6, CAST(N'2026-11-01' AS Date), NULL, CAST(N'2026-11-01' AS Date))
INSERT [dbo].[EmploymentWorkSchedule] ([EmploymentWorkScheduleId], [EmploymentId], [WorkScheduleId], [ValidFrom], [ValidTo], [CycleStartDate]) VALUES (13, 12, 1, CAST(N'2026-10-01' AS Date), NULL, CAST(N'2026-09-28' AS Date))
INSERT [dbo].[EmploymentWorkSchedule] ([EmploymentWorkScheduleId], [EmploymentId], [WorkScheduleId], [ValidFrom], [ValidTo], [CycleStartDate]) VALUES (15, 13, 6, CAST(N'2026-11-01' AS Date), NULL, CAST(N'2026-11-01' AS Date))
SET IDENTITY_INSERT [dbo].[EmploymentWorkSchedule] OFF
GO
SET IDENTITY_INSERT [dbo].[FieldType] ON 

INSERT [dbo].[FieldType] ([FieldTypeId], [Code], [Name]) VALUES (1, N'TEXT', N'Szöveg')
INSERT [dbo].[FieldType] ([FieldTypeId], [Code], [Name]) VALUES (2, N'NUMBER', N'Szám')
INSERT [dbo].[FieldType] ([FieldTypeId], [Code], [Name]) VALUES (3, N'DATE', N'Dátum')
INSERT [dbo].[FieldType] ([FieldTypeId], [Code], [Name]) VALUES (4, N'BOOLEAN', N'Igen/nem')
INSERT [dbo].[FieldType] ([FieldTypeId], [Code], [Name]) VALUES (5, N'LIST', N'Választólista')
SET IDENTITY_INSERT [dbo].[FieldType] OFF
GO
SET IDENTITY_INSERT [dbo].[MasterDataField] ON 

INSERT [dbo].[MasterDataField] ([FieldId], [MasterDataGroupId], [Code], [DisplayName], [FieldTypeId], [IsRequired], [IsUnique], [DisplayOrder], [IsActive]) VALUES (1, 3, N'BONUS_CATEGORY', N'Bónusz kategória', 5, 0, 0, 2, 1)
INSERT [dbo].[MasterDataField] ([FieldId], [MasterDataGroupId], [Code], [DisplayName], [FieldTypeId], [IsRequired], [IsUnique], [DisplayOrder], [IsActive]) VALUES (2, 1, N'EMPLOYEE_TEST_TEXT', N'Dolgozó teszt mező', 1, 0, 0, 1, 0)
INSERT [dbo].[MasterDataField] ([FieldId], [MasterDataGroupId], [Code], [DisplayName], [FieldTypeId], [IsRequired], [IsUnique], [DisplayOrder], [IsActive]) VALUES (5, 3, N'Department', N'Terület', 5, 0, 0, 1, 0)
INSERT [dbo].[MasterDataField] ([FieldId], [MasterDataGroupId], [Code], [DisplayName], [FieldTypeId], [IsRequired], [IsUnique], [DisplayOrder], [IsActive]) VALUES (6, 4, N'dep', N'terület', 5, 0, 0, 0, 1)
INSERT [dbo].[MasterDataField] ([FieldId], [MasterDataGroupId], [Code], [DisplayName], [FieldTypeId], [IsRequired], [IsUnique], [DisplayOrder], [IsActive]) VALUES (7, 5, N'PAYROLLELEMENT_Tavdíj', N'Távdíj számításhoz tartozó bérelem', 4, 0, 0, 0, 1)
INSERT [dbo].[MasterDataField] ([FieldId], [MasterDataGroupId], [Code], [DisplayName], [FieldTypeId], [IsRequired], [IsUnique], [DisplayOrder], [IsActive]) VALUES (8, 5, N'PAYROLLELEMENT_tesztlista', N'tesztlista', 5, 0, 0, 0, 1)
INSERT [dbo].[MasterDataField] ([FieldId], [MasterDataGroupId], [Code], [DisplayName], [FieldTypeId], [IsRequired], [IsUnique], [DisplayOrder], [IsActive]) VALUES (9, 6, N'PAYROLLELEMENT_4000-BRUTTO', N'Bérelem belekerül a 4000-BRUTTO bérelembe', 4, 0, 0, 0, 1)
INSERT [dbo].[MasterDataField] ([FieldId], [MasterDataGroupId], [Code], [DisplayName], [FieldTypeId], [IsRequired], [IsUnique], [DisplayOrder], [IsActive]) VALUES (10, 7, N'NEM', N'Nem', 5, 1, 0, 0, 1)
INSERT [dbo].[MasterDataField] ([FieldId], [MasterDataGroupId], [Code], [DisplayName], [FieldTypeId], [IsRequired], [IsUnique], [DisplayOrder], [IsActive]) VALUES (11, 7, N'TBET', N'Tartós betegség', 1, 0, 0, 0, 1)
INSERT [dbo].[MasterDataField] ([FieldId], [MasterDataGroupId], [Code], [DisplayName], [FieldTypeId], [IsRequired], [IsUnique], [DisplayOrder], [IsActive]) VALUES (12, 7, N'TAVOL', N'Lakhely távolsága km.', 2, 0, 0, 0, 1)
SET IDENTITY_INSERT [dbo].[MasterDataField] OFF
GO
SET IDENTITY_INSERT [dbo].[MasterDataFieldOption] ON 

INSERT [dbo].[MasterDataFieldOption] ([OptionId], [FieldId], [OptionCode], [DisplayName], [SortOrder], [IsActive]) VALUES (1, 1, N'Extra', N'Extra', 2, 1)
INSERT [dbo].[MasterDataFieldOption] ([OptionId], [FieldId], [OptionCode], [DisplayName], [SortOrder], [IsActive]) VALUES (2, 6, N'1', N'IT', 0, 1)
INSERT [dbo].[MasterDataFieldOption] ([OptionId], [FieldId], [OptionCode], [DisplayName], [SortOrder], [IsActive]) VALUES (3, 6, N'2', N'HR', 0, 1)
INSERT [dbo].[MasterDataFieldOption] ([OptionId], [FieldId], [OptionCode], [DisplayName], [SortOrder], [IsActive]) VALUES (4, 6, N'3', N'FI', 0, 1)
INSERT [dbo].[MasterDataFieldOption] ([OptionId], [FieldId], [OptionCode], [DisplayName], [SortOrder], [IsActive]) VALUES (5, 5, N'1', N'HR', 0, 1)
INSERT [dbo].[MasterDataFieldOption] ([OptionId], [FieldId], [OptionCode], [DisplayName], [SortOrder], [IsActive]) VALUES (6, 5, N'2', N'IT', 0, 1)
INSERT [dbo].[MasterDataFieldOption] ([OptionId], [FieldId], [OptionCode], [DisplayName], [SortOrder], [IsActive]) VALUES (7, 8, N'1', N'tessz', 0, 1)
INSERT [dbo].[MasterDataFieldOption] ([OptionId], [FieldId], [OptionCode], [DisplayName], [SortOrder], [IsActive]) VALUES (8, 10, N'NO', N'Nő', 0, 1)
INSERT [dbo].[MasterDataFieldOption] ([OptionId], [FieldId], [OptionCode], [DisplayName], [SortOrder], [IsActive]) VALUES (9, 10, N'FERFI', N'Férfi', 0, 1)
INSERT [dbo].[MasterDataFieldOption] ([OptionId], [FieldId], [OptionCode], [DisplayName], [SortOrder], [IsActive]) VALUES (10, 1, N'Basic', N'Alap', 1, 1)
SET IDENTITY_INSERT [dbo].[MasterDataFieldOption] OFF
GO
SET IDENTITY_INSERT [dbo].[MasterDataGroup] ON 

INSERT [dbo].[MasterDataGroup] ([MasterDataGroupId], [Code], [Name]) VALUES (1, N'EMPLOYEE_TEST', N'Munkavállalói tesztcsoport')
INSERT [dbo].[MasterDataGroup] ([MasterDataGroupId], [Code], [Name]) VALUES (2, N'EMPLOYMENT_TEST', N'Jogviszony tesztcsoport')
INSERT [dbo].[MasterDataGroup] ([MasterDataGroupId], [Code], [Name]) VALUES (3, N'PAYROLL_TEST', N'Béradat tesztcsoport')
INSERT [dbo].[MasterDataGroup] ([MasterDataGroupId], [Code], [Name]) VALUES (4, N'COMPDATA', N'Vállalati adatok')
INSERT [dbo].[MasterDataGroup] ([MasterDataGroupId], [Code], [Name]) VALUES (5, N'PAYROLLELEMENT_TAVDIJ', N'Távollétidíj Bérelem tulajdonságok')
INSERT [dbo].[MasterDataGroup] ([MasterDataGroupId], [Code], [Name]) VALUES (6, N'PAYROLLELEMENT_KUMULCSOP', N'Kumulációs csoport')
INSERT [dbo].[MasterDataGroup] ([MasterDataGroupId], [Code], [Name]) VALUES (7, N'KIEGALAPADAT', N'Kiegészítő alap adatok')
SET IDENTITY_INSERT [dbo].[MasterDataGroup] OFF
GO
INSERT [dbo].[MDGToRole] ([RoleId], [MasterDataGroupId], [CanRead], [CanEdit]) VALUES (1, 1, 1, 1)
INSERT [dbo].[MDGToRole] ([RoleId], [MasterDataGroupId], [CanRead], [CanEdit]) VALUES (1, 2, 1, 1)
INSERT [dbo].[MDGToRole] ([RoleId], [MasterDataGroupId], [CanRead], [CanEdit]) VALUES (1, 3, 1, 1)
INSERT [dbo].[MDGToRole] ([RoleId], [MasterDataGroupId], [CanRead], [CanEdit]) VALUES (1, 4, 1, 1)
INSERT [dbo].[MDGToRole] ([RoleId], [MasterDataGroupId], [CanRead], [CanEdit]) VALUES (1, 5, 1, 1)
INSERT [dbo].[MDGToRole] ([RoleId], [MasterDataGroupId], [CanRead], [CanEdit]) VALUES (1, 6, 1, 1)
INSERT [dbo].[MDGToRole] ([RoleId], [MasterDataGroupId], [CanRead], [CanEdit]) VALUES (1, 7, 1, 1)
INSERT [dbo].[MDGToRole] ([RoleId], [MasterDataGroupId], [CanRead], [CanEdit]) VALUES (5, 1, 1, 1)
INSERT [dbo].[MDGToRole] ([RoleId], [MasterDataGroupId], [CanRead], [CanEdit]) VALUES (6, 4, 1, 0)
GO
SET IDENTITY_INSERT [dbo].[PayrollElement] ON 

INSERT [dbo].[PayrollElement] ([PayrollElementId], [Code], [Name], [IsActive]) VALUES (1, N'1000-HAVIBER', N'Havibéres időbér', 1)
INSERT [dbo].[PayrollElement] ([PayrollElementId], [Code], [Name], [IsActive]) VALUES (2, N'1001-ORABER', N'Órabéres időbér', 1)
INSERT [dbo].[PayrollElement] ([PayrollElementId], [Code], [Name], [IsActive]) VALUES (10, N'2000-MRENDO', N'Munkarend szerint ledolgozott órák', 1)
INSERT [dbo].[PayrollElement] ([PayrollElementId], [Code], [Name], [IsActive]) VALUES (11, N'2001-MRENDSZ', N'Munkarend szerinti szünetek', 1)
INSERT [dbo].[PayrollElement] ([PayrollElementId], [Code], [Name], [IsActive]) VALUES (12, N'2002-FIZTAV', N'Fizetett távollétek', 1)
INSERT [dbo].[PayrollElement] ([PayrollElementId], [Code], [Name], [IsActive]) VALUES (13, N'2003-NFIZTAV', N'Nem fizetett távollétek', 1)
INSERT [dbo].[PayrollElement] ([PayrollElementId], [Code], [Name], [IsActive]) VALUES (14, N'3000-MJTAM', N'Munkába járás támogatás', 1)
INSERT [dbo].[PayrollElement] ([PayrollElementId], [Code], [Name], [IsActive]) VALUES (15, N'3001-JELBON', N'Jelenléti Bónusz', 1)
INSERT [dbo].[PayrollElement] ([PayrollElementId], [Code], [Name], [IsActive]) VALUES (16, N'1100-HAVIBER', N'Havibéres Havibér', 1)
INSERT [dbo].[PayrollElement] ([PayrollElementId], [Code], [Name], [IsActive]) VALUES (17, N'1101-ORABER', N'Órabéres havibér', 1)
INSERT [dbo].[PayrollElement] ([PayrollElementId], [Code], [Name], [IsActive]) VALUES (18, N'4000-BRUTTÓ', N'Bruttó bér', 1)
INSERT [dbo].[PayrollElement] ([PayrollElementId], [Code], [Name], [IsActive]) VALUES (19, N'5000-SZJA', N'Személyi jövedelemadó', 1)
INSERT [dbo].[PayrollElement] ([PayrollElementId], [Code], [Name], [IsActive]) VALUES (20, N'5001-TBH', N'Társadalombiztosítási hozzájárulás', 1)
INSERT [dbo].[PayrollElement] ([PayrollElementId], [Code], [Name], [IsActive]) VALUES (21, N'5002-SZOCHO', N'Szociális hozzájárulás', 1)
INSERT [dbo].[PayrollElement] ([PayrollElementId], [Code], [Name], [IsActive]) VALUES (22, N'6000-NETTO', N'Nettó bér', 1)
INSERT [dbo].[PayrollElement] ([PayrollElementId], [Code], [Name], [IsActive]) VALUES (23, N'7000-SZEPK', N'Szépkártya', 1)
INSERT [dbo].[PayrollElement] ([PayrollElementId], [Code], [Name], [IsActive]) VALUES (24, N'2005-MPDUO', N'Délutános műszakpótlék összeg', 1)
INSERT [dbo].[PayrollElement] ([PayrollElementId], [Code], [Name], [IsActive]) VALUES (25, N'2006-MPEJO', N'Éjszakai műszakpótlék összeg', 1)
INSERT [dbo].[PayrollElement] ([PayrollElementId], [Code], [Name], [IsActive]) VALUES (26, N'2007-MPEJH', N'Éjszakai műszakpótlék óra', 1)
INSERT [dbo].[PayrollElement] ([PayrollElementId], [Code], [Name], [IsActive]) VALUES (27, N'2004-MPDUh', N'Délutános műszakpótlék óra', 1)
INSERT [dbo].[PayrollElement] ([PayrollElementId], [Code], [Name], [IsActive]) VALUES (28, N'2008-TULOO', N'Túlóra összeg', 1)
INSERT [dbo].[PayrollElement] ([PayrollElementId], [Code], [Name], [IsActive]) VALUES (29, N'2009-TULOH', N'Túlóra óraszám', 1)
INSERT [dbo].[PayrollElement] ([PayrollElementId], [Code], [Name], [IsActive]) VALUES (30, N'2010-VASTULO', N'Vasárnapi túlóra összeg', 1)
INSERT [dbo].[PayrollElement] ([PayrollElementId], [Code], [Name], [IsActive]) VALUES (31, N'2011-VASTULH', N'Vasárnapi túlóra óraszám', 1)
INSERT [dbo].[PayrollElement] ([PayrollElementId], [Code], [Name], [IsActive]) VALUES (32, N'1200-EGYORA', N'Egy órára jutó bér', 1)
INSERT [dbo].[PayrollElement] ([PayrollElementId], [Code], [Name], [IsActive]) VALUES (33, N'1201-EGYTAVORA', N'Egy távolléti órára jutó bér', 1)
INSERT [dbo].[PayrollElement] ([PayrollElementId], [Code], [Name], [IsActive]) VALUES (34, N'1202-JELBER', N'Jelenléti bér', 1)
INSERT [dbo].[PayrollElement] ([PayrollElementId], [Code], [Name], [IsActive]) VALUES (35, N'1203-TAVBER', N'Távollétre jutó bér', 1)
INSERT [dbo].[PayrollElement] ([PayrollElementId], [Code], [Name], [IsActive]) VALUES (36, N'7001-SZEPKNORM', N'Szépkártya normál', 1)
INSERT [dbo].[PayrollElement] ([PayrollElementId], [Code], [Name], [IsActive]) VALUES (37, N'7002-SZEPKADÓ', N'Szépkártya adóköteles', 1)
INSERT [dbo].[PayrollElement] ([PayrollElementId], [Code], [Name], [IsActive]) VALUES (38, N'5003-ADOKEDV', N'Összevont adókedvezmény', 1)
SET IDENTITY_INSERT [dbo].[PayrollElement] OFF
GO
INSERT [dbo].[PayrollElementFieldValue] ([PayrollElementId], [FieldId], [FieldValue], [OptionId], [ValidFrom], [ValidTo]) VALUES (1, 1, NULL, 1, CAST(N'2026-10-24' AS Date), CAST(N'2026-10-31' AS Date))
INSERT [dbo].[PayrollElementFieldValue] ([PayrollElementId], [FieldId], [FieldValue], [OptionId], [ValidFrom], [ValidTo]) VALUES (1, 1, NULL, 1, CAST(N'2026-11-01' AS Date), CAST(N'2026-11-15' AS Date))
INSERT [dbo].[PayrollElementFieldValue] ([PayrollElementId], [FieldId], [FieldValue], [OptionId], [ValidFrom], [ValidTo]) VALUES (1, 7, N'false', NULL, CAST(N'2026-10-27' AS Date), CAST(N'2026-10-27' AS Date))
INSERT [dbo].[PayrollElementFieldValue] ([PayrollElementId], [FieldId], [FieldValue], [OptionId], [ValidFrom], [ValidTo]) VALUES (1, 7, N'true', NULL, CAST(N'2026-10-28' AS Date), NULL)
INSERT [dbo].[PayrollElementFieldValue] ([PayrollElementId], [FieldId], [FieldValue], [OptionId], [ValidFrom], [ValidTo]) VALUES (1, 8, NULL, 7, CAST(N'2026-10-27' AS Date), CAST(N'2026-10-27' AS Date))
INSERT [dbo].[PayrollElementFieldValue] ([PayrollElementId], [FieldId], [FieldValue], [OptionId], [ValidFrom], [ValidTo]) VALUES (1, 8, NULL, 7, CAST(N'2026-10-28' AS Date), NULL)
INSERT [dbo].[PayrollElementFieldValue] ([PayrollElementId], [FieldId], [FieldValue], [OptionId], [ValidFrom], [ValidTo]) VALUES (14, 9, N'false', NULL, CAST(N'2026-10-01' AS Date), NULL)
INSERT [dbo].[PayrollElementFieldValue] ([PayrollElementId], [FieldId], [FieldValue], [OptionId], [ValidFrom], [ValidTo]) VALUES (15, 9, N'true', NULL, CAST(N'2026-10-01' AS Date), NULL)
INSERT [dbo].[PayrollElementFieldValue] ([PayrollElementId], [FieldId], [FieldValue], [OptionId], [ValidFrom], [ValidTo]) VALUES (16, 9, N'true', NULL, CAST(N'2026-10-01' AS Date), NULL)
INSERT [dbo].[PayrollElementFieldValue] ([PayrollElementId], [FieldId], [FieldValue], [OptionId], [ValidFrom], [ValidTo]) VALUES (17, 9, N'true', NULL, CAST(N'2026-10-01' AS Date), NULL)
INSERT [dbo].[PayrollElementFieldValue] ([PayrollElementId], [FieldId], [FieldValue], [OptionId], [ValidFrom], [ValidTo]) VALUES (24, 9, N'true', NULL, CAST(N'2026-10-01' AS Date), NULL)
INSERT [dbo].[PayrollElementFieldValue] ([PayrollElementId], [FieldId], [FieldValue], [OptionId], [ValidFrom], [ValidTo]) VALUES (25, 9, N'true', NULL, CAST(N'2026-10-01' AS Date), NULL)
INSERT [dbo].[PayrollElementFieldValue] ([PayrollElementId], [FieldId], [FieldValue], [OptionId], [ValidFrom], [ValidTo]) VALUES (28, 9, N'true', NULL, CAST(N'2026-10-01' AS Date), NULL)
INSERT [dbo].[PayrollElementFieldValue] ([PayrollElementId], [FieldId], [FieldValue], [OptionId], [ValidFrom], [ValidTo]) VALUES (30, 9, N'true', NULL, CAST(N'2026-11-01' AS Date), NULL)
GO
SET IDENTITY_INSERT [dbo].[PayrollResult] ON 

INSERT [dbo].[PayrollResult] ([PayrollResultId], [RunId], [EmployeeId], [Period], [ResultType], [PayrollElementId], [Amount], [RunDate], [RunByUserId]) VALUES (41, N'cab7a509-7de2-431b-a8d3-3ce9955146cd', 5, N'202611', N'O', 10, CAST(157.50 AS Decimal(18, 2)), CAST(N'2026-11-08T14:56:03.0000000' AS DateTime2), 1)
INSERT [dbo].[PayrollResult] ([PayrollResultId], [RunId], [EmployeeId], [Period], [ResultType], [PayrollElementId], [Amount], [RunDate], [RunByUserId]) VALUES (42, N'cab7a509-7de2-431b-a8d3-3ce9955146cd', 5, N'202611', N'O', 11, CAST(10.50 AS Decimal(18, 2)), CAST(N'2026-11-08T14:56:03.0000000' AS DateTime2), 1)
INSERT [dbo].[PayrollResult] ([PayrollResultId], [RunId], [EmployeeId], [Period], [ResultType], [PayrollElementId], [Amount], [RunDate], [RunByUserId]) VALUES (43, N'cab7a509-7de2-431b-a8d3-3ce9955146cd', 5, N'202611', N'O', 12, CAST(0.00 AS Decimal(18, 2)), CAST(N'2026-11-08T14:56:03.0000000' AS DateTime2), 1)
INSERT [dbo].[PayrollResult] ([PayrollResultId], [RunId], [EmployeeId], [Period], [ResultType], [PayrollElementId], [Amount], [RunDate], [RunByUserId]) VALUES (44, N'cab7a509-7de2-431b-a8d3-3ce9955146cd', 5, N'202611', N'O', 13, CAST(0.00 AS Decimal(18, 2)), CAST(N'2026-11-08T14:56:03.0000000' AS DateTime2), 1)
INSERT [dbo].[PayrollResult] ([PayrollResultId], [RunId], [EmployeeId], [Period], [ResultType], [PayrollElementId], [Amount], [RunDate], [RunByUserId]) VALUES (45, N'cab7a509-7de2-431b-a8d3-3ce9955146cd', 5, N'202611', N'O', 15, CAST(20000.00 AS Decimal(18, 2)), CAST(N'2026-11-08T14:56:03.0000000' AS DateTime2), 1)
INSERT [dbo].[PayrollResult] ([PayrollResultId], [RunId], [EmployeeId], [Period], [ResultType], [PayrollElementId], [Amount], [RunDate], [RunByUserId]) VALUES (46, N'cab7a509-7de2-431b-a8d3-3ce9955146cd', 5, N'202611', N'O', 16, CAST(100000.00 AS Decimal(18, 2)), CAST(N'2026-11-08T14:56:03.0000000' AS DateTime2), 1)
INSERT [dbo].[PayrollResult] ([PayrollResultId], [RunId], [EmployeeId], [Period], [ResultType], [PayrollElementId], [Amount], [RunDate], [RunByUserId]) VALUES (47, N'cab7a509-7de2-431b-a8d3-3ce9955146cd', 5, N'202611', N'O', 18, CAST(120000.00 AS Decimal(18, 2)), CAST(N'2026-11-08T14:56:03.0000000' AS DateTime2), 1)
INSERT [dbo].[PayrollResult] ([PayrollResultId], [RunId], [EmployeeId], [Period], [ResultType], [PayrollElementId], [Amount], [RunDate], [RunByUserId]) VALUES (48, N'cab7a509-7de2-431b-a8d3-3ce9955146cd', 5, N'202611', N'O', 19, CAST(18000.00 AS Decimal(18, 2)), CAST(N'2026-11-08T14:56:03.0000000' AS DateTime2), 1)
INSERT [dbo].[PayrollResult] ([PayrollResultId], [RunId], [EmployeeId], [Period], [ResultType], [PayrollElementId], [Amount], [RunDate], [RunByUserId]) VALUES (49, N'cab7a509-7de2-431b-a8d3-3ce9955146cd', 5, N'202611', N'O', 20, CAST(22200.00 AS Decimal(18, 2)), CAST(N'2026-11-08T14:56:03.0000000' AS DateTime2), 1)
INSERT [dbo].[PayrollResult] ([PayrollResultId], [RunId], [EmployeeId], [Period], [ResultType], [PayrollElementId], [Amount], [RunDate], [RunByUserId]) VALUES (50, N'cab7a509-7de2-431b-a8d3-3ce9955146cd', 5, N'202611', N'O', 21, CAST(15600.00 AS Decimal(18, 2)), CAST(N'2026-11-08T14:56:03.0000000' AS DateTime2), 1)
INSERT [dbo].[PayrollResult] ([PayrollResultId], [RunId], [EmployeeId], [Period], [ResultType], [PayrollElementId], [Amount], [RunDate], [RunByUserId]) VALUES (51, N'cab7a509-7de2-431b-a8d3-3ce9955146cd', 5, N'202611', N'O', 25, CAST(0.00 AS Decimal(18, 2)), CAST(N'2026-11-08T14:56:03.0000000' AS DateTime2), 1)
INSERT [dbo].[PayrollResult] ([PayrollResultId], [RunId], [EmployeeId], [Period], [ResultType], [PayrollElementId], [Amount], [RunDate], [RunByUserId]) VALUES (52, N'cab7a509-7de2-431b-a8d3-3ce9955146cd', 5, N'202611', N'O', 26, CAST(0.00 AS Decimal(18, 2)), CAST(N'2026-11-08T14:56:03.0000000' AS DateTime2), 1)
INSERT [dbo].[PayrollResult] ([PayrollResultId], [RunId], [EmployeeId], [Period], [ResultType], [PayrollElementId], [Amount], [RunDate], [RunByUserId]) VALUES (53, N'cab7a509-7de2-431b-a8d3-3ce9955146cd', 5, N'202611', N'O', 32, CAST(168.00 AS Decimal(18, 2)), CAST(N'2026-11-08T14:56:03.0000000' AS DateTime2), 1)
INSERT [dbo].[PayrollResult] ([PayrollResultId], [RunId], [EmployeeId], [Period], [ResultType], [PayrollElementId], [Amount], [RunDate], [RunByUserId]) VALUES (54, N'cab7a509-7de2-431b-a8d3-3ce9955146cd', 5, N'202611', N'O', 34, CAST(100000.00 AS Decimal(18, 2)), CAST(N'2026-11-08T14:56:03.0000000' AS DateTime2), 1)
INSERT [dbo].[PayrollResult] ([PayrollResultId], [RunId], [EmployeeId], [Period], [ResultType], [PayrollElementId], [Amount], [RunDate], [RunByUserId]) VALUES (55, N'cab7a509-7de2-431b-a8d3-3ce9955146cd', 5, N'202611', N'O', 35, CAST(0.00 AS Decimal(18, 2)), CAST(N'2026-11-08T14:56:03.0000000' AS DateTime2), 1)
SET IDENTITY_INSERT [dbo].[PayrollResult] OFF
GO
SET IDENTITY_INSERT [dbo].[RelationshipType] ON 

INSERT [dbo].[RelationshipType] ([RelationshipTypeId], [Name]) VALUES (1, N'Gyermek')
SET IDENTITY_INSERT [dbo].[RelationshipType] OFF
GO
SET IDENTITY_INSERT [dbo].[Role] ON 

INSERT [dbo].[Role] ([RoleId], [Code], [RoleName], [IsActive]) VALUES (1, N'GOD', N'GOD', 1)
INSERT [dbo].[Role] ([RoleId], [Code], [RoleName], [IsActive]) VALUES (2, N'IT_ROLE', N'IT_ROLE', 1)
INSERT [dbo].[Role] ([RoleId], [Code], [RoleName], [IsActive]) VALUES (3, N'HR_MAX', N'HR_MAX', 1)
INSERT [dbo].[Role] ([RoleId], [Code], [RoleName], [IsActive]) VALUES (4, N'HR_LOW', N'HR_LOW', 1)
INSERT [dbo].[Role] ([RoleId], [Code], [RoleName], [IsActive]) VALUES (5, N'HR_TEST_01', N'HR teszt szerep', 1)
INSERT [dbo].[Role] ([RoleId], [Code], [RoleName], [IsActive]) VALUES (6, N'TESZT_SZEREP', N'teszt szerep', 1)
SET IDENTITY_INSERT [dbo].[Role] OFF
GO
INSERT [dbo].[RoleToUser] ([UserId], [RoleId], [ValidFrom], [ValidTo]) VALUES (1, 1, CAST(N'2026-10-23' AS Date), NULL)
INSERT [dbo].[RoleToUser] ([UserId], [RoleId], [ValidFrom], [ValidTo]) VALUES (2, 5, CAST(N'2026-10-23' AS Date), NULL)
INSERT [dbo].[RoleToUser] ([UserId], [RoleId], [ValidFrom], [ValidTo]) VALUES (11, 2, CAST(N'2026-10-27' AS Date), NULL)
GO
SET IDENTITY_INSERT [dbo].[User] ON 

INSERT [dbo].[User] ([UserId], [UserName], [PasswordHash], [IsActive]) VALUES (1, N'SYSTEM', N'PASSWORD', 1)
INSERT [dbo].[User] ([UserId], [UserName], [PasswordHash], [IsActive]) VALUES (2, N'TEST_USER_UPDATEDxxx', N'Alma', 0)
INSERT [dbo].[User] ([UserId], [UserName], [PasswordHash], [IsActive]) VALUES (4, N'TEST_USER2', N'TempPass123', 0)
INSERT [dbo].[User] ([UserId], [UserName], [PasswordHash], [IsActive]) VALUES (5, N'TEST_USER3', N'PASSWORDXXXXXXX', 0)
INSERT [dbo].[User] ([UserId], [UserName], [PasswordHash], [IsActive]) VALUES (8, N'TEST_USER4', N'TempPass123', 0)
INSERT [dbo].[User] ([UserId], [UserName], [PasswordHash], [IsActive]) VALUES (10, N'TESZT', N'teszt', 1)
INSERT [dbo].[User] ([UserId], [UserName], [PasswordHash], [IsActive]) VALUES (11, N'bela', N'bela', 1)
SET IDENTITY_INSERT [dbo].[User] OFF
GO
SET IDENTITY_INSERT [dbo].[WorkSchedule] ON 

INSERT [dbo].[WorkSchedule] ([WorkScheduleId], [Name], [PeriodLengthDays], [IsActive]) VALUES (1, N'HETI_5_NAPOS_8H_MODOSITOTT', 7, 1)
INSERT [dbo].[WorkSchedule] ([WorkScheduleId], [Name], [PeriodLengthDays], [IsActive]) VALUES (2, N'tetszt', 7, 1)
INSERT [dbo].[WorkSchedule] ([WorkScheduleId], [Name], [PeriodLengthDays], [IsActive]) VALUES (3, N'fdfdfsdsdsds', 30, 1)
INSERT [dbo].[WorkSchedule] ([WorkScheduleId], [Name], [PeriodLengthDays], [IsActive]) VALUES (4, N'12H', 14, 1)
INSERT [dbo].[WorkSchedule] ([WorkScheduleId], [Name], [PeriodLengthDays], [IsActive]) VALUES (5, N'8H_TESZT', 7, 1)
INSERT [dbo].[WorkSchedule] ([WorkScheduleId], [Name], [PeriodLengthDays], [IsActive]) VALUES (6, N'3 műszakos', 21, 1)
SET IDENTITY_INSERT [dbo].[WorkSchedule] OFF
GO
INSERT [dbo].[WorkScheduleDay] ([WorkScheduleId], [DayOfPeriod], [DayTypeId]) VALUES (1, 1, 1)
INSERT [dbo].[WorkScheduleDay] ([WorkScheduleId], [DayOfPeriod], [DayTypeId]) VALUES (1, 2, 1)
INSERT [dbo].[WorkScheduleDay] ([WorkScheduleId], [DayOfPeriod], [DayTypeId]) VALUES (1, 3, 1)
INSERT [dbo].[WorkScheduleDay] ([WorkScheduleId], [DayOfPeriod], [DayTypeId]) VALUES (1, 4, 1)
INSERT [dbo].[WorkScheduleDay] ([WorkScheduleId], [DayOfPeriod], [DayTypeId]) VALUES (1, 5, 1)
INSERT [dbo].[WorkScheduleDay] ([WorkScheduleId], [DayOfPeriod], [DayTypeId]) VALUES (1, 6, 2)
INSERT [dbo].[WorkScheduleDay] ([WorkScheduleId], [DayOfPeriod], [DayTypeId]) VALUES (1, 7, 2)
INSERT [dbo].[WorkScheduleDay] ([WorkScheduleId], [DayOfPeriod], [DayTypeId]) VALUES (2, 1, 2)
INSERT [dbo].[WorkScheduleDay] ([WorkScheduleId], [DayOfPeriod], [DayTypeId]) VALUES (2, 2, 2)
INSERT [dbo].[WorkScheduleDay] ([WorkScheduleId], [DayOfPeriod], [DayTypeId]) VALUES (2, 3, 2)
INSERT [dbo].[WorkScheduleDay] ([WorkScheduleId], [DayOfPeriod], [DayTypeId]) VALUES (2, 4, 1)
INSERT [dbo].[WorkScheduleDay] ([WorkScheduleId], [DayOfPeriod], [DayTypeId]) VALUES (2, 5, 1)
INSERT [dbo].[WorkScheduleDay] ([WorkScheduleId], [DayOfPeriod], [DayTypeId]) VALUES (2, 6, 2)
INSERT [dbo].[WorkScheduleDay] ([WorkScheduleId], [DayOfPeriod], [DayTypeId]) VALUES (2, 7, 2)
INSERT [dbo].[WorkScheduleDay] ([WorkScheduleId], [DayOfPeriod], [DayTypeId]) VALUES (3, 1, 2)
INSERT [dbo].[WorkScheduleDay] ([WorkScheduleId], [DayOfPeriod], [DayTypeId]) VALUES (3, 2, 2)
INSERT [dbo].[WorkScheduleDay] ([WorkScheduleId], [DayOfPeriod], [DayTypeId]) VALUES (3, 3, 2)
INSERT [dbo].[WorkScheduleDay] ([WorkScheduleId], [DayOfPeriod], [DayTypeId]) VALUES (3, 4, 2)
INSERT [dbo].[WorkScheduleDay] ([WorkScheduleId], [DayOfPeriod], [DayTypeId]) VALUES (3, 5, 2)
INSERT [dbo].[WorkScheduleDay] ([WorkScheduleId], [DayOfPeriod], [DayTypeId]) VALUES (3, 6, 2)
INSERT [dbo].[WorkScheduleDay] ([WorkScheduleId], [DayOfPeriod], [DayTypeId]) VALUES (3, 7, 2)
INSERT [dbo].[WorkScheduleDay] ([WorkScheduleId], [DayOfPeriod], [DayTypeId]) VALUES (3, 8, 2)
INSERT [dbo].[WorkScheduleDay] ([WorkScheduleId], [DayOfPeriod], [DayTypeId]) VALUES (3, 9, 2)
INSERT [dbo].[WorkScheduleDay] ([WorkScheduleId], [DayOfPeriod], [DayTypeId]) VALUES (3, 10, 2)
INSERT [dbo].[WorkScheduleDay] ([WorkScheduleId], [DayOfPeriod], [DayTypeId]) VALUES (3, 11, 2)
INSERT [dbo].[WorkScheduleDay] ([WorkScheduleId], [DayOfPeriod], [DayTypeId]) VALUES (3, 12, 2)
INSERT [dbo].[WorkScheduleDay] ([WorkScheduleId], [DayOfPeriod], [DayTypeId]) VALUES (3, 13, 2)
INSERT [dbo].[WorkScheduleDay] ([WorkScheduleId], [DayOfPeriod], [DayTypeId]) VALUES (3, 14, 2)
INSERT [dbo].[WorkScheduleDay] ([WorkScheduleId], [DayOfPeriod], [DayTypeId]) VALUES (3, 15, 2)
INSERT [dbo].[WorkScheduleDay] ([WorkScheduleId], [DayOfPeriod], [DayTypeId]) VALUES (3, 16, 2)
INSERT [dbo].[WorkScheduleDay] ([WorkScheduleId], [DayOfPeriod], [DayTypeId]) VALUES (3, 17, 2)
INSERT [dbo].[WorkScheduleDay] ([WorkScheduleId], [DayOfPeriod], [DayTypeId]) VALUES (3, 18, 2)
INSERT [dbo].[WorkScheduleDay] ([WorkScheduleId], [DayOfPeriod], [DayTypeId]) VALUES (3, 19, 2)
INSERT [dbo].[WorkScheduleDay] ([WorkScheduleId], [DayOfPeriod], [DayTypeId]) VALUES (3, 20, 2)
INSERT [dbo].[WorkScheduleDay] ([WorkScheduleId], [DayOfPeriod], [DayTypeId]) VALUES (3, 21, 2)
INSERT [dbo].[WorkScheduleDay] ([WorkScheduleId], [DayOfPeriod], [DayTypeId]) VALUES (3, 22, 2)
INSERT [dbo].[WorkScheduleDay] ([WorkScheduleId], [DayOfPeriod], [DayTypeId]) VALUES (3, 23, 2)
INSERT [dbo].[WorkScheduleDay] ([WorkScheduleId], [DayOfPeriod], [DayTypeId]) VALUES (3, 24, 2)
INSERT [dbo].[WorkScheduleDay] ([WorkScheduleId], [DayOfPeriod], [DayTypeId]) VALUES (3, 25, 2)
INSERT [dbo].[WorkScheduleDay] ([WorkScheduleId], [DayOfPeriod], [DayTypeId]) VALUES (3, 26, 2)
INSERT [dbo].[WorkScheduleDay] ([WorkScheduleId], [DayOfPeriod], [DayTypeId]) VALUES (3, 27, 2)
INSERT [dbo].[WorkScheduleDay] ([WorkScheduleId], [DayOfPeriod], [DayTypeId]) VALUES (3, 28, 2)
INSERT [dbo].[WorkScheduleDay] ([WorkScheduleId], [DayOfPeriod], [DayTypeId]) VALUES (3, 29, 2)
INSERT [dbo].[WorkScheduleDay] ([WorkScheduleId], [DayOfPeriod], [DayTypeId]) VALUES (3, 30, 2)
INSERT [dbo].[WorkScheduleDay] ([WorkScheduleId], [DayOfPeriod], [DayTypeId]) VALUES (4, 1, 5)
INSERT [dbo].[WorkScheduleDay] ([WorkScheduleId], [DayOfPeriod], [DayTypeId]) VALUES (4, 2, 5)
INSERT [dbo].[WorkScheduleDay] ([WorkScheduleId], [DayOfPeriod], [DayTypeId]) VALUES (4, 3, 5)
INSERT [dbo].[WorkScheduleDay] ([WorkScheduleId], [DayOfPeriod], [DayTypeId]) VALUES (4, 4, 5)
INSERT [dbo].[WorkScheduleDay] ([WorkScheduleId], [DayOfPeriod], [DayTypeId]) VALUES (4, 5, 5)
INSERT [dbo].[WorkScheduleDay] ([WorkScheduleId], [DayOfPeriod], [DayTypeId]) VALUES (4, 6, 2)
INSERT [dbo].[WorkScheduleDay] ([WorkScheduleId], [DayOfPeriod], [DayTypeId]) VALUES (4, 7, 2)
INSERT [dbo].[WorkScheduleDay] ([WorkScheduleId], [DayOfPeriod], [DayTypeId]) VALUES (4, 8, 5)
INSERT [dbo].[WorkScheduleDay] ([WorkScheduleId], [DayOfPeriod], [DayTypeId]) VALUES (4, 9, 5)
INSERT [dbo].[WorkScheduleDay] ([WorkScheduleId], [DayOfPeriod], [DayTypeId]) VALUES (4, 10, 5)
INSERT [dbo].[WorkScheduleDay] ([WorkScheduleId], [DayOfPeriod], [DayTypeId]) VALUES (4, 11, 5)
INSERT [dbo].[WorkScheduleDay] ([WorkScheduleId], [DayOfPeriod], [DayTypeId]) VALUES (4, 12, 5)
INSERT [dbo].[WorkScheduleDay] ([WorkScheduleId], [DayOfPeriod], [DayTypeId]) VALUES (4, 13, 2)
INSERT [dbo].[WorkScheduleDay] ([WorkScheduleId], [DayOfPeriod], [DayTypeId]) VALUES (4, 14, 2)
INSERT [dbo].[WorkScheduleDay] ([WorkScheduleId], [DayOfPeriod], [DayTypeId]) VALUES (5, 1, 1)
INSERT [dbo].[WorkScheduleDay] ([WorkScheduleId], [DayOfPeriod], [DayTypeId]) VALUES (5, 2, 1)
INSERT [dbo].[WorkScheduleDay] ([WorkScheduleId], [DayOfPeriod], [DayTypeId]) VALUES (5, 3, 1)
INSERT [dbo].[WorkScheduleDay] ([WorkScheduleId], [DayOfPeriod], [DayTypeId]) VALUES (5, 4, 1)
INSERT [dbo].[WorkScheduleDay] ([WorkScheduleId], [DayOfPeriod], [DayTypeId]) VALUES (5, 5, 1)
INSERT [dbo].[WorkScheduleDay] ([WorkScheduleId], [DayOfPeriod], [DayTypeId]) VALUES (5, 6, 2)
INSERT [dbo].[WorkScheduleDay] ([WorkScheduleId], [DayOfPeriod], [DayTypeId]) VALUES (5, 7, 2)
INSERT [dbo].[WorkScheduleDay] ([WorkScheduleId], [DayOfPeriod], [DayTypeId]) VALUES (6, 1, 6)
INSERT [dbo].[WorkScheduleDay] ([WorkScheduleId], [DayOfPeriod], [DayTypeId]) VALUES (6, 2, 6)
INSERT [dbo].[WorkScheduleDay] ([WorkScheduleId], [DayOfPeriod], [DayTypeId]) VALUES (6, 3, 6)
INSERT [dbo].[WorkScheduleDay] ([WorkScheduleId], [DayOfPeriod], [DayTypeId]) VALUES (6, 4, 6)
INSERT [dbo].[WorkScheduleDay] ([WorkScheduleId], [DayOfPeriod], [DayTypeId]) VALUES (6, 5, 6)
INSERT [dbo].[WorkScheduleDay] ([WorkScheduleId], [DayOfPeriod], [DayTypeId]) VALUES (6, 6, 2)
INSERT [dbo].[WorkScheduleDay] ([WorkScheduleId], [DayOfPeriod], [DayTypeId]) VALUES (6, 7, 2)
INSERT [dbo].[WorkScheduleDay] ([WorkScheduleId], [DayOfPeriod], [DayTypeId]) VALUES (6, 8, 8)
INSERT [dbo].[WorkScheduleDay] ([WorkScheduleId], [DayOfPeriod], [DayTypeId]) VALUES (6, 9, 8)
INSERT [dbo].[WorkScheduleDay] ([WorkScheduleId], [DayOfPeriod], [DayTypeId]) VALUES (6, 10, 8)
INSERT [dbo].[WorkScheduleDay] ([WorkScheduleId], [DayOfPeriod], [DayTypeId]) VALUES (6, 11, 8)
INSERT [dbo].[WorkScheduleDay] ([WorkScheduleId], [DayOfPeriod], [DayTypeId]) VALUES (6, 12, 8)
INSERT [dbo].[WorkScheduleDay] ([WorkScheduleId], [DayOfPeriod], [DayTypeId]) VALUES (6, 13, 2)
INSERT [dbo].[WorkScheduleDay] ([WorkScheduleId], [DayOfPeriod], [DayTypeId]) VALUES (6, 14, 2)
INSERT [dbo].[WorkScheduleDay] ([WorkScheduleId], [DayOfPeriod], [DayTypeId]) VALUES (6, 15, 7)
INSERT [dbo].[WorkScheduleDay] ([WorkScheduleId], [DayOfPeriod], [DayTypeId]) VALUES (6, 16, 7)
INSERT [dbo].[WorkScheduleDay] ([WorkScheduleId], [DayOfPeriod], [DayTypeId]) VALUES (6, 17, 7)
INSERT [dbo].[WorkScheduleDay] ([WorkScheduleId], [DayOfPeriod], [DayTypeId]) VALUES (6, 18, 7)
INSERT [dbo].[WorkScheduleDay] ([WorkScheduleId], [DayOfPeriod], [DayTypeId]) VALUES (6, 19, 7)
INSERT [dbo].[WorkScheduleDay] ([WorkScheduleId], [DayOfPeriod], [DayTypeId]) VALUES (6, 20, 2)
INSERT [dbo].[WorkScheduleDay] ([WorkScheduleId], [DayOfPeriod], [DayTypeId]) VALUES (6, 21, 2)
GO
