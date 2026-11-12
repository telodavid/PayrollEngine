USE [PY_2]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Object:  UserDefinedTableType [dbo].[WorkScheduleDayInputType]    Script Date: 2026. 11. 10. 21:19:39 ******/
CREATE TYPE [dbo].[WorkScheduleDayInputType] AS TABLE(
	[DayOfPeriod] [int] NOT NULL,
	[DayTypeId] [int] NOT NULL,
	PRIMARY KEY CLUSTERED 
(
	[DayOfPeriod] ASC
)WITH (IGNORE_DUP_KEY = OFF)
)
GO
/****** Object:  Table [dbo].[AbsenceType]    Script Date: 2026. 11. 10. 21:19:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AbsenceType](
	[AbsenceTypeId] [int] IDENTITY(1,1) NOT NULL,
	[Code] [nvarchar](30) NOT NULL,
	[Name] [nvarchar](100) NOT NULL,
	[IsPaid] [bit] NOT NULL,
	[IsActive] [bit] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[AbsenceTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[App]    Script Date: 2026. 11. 10. 21:19:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[App](
	[AppId] [int] IDENTITY(1,1) NOT NULL,
	[Code] [nvarchar](50) NOT NULL,
	[AppName] [nvarchar](100) NOT NULL,
	[IsActive] [bit] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[AppId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[AppToRole]    Script Date: 2026. 11. 10. 21:19:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AppToRole](
	[RoleId] [int] NOT NULL,
	[AppId] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[RoleId] ASC,
	[AppId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Company]    Script Date: 2026. 11. 10. 21:19:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Company](
	[CompanyId] [int] IDENTITY(1,1) NOT NULL,
	[CompanyName] [nvarchar](200) NOT NULL,
	[CompanyAddress] [nvarchar](500) NULL,
	[BankAccountNumber] [nvarchar](50) NULL,
	[TaxId] [nvarchar](30) NULL,
	[PhoneNumber] [nvarchar](30) NULL,
PRIMARY KEY CLUSTERED 
(
	[CompanyId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Constant]    Script Date: 2026. 11. 10. 21:19:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Constant](
	[ConstantId] [varchar](5) NOT NULL,
	[ConstantName] [nvarchar](50) NOT NULL,
	[Value] [decimal](18, 6) NOT NULL,
	[ValidFrom] [date] NOT NULL,
	[ValidTo] [date] NULL,
PRIMARY KEY CLUSTERED 
(
	[ConstantId] ASC,
	[ValidFrom] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DayType]    Script Date: 2026. 11. 10. 21:19:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DayType](
	[DayTypeId] [int] IDENTITY(1,1) NOT NULL,
	[Code] [nvarchar](30) NOT NULL,
	[Name] [nvarchar](100) NOT NULL,
	[IsWorkday] [bit] NOT NULL,
	[StartTime] [time](0) NULL,
	[EndTime] [time](0) NULL,
	[BreakMinutes] [smallint] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[DayTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Dependent]    Script Date: 2026. 11. 10. 21:19:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Dependent](
	[DependentId] [int] IDENTITY(1,1) NOT NULL,
	[FirstName] [nvarchar](100) NOT NULL,
	[LastName] [nvarchar](100) NOT NULL,
	[BirthDate] [date] NULL,
	[TaxId] [nvarchar](30) NULL,
PRIMARY KEY CLUSTERED 
(
	[DependentId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Employee]    Script Date: 2026. 11. 10. 21:19:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Employee](
	[EmployeeId] [int] IDENTITY(1,1) NOT NULL,
	[FirstName] [nvarchar](100) NOT NULL,
	[LastName] [nvarchar](100) NOT NULL,
	[BirthDate] [date] NULL,
	[IsActive] [bit] NOT NULL,
	[PersonalId] [nvarchar](30) NULL,
	[TaxId] [nvarchar](30) NULL,
	[TAJId] [nvarchar](30) NULL,
	[Address] [nvarchar](500) NULL,
	[PayrollRunFrom] [date] NULL,
	[JoinDate] [date] NULL,
	[TerminationDate] [date] NULL,
PRIMARY KEY CLUSTERED 
(
	[EmployeeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[EmployeeAbsence]    Script Date: 2026. 11. 10. 21:19:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EmployeeAbsence](
	[AbsenceId] [int] IDENTITY(1,1) NOT NULL,
	[EmploymentId] [int] NOT NULL,
	[AbsenceTypeId] [int] NOT NULL,
	[StartDate] [date] NOT NULL,
	[EndDate] [date] NOT NULL,
	[StartTime] [time](7) NULL,
	[EndTime] [time](7) NULL,
	[FullDay] [bit] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[AbsenceId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[EmployeeBankAccount]    Script Date: 2026. 11. 10. 21:19:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EmployeeBankAccount](
	[EmployeeBankAccountId] [int] IDENTITY(1,1) NOT NULL,
	[EmployeeId] [int] NOT NULL,
	[AccountIdentifier] [nvarchar](50) NOT NULL,
	[ValidFrom] [date] NOT NULL,
	[ValidTo] [date] NULL,
	[AccountType] [nvarchar](20) NOT NULL,
 CONSTRAINT [PK_EmployeeBankAccount] PRIMARY KEY CLUSTERED 
(
	[EmployeeBankAccountId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[EmployeeDependent]    Script Date: 2026. 11. 10. 21:19:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EmployeeDependent](
	[EmployeeDependentId] [int] IDENTITY(1,1) NOT NULL,
	[EmployeeId] [int] NOT NULL,
	[DependentId] [int] NOT NULL,
	[RelationshipTypeId] [int] NOT NULL,
	[ValidFrom] [date] NULL,
	[ValidTo] [date] NULL,
PRIMARY KEY CLUSTERED 
(
	[EmployeeDependentId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[EmployeeFieldValue]    Script Date: 2026. 11. 10. 21:19:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EmployeeFieldValue](
	[EmployeeId] [int] NOT NULL,
	[FieldId] [int] NOT NULL,
	[FieldValue] [nvarchar](4000) NULL,
	[OptionId] [int] NULL,
	[ValidFrom] [date] NOT NULL,
	[ValidTo] [date] NULL,
 CONSTRAINT [PK_EmployeeFieldValue] PRIMARY KEY CLUSTERED 
(
	[EmployeeId] ASC,
	[FieldId] ASC,
	[ValidFrom] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Employment]    Script Date: 2026. 11. 10. 21:19:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Employment](
	[EmploymentId] [int] IDENTITY(1,1) NOT NULL,
	[CompanyId] [int] NOT NULL,
	[EmployeeId] [int] NOT NULL,
	[ValidFrom] [date] NOT NULL,
	[ValidTo] [date] NULL,
PRIMARY KEY CLUSTERED 
(
	[EmploymentId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[EmploymentPayrollElement]    Script Date: 2026. 11. 10. 21:19:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EmploymentPayrollElement](
	[EmploymentPayrollElementId] [int] IDENTITY(1,1) NOT NULL,
	[EmploymentId] [int] NOT NULL,
	[PayrollElementId] [int] NOT NULL,
	[ValidFrom] [date] NOT NULL,
	[ValidTo] [date] NULL,
	[Amount] [decimal](18, 2) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[EmploymentPayrollElementId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[EmploymentWorkSchedule]    Script Date: 2026. 11. 10. 21:19:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EmploymentWorkSchedule](
	[EmploymentWorkScheduleId] [int] IDENTITY(1,1) NOT NULL,
	[EmploymentId] [int] NOT NULL,
	[WorkScheduleId] [int] NOT NULL,
	[ValidFrom] [date] NOT NULL,
	[ValidTo] [date] NULL,
	[CycleStartDate] [date] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[EmploymentWorkScheduleId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[FieldType]    Script Date: 2026. 11. 10. 21:19:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FieldType](
	[FieldTypeId] [int] IDENTITY(1,1) NOT NULL,
	[Code] [nvarchar](30) NOT NULL,
	[Name] [nvarchar](100) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[FieldTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[MasterDataField]    Script Date: 2026. 11. 10. 21:19:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MasterDataField](
	[FieldId] [int] IDENTITY(1,1) NOT NULL,
	[MasterDataGroupId] [int] NOT NULL,
	[Code] [nvarchar](50) NOT NULL,
	[DisplayName] [nvarchar](100) NOT NULL,
	[FieldTypeId] [int] NOT NULL,
	[IsRequired] [bit] NOT NULL,
	[IsUnique] [bit] NOT NULL,
	[DisplayOrder] [int] NOT NULL,
	[IsActive] [bit] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[FieldId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[MasterDataFieldOption]    Script Date: 2026. 11. 10. 21:19:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MasterDataFieldOption](
	[OptionId] [int] IDENTITY(1,1) NOT NULL,
	[FieldId] [int] NOT NULL,
	[OptionCode] [nvarchar](50) NOT NULL,
	[DisplayName] [nvarchar](100) NOT NULL,
	[SortOrder] [int] NOT NULL,
	[IsActive] [bit] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[OptionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[MasterDataGroup]    Script Date: 2026. 11. 10. 21:19:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MasterDataGroup](
	[MasterDataGroupId] [int] IDENTITY(1,1) NOT NULL,
	[Code] [nvarchar](50) NOT NULL,
	[Name] [nvarchar](100) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[MasterDataGroupId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[MDGToRole]    Script Date: 2026. 11. 10. 21:19:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MDGToRole](
	[RoleId] [int] NOT NULL,
	[MasterDataGroupId] [int] NOT NULL,
	[CanRead] [bit] NOT NULL,
	[CanEdit] [bit] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[RoleId] ASC,
	[MasterDataGroupId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PayrollElement]    Script Date: 2026. 11. 10. 21:19:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PayrollElement](
	[PayrollElementId] [int] IDENTITY(1,1) NOT NULL,
	[Code] [nvarchar](50) NOT NULL,
	[Name] [nvarchar](100) NOT NULL,
	[IsActive] [bit] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[PayrollElementId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PayrollElementFieldValue]    Script Date: 2026. 11. 10. 21:19:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PayrollElementFieldValue](
	[PayrollElementId] [int] NOT NULL,
	[FieldId] [int] NOT NULL,
	[FieldValue] [nvarchar](4000) NULL,
	[OptionId] [int] NULL,
	[ValidFrom] [date] NOT NULL,
	[ValidTo] [date] NULL,
 CONSTRAINT [PK_PayrollElementFieldValue] PRIMARY KEY CLUSTERED 
(
	[PayrollElementId] ASC,
	[FieldId] ASC,
	[ValidFrom] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PayrollResult]    Script Date: 2026. 11. 10. 21:19:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PayrollResult](
	[PayrollResultId] [int] IDENTITY(1,1) NOT NULL,
	[RunId] [uniqueidentifier] NOT NULL,
	[EmployeeId] [int] NOT NULL,
	[Period] [char](6) NOT NULL,
	[ResultType] [char](1) NOT NULL,
	[PayrollElementId] [int] NOT NULL,
	[Amount] [decimal](18, 2) NOT NULL,
	[RunDate] [datetime2](0) NOT NULL,
	[RunByUserId] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[PayrollResultId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[RelationshipType]    Script Date: 2026. 11. 10. 21:19:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RelationshipType](
	[RelationshipTypeId] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](100) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[RelationshipTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Role]    Script Date: 2026. 11. 10. 21:19:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Role](
	[RoleId] [int] IDENTITY(1,1) NOT NULL,
	[Code] [nvarchar](50) NOT NULL,
	[RoleName] [nvarchar](100) NOT NULL,
	[IsActive] [bit] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[RoleId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[RoleToUser]    Script Date: 2026. 11. 10. 21:19:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RoleToUser](
	[UserId] [int] NOT NULL,
	[RoleId] [int] NOT NULL,
	[ValidFrom] [date] NOT NULL,
	[ValidTo] [date] NULL,
PRIMARY KEY CLUSTERED 
(
	[UserId] ASC,
	[RoleId] ASC,
	[ValidFrom] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[User]    Script Date: 2026. 11. 10. 21:19:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[User](
	[UserId] [int] IDENTITY(1,1) NOT NULL,
	[UserName] [nvarchar](100) NOT NULL,
	[PasswordHash] [nvarchar](255) NOT NULL,
	[IsActive] [bit] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[UserId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[WorkSchedule]    Script Date: 2026. 11. 10. 21:19:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[WorkSchedule](
	[WorkScheduleId] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](100) NOT NULL,
	[PeriodLengthDays] [int] NOT NULL,
	[IsActive] [bit] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[WorkScheduleId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[WorkScheduleDay]    Script Date: 2026. 11. 10. 21:19:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[WorkScheduleDay](
	[WorkScheduleId] [int] NOT NULL,
	[DayOfPeriod] [int] NOT NULL,
	[DayTypeId] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[WorkScheduleId] ASC,
	[DayOfPeriod] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
