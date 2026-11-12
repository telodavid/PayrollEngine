USE [PY_2]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Object:  StoredProcedure [dbo].[usp_AbsenceType_Create]    Script Date: 2026. 11. 10. 21:19:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[usp_AbsenceType_Create]
    @Code NVARCHAR(30),
    @Name NVARCHAR(100),
    @IsPaid BIT
AS
BEGIN
    SET NOCOUNT ON;

    IF NULLIF(LTRIM(RTRIM(@Code)), N'') IS NULL
        THROW 50080, N'A távolléttípus kódja nem lehet üres.', 1;

    IF LEN(@Code) > 30
        THROW 50081, N'A távolléttípus kódja legfeljebb 30 karakter lehet.', 1;

    IF NULLIF(LTRIM(RTRIM(@Name)), N'') IS NULL
        THROW 50082, N'A távolléttípus neve nem lehet üres.', 1;

    IF LEN(@Name) > 100
        THROW 50083, N'A távolléttípus neve legfeljebb 100 karakter lehet.', 1;

    INSERT INTO dbo.AbsenceType (Code, Name, IsPaid, IsActive)
    OUTPUT INSERTED.AbsenceTypeId
    VALUES (LTRIM(RTRIM(@Code)), LTRIM(RTRIM(@Name)), @IsPaid, 1);
