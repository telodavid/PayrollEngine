USE [PY_2]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Object:  StoredProcedure [dbo].[usp_User_GetApps]    Script Date: 2026. 11. 10. 21:19:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[usp_User_GetApps]
    @UserId INT,
    @AsOfDate DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SET @AsOfDate = COALESCE(@AsOfDate, CONVERT(DATE, GETDATE()));

    SELECT DISTINCT
        a.AppId,
        a.Code,
        a.AppName
    FROM dbo.[User] AS u
    INNER JOIN dbo.RoleToUser AS rtu
        ON rtu.UserId = u.UserId
    INNER JOIN dbo.[Role] AS r
        ON r.RoleId = rtu.RoleId
    INNER JOIN dbo.AppToRole AS atr
        ON atr.RoleId = r.RoleId
    INNER JOIN dbo.[App] AS a
        ON a.AppId = atr.AppId
    WHERE u.UserId = @UserId
      AND u.IsActive = 1
      AND r.IsActive = 1
      AND a.IsActive = 1
      AND rtu.ValidFrom <= @AsOfDate
      AND (rtu.ValidTo IS NULL OR rtu.ValidTo >= @AsOfDate)
    ORDER BY a.Code;
END;
GO
/****** Object:  StoredProcedure [dbo].[usp_User_GetAuthorizedApps]    Script Date: 2026. 11. 10. 21:19:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[usp_User_GetAuthorizedApps]
    @UserId INT,
    @AsOfDate DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SET @AsOfDate = COALESCE(@AsOfDate, CONVERT(DATE, GETDATE()));

    SELECT DISTINCT
        a.AppId,
        a.Code,
        a.AppName
    FROM dbo.[User] AS u
    INNER JOIN dbo.RoleToUser AS rtu
        ON rtu.UserId = u.UserId
    INNER JOIN dbo.[Role] AS r
        ON r.RoleId = rtu.RoleId
    INNER JOIN dbo.AppToRole AS atr
        ON atr.RoleId = r.RoleId
    INNER JOIN dbo.App AS a
        ON a.AppId = atr.AppId
    WHERE u.UserId = @UserId
      AND u.IsActive = 1
      AND r.IsActive = 1
      AND a.IsActive = 1
      AND rtu.ValidFrom <= @AsOfDate
      AND (rtu.ValidTo IS NULL OR rtu.ValidTo >= @AsOfDate)
    ORDER BY a.Code;
END;
GO
/****** Object:  StoredProcedure [dbo].[usp_User_GetForLogin]    Script Date: 2026. 11. 10. 21:19:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[usp_User_GetForLogin]
    @UserName NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        UserId,
        UserName,
        PasswordHash,
        IsActive
    FROM dbo.[User]
    WHERE UserName = @UserName;
END;
GO
/****** Object:  StoredProcedure [dbo].[usp_User_Search]    Script Date: 2026. 11. 10. 21:19:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[usp_User_Search]
    @Search NVARCHAR(100) = NULL,
    @IsActive BIT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SET @Search = NULLIF(LTRIM(RTRIM(@Search)), N'');

    SELECT
        [UserId],
        [UserName],
        [IsActive]
    FROM dbo.[User]
    WHERE
        (
            @Search IS NULL
            OR [UserName] LIKE N'%' + @Search + N'%'
        )
        AND
        (
            @IsActive IS NULL
            OR [IsActive] = @IsActive
        )
    ORDER BY
        [UserName],
        [UserId];
END;
GO
/****** Object:  StoredProcedure [dbo].[usp_User_SetPassword]    Script Date: 2026. 11. 10. 21:19:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[usp_User_SetPassword]
    @UserId INT,
    @NewPassword NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

    IF NULLIF(@NewPassword, N'') IS NULL
        THROW 50006, 'A jelszó nem lehet üres.', 1;

    UPDATE dbo.[User]
    SET PasswordHash = @NewPassword
    WHERE UserId = @UserId;

    IF @@ROWCOUNT = 0
        THROW 50002, 'A felhasználó nem található.', 1;
END;
GO
/****** Object:  StoredProcedure [dbo].[usp_User_Update]    Script Date: 2026. 11. 10. 21:19:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[usp_User_Update]
    @UserId INT,
    @UserName NVARCHAR(100),
    @IsActive BIT,
    @CurrentUserId INT
AS
BEGIN
    SET NOCOUNT ON;

    IF @UserName IS NULL OR LEN(LTRIM(RTRIM(@UserName))) = 0
    BEGIN
        THROW 50008, 'UserName cannot be empty.', 1;
    END;

    IF @UserId = @CurrentUserId AND @IsActive = 0
    BEGIN
        THROW 50009, 'The current user cannot deactivate their own account.', 1;
    END;

    UPDATE dbo.[User]
    SET UserName = @UserName,
        IsActive = @IsActive
    WHERE UserId = @UserId;

    IF @@ROWCOUNT = 0
    BEGIN
        THROW 50002, 'User not found.', 1;
    END;
END;
GO
/****** Object:  StoredProcedure [dbo].[usp_WorkSchedule_Create]    Script Date: 2026. 11. 10. 21:19:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[usp_WorkSchedule_Create]
    @Name NVARCHAR(100),
    @PeriodLengthDays INT,
    @Days dbo.WorkScheduleDayInputType READONLY
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    SET @Name = LTRIM(RTRIM(@Name));

    IF @Name IS NULL OR @Name = N''
        THROW 50060, N'A munkarend neve nem lehet üres.', 1;

    IF @PeriodLengthDays <= 0
        THROW 50061, N'A ciklus hossza legalább egy nap legyen.', 1;

    IF (SELECT COUNT(*) FROM @Days) <> @PeriodLengthDays
       OR (SELECT MIN(DayOfPeriod) FROM @Days) <> 1
       OR (SELECT MAX(DayOfPeriod) FROM @Days) <> @PeriodLengthDays
        THROW 50062, N'A ciklus napjainak sorszáma vagy darabszáma hibás.', 1;

    IF EXISTS
    (
        SELECT 1
        FROM @Days AS d
        LEFT JOIN dbo.DayType AS dt
            ON dt.DayTypeId = d.DayTypeId
        WHERE dt.DayTypeId IS NULL
    )
        THROW 50063, N'A ciklus olyan nap típust tartalmaz, amely nem található.', 1;

    DECLARE @WorkScheduleId INT;

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO dbo.WorkSchedule
        (
            Name,
            PeriodLengthDays,
            IsActive
        )
        VALUES
        (
            @Name,
            @PeriodLengthDays,
            1
        );

        SET @WorkScheduleId = CONVERT(INT, SCOPE_IDENTITY());

        INSERT INTO dbo.WorkScheduleDay
        (
            WorkScheduleId,
            DayOfPeriod,
            DayTypeId
        )
        SELECT
            @WorkScheduleId,
            DayOfPeriod,
            DayTypeId
        FROM @Days;

        COMMIT TRANSACTION;

        SELECT @WorkScheduleId AS WorkScheduleId;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH;
END;
GO
/****** Object:  StoredProcedure [dbo].[usp_WorkSchedule_GetById]    Script Date: 2026. 11. 10. 21:19:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[usp_WorkSchedule_GetById]
    @WorkScheduleId INT
AS
BEGIN
    SET NOCOUNT ON;

    IF @WorkScheduleId <= 0
        THROW 50071, N'Érvénytelen munkarend-azonosító.', 1;

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.WorkSchedule
        WHERE WorkScheduleId = @WorkScheduleId
    )
        THROW 50072, N'A munkarend nem található.', 1;

    SELECT
        WorkScheduleId,
        Name,
        PeriodLengthDays,
        IsActive
    FROM dbo.WorkSchedule
    WHERE WorkScheduleId = @WorkScheduleId;

    SELECT
        wsd.DayOfPeriod,
        dt.DayTypeId,
        dt.Code AS DayTypeCode,
        dt.Name AS DayTypeName,
        dt.IsWorkday,
        dt.StartTime,
        dt.EndTime,
        dt.BreakMinutes
    FROM dbo.WorkScheduleDay AS wsd
    INNER JOIN dbo.DayType AS dt
        ON dt.DayTypeId = wsd.DayTypeId
    WHERE wsd.WorkScheduleId = @WorkScheduleId
    ORDER BY wsd.DayOfPeriod;
END;
GO
/****** Object:  StoredProcedure [dbo].[usp_WorkSchedule_Search]    Script Date: 2026. 11. 10. 21:19:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[usp_WorkSchedule_Search]
    @Search NVARCHAR(100) = NULL,
    @IsActive BIT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SET @Search = NULLIF(LTRIM(RTRIM(@Search)), N'');

    SELECT
        ws.WorkScheduleId,
        ws.Name,
        ws.PeriodLengthDays,
        ws.IsActive,
        COUNT(wsd.DayOfPeriod) AS ConfiguredDays
    FROM dbo.WorkSchedule AS ws
    LEFT JOIN dbo.WorkScheduleDay AS wsd
        ON wsd.WorkScheduleId = ws.WorkScheduleId
    WHERE
        (
            @Search IS NULL
            OR ws.Name LIKE N'%' + @Search + N'%'
        )
        AND
        (
            @IsActive IS NULL
            OR ws.IsActive = @IsActive
        )
    GROUP BY
        ws.WorkScheduleId,
        ws.Name,
        ws.PeriodLengthDays,
        ws.IsActive
    ORDER BY
        ws.Name;
END;
GO
/****** Object:  StoredProcedure [dbo].[usp_WorkSchedule_Update]    Script Date: 2026. 11. 10. 21:19:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[usp_WorkSchedule_Update]
    @WorkScheduleId INT,
    @Name NVARCHAR(100),
    @PeriodLengthDays INT,
    @IsActive BIT,
    @Days dbo.WorkScheduleDayInputType READONLY
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF @WorkScheduleId <= 0
        THROW 50064, N'Érvénytelen munkarend-azonosító.', 1;

    SET @Name = LTRIM(RTRIM(@Name));

    IF @Name IS NULL OR @Name = N''
        THROW 50065, N'A munkarend neve nem lehet üres.', 1;

    IF @PeriodLengthDays <= 0
        THROW 50066, N'A ciklus hossza legalább egy nap legyen.', 1;

    IF @IsActive IS NULL
        THROW 50067, N'Meg kell adni a munkarend aktív állapotát.', 1;

    IF (SELECT COUNT(*) FROM @Days) <> @PeriodLengthDays
       OR (SELECT MIN(DayOfPeriod) FROM @Days) <> 1
       OR (SELECT MAX(DayOfPeriod) FROM @Days) <> @PeriodLengthDays
        THROW 50068, N'A ciklus napjainak sorszáma vagy darabszáma hibás.', 1;

    IF EXISTS
    (
        SELECT 1
        FROM @Days AS d
        LEFT JOIN dbo.DayType AS dt
            ON dt.DayTypeId = d.DayTypeId
        WHERE dt.DayTypeId IS NULL
    )
        THROW 50069, N'A ciklus olyan nap típust tartalmaz, amely nem található.', 1;

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.WorkSchedule
        WHERE WorkScheduleId = @WorkScheduleId
    )
        THROW 50070, N'A munkarend nem található.', 1;

    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE dbo.WorkSchedule
        SET
            Name = @Name,
            PeriodLengthDays = @PeriodLengthDays,
            IsActive = @IsActive
        WHERE WorkScheduleId = @WorkScheduleId;

        DELETE FROM dbo.WorkScheduleDay
        WHERE WorkScheduleId = @WorkScheduleId;

        INSERT INTO dbo.WorkScheduleDay
        (
            WorkScheduleId,
            DayOfPeriod,
            DayTypeId
        )
        SELECT
            @WorkScheduleId,
            DayOfPeriod,
            DayTypeId
        FROM @Days;

        COMMIT TRANSACTION;

        SELECT @WorkScheduleId AS WorkScheduleId;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH;
END;
GO
