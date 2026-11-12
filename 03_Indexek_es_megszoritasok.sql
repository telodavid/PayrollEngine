USE [PY_2]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UQ__AbsenceT__A25C5AA7E528D6F1]    Script Date: 2026. 11. 10. 21:19:40 ******/
ALTER TABLE [dbo].[AbsenceType] ADD UNIQUE NONCLUSTERED 
(
	[Code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UQ__App__A25C5AA7E454D185]    Script Date: 2026. 11. 10. 21:19:40 ******/
ALTER TABLE [dbo].[App] ADD UNIQUE NONCLUSTERED 
(
	[Code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UQ__DayType__A25C5AA706091295]    Script Date: 2026. 11. 10. 21:19:40 ******/
ALTER TABLE [dbo].[DayType] ADD UNIQUE NONCLUSTERED 
(
	[Code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UX_Employee_PersonalId]    Script Date: 2026. 11. 10. 21:19:40 ******/
CREATE UNIQUE NONCLUSTERED INDEX [UX_Employee_PersonalId] ON [dbo].[Employee]
(
	[PersonalId] ASC
)
WHERE ([PersonalId] IS NOT NULL)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UX_Employee_TAJId]    Script Date: 2026. 11. 10. 21:19:40 ******/
CREATE UNIQUE NONCLUSTERED INDEX [UX_Employee_TAJId] ON [dbo].[Employee]
(
	[TAJId] ASC
)
WHERE ([TAJId] IS NOT NULL)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UX_Employee_TaxId]    Script Date: 2026. 11. 10. 21:19:40 ******/
CREATE UNIQUE NONCLUSTERED INDEX [UX_Employee_TaxId] ON [dbo].[Employee]
(
	[TaxId] ASC
)
WHERE ([TaxId] IS NOT NULL)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_EmployeeBankAccount_Employee_Dates]    Script Date: 2026. 11. 10. 21:19:40 ******/
CREATE NONCLUSTERED INDEX [IX_EmployeeBankAccount_Employee_Dates] ON [dbo].[EmployeeBankAccount]
(
	[EmployeeId] ASC,
	[ValidFrom] ASC,
	[ValidTo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UX_EmployeeBankAccount_Employee_Type_ValidFrom]    Script Date: 2026. 11. 10. 21:19:40 ******/
CREATE UNIQUE NONCLUSTERED INDEX [UX_EmployeeBankAccount_Employee_Type_ValidFrom] ON [dbo].[EmployeeBankAccount]
(
	[EmployeeId] ASC,
	[AccountType] ASC,
	[ValidFrom] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [UX_EmployeeFieldValue_OneOpenVersion]    Script Date: 2026. 11. 10. 21:19:40 ******/
CREATE UNIQUE NONCLUSTERED INDEX [UX_EmployeeFieldValue_OneOpenVersion] ON [dbo].[EmployeeFieldValue]
(
	[EmployeeId] ASC,
	[FieldId] ASC
)
WHERE ([ValidTo] IS NULL)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Employment_Employee]    Script Date: 2026. 11. 10. 21:19:40 ******/
CREATE NONCLUSTERED INDEX [IX_Employment_Employee] ON [dbo].[Employment]
(
	[EmployeeId] ASC,
	[ValidFrom] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [UQ__Employme__2EA64772FFE83B9F]    Script Date: 2026. 11. 10. 21:19:40 ******/
ALTER TABLE [dbo].[EmploymentPayrollElement] ADD UNIQUE NONCLUSTERED 
(
	[EmploymentId] ASC,
	[PayrollElementId] ASC,
	[ValidFrom] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_EmploymentPayrollElement_Employment_Dates]    Script Date: 2026. 11. 10. 21:19:40 ******/
CREATE NONCLUSTERED INDEX [IX_EmploymentPayrollElement_Employment_Dates] ON [dbo].[EmploymentPayrollElement]
(
	[EmploymentId] ASC,
	[ValidFrom] ASC,
	[ValidTo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UQ__FieldTyp__A25C5AA7F7A4BE70]    Script Date: 2026. 11. 10. 21:19:40 ******/
ALTER TABLE [dbo].[FieldType] ADD UNIQUE NONCLUSTERED 
(
	[Code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UQ__MasterDa__ECC87BE20B3E6DE6]    Script Date: 2026. 11. 10. 21:19:40 ******/
ALTER TABLE [dbo].[MasterDataField] ADD UNIQUE NONCLUSTERED 
(
	[MasterDataGroupId] ASC,
	[Code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UQ__MasterDa__17A87EDC84C6D352]    Script Date: 2026. 11. 10. 21:19:40 ******/
ALTER TABLE [dbo].[MasterDataFieldOption] ADD UNIQUE NONCLUSTERED 
(
	[FieldId] ASC,
	[OptionCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [UQ__MasterDa__219A8519BA1E9506]    Script Date: 2026. 11. 10. 21:19:40 ******/
ALTER TABLE [dbo].[MasterDataFieldOption] ADD UNIQUE NONCLUSTERED 
(
	[FieldId] ASC,
	[OptionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UQ__MasterDa__A25C5AA7C58B926C]    Script Date: 2026. 11. 10. 21:19:40 ******/
ALTER TABLE [dbo].[MasterDataGroup] ADD UNIQUE NONCLUSTERED 
(
	[Code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UQ__PayrollE__A25C5AA73707CD30]    Script Date: 2026. 11. 10. 21:19:40 ******/
ALTER TABLE [dbo].[PayrollElement] ADD UNIQUE NONCLUSTERED 
(
	[Code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_PayrollResult_Run_Employee_Period]    Script Date: 2026. 11. 10. 21:19:40 ******/
CREATE NONCLUSTERED INDEX [IX_PayrollResult_Run_Employee_Period] ON [dbo].[PayrollResult]
(
	[RunId] ASC,
	[EmployeeId] ASC,
	[Period] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UQ__Role__A25C5AA77864F64D]    Script Date: 2026. 11. 10. 21:19:40 ******/
ALTER TABLE [dbo].[Role] ADD UNIQUE NONCLUSTERED 
(
	[Code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UQ__User__C9F28456C0B46BDD]    Script Date: 2026. 11. 10. 21:19:40 ******/
ALTER TABLE [dbo].[User] ADD UNIQUE NONCLUSTERED 
(
	[UserName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AbsenceType] ADD  DEFAULT ((0)) FOR [IsPaid]
GO
ALTER TABLE [dbo].[AbsenceType] ADD  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[App] ADD  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[DayType] ADD  DEFAULT ((0)) FOR [BreakMinutes]
GO
ALTER TABLE [dbo].[Employee] ADD  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[EmployeeAbsence] ADD  CONSTRAINT [DF_EmployeeAbsence_FullDay]  DEFAULT ((1)) FOR [FullDay]
GO
ALTER TABLE [dbo].[EmployeeBankAccount] ADD  CONSTRAINT [DF_EmployeeBankAccount_AccountType]  DEFAULT (N'BANK_ACCOUNT') FOR [AccountType]
GO
ALTER TABLE [dbo].[MasterDataField] ADD  DEFAULT ((0)) FOR [IsRequired]
GO
ALTER TABLE [dbo].[MasterDataField] ADD  DEFAULT ((0)) FOR [IsUnique]
GO
ALTER TABLE [dbo].[MasterDataField] ADD  DEFAULT ((0)) FOR [DisplayOrder]
GO
ALTER TABLE [dbo].[MasterDataField] ADD  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[MasterDataFieldOption] ADD  DEFAULT ((0)) FOR [SortOrder]
GO
ALTER TABLE [dbo].[MasterDataFieldOption] ADD  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[MDGToRole] ADD  DEFAULT ((0)) FOR [CanRead]
GO
ALTER TABLE [dbo].[MDGToRole] ADD  DEFAULT ((0)) FOR [CanEdit]
GO
ALTER TABLE [dbo].[PayrollElement] ADD  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[PayrollResult] ADD  DEFAULT (sysdatetime()) FOR [RunDate]
GO
ALTER TABLE [dbo].[Role] ADD  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[User] ADD  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[WorkSchedule] ADD  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[AppToRole]  WITH CHECK ADD FOREIGN KEY([AppId])
REFERENCES [dbo].[App] ([AppId])
GO
ALTER TABLE [dbo].[AppToRole]  WITH CHECK ADD FOREIGN KEY([RoleId])
REFERENCES [dbo].[Role] ([RoleId])
GO
ALTER TABLE [dbo].[EmployeeAbsence]  WITH CHECK ADD FOREIGN KEY([AbsenceTypeId])
REFERENCES [dbo].[AbsenceType] ([AbsenceTypeId])
GO
ALTER TABLE [dbo].[EmployeeAbsence]  WITH CHECK ADD FOREIGN KEY([EmploymentId])
REFERENCES [dbo].[Employment] ([EmploymentId])
GO
ALTER TABLE [dbo].[EmployeeBankAccount]  WITH CHECK ADD  CONSTRAINT [FK_EmployeeBankAccount_Employee] FOREIGN KEY([EmployeeId])
REFERENCES [dbo].[Employee] ([EmployeeId])
GO
ALTER TABLE [dbo].[EmployeeBankAccount] CHECK CONSTRAINT [FK_EmployeeBankAccount_Employee]
GO
ALTER TABLE [dbo].[EmployeeDependent]  WITH CHECK ADD FOREIGN KEY([DependentId])
REFERENCES [dbo].[Dependent] ([DependentId])
GO
ALTER TABLE [dbo].[EmployeeDependent]  WITH CHECK ADD FOREIGN KEY([EmployeeId])
REFERENCES [dbo].[Employee] ([EmployeeId])
GO
ALTER TABLE [dbo].[EmployeeDependent]  WITH CHECK ADD FOREIGN KEY([RelationshipTypeId])
REFERENCES [dbo].[RelationshipType] ([RelationshipTypeId])
GO
ALTER TABLE [dbo].[EmployeeFieldValue]  WITH CHECK ADD FOREIGN KEY([EmployeeId])
REFERENCES [dbo].[Employee] ([EmployeeId])
GO
ALTER TABLE [dbo].[EmployeeFieldValue]  WITH CHECK ADD FOREIGN KEY([FieldId])
REFERENCES [dbo].[MasterDataField] ([FieldId])
GO
ALTER TABLE [dbo].[EmployeeFieldValue]  WITH CHECK ADD FOREIGN KEY([FieldId], [OptionId])
REFERENCES [dbo].[MasterDataFieldOption] ([FieldId], [OptionId])
GO
ALTER TABLE [dbo].[Employment]  WITH CHECK ADD FOREIGN KEY([CompanyId])
REFERENCES [dbo].[Company] ([CompanyId])
GO
ALTER TABLE [dbo].[Employment]  WITH CHECK ADD FOREIGN KEY([EmployeeId])
REFERENCES [dbo].[Employee] ([EmployeeId])
GO
ALTER TABLE [dbo].[EmploymentPayrollElement]  WITH CHECK ADD FOREIGN KEY([EmploymentId])
REFERENCES [dbo].[Employment] ([EmploymentId])
GO
ALTER TABLE [dbo].[EmploymentPayrollElement]  WITH CHECK ADD FOREIGN KEY([PayrollElementId])
REFERENCES [dbo].[PayrollElement] ([PayrollElementId])
GO
ALTER TABLE [dbo].[EmploymentWorkSchedule]  WITH CHECK ADD FOREIGN KEY([EmploymentId])
REFERENCES [dbo].[Employment] ([EmploymentId])
GO
ALTER TABLE [dbo].[EmploymentWorkSchedule]  WITH CHECK ADD FOREIGN KEY([WorkScheduleId])
REFERENCES [dbo].[WorkSchedule] ([WorkScheduleId])
GO
ALTER TABLE [dbo].[MasterDataField]  WITH CHECK ADD FOREIGN KEY([FieldTypeId])
REFERENCES [dbo].[FieldType] ([FieldTypeId])
GO
ALTER TABLE [dbo].[MasterDataField]  WITH CHECK ADD FOREIGN KEY([MasterDataGroupId])
REFERENCES [dbo].[MasterDataGroup] ([MasterDataGroupId])
GO
ALTER TABLE [dbo].[MasterDataFieldOption]  WITH CHECK ADD FOREIGN KEY([FieldId])
REFERENCES [dbo].[MasterDataField] ([FieldId])
GO
ALTER TABLE [dbo].[MDGToRole]  WITH CHECK ADD FOREIGN KEY([MasterDataGroupId])
REFERENCES [dbo].[MasterDataGroup] ([MasterDataGroupId])
GO
ALTER TABLE [dbo].[MDGToRole]  WITH CHECK ADD FOREIGN KEY([RoleId])
REFERENCES [dbo].[Role] ([RoleId])
GO
ALTER TABLE [dbo].[PayrollElementFieldValue]  WITH CHECK ADD FOREIGN KEY([FieldId])
REFERENCES [dbo].[MasterDataField] ([FieldId])
GO
ALTER TABLE [dbo].[PayrollElementFieldValue]  WITH CHECK ADD FOREIGN KEY([PayrollElementId])
REFERENCES [dbo].[PayrollElement] ([PayrollElementId])
GO
ALTER TABLE [dbo].[PayrollElementFieldValue]  WITH CHECK ADD FOREIGN KEY([FieldId], [OptionId])
REFERENCES [dbo].[MasterDataFieldOption] ([FieldId], [OptionId])
GO
ALTER TABLE [dbo].[PayrollResult]  WITH CHECK ADD FOREIGN KEY([EmployeeId])
REFERENCES [dbo].[Employee] ([EmployeeId])
GO
ALTER TABLE [dbo].[PayrollResult]  WITH CHECK ADD FOREIGN KEY([PayrollElementId])
REFERENCES [dbo].[PayrollElement] ([PayrollElementId])
GO
ALTER TABLE [dbo].[PayrollResult]  WITH CHECK ADD FOREIGN KEY([RunByUserId])
REFERENCES [dbo].[User] ([UserId])
GO
ALTER TABLE [dbo].[RoleToUser]  WITH CHECK ADD FOREIGN KEY([RoleId])
REFERENCES [dbo].[Role] ([RoleId])
GO
ALTER TABLE [dbo].[RoleToUser]  WITH CHECK ADD FOREIGN KEY([UserId])
REFERENCES [dbo].[User] ([UserId])
GO
ALTER TABLE [dbo].[WorkScheduleDay]  WITH CHECK ADD FOREIGN KEY([DayTypeId])
REFERENCES [dbo].[DayType] ([DayTypeId])
GO
ALTER TABLE [dbo].[WorkScheduleDay]  WITH CHECK ADD FOREIGN KEY([WorkScheduleId])
REFERENCES [dbo].[WorkSchedule] ([WorkScheduleId])
GO
ALTER TABLE [dbo].[Constant]  WITH CHECK ADD CHECK  (([ValidTo] IS NULL OR [ValidTo]>=[ValidFrom]))
GO
ALTER TABLE [dbo].[Constant]  WITH CHECK ADD CHECK  ((len([ConstantId])=(5) AND NOT [ConstantId] like '%[^A-Z0-9]%'))
GO
ALTER TABLE [dbo].[DayType]  WITH CHECK ADD CHECK  (([BreakMinutes]>=(0)))
GO
ALTER TABLE [dbo].[EmployeeAbsence]  WITH CHECK ADD CHECK  (([EndDate]>=[StartDate]))
GO
ALTER TABLE [dbo].[EmployeeAbsence]  WITH CHECK ADD  CONSTRAINT [CK_EmployeeAbsence_FullDay_TimeRange] CHECK  (([FullDay]=(1) AND [StartTime] IS NULL AND [EndTime] IS NULL OR [FullDay]=(0) AND [StartTime] IS NOT NULL AND [EndTime] IS NOT NULL AND ([EndDate]>[StartDate] OR [EndDate]=[StartDate] AND [EndTime]>[StartTime])))
GO
ALTER TABLE [dbo].[EmployeeAbsence] CHECK CONSTRAINT [CK_EmployeeAbsence_FullDay_TimeRange]
GO
ALTER TABLE [dbo].[EmployeeBankAccount]  WITH CHECK ADD  CONSTRAINT [CK_EmployeeBankAccount_AccountType] CHECK  (([AccountType]=N'SZEP_CARD' OR [AccountType]=N'BANK_ACCOUNT'))
GO
ALTER TABLE [dbo].[EmployeeBankAccount] CHECK CONSTRAINT [CK_EmployeeBankAccount_AccountType]
GO
ALTER TABLE [dbo].[EmployeeBankAccount]  WITH CHECK ADD  CONSTRAINT [CK_EmployeeBankAccount_ValidDates] CHECK  (([ValidTo] IS NULL OR [ValidTo]>=[ValidFrom]))
GO
ALTER TABLE [dbo].[EmployeeBankAccount] CHECK CONSTRAINT [CK_EmployeeBankAccount_ValidDates]
GO
ALTER TABLE [dbo].[EmployeeDependent]  WITH CHECK ADD CHECK  (([ValidTo] IS NULL OR [ValidFrom] IS NULL OR [ValidTo]>=[ValidFrom]))
GO
ALTER TABLE [dbo].[EmployeeFieldValue]  WITH CHECK ADD CHECK  (([OptionId] IS NOT NULL AND [FieldValue] IS NULL OR [OptionId] IS NULL AND [FieldValue] IS NOT NULL))
GO
ALTER TABLE [dbo].[EmployeeFieldValue]  WITH CHECK ADD  CONSTRAINT [CK_EmployeeFieldValue_ValidRange] CHECK  (([ValidTo] IS NULL OR [ValidTo]>=[ValidFrom]))
GO
ALTER TABLE [dbo].[EmployeeFieldValue] CHECK CONSTRAINT [CK_EmployeeFieldValue_ValidRange]
GO
ALTER TABLE [dbo].[Employment]  WITH CHECK ADD CHECK  (([ValidTo] IS NULL OR [ValidTo]>=[ValidFrom]))
GO
ALTER TABLE [dbo].[EmploymentPayrollElement]  WITH CHECK ADD CHECK  (([ValidTo] IS NULL OR [ValidTo]>=[ValidFrom]))
GO
ALTER TABLE [dbo].[EmploymentWorkSchedule]  WITH CHECK ADD CHECK  (([ValidTo] IS NULL OR [ValidTo]>=[ValidFrom]))
GO
ALTER TABLE [dbo].[MDGToRole]  WITH CHECK ADD CHECK  (([CanEdit]=(0) OR [CanRead]=(1)))
GO
ALTER TABLE [dbo].[PayrollElementFieldValue]  WITH CHECK ADD CHECK  (([OptionId] IS NOT NULL AND [FieldValue] IS NULL OR [OptionId] IS NULL AND [FieldValue] IS NOT NULL))
GO
ALTER TABLE [dbo].[PayrollElementFieldValue]  WITH CHECK ADD  CONSTRAINT [CK_PayrollElementFieldValue_ValidPeriod] CHECK  (([ValidTo] IS NULL OR [ValidTo]>=[ValidFrom]))
GO
ALTER TABLE [dbo].[PayrollElementFieldValue] CHECK CONSTRAINT [CK_PayrollElementFieldValue_ValidPeriod]
GO
ALTER TABLE [dbo].[PayrollResult]  WITH CHECK ADD CHECK  (([Period] like '[0-9][0-9][0-9][0-9][0-9][0-9]' AND (substring([Period],(5),(2))>='01' AND substring([Period],(5),(2))<='12')))
GO
ALTER TABLE [dbo].[PayrollResult]  WITH CHECK ADD CHECK  (([ResultType]='P' OR [ResultType]='A' OR [ResultType]='O'))
GO
ALTER TABLE [dbo].[RoleToUser]  WITH CHECK ADD CHECK  (([ValidTo] IS NULL OR [ValidTo]>=[ValidFrom]))
GO
ALTER TABLE [dbo].[WorkSchedule]  WITH CHECK ADD CHECK  (([PeriodLengthDays]>(0)))
GO
ALTER TABLE [dbo].[WorkScheduleDay]  WITH CHECK ADD CHECK  (([DayOfPeriod]>(0)))
GO