END;
GO
/****** Object:  StoredProcedure [dbo].[usp_AbsenceType_GetById]    Script Date: 2026. 11. 10. 21:19:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[usp_AbsenceType_GetById]
    @AbsenceTypeId INT
AS
BEGIN
    SET NOCOUNT ON;

    IF @AbsenceTypeId <= 0
        THROW 50084, N'Érvénytelen távolléttípus-azonosító.', 1;

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.AbsenceType
        WHERE AbsenceTypeId = @AbsenceTypeId
    )
        THROW 50085, N'A távolléttípus nem található.', 1;

    SELECT
        AbsenceTypeId,
        Code,
        Name,
        IsPaid,
        IsActive
    FROM dbo.AbsenceType
    WHERE AbsenceTypeId = @AbsenceTypeId;
END;
GO
/****** Object:  StoredProcedure [dbo].[usp_AbsenceType_Search]    Script Date: 2026. 11. 10. 21:19:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[usp_AbsenceType_Search]
    @Search NVARCHAR(100) = NULL,
    @IsPaid BIT = NULL,
    @IsActive BIT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        AbsenceTypeId,
        Code,
        Name,
        IsPaid,
        IsActive
    FROM dbo.AbsenceType
    WHERE
        (
            NULLIF(LTRIM(RTRIM(@Search)), N'') IS NULL
            OR Code LIKE N'%' + LTRIM(RTRIM(@Search)) + N'%'
            OR Name LIKE N'%' + LTRIM(RTRIM(@Search)) + N'%'
        )
        AND (@IsPaid IS NULL OR IsPaid = @IsPaid)
        AND (@IsActive IS NULL OR IsActive = @IsActive)
    ORDER BY Name, Code;
END;
GO
/****** Object:  StoredProcedure [dbo].[usp_AbsenceType_Update]    Script Date: 2026. 11. 10. 21:19:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[usp_AbsenceType_Update]
    @AbsenceTypeId INT,
    @Code NVARCHAR(30),
    @Name NVARCHAR(100),
    @IsPaid BIT,
    @IsActive BIT
AS
BEGIN
    SET NOCOUNT ON;

    IF @AbsenceTypeId <= 0
        THROW 50084, N'Érvénytelen távolléttípus-azonosító.', 1;

    IF NULLIF(LTRIM(RTRIM(@Code)), N'') IS NULL
        THROW 50080, N'A távolléttípus kódja nem lehet üres.', 1;

    IF LEN(@Code) > 30
        THROW 50081, N'A távolléttípus kódja legfeljebb 30 karakter lehet.', 1;

    IF NULLIF(LTRIM(RTRIM(@Name)), N'') IS NULL
        THROW 50082, N'A távolléttípus neve nem lehet üres.', 1;

    IF LEN(@Name) > 100
        THROW 50083, N'A távolléttípus neve legfeljebb 100 karakter lehet.', 1;

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.AbsenceType
        WHERE AbsenceTypeId = @AbsenceTypeId
    )
        THROW 50085, N'A távolléttípus nem található.', 1;

    UPDATE dbo.AbsenceType
    SET
        Code = LTRIM(RTRIM(@Code)),
        Name = LTRIM(RTRIM(@Name)),
        IsPaid = @IsPaid,
        IsActive = @IsActive
    WHERE AbsenceTypeId = @AbsenceTypeId;
END;
GO
/****** Object:  StoredProcedure [dbo].[usp_App_Create]    Script Date: 2026. 11. 10. 21:19:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[usp_App_Create]
    @Code NVARCHAR(50),
    @AppName NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.App
    (
        Code,
        AppName,
        IsActive
    )
    VALUES
    (
        @Code,
        @AppName,
        1
    );

    SELECT CONVERT(INT, SCOPE_IDENTITY()) AS AppId;
END;
GO
/****** Object:  StoredProcedure [dbo].[usp_App_Search]    Script Date: 2026. 11. 10. 21:19:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[usp_App_Search]
    @Search NVARCHAR(100) = NULL,
    @IsActive BIT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SET @Search = NULLIF(LTRIM(RTRIM(@Search)), N'');

    SELECT
        AppId,
        Code,
        AppName,
        IsActive
    FROM dbo.App
    WHERE
        (
            @Search IS NULL
            OR Code LIKE N'%' + @Search + N'%'
            OR AppName LIKE N'%' + @Search + N'%'
        )
        AND (@IsActive IS NULL OR IsActive = @IsActive)
    ORDER BY AppName, AppId;
END;
GO
/****** Object:  StoredProcedure [dbo].[usp_App_Update]    Script Date: 2026. 11. 10. 21:19:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[usp_App_Update]
    @AppId INT,
    @Code NVARCHAR(50),
    @AppName NVARCHAR(100),
    @IsActive BIT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.[App]
        WHERE AppId = @AppId
    )
    BEGIN
        THROW 50002, 'Application not found.', 1;
    END;

    IF EXISTS
    (
        SELECT 1
        FROM dbo.[App]
        WHERE AppId = @AppId
          AND Code IN
          (
              N'USER_MAINTENANCE',
              N'MASTERDATA_MAINTENANCE',
              N'WORKSCHEDULE_CONFIG',
              N'ABSENCE_TYPE_MAINTENANCE',
              N'MASTERDATA_TYPE_MAINTENANCE',
              N'PAYROLL_ELEMENT_MAINTENANCE',
              N'CALCULATION_RULE_MAINTENANCE',
              N'PAYROLL_SCHEMA_MAINTENANCE',
              N'PAYROLL_RUN',
              N'REPORT_BUILDER'
          )
    )
    BEGIN
        THROW 50011, 'Core applications cannot be modified.', 1;
    END;

    UPDATE dbo.[App]
    SET Code = @Code,
        AppName = @AppName,
        IsActive = @IsActive
    WHERE AppId = @AppId;
END;
GO
/****** Object:  StoredProcedure [dbo].[usp_AppToRole_Assign]    Script Date: 2026. 11. 10. 21:19:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[usp_AppToRole_Assign]
    @RoleId INT,
    @AppId INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.[Role]
        WHERE RoleId = @RoleId
          AND IsActive = 1
    )
    BEGIN
        THROW 50020, 'Az aktív szerep nem található.', 1;
    END;

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.App
        WHERE AppId = @AppId
          AND IsActive = 1
    )
    BEGIN
        THROW 50021, 'Az aktív alkalmazás nem található.', 1;
    END;

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.AppToRole
        WHERE RoleId = @RoleId
          AND AppId = @AppId
    )
    BEGIN
        INSERT INTO dbo.AppToRole (RoleId, AppId)
        VALUES (@RoleId, @AppId);
    END;
END;
GO
/****** Object:  StoredProcedure [dbo].[usp_AppToRole_GetByRoleId]    Script Date: 2026. 11. 10. 21:19:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[usp_AppToRole_GetByRoleId]
    @RoleId INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.[Role]
        WHERE RoleId = @RoleId
    )
    BEGIN
        THROW 50024, 'A szerep nem található.', 1;
    END;

    SELECT
        r.RoleId,
        a.AppId,
        a.Code,
        a.AppName,
        a.IsActive
    FROM dbo.AppToRole AS r
    INNER JOIN dbo.App AS a
        ON a.AppId = r.AppId
    WHERE r.RoleId = @RoleId
    ORDER BY a.AppName, a.AppId;
END;
GO
/****** Object:  StoredProcedure [dbo].[usp_AppToRole_Remove]    Script Date: 2026. 11. 10. 21:19:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[usp_AppToRole_Remove]
    @RoleId INT,
    @AppId INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.[Role]
        WHERE RoleId = @RoleId
    )
    BEGIN
        THROW 50025, 'A szerep nem található.', 1;
    END;

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.App
        WHERE AppId = @AppId
    )
    BEGIN
        THROW 50026, 'Az alkalmazás nem található.', 1;
    END;

    DELETE FROM dbo.AppToRole
    WHERE RoleId = @RoleId
      AND AppId = @AppId;

    IF @@ROWCOUNT = 0
    BEGIN
        THROW 50027, 'Ez az alkalmazás nincs ehhez a szerephez rendelve.', 1;
    END;
END;
GO
/****** Object:  StoredProcedure [dbo].[usp_Company_Create]    Script Date: 2026. 11. 10. 21:19:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[usp_Company_Create]
    @CompanyName NVARCHAR(200),
    @CompanyAddress NVARCHAR(500) = NULL,
    @BankAccountNumber NVARCHAR(50) = NULL,
    @TaxId NVARCHAR(30) = NULL,
    @PhoneNumber NVARCHAR(30) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF NULLIF(LTRIM(RTRIM(@CompanyName)), N'') IS NULL
    BEGIN
        THROW 50301, N'A cégnév nem lehet üres.', 1;
    END;

    INSERT INTO dbo.Company
    (
        CompanyName,
        CompanyAddress,
        BankAccountNumber,
        TaxId,
        PhoneNumber
    )
    VALUES
    (
        LTRIM(RTRIM(@CompanyName)),
        @CompanyAddress,
        @BankAccountNumber,
        @TaxId,
        @PhoneNumber
    );

    SELECT CONVERT(INT, SCOPE_IDENTITY()) AS CompanyId;
END;
GO
/****** Object:  StoredProcedure [dbo].[usp_Company_GetById]    Script Date: 2026. 11. 10. 21:19:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[usp_Company_GetById]
    @CompanyId INT
AS
BEGIN
    SET NOCOUNT ON;

    IF @CompanyId <= 0
    BEGIN
        THROW 50302, N'Érvénytelen cégazonosító.', 1;
    END;

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.Company
        WHERE CompanyId = @CompanyId
    )
    BEGIN
        THROW 50303, N'A cég nem található.', 1;
    END;

    SELECT
        CompanyId,
        CompanyName,
        CompanyAddress,
        BankAccountNumber,
        TaxId,
        PhoneNumber
    FROM dbo.Company
    WHERE CompanyId = @CompanyId;
END;
GO
/****** Object:  StoredProcedure [dbo].[usp_Company_Search]    Script Date: 2026. 11. 10. 21:19:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[usp_Company_Search]
    @Search NVARCHAR(200) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SET @Search = NULLIF(LTRIM(RTRIM(@Search)), N'');

    SELECT
        CompanyId,
        CompanyName,
        CompanyAddress,
        BankAccountNumber,
        TaxId,
        PhoneNumber
    FROM dbo.Company
    WHERE @Search IS NULL
       OR CompanyName LIKE N'%' + @Search + N'%'
       OR CompanyAddress LIKE N'%' + @Search + N'%'
       OR TaxId LIKE N'%' + @Search + N'%'
    ORDER BY CompanyName, CompanyId;
END;
GO
/****** Object:  StoredProcedure [dbo].[usp_Company_Update]    Script Date: 2026. 11. 10. 21:19:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[usp_Company_Update]
    @CompanyId INT,
    @CompanyName NVARCHAR(200),
    @CompanyAddress NVARCHAR(500) = NULL,
    @BankAccountNumber NVARCHAR(50) = NULL,
    @TaxId NVARCHAR(30) = NULL,
    @PhoneNumber NVARCHAR(30) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @CompanyId <= 0
    BEGIN
        THROW 50302, N'Érvénytelen cégazonosító.', 1;
    END;

    IF NULLIF(LTRIM(RTRIM(@CompanyName)), N'') IS NULL
    BEGIN
        THROW 50301, N'A cégnév nem lehet üres.', 1;
    END;

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.Company
        WHERE CompanyId = @CompanyId
    )
    BEGIN
        THROW 50303, N'A cég nem található.', 1;
    END;

    UPDATE dbo.Company
    SET
        CompanyName = LTRIM(RTRIM(@CompanyName)),
        CompanyAddress = @CompanyAddress,
        BankAccountNumber = @BankAccountNumber,
        TaxId = @TaxId,
        PhoneNumber = @PhoneNumber
    WHERE CompanyId = @CompanyId;
END;
GO
/****** Object:  StoredProcedure [dbo].[usp_Constant_Create]    Script Date: 2026. 11. 10. 21:19:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[usp_Constant_Create]
    @ConstantId VARCHAR(5),
    @ConstantName NVARCHAR(50),
    @Value DECIMAL(18, 6),
    @ValidFrom DATE,
    @ValidTo DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SET @ConstantId = LTRIM(RTRIM(@ConstantId));
    SET @ConstantName = LTRIM(RTRIM(@ConstantName));

    IF @ConstantId IS NULL OR LEN(@ConstantId) = 0
        THROW 50801, 'A konstans azonosítójának megadása kötelező.', 1;

    IF @ConstantName IS NULL OR LEN(@ConstantName) = 0
        THROW 50801, 'A konstans nevének megadása kötelező.', 1;

    IF @ValidFrom IS NULL
        THROW 50801, 'Az érvényesség kezdetének megadása kötelező.', 1;

    IF @ValidTo IS NOT NULL AND @ValidTo < @ValidFrom
        THROW 50804, 'Az érvényesség vége nem lehet korábbi a kezdeténél.', 1;

    INSERT INTO dbo.Constant
        (ConstantId, ConstantName, Value, ValidFrom, ValidTo)
    VALUES
        (@ConstantId, @ConstantName, @Value, @ValidFrom, @ValidTo);

    SELECT
        ConstantId,
        ConstantName,
        Value,
        ValidFrom,
        ValidTo
    FROM dbo.Constant
    WHERE ConstantId = @ConstantId
      AND ValidFrom = @ValidFrom;
END;
GO
/****** Object:  StoredProcedure [dbo].[usp_Constant_Delete]    Script Date: 2026. 11. 10. 21:19:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[usp_Constant_Delete]
    @ConstantId VARCHAR(5),
    @ValidFrom DATE
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM dbo.Constant
    WHERE ConstantId = @ConstantId
      AND ValidFrom = @ValidFrom;

    IF @@ROWCOUNT = 0
        THROW 50802, 'A megadott konstans nem található.', 1;
END;
GO
/****** Object:  StoredProcedure [dbo].[usp_Constant_GetAll]    Script Date: 2026. 11. 10. 21:19:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[usp_Constant_GetAll]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        ConstantId,
        ConstantName,
        Value,
        ValidFrom,
        ValidTo
    FROM dbo.Constant
    ORDER BY ConstantId, ValidFrom;
END;
GO
/****** Object:  StoredProcedure [dbo].[usp_Constant_Update]    Script Date: 2026. 11. 10. 21:19:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[usp_Constant_Update]
    @ConstantId VARCHAR(5),
    @ValidFrom DATE,
    @ConstantName NVARCHAR(50),
    @Value DECIMAL(18, 6),
    @ValidTo DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SET @ConstantId = LTRIM(RTRIM(@ConstantId));
    SET @ConstantName = LTRIM(RTRIM(@ConstantName));

    IF @ConstantId IS NULL OR LEN(@ConstantId) = 0
        THROW 50801, 'A konstans azonosítójának megadása kötelező.', 1;

    IF @ConstantName IS NULL OR LEN(@ConstantName) = 0
        THROW 50801, 'A konstans nevének megadása kötelező.', 1;

    IF @ValidFrom IS NULL
        THROW 50801, 'Az érvényesség kezdetének megadása kötelező.', 1;

    IF @ValidTo IS NOT NULL AND @ValidTo < @ValidFrom
        THROW 50804, 'Az érvényesség vége nem lehet korábbi a kezdeténél.', 1;

    UPDATE dbo.Constant
    SET ConstantName = @ConstantName,
        Value = @Value,
        ValidTo = @ValidTo
    WHERE ConstantId = @ConstantId
      AND ValidFrom = @ValidFrom;

    IF @@ROWCOUNT = 0
        THROW 50802, 'A megadott konstans nem található.', 1;

    SELECT
        ConstantId,
        ConstantName,
        Value,
        ValidFrom,
        ValidTo
    FROM dbo.Constant
    WHERE ConstantId = @ConstantId
      AND ValidFrom = @ValidFrom;
END;
GO
/****** Object:  StoredProcedure [dbo].[usp_DayType_Create]    Script Date: 2026. 11. 10. 21:19:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[usp_DayType_Create]
    @Code NVARCHAR(30),
    @Name NVARCHAR(100),
    @IsWorkday BIT,
    @StartTime TIME(0) = NULL,
    @EndTime TIME(0) = NULL,
    @BreakMinutes SMALLINT = 0
AS
BEGIN
    SET NOCOUNT ON;

    SET @Code = LTRIM(RTRIM(@Code));
    SET @Name = LTRIM(RTRIM(@Name));

    IF @Code IS NULL OR @Code = N''
        THROW 50040, N'A napkód nem lehet üres.', 1;

    IF @Name IS NULL OR @Name = N''
        THROW 50041, N'A nap megnevezése nem lehet üres.', 1;

    IF @IsWorkday IS NULL
        THROW 50042, N'Meg kell adni, hogy a nap munkanap-e.', 1;

    IF @BreakMinutes IS NULL OR @BreakMinutes < 0
        THROW 50043, N'A szünet perceinek száma nem lehet negatív.', 1;

    IF @IsWorkday = 1 AND (@StartTime IS NULL OR @EndTime IS NULL)
        THROW 50044, N'Munkanap esetén a kezdő és záró időpont megadása kötelező.', 1;

    INSERT INTO dbo.DayType
    (
        Code,
        Name,
        IsWorkday,
        StartTime,
        EndTime,
        BreakMinutes
    )
    VALUES
    (
        @Code,
        @Name,
        @IsWorkday,
        @StartTime,
        @EndTime,
        @BreakMinutes
    );

    SELECT CONVERT(INT, SCOPE_IDENTITY()) AS DayTypeId;
END;
GO
/****** Object:  StoredProcedure [dbo].[usp_DayType_Delete]    Script Date: 2026. 11. 10. 21:19:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[usp_DayType_Delete]
    @DayTypeId INT
AS
BEGIN
    SET NOCOUNT ON;

    IF @DayTypeId <= 0
        THROW 50054, N'Érvénytelen nap típus azonosító.', 1;

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.DayType
        WHERE DayTypeId = @DayTypeId
    )
        THROW 50055, N'A nap típus nem található.', 1;

    IF EXISTS
    (
        SELECT 1
        FROM dbo.WorkScheduleDay
        WHERE DayTypeId = @DayTypeId
    )
        THROW 50056, N'A nap típus munkarendben szerepel, ezért nem törölhető.', 1;

    DELETE FROM dbo.DayType
    WHERE DayTypeId = @DayTypeId;
END;
GO
/****** Object:  StoredProcedure [dbo].[usp_DayType_GetById]    Script Date: 2026. 11. 10. 21:19:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[usp_DayType_GetById]
    @DayTypeId INT
AS
BEGIN
    SET NOCOUNT ON;

    IF @DayTypeId <= 0
        THROW 50052, N'Érvénytelen nap típus azonosító.', 1;

    SELECT
        DayTypeId,
        Code,
        Name,
        IsWorkday,
        StartTime,
        EndTime,
        BreakMinutes
    FROM dbo.DayType
    WHERE DayTypeId = @DayTypeId;

    IF @@ROWCOUNT = 0
        THROW 50053, N'A nap típus nem található.', 1;
END;
GO
/****** Object:  StoredProcedure [dbo].[usp_DayType_Search]    Script Date: 2026. 11. 10. 21:19:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[usp_DayType_Search]
    @Search NVARCHAR(100) = NULL,
    @IsWorkday BIT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SET @Search = NULLIF(LTRIM(RTRIM(@Search)), N'');

    SELECT
        DayTypeId,
        Code,
        Name,
        IsWorkday,
        StartTime,
        EndTime,
        BreakMinutes
    FROM dbo.DayType
    WHERE
        (
            @Search IS NULL
            OR Code LIKE N'%' + @Search + N'%'
            OR Name LIKE N'%' + @Search + N'%'
        )
        AND
        (
            @IsWorkday IS NULL
            OR IsWorkday = @IsWorkday
        )
    ORDER BY Code;
END;
GO
/****** Object:  StoredProcedure [dbo].[usp_DayType_Update]    Script Date: 2026. 11. 10. 21:19:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[usp_DayType_Update]
    @DayTypeId INT,
    @Code NVARCHAR(30),
    @Name NVARCHAR(100),
    @IsWorkday BIT,
    @StartTime TIME(0) = NULL,
    @EndTime TIME(0) = NULL,
    @BreakMinutes SMALLINT = 0
AS
BEGIN
    SET NOCOUNT ON;

    IF @DayTypeId <= 0
        THROW 50045, N'Érvénytelen nap típus azonosító.', 1;

    SET @Code = LTRIM(RTRIM(@Code));
    SET @Name = LTRIM(RTRIM(@Name));

    IF @Code IS NULL OR @Code = N''
        THROW 50046, N'A napkód nem lehet üres.', 1;

    IF @Name IS NULL OR @Name = N''
        THROW 50047, N'A nap megnevezése nem lehet üres.', 1;

    IF @IsWorkday IS NULL
        THROW 50048, N'Meg kell adni, hogy a nap munkanap-e.', 1;

    IF @BreakMinutes IS NULL OR @BreakMinutes < 0
        THROW 50049, N'A szünet perceinek száma nem lehet negatív.', 1;

    IF @IsWorkday = 1 AND (@StartTime IS NULL OR @EndTime IS NULL)
        THROW 50050, N'Munkanap esetén a kezdő és záró időpont megadása kötelező.', 1;

    UPDATE dbo.DayType
    SET
        Code = @Code,
        Name = @Name,
        IsWorkday = @IsWorkday,
        StartTime = @StartTime,
        EndTime = @EndTime,
        BreakMinutes = @BreakMinutes
    WHERE DayTypeId = @DayTypeId;

    IF @@ROWCOUNT = 0
        THROW 50051, N'A nap típus nem található.', 1;
END;
GO
/****** Object:  StoredProcedure [dbo].[usp_Employee_GetById]    Script Date: 2026. 11. 10. 21:19:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[usp_Employee_GetById]
    @EmployeeId INT
AS
BEGIN
    SET NOCOUNT ON;

    IF @EmployeeId IS NULL OR @EmployeeId <= 0
        THROW 50100, N'Érvénytelen munkavállaló-azonosító.', 1;

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.Employee
        WHERE EmployeeId = @EmployeeId
    )
        THROW 50101, N'A munkavállaló nem található.', 1;

    SELECT
        EmployeeId,
        FirstName,
        LastName,
        BirthDate,
        IsActive,
        PersonalId,
        TaxId,
        TAJId,
        Address,
        PayrollRunFrom,
        JoinDate
    FROM dbo.Employee
    WHERE EmployeeId = @EmployeeId;
END;
GO
/****** Object:  StoredProcedure [dbo].[usp_Employee_Onboard]    Script Date: 2026. 11. 10. 21:19:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[usp_Employee_Onboard]
    @FirstName        NVARCHAR(100),
    @LastName         NVARCHAR(100),
    @BirthDate        DATE,
    @PersonalId       NVARCHAR(30),
    @TaxId            NVARCHAR(30),
    @TAJId            NVARCHAR(30),
    @Address          NVARCHAR(500),
    @JoinDate         DATE,
    @CompanyId        INT,
    @WorkScheduleId   INT,
    @PayrollElementId INT,
    @BaseSalaryAmount DECIMAL(18,2)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF NULLIF(LTRIM(RTRIM(@FirstName)), N'') IS NULL
       OR NULLIF(LTRIM(RTRIM(@LastName)), N'') IS NULL
       OR @BirthDate IS NULL
       OR NULLIF(LTRIM(RTRIM(@PersonalId)), N'') IS NULL
       OR NULLIF(LTRIM(RTRIM(@TaxId)), N'') IS NULL
       OR NULLIF(LTRIM(RTRIM(@TAJId)), N'') IS NULL
       OR NULLIF(LTRIM(RTRIM(@Address)), N'') IS NULL
       OR @JoinDate IS NULL
       OR @CompanyId IS NULL
       OR @WorkScheduleId IS NULL
       OR @PayrollElementId IS NULL
       OR @BaseSalaryAmount IS NULL
    BEGIN
        THROW 50080, N'Minden beléptetési adat megadása kötelező.', 1;
    END;

    IF @CompanyId <= 0
       OR @WorkScheduleId <= 0
       OR @PayrollElementId <= 0
       OR @BaseSalaryAmount <= 0
       OR @BirthDate > @JoinDate
    BEGIN
        THROW 50081, N'Érvénytelen beléptetési adat.', 1;
    END;

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.Company
        WHERE CompanyId = @CompanyId
    )
    BEGIN
        THROW 50082, N'A megadott cég nem található.', 1;
    END;

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.PayrollElement
        WHERE PayrollElementId = @PayrollElementId
          AND IsActive = 1
    )
    BEGIN
        THROW 50083, N'A megadott aktív bérelem nem található.', 1;
    END;

    DECLARE @PeriodLengthDays INT;

    SELECT @PeriodLengthDays = PeriodLengthDays
    FROM dbo.WorkSchedule
    WHERE WorkScheduleId = @WorkScheduleId
      AND IsActive = 1;

    IF @PeriodLengthDays IS NULL
       OR @PeriodLengthDays <> 7
       OR
       (
           SELECT COUNT(*)
           FROM dbo.WorkScheduleDay
           WHERE WorkScheduleId = @WorkScheduleId
       ) <> @PeriodLengthDays
    BEGIN
        THROW 50084, N'Csak teljesen konfigurált, aktív munkarend használható beléptetéskor.', 1;
    END;

    DECLARE @EmployeeId INT;
    DECLARE @EmploymentId INT;
    DECLARE @CycleStartDate DATE;

    -- A heti ciklus hétfőn kezdődik.
    -- A munkarend tényleges érvényessége a JoinDate napján indul.
    SET @CycleStartDate =
        DATEADD
        (
            DAY,
            -(
                (
                    DATEDIFF(DAY, CONVERT(DATE, '19000101', 112), @JoinDate) % 7
                    + 7
                ) % 7
            ),
            @JoinDate
        );

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO dbo.Employee
        (
            FirstName,
            LastName,
            BirthDate,
            PayrollRunFrom,
            IsActive,
            PersonalId,
            TaxId,
            TAJId,
            Address,
            JoinDate
        )
        VALUES
        (
            @FirstName,
            @LastName,
            @BirthDate,
            @JoinDate,
            1,
            @PersonalId,
            @TaxId,
            @TAJId,
            @Address,
            @JoinDate
        );

        SET @EmployeeId = CONVERT(INT, SCOPE_IDENTITY());

        INSERT INTO dbo.Employment
        (
            CompanyId,
            EmployeeId,
            ValidFrom,
            ValidTo
        )
        VALUES
        (
            @CompanyId,
            @EmployeeId,
            @JoinDate,
            NULL
        );

        SET @EmploymentId = CONVERT(INT, SCOPE_IDENTITY());

        INSERT INTO dbo.EmploymentWorkSchedule
        (
            EmploymentId,
            WorkScheduleId,
            ValidFrom,
            ValidTo,
            CycleStartDate
        )
        VALUES
        (
            @EmploymentId,
            @WorkScheduleId,
            @JoinDate,
            NULL,
            @CycleStartDate
        );

        INSERT INTO dbo.EmploymentPayrollElement
        (
            EmploymentId,
            PayrollElementId,
            ValidFrom,
            ValidTo,
            Amount
        )
        VALUES
        (
            @EmploymentId,
            @PayrollElementId,
            @JoinDate,
            NULL,
            @BaseSalaryAmount
        );

        COMMIT TRANSACTION;

        SELECT
            @EmployeeId AS EmployeeId,
            @EmploymentId AS EmploymentId,
            @JoinDate AS JoinDate,
            @JoinDate AS PayrollRunFrom,
            @WorkScheduleId AS WorkScheduleId,
            @PayrollElementId AS PayrollElementId,
            @BaseSalaryAmount AS BaseSalaryAmount,
            @CycleStartDate AS CycleStartDate;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH;
END;
GO
/****** Object:  StoredProcedure [dbo].[usp_Employee_Search]    Script Date: 2026. 11. 10. 21:19:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[usp_Employee_Search]
    @Search NVARCHAR(100) = NULL,
    @IsActive BIT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SET @Search = NULLIF(LTRIM(RTRIM(@Search)), N'');

    SELECT
        EmployeeId,
        FirstName,
        LastName,
        IsActive,
        JoinDate,
        PayrollRunFrom
    FROM dbo.Employee
    WHERE
        (@IsActive IS NULL OR IsActive = @IsActive)
        AND
        (
            @Search IS NULL
            OR FirstName LIKE N'%' + @Search + N'%'
            OR LastName LIKE N'%' + @Search + N'%'
            OR PersonalId LIKE N'%' + @Search + N'%'
            OR TaxId LIKE N'%' + @Search + N'%'
            OR TAJId LIKE N'%' + @Search + N'%'
        )
    ORDER BY LastName, FirstName, EmployeeId;
END;
GO
/****** Object:  StoredProcedure [dbo].[usp_Employee_Terminate]    Script Date: 2026. 11. 10. 21:19:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[usp_Employee_Terminate]
    @EmployeeId INT,
    @TerminationDate DATE
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @JoinDate DATE;
    DECLARE @IsActive BIT;
    DECLARE @ClosedPayrollElements INT = 0;
    DECLARE @DeletedFuturePayrollElements INT = 0;

    BEGIN TRY
        BEGIN TRANSACTION;

        SELECT
            @JoinDate = JoinDate,
            @IsActive = IsActive
        FROM dbo.Employee WITH (UPDLOCK, HOLDLOCK)
        WHERE EmployeeId = @EmployeeId;

        IF @JoinDate IS NULL
        BEGIN
            IF NOT EXISTS
            (
                SELECT 1
                FROM dbo.Employee
                WHERE EmployeeId = @EmployeeId
            )
                THROW 50201, N'A munkavállaló nem található.', 1;

            THROW 50202, N'A munkavállaló belépési dátuma nincs megadva.', 1;
        END;

        IF @IsActive = 0
            THROW 50203, N'A munkavállaló már inaktív.', 1;

        IF @TerminationDate < @JoinDate
            THROW 50204, N'A kilépés dátuma nem lehet korábbi a belépés dátumánál.', 1;

        UPDATE payrollElement
        SET ValidTo = @TerminationDate
        FROM dbo.EmploymentPayrollElement AS payrollElement
        INNER JOIN dbo.Employment AS employment
            ON employment.EmploymentId = payrollElement.EmploymentId
        WHERE employment.EmployeeId = @EmployeeId
          AND payrollElement.ValidFrom <= @TerminationDate
          AND
          (
              payrollElement.ValidTo IS NULL
              OR payrollElement.ValidTo > @TerminationDate
          );

        SET @ClosedPayrollElements = @@ROWCOUNT;

        DELETE payrollElement
        FROM dbo.EmploymentPayrollElement AS payrollElement
        INNER JOIN dbo.Employment AS employment
            ON employment.EmploymentId = payrollElement.EmploymentId
        WHERE employment.EmployeeId = @EmployeeId
          AND payrollElement.ValidFrom > @TerminationDate;

        SET @DeletedFuturePayrollElements = @@ROWCOUNT;

        UPDATE dbo.Employee
        SET IsActive = 0
        WHERE EmployeeId = @EmployeeId;

        COMMIT TRANSACTION;

        SELECT
            @EmployeeId AS EmployeeId,
            @TerminationDate AS TerminationDate,
            CAST(0 AS BIT) AS IsActive,
            @ClosedPayrollElements AS ClosedPayrollElements,
            @DeletedFuturePayrollElements AS DeletedFuturePayrollElements;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH;
END;
GO
/****** Object:  StoredProcedure [dbo].[usp_Employee_Update]    Script Date: 2026. 11. 10. 21:19:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[usp_Employee_Update]
    @EmployeeId INT,
    @FirstName  NVARCHAR(100),
    @LastName   NVARCHAR(100),
    @BirthDate  DATE,
    @PersonalId NVARCHAR(30),
    @TaxId      NVARCHAR(30),
    @TAJId      NVARCHAR(30),
    @Address    NVARCHAR(500)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF @EmployeeId IS NULL
       OR @EmployeeId <= 0
       OR NULLIF(LTRIM(RTRIM(@FirstName)), N'') IS NULL
       OR NULLIF(LTRIM(RTRIM(@LastName)), N'') IS NULL
       OR @BirthDate IS NULL
       OR NULLIF(LTRIM(RTRIM(@PersonalId)), N'') IS NULL
       OR NULLIF(LTRIM(RTRIM(@TaxId)), N'') IS NULL
       OR NULLIF(LTRIM(RTRIM(@TAJId)), N'') IS NULL
       OR NULLIF(LTRIM(RTRIM(@Address)), N'') IS NULL
    BEGIN
        THROW 50085, N'Minden szerkeszthető munkavállalói adat megadása kötelező.', 1;
    END;

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.Employee
        WHERE EmployeeId = @EmployeeId
    )
    BEGIN
        THROW 50087, N'A munkavállaló nem található.', 1;
    END;

    DECLARE @JoinDate DATE;

    SELECT @JoinDate = JoinDate
    FROM dbo.Employee
    WHERE EmployeeId = @EmployeeId;

    IF @JoinDate IS NULL
       OR @BirthDate > @JoinDate
    BEGIN
        THROW 50086, N'Érvénytelen születési dátum vagy hiányzó belépési dátum.', 1;
    END;

    UPDATE dbo.Employee
    SET
        FirstName = @FirstName,
        LastName = @LastName,
        BirthDate = @BirthDate,
        PersonalId = @PersonalId,
        TaxId = @TaxId,
        TAJId = @TAJId,
        Address = @Address
    WHERE EmployeeId = @EmployeeId;

    SELECT
        EmployeeId,
        FirstName,
        LastName,
        BirthDate,
        IsActive,
        PersonalId,
        TaxId,
        TAJId,
        Address,
        PayrollRunFrom,
        JoinDate
    FROM dbo.Employee
    WHERE EmployeeId = @EmployeeId;
END;
GO
/****** Object:  StoredProcedure [dbo].[usp_EmployeeAbsence_Create]    Script Date: 2026. 11. 10. 21:19:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[usp_EmployeeAbsence_Create]
    @EmployeeId INT,
    @AbsenceTypeId INT,
    @StartDate DATE,
    @EndDate DATE,
    @FullDay BIT,
    @StartTime TIME(7) = NULL,
    @EndTime TIME(7) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @JoinDate DATE;

        DECLARE @CreatedAbsences TABLE
        (
            AbsenceId INT,
            EmploymentId INT,
            AbsenceTypeId INT,
            StartDate DATE,
            EndDate DATE,
            FullDay BIT,
            StartTime TIME(7) NULL,
            EndTime TIME(7) NULL
        );

        DECLARE @EmploymentSegments TABLE
        (
            EmploymentId INT PRIMARY KEY,
            SegmentStart DATE NOT NULL,
            SegmentEnd DATE NOT NULL
        );

        SELECT @JoinDate = JoinDate
        FROM dbo.Employee WITH (UPDLOCK, HOLDLOCK)
        WHERE EmployeeId = @EmployeeId;

        IF @JoinDate IS NULL
        BEGIN
            THROW 50401, N'A munkavállaló nem található, vagy nincs belépési dátuma.', 1;
        END;

        IF @StartDate IS NULL OR @EndDate IS NULL
        BEGIN
            THROW 50407, N'A távollét kezdő és záró dátumát is meg kell adni.', 1;
        END;

        IF @StartDate < @JoinDate
        BEGIN
            THROW 50402, N'A távollét nem kezdődhet a belépés dátuma előtt.', 1;
        END;

        IF @EndDate < @StartDate
        BEGIN
            THROW 50403, N'A távollét vége nem lehet korábbi a kezdeténél.', 1;
        END;

        IF @FullDay IS NULL
        BEGIN
            THROW 50410, N'Meg kell adni, hogy a távollét egész napos-e.', 1;
        END;

        IF @FullDay = 1
           AND (@StartTime IS NOT NULL OR @EndTime IS NOT NULL)
        BEGIN
            THROW 50411, N'Egész napos távollétnél kezdő és záró időpont nem adható meg.', 1;
        END;

        IF @FullDay = 0
           AND (@StartTime IS NULL OR @EndTime IS NULL)
        BEGIN
            THROW 50412, N'Résznapos távollétnél a kezdő és záró időpont megadása kötelező.', 1;
        END;

        IF @FullDay = 0
           AND @StartDate = @EndDate
           AND @EndTime <= @StartTime
        BEGIN
            THROW 50413, N'A záró időpontnak későbbinek kell lennie a kezdő időpontnál.', 1;
        END;

        IF NOT EXISTS
        (
            SELECT 1
            FROM dbo.AbsenceType
            WHERE AbsenceTypeId = @AbsenceTypeId
              AND IsActive = 1
        )
        BEGIN
            THROW 50404, N'A távolléttípus nem található vagy inaktív.', 1;
        END;

        INSERT INTO @EmploymentSegments
        (
            EmploymentId,
            SegmentStart,
            SegmentEnd
        )
        SELECT
            EmploymentId,
            CASE
                WHEN ValidFrom < @StartDate THEN @StartDate
                ELSE ValidFrom
            END,
            CASE
                WHEN ValidTo IS NULL OR ValidTo > @EndDate THEN @EndDate
                ELSE ValidTo
            END
        FROM dbo.Employment WITH (UPDLOCK, HOLDLOCK)
        WHERE EmployeeId = @EmployeeId
          AND ValidFrom <= @EndDate
          AND (ValidTo IS NULL OR ValidTo >= @StartDate);

        IF NOT EXISTS
        (
            SELECT 1
            FROM @EmploymentSegments
        )
        BEGIN
            THROW 50405, N'A távollét időszakában nincs érvényes munkaviszony.', 1;
        END;

        IF
            (SELECT MIN(SegmentStart) FROM @EmploymentSegments) <> @StartDate
            OR
            (SELECT MAX(SegmentEnd) FROM @EmploymentSegments) <> @EndDate
        BEGIN
            THROW 50406, N'A munkaviszonyok nem fedik le a teljes távolléti időszakot.', 1;
        END;

        IF EXISTS
        (
            SELECT 1
            FROM
            (
                SELECT
                    SegmentStart,
                    LAG(SegmentEnd) OVER
                    (
                        ORDER BY SegmentStart, EmploymentId
                    ) AS PreviousSegmentEnd
                FROM @EmploymentSegments
            ) AS OrderedSegments
            WHERE PreviousSegmentEnd IS NOT NULL
              AND DATEADD(DAY, 1, PreviousSegmentEnd) <> SegmentStart
        )
        BEGIN
            THROW 50406, N'A munkaviszonyok nem fedik le folytonosan a teljes távolléti időszakot.', 1;
        END;

        INSERT INTO dbo.EmployeeAbsence
        (
            EmploymentId,
            AbsenceTypeId,
            StartDate,
            EndDate,
            FullDay,
            StartTime,
            EndTime
        )
        OUTPUT
            inserted.AbsenceId,
            inserted.EmploymentId,
            inserted.AbsenceTypeId,
            inserted.StartDate,
            inserted.EndDate,
            inserted.FullDay,
            inserted.StartTime,
            inserted.EndTime
        INTO @CreatedAbsences
        SELECT
            EmploymentId,
            @AbsenceTypeId,
            SegmentStart,
            SegmentEnd,
            @FullDay,
            CASE
                WHEN @FullDay = 1 THEN NULL
                WHEN SegmentStart = @StartDate THEN @StartTime
                ELSE CONVERT(TIME(7), '00:00:00')
            END,
            CASE
                WHEN @FullDay = 1 THEN NULL
                WHEN SegmentEnd = @EndDate THEN @EndTime
                ELSE CONVERT(TIME(7), '23:59:59.9999999')
            END
        FROM @EmploymentSegments;

        COMMIT TRANSACTION;

        SELECT
            AbsenceId,
            EmploymentId,
            AbsenceTypeId,
            StartDate,
            EndDate,
            FullDay,
            StartTime,
            EndTime
        FROM @CreatedAbsences
        ORDER BY StartDate, AbsenceId;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
        BEGIN
            ROLLBACK TRANSACTION;
        END;

        THROW;
    END CATCH;
END;
GO
/****** Object:  StoredProcedure [dbo].[usp_EmployeeAbsence_Delete]    Script Date: 2026. 11. 10. 21:19:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[usp_EmployeeAbsence_Delete]
    @EmployeeId INT,
    @AbsenceId INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @DeletedAbsence TABLE
        (
            AbsenceId INT,
            EmploymentId INT,
            AbsenceTypeId INT,
            StartDate DATE,
            EndDate DATE,
            FullDay BIT,
            StartTime TIME(7) NULL,
            EndTime TIME(7) NULL
        );

        IF @EmployeeId <= 0
        BEGIN
            THROW 50414, N'Érvénytelen munkavállaló-azonosító.', 1;
        END;

        IF @AbsenceId <= 0
        BEGIN
            THROW 50408, N'Érvénytelen távollét-azonosító.', 1;
        END;

        IF NOT EXISTS
        (
            SELECT 1
            FROM dbo.EmployeeAbsence AS a WITH (UPDLOCK, HOLDLOCK)
            INNER JOIN dbo.Employment AS e
                ON e.EmploymentId = a.EmploymentId
            WHERE a.AbsenceId = @AbsenceId
              AND e.EmployeeId = @EmployeeId
        )
        BEGIN
            THROW 50409, N'A távollét nem található ennél a munkavállalónál.', 1;
        END;

        DELETE a
        OUTPUT
            deleted.AbsenceId,
            deleted.EmploymentId,
            deleted.AbsenceTypeId,
            deleted.StartDate,
            deleted.EndDate,
            deleted.FullDay,
            deleted.StartTime,
            deleted.EndTime
        INTO @DeletedAbsence
        FROM dbo.EmployeeAbsence AS a
        INNER JOIN dbo.Employment AS e
            ON e.EmploymentId = a.EmploymentId
        WHERE a.AbsenceId = @AbsenceId
          AND e.EmployeeId = @EmployeeId;

        COMMIT TRANSACTION;

        SELECT
            AbsenceId,
            EmploymentId,
            AbsenceTypeId,
            StartDate,
            EndDate,
            FullDay,
            StartTime,
            EndTime
        FROM @DeletedAbsence;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
        BEGIN
            ROLLBACK TRANSACTION;
        END;

        THROW;
    END CATCH;
END;
GO
/****** Object:  StoredProcedure [dbo].[usp_EmployeeAbsence_GetByEmployeeId]    Script Date: 2026. 11. 10. 21:19:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[usp_EmployeeAbsence_GetByEmployeeId]
    @EmployeeId INT
AS
BEGIN
    SET NOCOUNT ON;

    IF @EmployeeId <= 0
    BEGIN
        THROW 50414, N'Érvénytelen munkavállaló-azonosító.', 1;
    END;

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.Employee
        WHERE EmployeeId = @EmployeeId
    )
    BEGIN
        THROW 50401, N'A munkavállaló nem található.', 1;
    END;

    SELECT
        e.EmployeeId,
        a.AbsenceId,
        a.EmploymentId,
        a.AbsenceTypeId,
        at.Code AS AbsenceTypeCode,
        at.Name AS AbsenceTypeName,
        at.IsPaid,
        a.StartDate,
        a.EndDate,
        a.FullDay,
        a.StartTime,
        a.EndTime
    FROM dbo.EmployeeAbsence AS a
    INNER JOIN dbo.Employment AS e
        ON e.EmploymentId = a.EmploymentId
    INNER JOIN dbo.AbsenceType AS at
        ON at.AbsenceTypeId = a.AbsenceTypeId
    WHERE e.EmployeeId = @EmployeeId
    ORDER BY
        a.StartDate,
        a.StartTime,
        a.AbsenceId;
END;
GO
/****** Object:  StoredProcedure [dbo].[usp_EmployeeBankAccount_Delete]    Script Date: 2026. 11. 10. 21:19:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[usp_EmployeeBankAccount_Delete]
    @EmployeeId INT,
    @EmployeeBankAccountId INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF @EmployeeId <= 0 OR @EmployeeBankAccountId <= 0
    BEGIN
        THROW 51001, 'Érvénytelen munkavállaló- vagy bankszámla-azonosító.', 1;
    END;

    BEGIN TRY
        BEGIN TRANSACTION;

        DELETE FROM dbo.EmployeeBankAccount
        WHERE EmployeeId = @EmployeeId
          AND EmployeeBankAccountId = @EmployeeBankAccountId;

        IF @@ROWCOUNT = 0
        BEGIN
            THROW 51002, 'A bankszámla nem található ennél a dolgozónál.', 1;
        END;

        COMMIT TRANSACTION;

        SELECT
            @EmployeeId AS EmployeeId,
            @EmployeeBankAccountId AS EmployeeBankAccountId;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
        BEGIN
            ROLLBACK TRANSACTION;
        END;

        THROW;
    END CATCH;
END;
GO
/****** Object:  StoredProcedure [dbo].[usp_EmployeeBankAccount_GetByEmployeeId]    Script Date: 2026. 11. 10. 21:19:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[usp_EmployeeBankAccount_GetByEmployeeId]
    @EmployeeId INT
AS
BEGIN
    SET NOCOUNT ON;

    IF @EmployeeId IS NULL OR @EmployeeId <= 0
        THROW 50601, N'Érvénytelen munkavállaló-azonosító.', 1;

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.Employee
        WHERE EmployeeId = @EmployeeId
    )
        THROW 50604, N'A munkavállaló nem található.', 1;

    SELECT
        EmployeeBankAccountId,
        EmployeeId,
        AccountType,
        AccountIdentifier,
        ValidFrom,
        ValidTo
    FROM dbo.EmployeeBankAccount
    WHERE EmployeeId = @EmployeeId
    ORDER BY
        AccountType,
        ValidFrom;
END;
GO
/****** Object:  StoredProcedure [dbo].[usp_EmployeeBankAccount_Set]    Script Date: 2026. 11. 10. 21:19:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[usp_EmployeeBankAccount_Set]
    @EmployeeId INT,
    @AccountType NVARCHAR(20),
    @AccountIdentifier NVARCHAR(50),
    @ValidFrom DATE
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF @EmployeeId IS NULL OR @EmployeeId <= 0
        THROW 50601, N'Érvénytelen munkavállaló-azonosító.', 1;

    IF @AccountType IS NULL
       OR @AccountType NOT IN (N'BANK_ACCOUNT', N'SZEP_CARD')
        THROW 50606, N'Érvénytelen számlatípus.', 1;

    IF @AccountIdentifier IS NULL
       OR LEN(LTRIM(RTRIM(@AccountIdentifier))) = 0
       OR LEN(LTRIM(RTRIM(@AccountIdentifier))) > 50
        THROW 50602, N'A számlaazonosító nem lehet üres, és legfeljebb 50 karakter lehet.', 1;

    IF @ValidFrom IS NULL
        THROW 50603, N'A kezdődátum megadása kötelező.', 1;

    DECLARE @JoinDate DATE;

    SELECT @JoinDate = JoinDate
    FROM dbo.Employee
    WHERE EmployeeId = @EmployeeId;

    IF @JoinDate IS NULL
        THROW 50604, N'A munkavállaló nem található.', 1;

    IF @ValidFrom < @JoinDate
        THROW 50605, N'A számla kezdődátuma nem lehet korábbi a belépés dátumánál.', 1;

    DECLARE @NextValidFrom DATE;
    DECLARE @EffectiveValidTo DATE = NULL;
    DECLARE @EmployeeBankAccountId INT;

    SELECT @NextValidFrom = MIN(ValidFrom)
    FROM dbo.EmployeeBankAccount
    WHERE EmployeeId = @EmployeeId
      AND AccountType = @AccountType
      AND ValidFrom > @ValidFrom;

    IF @NextValidFrom IS NOT NULL
        SET @EffectiveValidTo = DATEADD(DAY, -1, @NextValidFrom);

    BEGIN TRY
        BEGIN TRANSACTION;

        SELECT @EmployeeBankAccountId = EmployeeBankAccountId
        FROM dbo.EmployeeBankAccount
        WHERE EmployeeId = @EmployeeId
          AND AccountType = @AccountType
          AND ValidFrom = @ValidFrom;

        IF @EmployeeBankAccountId IS NOT NULL
        BEGIN
            UPDATE dbo.EmployeeBankAccount
            SET
                AccountIdentifier = LTRIM(RTRIM(@AccountIdentifier)),
                ValidTo = @EffectiveValidTo
            WHERE EmployeeBankAccountId = @EmployeeBankAccountId;
        END
        ELSE
        BEGIN
            UPDATE dbo.EmployeeBankAccount
            SET ValidTo = DATEADD(DAY, -1, @ValidFrom)
            WHERE EmployeeId = @EmployeeId
              AND AccountType = @AccountType
              AND ValidFrom < @ValidFrom
              AND (ValidTo IS NULL OR ValidTo >= @ValidFrom);

            INSERT INTO dbo.EmployeeBankAccount
            (
                EmployeeId,
                AccountType,
                AccountIdentifier,
                ValidFrom,
                ValidTo
            )
            VALUES
            (
                @EmployeeId,
                @AccountType,
                LTRIM(RTRIM(@AccountIdentifier)),
                @ValidFrom,
                @EffectiveValidTo
            );

            SET @EmployeeBankAccountId = CONVERT(INT, SCOPE_IDENTITY());
        END;

        COMMIT TRANSACTION;

        SELECT
            EmployeeBankAccountId,
            EmployeeId,
            AccountType,
            AccountIdentifier,
            ValidFrom,
            ValidTo
        FROM dbo.EmployeeBankAccount
        WHERE EmployeeBankAccountId = @EmployeeBankAccountId;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH;
END;
GO
/****** Object:  StoredProcedure [dbo].[usp_EmployeeDependent_Create]    Script Date: 2026. 11. 10. 21:19:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[usp_EmployeeDependent_Create]
    @EmployeeId INT,
    @FirstName NVARCHAR(100),
    @LastName NVARCHAR(100),
    @BirthDate DATE = NULL,
    @TaxId NVARCHAR(30) = NULL,
    @RelationshipTypeId INT,
    @ValidFrom DATE = NULL,
    @ValidTo DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF NOT EXISTS (
        SELECT 1
        FROM dbo.Employee
        WHERE EmployeeId = @EmployeeId
    )
        THROW 50701, 'A munkavállaló nem található.', 1;

    IF NOT EXISTS (
        SELECT 1
        FROM dbo.RelationshipType
        WHERE RelationshipTypeId = @RelationshipTypeId
    )
        THROW 50702, 'A rokonsági típus nem található.', 1;

    IF @ValidFrom IS NOT NULL
       AND @ValidTo IS NOT NULL
       AND @ValidTo < @ValidFrom
        THROW 50704, 'Az érvényesség vége nem lehet korábbi a kezdeténél.', 1;

    DECLARE @DependentId INT;
    DECLARE @EmployeeDependentId INT;

    BEGIN TRANSACTION;

    INSERT dbo.Dependent (FirstName, LastName, BirthDate, TaxId)
    VALUES (@FirstName, @LastName, @BirthDate, @TaxId);

    SET @DependentId = CONVERT(INT, SCOPE_IDENTITY());

    INSERT dbo.EmployeeDependent
        (EmployeeId, DependentId, RelationshipTypeId, ValidFrom, ValidTo)
    VALUES
        (@EmployeeId, @DependentId, @RelationshipTypeId, @ValidFrom, @ValidTo);

    SET @EmployeeDependentId = CONVERT(INT, SCOPE_IDENTITY());

    COMMIT TRANSACTION;

    SELECT
        ed.EmployeeDependentId,
        ed.EmployeeId,
        d.DependentId,
        d.FirstName,
        d.LastName,
        d.BirthDate,
        d.TaxId,
        ed.RelationshipTypeId,
        rt.Name AS RelationshipTypeName,
        ed.ValidFrom,
        ed.ValidTo
    FROM dbo.EmployeeDependent AS ed
    INNER JOIN dbo.Dependent AS d
        ON d.DependentId = ed.DependentId
    INNER JOIN dbo.RelationshipType AS rt
        ON rt.RelationshipTypeId = ed.RelationshipTypeId
    WHERE ed.EmployeeDependentId = @EmployeeDependentId;
END;
GO
/****** Object:  StoredProcedure [dbo].[usp_EmployeeDependent_Delete]    Script Date: 2026. 11. 10. 21:19:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[usp_EmployeeDependent_Delete]
    @EmployeeId INT,
    @EmployeeDependentId INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @DependentId INT;

    SELECT @DependentId = DependentId
    FROM dbo.EmployeeDependent
    WHERE EmployeeId = @EmployeeId
      AND EmployeeDependentId = @EmployeeDependentId;

    IF @DependentId IS NULL
        THROW 50703, 'Az eltartott-hozzárendelés nem található.', 1;

    BEGIN TRANSACTION;

    DELETE dbo.EmployeeDependent
    WHERE EmployeeId = @EmployeeId
      AND EmployeeDependentId = @EmployeeDependentId;

    IF NOT EXISTS (
        SELECT 1
        FROM dbo.EmployeeDependent
        WHERE DependentId = @DependentId
    )
        DELETE dbo.Dependent
        WHERE DependentId = @DependentId;

    COMMIT TRANSACTION;
END;
GO
/****** Object:  StoredProcedure [dbo].[usp_EmployeeDependent_GetByEmployeeId]    Script Date: 2026. 11. 10. 21:19:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[usp_EmployeeDependent_GetByEmployeeId]
    @EmployeeId INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (
        SELECT 1
        FROM dbo.Employee
        WHERE EmployeeId = @EmployeeId
    )
        THROW 50701, 'A munkavállaló nem található.', 1;

    SELECT
        ed.EmployeeDependentId,
        ed.EmployeeId,
        d.DependentId,
        d.FirstName,
        d.LastName,
        d.BirthDate,
        d.TaxId,
        ed.RelationshipTypeId,
        rt.Name AS RelationshipTypeName,
        ed.ValidFrom,
        ed.ValidTo
    FROM dbo.EmployeeDependent AS ed
    INNER JOIN dbo.Dependent AS d
        ON d.DependentId = ed.DependentId
    INNER JOIN dbo.RelationshipType AS rt
        ON rt.RelationshipTypeId = ed.RelationshipTypeId
    WHERE ed.EmployeeId = @EmployeeId
    ORDER BY d.LastName, d.FirstName, d.BirthDate, ed.EmployeeDependentId;
END;
GO
/****** Object:  StoredProcedure [dbo].[usp_EmployeeDependent_Update]    Script Date: 2026. 11. 10. 21:19:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[usp_EmployeeDependent_Update]
    @EmployeeId INT,
    @EmployeeDependentId INT,
    @FirstName NVARCHAR(100),
    @LastName NVARCHAR(100),
    @BirthDate DATE = NULL,
    @TaxId NVARCHAR(30) = NULL,
    @RelationshipTypeId INT,
    @ValidFrom DATE = NULL,
    @ValidTo DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF NOT EXISTS (
        SELECT 1
        FROM dbo.Employee
        WHERE EmployeeId = @EmployeeId
    )
        THROW 50701, 'A munkavállaló nem található.', 1;

    IF NOT EXISTS (
        SELECT 1
        FROM dbo.RelationshipType
        WHERE RelationshipTypeId = @RelationshipTypeId
    )
        THROW 50702, 'A rokonsági típus nem található.', 1;

    IF @ValidFrom IS NOT NULL
       AND @ValidTo IS NOT NULL
       AND @ValidTo < @ValidFrom
        THROW 50704, 'Az érvényesség vége nem lehet korábbi a kezdeténél.', 1;

    DECLARE @DependentId INT;

    SELECT @DependentId = DependentId
    FROM dbo.EmployeeDependent
    WHERE EmployeeId = @EmployeeId
      AND EmployeeDependentId = @EmployeeDependentId;

    IF @DependentId IS NULL
        THROW 50703, 'Az eltartott-hozzárendelés nem található.', 1;

    BEGIN TRANSACTION;

    UPDATE dbo.Dependent
    SET FirstName = @FirstName,
        LastName = @LastName,
        BirthDate = @BirthDate,
        TaxId = @TaxId
    WHERE DependentId = @DependentId;

    UPDATE dbo.EmployeeDependent
    SET RelationshipTypeId = @RelationshipTypeId,
        ValidFrom = @ValidFrom,
        ValidTo = @ValidTo
    WHERE EmployeeDependentId = @EmployeeDependentId
      AND EmployeeId = @EmployeeId;

    COMMIT TRANSACTION;

    SELECT
        ed.EmployeeDependentId,
        ed.EmployeeId,
        d.DependentId,
        d.FirstName,
        d.LastName,
        d.BirthDate,
        d.TaxId,
        ed.RelationshipTypeId,
        rt.Name AS RelationshipTypeName,
        ed.ValidFrom,
        ed.ValidTo
    FROM dbo.EmployeeDependent AS ed
    INNER JOIN dbo.Dependent AS d
        ON d.DependentId = ed.DependentId
    INNER JOIN dbo.RelationshipType AS rt
        ON rt.RelationshipTypeId = ed.RelationshipTypeId
    WHERE ed.EmployeeDependentId = @EmployeeDependentId
      AND ed.EmployeeId = @EmployeeId;
END;
GO
/****** Object:  StoredProcedure [dbo].[usp_EmployeeFieldValue_End]    Script Date: 2026. 11. 10. 21:19:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[usp_EmployeeFieldValue_End]
    @EmployeeId INT,
    @FieldId INT,
    @UserId INT,
    @ValidFrom DATE,
    @ValidTo DATE,
    @RetroPayrollRunFrom DATE
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @AccessDate DATE = CONVERT(DATE, GETDATE());
    DECLARE @JoinDate DATE;
    DECLARE @PayrollRunFrom DATE;
    DECLARE @MasterDataGroupId INT;
    DECLARE @CurrentValidTo DATE;
    DECLARE @NextValidFrom DATE;
    DECLARE @ChangeEffectiveFrom DATE;
    DECLARE @SuggestedPayrollRunFrom DATE;
    DECLARE @RequiresRetroPayroll BIT = 0;

    IF @EmployeeId <= 0 OR @FieldId <= 0 OR @UserId <= 0
        THROW 50310, N'Érvénytelen munkavállaló-, mező- vagy felhasználó-azonosító.', 1;

    IF @ValidFrom IS NULL OR @ValidTo IS NULL OR @ValidTo < @ValidFrom
        THROW 50311, N'Érvénytelen érvényességi időszak.', 1;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF NOT EXISTS
        (
            SELECT 1
            FROM dbo.[User]
            WHERE UserId = @UserId
              AND IsActive = 1
        )
            THROW 50301, N'A felhasználó nem található vagy inaktív.', 1;

        SELECT
            @JoinDate = JoinDate,
            @PayrollRunFrom = PayrollRunFrom
        FROM dbo.Employee WITH (UPDLOCK, HOLDLOCK)
        WHERE EmployeeId = @EmployeeId;

        IF @@ROWCOUNT = 0
            THROW 50302, N'A munkavállaló nem található.', 1;

        IF @JoinDate IS NULL OR @ValidTo < @JoinDate
            THROW 50312, N'Az érvényesség vége nem lehet korábbi a belépés dátumánál.', 1;

        SELECT
            @MasterDataGroupId = field.MasterDataGroupId
        FROM dbo.MasterDataField AS field
        INNER JOIN dbo.MasterDataGroup AS dataGroup
            ON dataGroup.MasterDataGroupId = field.MasterDataGroupId
        WHERE field.FieldId = @FieldId
          AND field.IsActive = 1
          AND dataGroup.Code LIKE N'EMPLOYEE%';

        IF @MasterDataGroupId IS NULL
            THROW 50304, N'A dolgozói mező nem található vagy inaktív.', 1;

        IF NOT EXISTS
        (
            SELECT 1
            FROM dbo.RoleToUser AS roleToUser
            INNER JOIN dbo.[Role] AS userRole
                ON userRole.RoleId = roleToUser.RoleId
               AND userRole.IsActive = 1
            INNER JOIN dbo.MDGToRole AS permission
                ON permission.RoleId = userRole.RoleId
            WHERE roleToUser.UserId = @UserId
              AND roleToUser.ValidFrom <= @AccessDate
              AND (roleToUser.ValidTo IS NULL OR roleToUser.ValidTo >= @AccessDate)
              AND permission.MasterDataGroupId = @MasterDataGroupId
              AND permission.CanEdit = 1
        )
            THROW 50305, N'Nincs szerkesztési joga ehhez a törzsadatcsoporthoz.', 1;

        SELECT
            @CurrentValidTo = ValidTo
        FROM dbo.EmployeeFieldValue WITH (UPDLOCK, HOLDLOCK)
        WHERE EmployeeId = @EmployeeId
          AND FieldId = @FieldId
          AND ValidFrom = @ValidFrom;

        IF @@ROWCOUNT = 0
            THROW 50313, N'A megadott mezőérték nem található.', 1;

        IF @CurrentValidTo IS NOT NULL AND @ValidTo >= @CurrentValidTo
            THROW 50314, N'Csak az érvényességi időszak rövidíthető ezzel a művelettel.', 1;

        SELECT
            @NextValidFrom = MIN(ValidFrom)
        FROM dbo.EmployeeFieldValue WITH (UPDLOCK, HOLDLOCK)
        WHERE EmployeeId = @EmployeeId
          AND FieldId = @FieldId
          AND ValidFrom > @ValidFrom;

        IF @NextValidFrom IS NOT NULL
           AND @ValidTo >= @NextValidFrom
            THROW 50311, N'Az érvényesség vége nem érhet bele a következő mezőérték időszakába.', 1;

        SET @ChangeEffectiveFrom = DATEADD(DAY, 1, @ValidTo);

        IF @PayrollRunFrom IS NOT NULL
           AND @ChangeEffectiveFrom < @PayrollRunFrom
        BEGIN
            SET @RequiresRetroPayroll = 1;

            DECLARE @MonthStart DATE =
                DATEFROMPARTS(
                    YEAR(@ChangeEffectiveFrom),
                    MONTH(@ChangeEffectiveFrom),
                    1);

            SET @SuggestedPayrollRunFrom =
                CASE
                    WHEN @MonthStart < @JoinDate THEN @JoinDate
                    ELSE @MonthStart
                END;
        END;

        IF @RetroPayrollRunFrom IS NOT NULL
           AND
           (
               @RetroPayrollRunFrom < @JoinDate
               OR @RetroPayrollRunFrom > @ChangeEffectiveFrom
           )
            THROW 50309, N'Érvénytelen visszamenőleges számfejtési kezdődátum.', 1;

        UPDATE dbo.EmployeeFieldValue
        SET ValidTo = @ValidTo
        WHERE EmployeeId = @EmployeeId
          AND FieldId = @FieldId
          AND ValidFrom = @ValidFrom;

        IF @RetroPayrollRunFrom IS NOT NULL
        BEGIN
            UPDATE dbo.Employee
            SET PayrollRunFrom =
                CASE
                    WHEN PayrollRunFrom IS NULL
                         OR @RetroPayrollRunFrom < PayrollRunFrom
                        THEN @RetroPayrollRunFrom
                    ELSE PayrollRunFrom
                END
            WHERE EmployeeId = @EmployeeId;
        END;

        COMMIT TRANSACTION;

        SELECT
            @EmployeeId AS EmployeeId,
            @FieldId AS FieldId,
            @ValidFrom AS ValidFrom,
            @ValidTo AS ValidTo,
            @RequiresRetroPayroll AS RequiresRetroPayroll,
            @SuggestedPayrollRunFrom AS SuggestedPayrollRunFrom;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH;
END;
GO
/****** Object:  StoredProcedure [dbo].[usp_EmployeeFieldValue_GetByEmployeeId]    Script Date: 2026. 11. 10. 21:19:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[usp_EmployeeFieldValue_GetByEmployeeId]
    @EmployeeId INT,
    @UserId INT,
    @AsOfDate DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @AccessDate DATE = CONVERT(DATE, GETDATE());

    SET @AsOfDate = COALESCE(@AsOfDate, @AccessDate);

    IF @EmployeeId <= 0 OR @UserId <= 0
        THROW 50300, N'Érvénytelen munkavállaló- vagy felhasználó-azonosító.', 1;

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.[User]
        WHERE UserId = @UserId
          AND IsActive = 1
    )
        THROW 50301, N'A felhasználó nem található vagy inaktív.', 1;

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.Employee
        WHERE EmployeeId = @EmployeeId
    )
        THROW 50302, N'A munkavállaló nem található.', 1;

    CREATE TABLE #GroupPermissions
    (
        MasterDataGroupId INT NOT NULL PRIMARY KEY,
        CanRead BIT NOT NULL,
        CanEdit BIT NOT NULL
    );

    INSERT INTO #GroupPermissions
    (
        MasterDataGroupId,
        CanRead,
        CanEdit
    )
    SELECT
        permission.MasterDataGroupId,
        CONVERT(BIT, MAX(CONVERT(INT, permission.CanRead))),
        CONVERT(BIT, MAX(CONVERT(INT, permission.CanEdit)))
    FROM dbo.RoleToUser AS roleToUser
    INNER JOIN dbo.[Role] AS userRole
        ON userRole.RoleId = roleToUser.RoleId
       AND userRole.IsActive = 1
    INNER JOIN dbo.MDGToRole AS permission
        ON permission.RoleId = userRole.RoleId
    WHERE roleToUser.UserId = @UserId
      AND roleToUser.ValidFrom <= @AccessDate
      AND
      (
          roleToUser.ValidTo IS NULL
          OR roleToUser.ValidTo >= @AccessDate
      )
    GROUP BY permission.MasterDataGroupId;

    CREATE TABLE #EmployeeFields
    (
        FieldId INT NOT NULL PRIMARY KEY,
        MasterDataGroupId INT NOT NULL,
        CanRead BIT NOT NULL,
        CanEdit BIT NOT NULL
    );

    INSERT INTO #EmployeeFields
    (
        FieldId,
        MasterDataGroupId,
        CanRead,
        CanEdit
    )
    SELECT
        field.FieldId,
        field.MasterDataGroupId,
        groupPermission.CanRead,
        groupPermission.CanEdit
    FROM dbo.MasterDataField AS field
    INNER JOIN dbo.MasterDataGroup AS dataGroup
        ON dataGroup.MasterDataGroupId = field.MasterDataGroupId
    INNER JOIN #GroupPermissions AS groupPermission
        ON groupPermission.MasterDataGroupId = field.MasterDataGroupId
    WHERE field.IsActive = 1
      AND dataGroup.Code NOT LIKE N'PAYROLLELEMENT[_]%'
      AND groupPermission.CanRead = 1;

    SELECT
        dataGroup.MasterDataGroupId,
        dataGroup.Code AS MasterDataGroupCode,
        dataGroup.Name AS MasterDataGroupName,
        field.FieldId,
        field.Code,
        field.DisplayName,
        field.FieldTypeId,
        fieldType.Code AS FieldTypeCode,
        fieldType.Name AS FieldTypeName,
        field.IsRequired,
        field.IsUnique,
        field.DisplayOrder,
        employeeField.CanRead,
        employeeField.CanEdit,
        fieldValue.FieldValue,
        fieldValue.OptionId,
        fieldValue.ValidFrom,
        fieldValue.ValidTo
    FROM #EmployeeFields AS employeeField
    INNER JOIN dbo.MasterDataField AS field
        ON field.FieldId = employeeField.FieldId
    INNER JOIN dbo.MasterDataGroup AS dataGroup
        ON dataGroup.MasterDataGroupId = field.MasterDataGroupId
    INNER JOIN dbo.FieldType AS fieldType
        ON fieldType.FieldTypeId = field.FieldTypeId
    OUTER APPLY
    (
        SELECT TOP (1)
            value.FieldValue,
            value.OptionId,
            value.ValidFrom,
            value.ValidTo
        FROM dbo.EmployeeFieldValue AS value
        WHERE value.EmployeeId = @EmployeeId
          AND value.FieldId = field.FieldId
          AND value.ValidFrom <= @AsOfDate
          AND
          (
              value.ValidTo IS NULL
              OR value.ValidTo >= @AsOfDate
          )
        ORDER BY value.ValidFrom DESC
    ) AS fieldValue
    ORDER BY
        dataGroup.Name,
        field.DisplayOrder,
        field.DisplayName;

    SELECT
        optionValue.FieldId,
        optionValue.OptionId,
        optionValue.OptionCode,
        optionValue.DisplayName,
        optionValue.SortOrder
    FROM dbo.MasterDataFieldOption AS optionValue
    INNER JOIN #EmployeeFields AS employeeField
        ON employeeField.FieldId = optionValue.FieldId
    WHERE optionValue.IsActive = 1
    ORDER BY
        optionValue.FieldId,
        optionValue.SortOrder,
        optionValue.DisplayName;
END;
GO
