USE [PY_2]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Object:  StoredProcedure [dbo].[usp_MasterDataGroup_Create]    Script Date: 2026. 11. 10. 21:19:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[usp_MasterDataGroup_Create]
    @Code NVARCHAR(4000),
    @Name NVARCHAR(4000)
AS
BEGIN
    SET NOCOUNT ON;

    SET @Code = LTRIM(RTRIM(@Code));
    SET @Name = LTRIM(RTRIM(@Name));

    IF @Code IS NULL OR @Code = N'' OR LEN(@Code) > 50
        THROW 51101, 'A csoportkód nem lehet üres, és legfeljebb 50 karakter lehet.', 1;

    IF @Name IS NULL OR @Name = N'' OR LEN(@Name) > 100
        THROW 51102, 'A csoport neve nem lehet üres, és legfeljebb 100 karakter lehet.', 1;

    INSERT INTO dbo.MasterDataGroup (Code, Name)
    VALUES (@Code, @Name);

    SELECT CONVERT(INT, SCOPE_IDENTITY()) AS MasterDataGroupId;
END;
GO
/****** Object:  StoredProcedure [dbo].[usp_MasterDataGroup_GetAccessByUserId]    Script Date: 2026. 11. 10. 21:19:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[usp_MasterDataGroup_GetAccessByUserId]
    @UserId INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @AccessDate DATE = CONVERT(DATE, GETDATE());

    IF @UserId <= 0
        THROW 50310, N'Érvénytelen felhasználó-azonosító.', 1;

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.[User]
        WHERE UserId = @UserId
          AND IsActive = 1
    )
        THROW 50311, N'A felhasználó nem található vagy inaktív.', 1;

    SELECT DISTINCT
        dataGroup.MasterDataGroupId,
        dataGroup.Code AS MasterDataGroupCode,
        dataGroup.Name AS MasterDataGroupName,
        userRole.RoleId,
        userRole.Code AS RoleCode,
        userRole.RoleName,
        permission.CanRead,
        permission.CanEdit
    FROM dbo.RoleToUser AS roleToUser
    INNER JOIN dbo.[Role] AS userRole
        ON userRole.RoleId = roleToUser.RoleId
       AND userRole.IsActive = 1
    INNER JOIN dbo.MDGToRole AS permission
        ON permission.RoleId = userRole.RoleId
    INNER JOIN dbo.MasterDataGroup AS dataGroup
        ON dataGroup.MasterDataGroupId = permission.MasterDataGroupId
    WHERE roleToUser.UserId = @UserId
      AND roleToUser.ValidFrom <= @AccessDate
      AND
      (
          roleToUser.ValidTo IS NULL
          OR roleToUser.ValidTo >= @AccessDate
      )
      AND
      (
          permission.CanRead = 1
          OR permission.CanEdit = 1
      )
    ORDER BY
        dataGroup.Name,
        userRole.RoleName,
        userRole.RoleId;
END;
GO
/****** Object:  StoredProcedure [dbo].[usp_MasterDataGroup_GetAll]    Script Date: 2026. 11. 10. 21:19:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[usp_MasterDataGroup_GetAll]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        MasterDataGroupId,
        Code,
        Name
    FROM dbo.MasterDataGroup
    ORDER BY Name, Code;
END;
GO
/****** Object:  StoredProcedure [dbo].[usp_MasterDataGroup_Update]    Script Date: 2026. 11. 10. 21:19:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[usp_MasterDataGroup_Update]
    @MasterDataGroupId INT,
    @Code NVARCHAR(4000),
    @Name NVARCHAR(4000)
AS
BEGIN
    SET NOCOUNT ON;

    IF @MasterDataGroupId <= 0
        THROW 51103, 'Érvénytelen törzsadatcsoport-azonosító.', 1;

    SET @Code = LTRIM(RTRIM(@Code));
    SET @Name = LTRIM(RTRIM(@Name));

    IF @Code IS NULL OR @Code = N'' OR LEN(@Code) > 50
        THROW 51101, 'A csoportkód nem lehet üres, és legfeljebb 50 karakter lehet.', 1;

    IF @Name IS NULL OR @Name = N'' OR LEN(@Name) > 100
        THROW 51102, 'A csoport neve nem lehet üres, és legfeljebb 100 karakter lehet.', 1;

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.MasterDataGroup
        WHERE MasterDataGroupId = @MasterDataGroupId
    )
        THROW 51104, 'A törzsadatcsoport nem található.', 1;

    UPDATE dbo.MasterDataGroup
    SET Code = @Code,
        Name = @Name
    WHERE MasterDataGroupId = @MasterDataGroupId;
END;
GO
/****** Object:  StoredProcedure [dbo].[usp_MDGToRole_GetByRoleId]    Script Date: 2026. 11. 10. 21:19:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[usp_MDGToRole_GetByRoleId]
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
        THROW 50033, 'A szerep nem található.', 1;
    END;

    SELECT
        @RoleId AS RoleId,
        mdg.MasterDataGroupId,
        mdg.Code,
        mdg.[Name],
        ISNULL(permission.CanRead, 0) AS CanRead,
        ISNULL(permission.CanEdit, 0) AS CanEdit
    FROM dbo.MasterDataGroup AS mdg
    LEFT JOIN dbo.MDGToRole AS permission
        ON permission.MasterDataGroupId = mdg.MasterDataGroupId
       AND permission.RoleId = @RoleId
    ORDER BY mdg.[Name], mdg.MasterDataGroupId;
END;
GO
/****** Object:  StoredProcedure [dbo].[usp_MDGToRole_SetPermissions]    Script Date: 2026. 11. 10. 21:19:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[usp_MDGToRole_SetPermissions]
    @RoleId INT,
    @MasterDataGroupId INT,
    @CanRead BIT,
    @CanEdit BIT
AS
BEGIN
    SET NOCOUNT ON;

    IF @CanEdit = 1 AND @CanRead = 0
    BEGIN
        THROW 50032, 'Szerkesztési jog csak olvasási joggal együtt adható.', 1;
    END;

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.[Role]
        WHERE RoleId = @RoleId
          AND IsActive = 1
    )
    BEGIN
        THROW 50030, 'Az aktív szerep nem található.', 1;
    END;

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.MasterDataGroup
        WHERE MasterDataGroupId = @MasterDataGroupId
    )
    BEGIN
        THROW 50031, 'A törzsadatcsoport nem található.', 1;
    END;

    IF EXISTS
    (
        SELECT 1
        FROM dbo.MDGToRole
        WHERE RoleId = @RoleId
          AND MasterDataGroupId = @MasterDataGroupId
    )
    BEGIN
        UPDATE dbo.MDGToRole
        SET
            CanRead = @CanRead,
            CanEdit = @CanEdit
        WHERE RoleId = @RoleId
          AND MasterDataGroupId = @MasterDataGroupId;
    END
    ELSE
    BEGIN
        INSERT INTO dbo.MDGToRole
        (
            RoleId,
            MasterDataGroupId,
            CanRead,
            CanEdit
        )
        VALUES
        (
            @RoleId,
            @MasterDataGroupId,
            @CanRead,
            @CanEdit
        );
    END;
END;
GO
/****** Object:  StoredProcedure [dbo].[usp_PayrollElement_Create]    Script Date: 2026. 11. 10. 21:19:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[usp_PayrollElement_Create]
    @Code NVARCHAR(50),
    @Name NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    SET @Code = NULLIF(LTRIM(RTRIM(@Code)), N'');
    SET @Name = NULLIF(LTRIM(RTRIM(@Name)), N'');

    IF @Code IS NULL OR @Name IS NULL
        THROW 50400, N'A bérelem kódja és neve kötelező.', 1;

    INSERT INTO dbo.PayrollElement (Code, Name, IsActive)
    VALUES (@Code, @Name, 1);

    SELECT CONVERT(INT, SCOPE_IDENTITY()) AS PayrollElementId;
END;
GO
/****** Object:  StoredProcedure [dbo].[usp_PayrollElement_GetById]    Script Date: 2026. 11. 10. 21:19:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[usp_PayrollElement_GetById]
    @PayrollElementId INT
AS
BEGIN
    SET NOCOUNT ON;

    IF @PayrollElementId <= 0
        THROW 50400, N'Érvénytelen bérelem-azonosító.', 1;

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.PayrollElement
        WHERE PayrollElementId = @PayrollElementId
    )
        THROW 50402, N'A bérelem nem található.', 1;

    SELECT
        PayrollElementId,
        Code,
        Name,
        IsActive
    FROM dbo.PayrollElement
    WHERE PayrollElementId = @PayrollElementId;
END;
GO
/****** Object:  StoredProcedure [dbo].[usp_PayrollElement_Search]    Script Date: 2026. 11. 10. 21:19:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[usp_PayrollElement_Search]
    @Search NVARCHAR(100) = NULL,
    @IsActive BIT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SET @Search = NULLIF(LTRIM(RTRIM(@Search)), N'');

    SELECT
        PayrollElementId,
        Code,
        Name,
        IsActive
    FROM dbo.PayrollElement
    WHERE
        (
            @Search IS NULL
            OR Code LIKE N'%' + @Search + N'%'
            OR Name LIKE N'%' + @Search + N'%'
        )
        AND (@IsActive IS NULL OR IsActive = @IsActive)
    ORDER BY Code;
END;
GO
/****** Object:  StoredProcedure [dbo].[usp_PayrollElement_Update]    Script Date: 2026. 11. 10. 21:19:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[usp_PayrollElement_Update]
    @PayrollElementId INT,
    @Code NVARCHAR(50),
    @Name NVARCHAR(100),
    @IsActive BIT
AS
BEGIN
    SET NOCOUNT ON;

    SET @Code = NULLIF(LTRIM(RTRIM(@Code)), N'');
    SET @Name = NULLIF(LTRIM(RTRIM(@Name)), N'');

    IF @PayrollElementId <= 0
        THROW 50400, N'Érvénytelen bérelem-azonosító.', 1;

    IF @Code IS NULL OR @Name IS NULL OR @IsActive IS NULL
        THROW 50401, N'A bérelem kódja, neve és aktív állapota kötelező.', 1;

    UPDATE dbo.PayrollElement
    SET
        Code = @Code,
        Name = @Name,
        IsActive = @IsActive
    WHERE PayrollElementId = @PayrollElementId;

    IF @@ROWCOUNT = 0
        THROW 50402, N'A bérelem nem található.', 1;

    SELECT
        PayrollElementId,
        Code,
        Name,
        IsActive
    FROM dbo.PayrollElement
    WHERE PayrollElementId = @PayrollElementId;
END;
GO
/****** Object:  StoredProcedure [dbo].[usp_PayrollElementFieldValue_End]    Script Date: 2026. 11. 10. 21:19:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[usp_PayrollElementFieldValue_End]
    @PayrollElementId INT,
    @FieldId INT,
    @ValidTo DATE,
    @UserId INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @Today DATE = CONVERT(DATE, GETDATE());
    DECLARE @MasterDataGroupId INT;

    IF @PayrollElementId <= 0 OR @FieldId <= 0 OR @UserId <= 0
        THROW 50540, N'Érvénytelen bérelem-, mező- vagy felhasználó-azonosító.', 1;

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.[User]
        WHERE UserId = @UserId
          AND IsActive = 1
    )
        THROW 50541, N'A felhasználó nem található vagy inaktív.', 1;

    SELECT @MasterDataGroupId = field.MasterDataGroupId
    FROM dbo.MasterDataField AS field
    INNER JOIN dbo.MasterDataGroup AS dataGroup
        ON dataGroup.MasterDataGroupId = field.MasterDataGroupId
    WHERE field.FieldId = @FieldId
      AND field.IsActive = 1
      AND dataGroup.Code LIKE N'PAYROLL%';

    IF @MasterDataGroupId IS NULL
        THROW 50543, N'A mező nem található vagy nem használható bérelemhez.', 1;

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.RoleToUser AS roleToUser
        INNER JOIN dbo.[Role] AS userRole
            ON userRole.RoleId = roleToUser.RoleId
           AND userRole.IsActive = 1
        INNER JOIN dbo.MDGToRole AS permission
            ON permission.RoleId = userRole.RoleId
           AND permission.MasterDataGroupId = @MasterDataGroupId
           AND permission.CanEdit = 1
        WHERE roleToUser.UserId = @UserId
          AND roleToUser.ValidFrom <= @Today
          AND
          (
              roleToUser.ValidTo IS NULL
              OR roleToUser.ValidTo >= @Today
          )
    )
        THROW 50542, N'A felhasználónak nincs szerkesztési joga ehhez a törzsadatcsoporthoz.', 1;

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.PayrollElementFieldValue
        WHERE PayrollElementId = @PayrollElementId
          AND FieldId = @FieldId
          AND ValidFrom <= @ValidTo
          AND (ValidTo IS NULL OR ValidTo >= @ValidTo)
    )
        THROW 50544, N'Az adott napon érvényes mezőérték nem található.', 1;

    UPDATE dbo.PayrollElementFieldValue
    SET ValidTo = @ValidTo
    WHERE PayrollElementId = @PayrollElementId
      AND FieldId = @FieldId
      AND ValidFrom <= @ValidTo
      AND (ValidTo IS NULL OR ValidTo > @ValidTo);

    SELECT TOP (1)
        PayrollElementId,
        FieldId,
        FieldValue,
        OptionId,
        ValidFrom,
        ValidTo
    FROM dbo.PayrollElementFieldValue
    WHERE PayrollElementId = @PayrollElementId
      AND FieldId = @FieldId
      AND ValidFrom <= @ValidTo
      AND ValidTo = @ValidTo
    ORDER BY ValidFrom DESC;
END;
GO
/****** Object:  StoredProcedure [dbo].[usp_PayrollElementFieldValue_GetByPayrollElementId]    Script Date: 2026. 11. 10. 21:19:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[usp_PayrollElementFieldValue_GetByPayrollElementId]      @PayrollElementId INT,      @UserId INT,      @AsOfDate DATE = NULL  AS  BEGIN      SET NOCOUNT ON;        DECLARE @PermissionDate DATE = CONVERT(DATE, GETDATE());      SET @AsOfDate = COALESCE(@AsOfDate, @PermissionDate);        IF @PayrollElementId <= 0 OR @UserId <= 0          THROW 50500, N'Érvénytelen bérelem- vagy felhasználó-azonosító.', 1;        IF NOT EXISTS      (          SELECT 1          FROM dbo.[User]          WHERE UserId = @UserId            AND IsActive = 1      )          THROW 50501, N'A felhasználó nem található vagy inaktív.', 1;        IF NOT EXISTS      (          SELECT 1          FROM dbo.PayrollElement          WHERE PayrollElementId = @PayrollElementId      )          THROW 50502, N'A bérelem nem található.', 1;        CREATE TABLE #GroupPermissions      (          MasterDataGroupId INT NOT NULL PRIMARY KEY,          CanRead BIT NOT NULL,          CanEdit BIT NOT NULL      );        INSERT INTO #GroupPermissions      (          MasterDataGroupId,          CanRead,          CanEdit      )      SELECT          permission.MasterDataGroupId,          CONVERT(BIT, MAX(CONVERT(INT, permission.CanRead))),          CONVERT(BIT, MAX(CONVERT(INT, permission.CanEdit)))      FROM dbo.RoleToUser AS roleToUser      INNER JOIN dbo.[Role] AS userRole          ON userRole.RoleId = roleToUser.RoleId         AND userRole.IsActive = 1      INNER JOIN dbo.MDGToRole AS permission          ON permission.RoleId = userRole.RoleId      WHERE roleToUser.UserId = @UserId        AND roleToUser.ValidFrom <= @PermissionDate        AND        (            roleToUser.ValidTo IS NULL            OR roleToUser.ValidTo >= @PermissionDate        )      GROUP BY permission.MasterDataGroupId;        CREATE TABLE #AllowedFields      (          FieldId INT NOT NULL PRIMARY KEY,          MasterDataGroupId INT NOT NULL,          CanRead BIT NOT NULL,          CanEdit BIT NOT NULL      );        INSERT INTO #AllowedFields      (          FieldId,          MasterDataGroupId,          CanRead,          CanEdit      )      SELECT          field.FieldId,          field.MasterDataGroupId,          permission.CanRead,          permission.CanEdit      FROM dbo.MasterDataField AS field      INNER JOIN dbo.MasterDataGroup AS dataGroup          ON dataGroup.MasterDataGroupId = field.MasterDataGroupId      INNER JOIN #GroupPermissions AS permission          ON permission.MasterDataGroupId = field.MasterDataGroupId      WHERE field.IsActive = 1        AND dataGroup.Code LIKE N'PAYROLLELEMENT[_]%'   AND field.Code LIKE N'PAYROLLELEMENT[_]%'       AND permission.CanRead = 1;        SELECT          dataGroup.MasterDataGroupId,          dataGroup.Code AS MasterDataGroupCode,          dataGroup.Name AS MasterDataGroupName,          field.FieldId,          field.Code,          field.DisplayName,          field.FieldTypeId,          fieldType.Code AS FieldTypeCode,          fieldType.Name AS FieldTypeName,          field.IsRequired,          field.IsUnique,          field.DisplayOrder,          allowedField.CanRead,          allowedField.CanEdit,          fieldValue.FieldValue,          fieldValue.OptionId,          fieldValue.ValidFrom,          fieldValue.ValidTo      FROM #AllowedFields AS allowedField      INNER JOIN dbo.MasterDataField AS field          ON field.FieldId = allowedField.FieldId      INNER JOIN dbo.MasterDataGroup AS dataGroup          ON dataGroup.MasterDataGroupId = field.MasterDataGroupId      INNER JOIN dbo.FieldType AS fieldType          ON fieldType.FieldTypeId = field.FieldTypeId      OUTER APPLY      (          SELECT TOP (1)              value.FieldValue,              value.OptionId,              value.ValidFrom,              value.ValidTo          FROM dbo.PayrollElementFieldValue AS value          WHERE value.PayrollElementId = @PayrollElementId            AND value.FieldId = field.FieldId            AND value.ValidFrom <= @AsOfDate            AND            (                value.ValidTo IS NULL                OR value.ValidTo >= @AsOfDate            )          ORDER BY value.ValidFrom DESC      ) AS fieldValue      ORDER BY          dataGroup.Name,          field.DisplayOrder,          field.DisplayName;        SELECT          optionValue.FieldId,          optionValue.OptionId,          optionValue.OptionCode,          optionValue.DisplayName,          optionValue.SortOrder      FROM dbo.MasterDataFieldOption AS optionValue      INNER JOIN #AllowedFields AS allowedField          ON allowedField.FieldId = optionValue.FieldId      WHERE optionValue.IsActive = 1      ORDER BY          optionValue.FieldId,          optionValue.SortOrder,          optionValue.DisplayName;  END;
GO
/****** Object:  StoredProcedure [dbo].[usp_PayrollElementFieldValue_GetHistory]    Script Date: 2026. 11. 10. 21:19:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[usp_PayrollElementFieldValue_GetHistory]
    @PayrollElementId INT,
    @FieldId INT,
    @UserId INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @PermissionDate DATE = CONVERT(DATE, GETDATE());
    DECLARE @MasterDataGroupId INT = NULL;

    IF @PayrollElementId <= 0 OR @FieldId <= 0 OR @UserId <= 0
        THROW 50500, N'Érvénytelen bérelem-, tulajdonság- vagy felhasználó-azonosító.', 1;

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.[User]
        WHERE UserId = @UserId
          AND IsActive = 1
    )
        THROW 50501, N'A felhasználó nem található vagy inaktív.', 1;

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.PayrollElement
        WHERE PayrollElementId = @PayrollElementId
    )
        THROW 50502, N'A bérelem nem található.', 1;

    SELECT
        @MasterDataGroupId = field.MasterDataGroupId
    FROM dbo.MasterDataField AS field
    INNER JOIN dbo.MasterDataGroup AS dataGroup
        ON dataGroup.MasterDataGroupId = field.MasterDataGroupId
    WHERE field.FieldId = @FieldId
      AND field.Code LIKE N'PAYROLLELEMENT[_]%'
      AND dataGroup.Code LIKE N'PAYROLLELEMENT[_]%';

    IF @MasterDataGroupId IS NULL
        THROW 50503, N'A bérelem-tulajdonság nem található.', 1;

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.RoleToUser AS roleToUser
        INNER JOIN dbo.[Role] AS userRole
            ON userRole.RoleId = roleToUser.RoleId
           AND userRole.IsActive = 1
        INNER JOIN dbo.MDGToRole AS permission
            ON permission.RoleId = userRole.RoleId
           AND permission.MasterDataGroupId = @MasterDataGroupId
           AND permission.CanRead = 1
        WHERE roleToUser.UserId = @UserId
          AND roleToUser.ValidFrom <= @PermissionDate
          AND
          (
              roleToUser.ValidTo IS NULL
              OR roleToUser.ValidTo >= @PermissionDate
          )
    )
        THROW 50504, N'Nincs jogosultság a bérelem-tulajdonság előzményeinek megtekintéséhez.', 1;

    SELECT
        fieldValue.FieldValue,
        fieldValue.OptionId,
        optionValue.OptionCode,
        optionValue.DisplayName AS OptionDisplayName,
        COALESCE(
            optionValue.DisplayName,
            optionValue.OptionCode,
            fieldValue.FieldValue
        ) AS DisplayValue,
        fieldValue.ValidFrom,
        fieldValue.ValidTo
    FROM dbo.PayrollElementFieldValue AS fieldValue
    LEFT JOIN dbo.MasterDataFieldOption AS optionValue
        ON optionValue.OptionId = fieldValue.OptionId
       AND optionValue.FieldId = fieldValue.FieldId
    WHERE fieldValue.PayrollElementId = @PayrollElementId
      AND fieldValue.FieldId = @FieldId
    ORDER BY
        fieldValue.ValidFrom ASC,
        fieldValue.ValidTo ASC;
END;
GO
/****** Object:  StoredProcedure [dbo].[usp_PayrollElementFieldValue_Save]    Script Date: 2026. 11. 10. 21:19:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[usp_PayrollElementFieldValue_Save]
    @PayrollElementId INT,
    @FieldId INT,
    @FieldValue NVARCHAR(4000) = NULL,
    @OptionId INT = NULL,
    @ValidFrom DATE,
    @ValidTo DATE = NULL,
    @UserId INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @Today DATE = CONVERT(DATE, GETDATE());
    DECLARE @FieldTypeCode NVARCHAR(60);
    DECLARE @IsRequired BIT;
    DECLARE @IsUnique BIT;
    DECLARE @MasterDataGroupId INT;
    DECLARE @NextValidFrom DATE;
    DECLARE @EffectiveValidTo DATE = @ValidTo;

    IF @PayrollElementId <= 0 OR @FieldId <= 0 OR @UserId <= 0
        THROW 50520, N'Érvénytelen bérelem-, mező- vagy felhasználó-azonosító.', 1;

    IF @ValidTo IS NOT NULL AND @ValidTo < @ValidFrom
        THROW 50521, N'Az érvényesség vége nem lehet korábbi a kezdeténél.', 1;

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.[User]
        WHERE UserId = @UserId
          AND IsActive = 1
    )
        THROW 50522, N'A felhasználó nem található vagy inaktív.', 1;

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.PayrollElement
        WHERE PayrollElementId = @PayrollElementId
          AND IsActive = 1
    )
        THROW 50523, N'Az aktív bérelem nem található.', 1;

    SELECT
        @FieldTypeCode = fieldType.Code,
        @IsRequired = field.IsRequired,
        @IsUnique = field.IsUnique,
        @MasterDataGroupId = field.MasterDataGroupId
    FROM dbo.MasterDataField AS field
    INNER JOIN dbo.MasterDataGroup AS dataGroup
        ON dataGroup.MasterDataGroupId = field.MasterDataGroupId
    INNER JOIN dbo.FieldType AS fieldType
        ON fieldType.FieldTypeId = field.FieldTypeId
    WHERE field.FieldId = @FieldId
      AND field.IsActive = 1
      AND dataGroup.Code LIKE N'PAYROLL%';

    IF @FieldTypeCode IS NULL
        THROW 50524, N'A mező nem található vagy nem használható bérelemhez.', 1;

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.RoleToUser AS roleToUser
        INNER JOIN dbo.[Role] AS userRole
            ON userRole.RoleId = roleToUser.RoleId
           AND userRole.IsActive = 1
        INNER JOIN dbo.MDGToRole AS permission
            ON permission.RoleId = userRole.RoleId
           AND permission.MasterDataGroupId = @MasterDataGroupId
           AND permission.CanEdit = 1
        WHERE roleToUser.UserId = @UserId
          AND roleToUser.ValidFrom <= @Today
          AND
          (
              roleToUser.ValidTo IS NULL
              OR roleToUser.ValidTo >= @Today
          )
    )
        THROW 50525, N'A felhasználónak nincs szerkesztési joga ehhez a törzsadatcsoporthoz.', 1;

    IF @FieldTypeCode = N'LIST'
    BEGIN
        IF @OptionId IS NULL OR @FieldValue IS NOT NULL
            THROW 50526, N'Lista típusú mezőnél aktív listaopciót kell megadni.', 1;

        IF NOT EXISTS
        (
            SELECT 1
            FROM dbo.MasterDataFieldOption
            WHERE FieldId = @FieldId
              AND OptionId = @OptionId
              AND IsActive = 1
        )
            THROW 50527, N'A listaopció nem található vagy inaktív.', 1;
    END
    ELSE
    BEGIN
        IF @OptionId IS NOT NULL OR @FieldValue IS NULL
            THROW 50528, N'Ehhez a mezőtípushoz szöveges értéket kell megadni listaopció nélkül.', 1;

        IF @IsRequired = 1 AND LEN(LTRIM(RTRIM(@FieldValue))) = 0
            THROW 50529, N'A mező kitöltése kötelező.', 1;

        IF @FieldTypeCode = N'NUMBER'
           AND TRY_CONVERT(DECIMAL(38, 10), @FieldValue) IS NULL
            THROW 50530, N'A mező értéke nem érvényes szám.', 1;

        IF @FieldTypeCode = N'DATE'
           AND TRY_CONVERT(DATE, @FieldValue, 23) IS NULL
            THROW 50531, N'A dátumot yyyy-MM-dd formátumban kell megadni.', 1;

        IF @FieldTypeCode = N'BOOLEAN'
           AND LOWER(@FieldValue) NOT IN (N'true', N'false', N'1', N'0')
            THROW 50532, N'Az érték true, false, 1 vagy 0 lehet.', 1;
    END;

    BEGIN TRY
        BEGIN TRANSACTION;

        SELECT @NextValidFrom = MIN(ValidFrom)
        FROM dbo.PayrollElementFieldValue WITH (UPDLOCK, HOLDLOCK)
        WHERE PayrollElementId = @PayrollElementId
          AND FieldId = @FieldId
          AND ValidFrom > @ValidFrom;

        IF @NextValidFrom IS NOT NULL
           AND (@EffectiveValidTo IS NULL OR @EffectiveValidTo >= @NextValidFrom)
        BEGIN
            SET @EffectiveValidTo = DATEADD(DAY, -1, @NextValidFrom);
        END;

        IF @EffectiveValidTo IS NOT NULL
           AND @EffectiveValidTo < @ValidFrom
            THROW 50533, N'Az új érvényességi időszak nem fér el a következő rögzített érték előtt.', 1;

        IF @IsUnique = 1
           AND EXISTS
           (
               SELECT 1
               FROM dbo.PayrollElementFieldValue AS existingValue
                   WITH (UPDLOCK, HOLDLOCK)
               WHERE existingValue.FieldId = @FieldId
                 AND existingValue.PayrollElementId <> @PayrollElementId
                 AND
                 (
                     ( @OptionId IS NOT NULL
                       AND existingValue.OptionId = @OptionId )
                     OR
                     ( @OptionId IS NULL
                       AND existingValue.FieldValue = @FieldValue )
                 )
                 AND existingValue.ValidFrom
                     <= COALESCE(@EffectiveValidTo, CONVERT(DATE, '99991231'))
                 AND COALESCE(existingValue.ValidTo, CONVERT(DATE, '99991231'))
                     >= @ValidFrom
           )
            THROW 50534, N'Ez az egyedi mezőérték másik bérelemnél már érvényes ebben az időszakban.', 1;

        UPDATE dbo.PayrollElementFieldValue
        SET ValidTo = DATEADD(DAY, -1, @ValidFrom)
        WHERE PayrollElementId = @PayrollElementId
          AND FieldId = @FieldId
          AND ValidFrom < @ValidFrom
          AND (ValidTo IS NULL OR ValidTo >= @ValidFrom);

        IF EXISTS
        (
            SELECT 1
            FROM dbo.PayrollElementFieldValue
            WHERE PayrollElementId = @PayrollElementId
              AND FieldId = @FieldId
              AND ValidFrom = @ValidFrom
        )
        BEGIN
            UPDATE dbo.PayrollElementFieldValue
            SET
                FieldValue = @FieldValue,
                OptionId = @OptionId,
                ValidTo = @EffectiveValidTo
            WHERE PayrollElementId = @PayrollElementId
              AND FieldId = @FieldId
              AND ValidFrom = @ValidFrom;
        END
        ELSE
        BEGIN
            INSERT INTO dbo.PayrollElementFieldValue
            (
                PayrollElementId,
                FieldId,
                FieldValue,
                OptionId,
                ValidFrom,
                ValidTo
            )
            VALUES
            (
                @PayrollElementId,
                @FieldId,
                @FieldValue,
                @OptionId,
                @ValidFrom,
                @EffectiveValidTo
            );
        END;

        COMMIT TRANSACTION;

        SELECT
            PayrollElementId,
            FieldId,
            FieldValue,
            OptionId,
            ValidFrom,
            ValidTo
        FROM dbo.PayrollElementFieldValue
        WHERE PayrollElementId = @PayrollElementId
          AND FieldId = @FieldId
          AND ValidFrom = @ValidFrom;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH;
END;
GO
/****** Object:  StoredProcedure [dbo].[usp_PayrollRun_GetPreviousPeriodResults]    Script Date: 2026. 11. 10. 21:19:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_PayrollRun_GetPreviousPeriodResults]
    @EmployeeId INT,
    @Period CHAR(6)
AS
BEGIN
    SET NOCOUNT ON;

    IF @EmployeeId <= 0
        THROW 50510, N'Érvénytelen munkavállaló-azonosító.', 1;

    DECLARE @PeriodStart DATE =
        TRY_CONVERT(DATE, RTRIM(@Period) + '01', 112);

    IF @PeriodStart IS NULL
       OR CONVERT(CHAR(6), @PeriodStart, 112) <> RTRIM(@Period)
        THROW 50511, N'A periódust yyyyMM formátumban kell megadni.', 1;

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.Employee
        WHERE EmployeeId = @EmployeeId
    )
        THROW 50512, N'A munkavállaló nem található.', 1;

    ;WITH LatestRunPerPeriod AS
    (
        SELECT
            result.Period,
            result.RunId,
            ROW_NUMBER() OVER
            (
                PARTITION BY result.Period
                ORDER BY
                    result.RunDate DESC,
                    result.PayrollResultId DESC
            ) AS RunNumber
        FROM dbo.PayrollResult AS result
        WHERE result.EmployeeId = @EmployeeId
          AND result.Period <= RTRIM(@Period)
    )
    SELECT
        latest.RunId AS PreviousRunId,
        CONVERT(DATE, RTRIM(latest.Period) + '01', 112) AS Period,
        result.PayrollElementId,
        element.Code AS PayrollElementCode,
        element.Name AS PayrollElementName,
        result.ResultType,
        SUM(result.Amount) AS Amount
    FROM LatestRunPerPeriod AS latest
    INNER JOIN dbo.PayrollResult AS result
        ON result.RunId = latest.RunId
       AND result.Period = latest.Period
       AND result.EmployeeId = @EmployeeId
    INNER JOIN dbo.PayrollElement AS element
        ON element.PayrollElementId = result.PayrollElementId
    WHERE latest.RunNumber = 1
    GROUP BY
        latest.RunId,
        latest.Period,
        result.PayrollElementId,
        element.Code,
        element.Name,
        result.ResultType
    ORDER BY
        latest.Period,
        element.Code,
        result.ResultType;
END;
GO
/****** Object:  StoredProcedure [dbo].[usp_PayrollRun_LoadEmployeePeriodBaseData]    Script Date: 2026. 11. 10. 21:19:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_PayrollRun_LoadEmployeePeriodBaseData]
    @EmployeeId INT,
    @PeriodStart DATE
AS
BEGIN
    SET NOCOUNT ON;

    IF @EmployeeId <= 0
    BEGIN
        ;THROW 50410, N'Érvénytelen munkavállaló-azonosító.', 1;
    END;

    IF @PeriodStart IS NULL OR DAY(@PeriodStart) <> 1
    BEGIN
        ;THROW 50411, N'A periódus kezdete csak a hónap első napja lehet.', 1;
    END;

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.Employee
        WHERE EmployeeId = @EmployeeId
    )
    BEGIN
        ;THROW 50412, N'A munkavállaló nem található.', 1;
    END;

    DECLARE @PeriodEnd DATE = EOMONTH(@PeriodStart);

    -- 1. eredményhalmaz: dolgozó alapadatai, gyökéradatként.
    SELECT
        referenceData.Reference,
        referenceData.DataType,
        referenceData.Value
    FROM dbo.Employee AS employee
    CROSS APPLY
    (
        VALUES
            (N'dbo.Employee.EmployeeId', N'integer',
                CONVERT(NVARCHAR(MAX), employee.EmployeeId)),
            (N'dbo.Employee.FirstName', N'text',
                CONVERT(NVARCHAR(MAX), employee.FirstName)),
            (N'dbo.Employee.LastName', N'text',
                CONVERT(NVARCHAR(MAX), employee.LastName)),
            (N'dbo.Employee.BirthDate', N'date',
                CONVERT(NVARCHAR(MAX), employee.BirthDate, 23)),
            (N'dbo.Employee.IsActive', N'boolean',
                CONVERT(NVARCHAR(MAX), employee.IsActive)),
            (N'dbo.Employee.PersonalId', N'text',
                CONVERT(NVARCHAR(MAX), employee.PersonalId)),
            (N'dbo.Employee.TaxId', N'text',
                CONVERT(NVARCHAR(MAX), employee.TaxId)),
            (N'dbo.Employee.TAJId', N'text',
                CONVERT(NVARCHAR(MAX), employee.TAJId)),
            (N'dbo.Employee.Address', N'text',
                CONVERT(NVARCHAR(MAX), employee.Address)),
            (N'dbo.Employee.PayrollRunFrom', N'date',
                CONVERT(NVARCHAR(MAX), employee.PayrollRunFrom, 23)),
            (N'dbo.Employee.JoinDate', N'date',
                CONVERT(NVARCHAR(MAX), employee.JoinDate, 23))
    ) AS referenceData(Reference, DataType, Value)
    WHERE employee.EmployeeId = @EmployeeId;

    -- 2. eredményhalmaz: a hónappal átfedő munkaviszonyok és cégeik.
    SELECT
        N'employee.employments' AS CollectionReference,
        CONVERT(NVARCHAR(100), employment.EmploymentId) AS RowKey,
        referenceData.Reference,
        referenceData.DataType,
        referenceData.Value
    FROM dbo.Employment AS employment
    INNER JOIN dbo.Company AS company
        ON company.CompanyId = employment.CompanyId
    CROSS APPLY
    (
        VALUES
            (N'dbo.Employment.EmploymentId', N'integer',
                CONVERT(NVARCHAR(MAX), employment.EmploymentId)),
            (N'dbo.Employment.CompanyId', N'integer',
                CONVERT(NVARCHAR(MAX), employment.CompanyId)),
            (N'dbo.Employment.EmployeeId', N'integer',
                CONVERT(NVARCHAR(MAX), employment.EmployeeId)),
            (N'dbo.Employment.ValidFrom', N'date',
                CONVERT(NVARCHAR(MAX), employment.ValidFrom, 23)),
            (N'dbo.Employment.ValidTo', N'date',
                CONVERT(NVARCHAR(MAX), employment.ValidTo, 23)),
            (N'dbo.Company.CompanyId', N'integer',
                CONVERT(NVARCHAR(MAX), company.CompanyId)),
            (N'dbo.Company.CompanyName', N'text',
                CONVERT(NVARCHAR(MAX), company.CompanyName)),
            (N'dbo.Company.CompanyAddress', N'text',
                CONVERT(NVARCHAR(MAX), company.CompanyAddress)),
            (N'dbo.Company.BankAccountNumber', N'text',
                CONVERT(NVARCHAR(MAX), company.BankAccountNumber)),
            (N'dbo.Company.TaxId', N'text',
                CONVERT(NVARCHAR(MAX), company.TaxId)),
            (N'dbo.Company.PhoneNumber', N'text',
                CONVERT(NVARCHAR(MAX), company.PhoneNumber))
    ) AS referenceData(Reference, DataType, Value)
    WHERE employment.EmployeeId = @EmployeeId
      AND employment.ValidFrom <= @PeriodEnd
      AND
      (
          employment.ValidTo IS NULL
          OR employment.ValidTo >= @PeriodStart
      );

    -- 3. eredményhalmaz: a periódussal átfedő munkavállalói dinamikus mezők.
    -- A hivatkozás formája: Csoportkód.Mezőkód, például KIEGALAPADAT.TAVOL.
    SELECT
        N'employee.customFields' AS CollectionReference,
        CONCAT(
            value.FieldId,
            N'/',
            CONVERT(NVARCHAR(10), value.ValidFrom, 23)
        ) AS RowKey,
        CONCAT(
            dataGroup.Code,
            N'.',
            field.Code
        ) AS Reference,
        CASE fieldType.Code
            WHEN N'NUMBER' THEN N'decimal'
            WHEN N'DATE' THEN N'date'
            WHEN N'BOOLEAN' THEN N'boolean'
            ELSE N'text'
        END AS DataType,
        COALESCE(
            optionValue.OptionCode,
            value.FieldValue
        ) AS Value
    FROM dbo.EmployeeFieldValue AS value
    INNER JOIN dbo.MasterDataField AS field
        ON field.FieldId = value.FieldId
       AND field.IsActive = 1
    INNER JOIN dbo.MasterDataGroup AS dataGroup
        ON dataGroup.MasterDataGroupId = field.MasterDataGroupId
    INNER JOIN dbo.FieldType AS fieldType
        ON fieldType.FieldTypeId = field.FieldTypeId
    LEFT JOIN dbo.MasterDataFieldOption AS optionValue
        ON optionValue.FieldId = value.FieldId
       AND optionValue.OptionId = value.OptionId
    WHERE value.EmployeeId = @EmployeeId
      AND value.ValidFrom <= @PeriodEnd
      AND
      (
          value.ValidTo IS NULL
          OR value.ValidTo >= @PeriodStart
      )
    ORDER BY field.DisplayOrder, field.DisplayName, value.ValidFrom;
END;
GO
/****** Object:  StoredProcedure [dbo].[usp_PayrollRun_LoadEmployeePeriodExtendedData]    Script Date: 2026. 11. 10. 21:19:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_PayrollRun_LoadEmployeePeriodExtendedData]
    @EmployeeId INT,
    @PeriodStart DATE
AS
BEGIN
    SET NOCOUNT ON;

    IF @EmployeeId <= 0
    BEGIN
        ;THROW 50413, N'Érvénytelen munkavállaló-azonosító.', 1;
    END;

    IF @PeriodStart IS NULL OR DAY(@PeriodStart) <> 1
    BEGIN
        ;THROW 50414, N'A periódus kezdete csak a hónap első napja lehet.', 1;
    END;

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.Employee
        WHERE EmployeeId = @EmployeeId
    )
    BEGIN
        ;THROW 50415, N'A munkavállaló nem található.', 1;
    END;

    DECLARE @PeriodEnd DATE = EOMONTH(@PeriodStart);

    -- Munkarend-hozzárendelések és a munkarendek adatai.
    SELECT
        N'employee.employments.workSchedules' AS CollectionReference,
        CONCAT(
            workScheduleAssignment.EmploymentWorkScheduleId,
            N'/',
            CONVERT(NVARCHAR(10), workScheduleAssignment.ValidFrom, 23)
        ) AS RowKey,
        referenceData.Reference,
        referenceData.DataType,
        referenceData.Value
    FROM dbo.EmploymentWorkSchedule AS workScheduleAssignment
    INNER JOIN dbo.Employment AS employment
        ON employment.EmploymentId = workScheduleAssignment.EmploymentId
    INNER JOIN dbo.WorkSchedule AS workSchedule
        ON workSchedule.WorkScheduleId =
           workScheduleAssignment.WorkScheduleId
    CROSS APPLY
    (
        VALUES
            (N'dbo.EmploymentWorkSchedule.EmploymentWorkScheduleId', N'integer',
                CONVERT(NVARCHAR(MAX), workScheduleAssignment.EmploymentWorkScheduleId)),
            (N'dbo.EmploymentWorkSchedule.EmploymentId', N'integer',
                CONVERT(NVARCHAR(MAX), workScheduleAssignment.EmploymentId)),
            (N'dbo.EmploymentWorkSchedule.WorkScheduleId', N'integer',
                CONVERT(NVARCHAR(MAX), workScheduleAssignment.WorkScheduleId)),
            (N'dbo.EmploymentWorkSchedule.ValidFrom', N'date',
                CONVERT(NVARCHAR(MAX), workScheduleAssignment.ValidFrom, 23)),
            (N'dbo.EmploymentWorkSchedule.ValidTo', N'date',
                CONVERT(NVARCHAR(MAX), workScheduleAssignment.ValidTo, 23)),
            (N'dbo.EmploymentWorkSchedule.CycleStartDate', N'date',
                CONVERT(NVARCHAR(MAX), workScheduleAssignment.CycleStartDate, 23)),
            (N'dbo.WorkSchedule.WorkScheduleId', N'integer',
                CONVERT(NVARCHAR(MAX), workSchedule.WorkScheduleId)),
            (N'dbo.WorkSchedule.Name', N'text',
                CONVERT(NVARCHAR(MAX), workSchedule.Name)),
            (N'dbo.WorkSchedule.PeriodLengthDays', N'integer',
                CONVERT(NVARCHAR(MAX), workSchedule.PeriodLengthDays)),
            (N'dbo.WorkSchedule.IsActive', N'boolean',
                CONVERT(NVARCHAR(MAX), workSchedule.IsActive))
    ) AS referenceData(Reference, DataType, Value)
    WHERE employment.EmployeeId = @EmployeeId
      AND employment.ValidFrom <= @PeriodEnd
      AND
      (
          employment.ValidTo IS NULL
          OR employment.ValidTo >= @PeriodStart
      )
      AND workScheduleAssignment.ValidFrom <= @PeriodEnd
      AND
      (
          workScheduleAssignment.ValidTo IS NULL
          OR workScheduleAssignment.ValidTo >= @PeriodStart
      );

    -- Munkarend ciklusnapjai és a hozzájuk tartozó naptípusok.
    SELECT
        N'workSchedule.days' AS CollectionReference,
        CONCAT(
            workScheduleDay.WorkScheduleId,
            N'/',
            workScheduleDay.DayOfPeriod
        ) AS RowKey,
        referenceData.Reference,
        referenceData.DataType,
        referenceData.Value
    FROM dbo.WorkScheduleDay AS workScheduleDay
    INNER JOIN dbo.DayType AS dayType
        ON dayType.DayTypeId = workScheduleDay.DayTypeId
    CROSS APPLY
    (
        VALUES
            (N'dbo.WorkScheduleDay.WorkScheduleId', N'integer',
                CONVERT(NVARCHAR(MAX), workScheduleDay.WorkScheduleId)),
            (N'dbo.WorkScheduleDay.DayOfPeriod', N'integer',
                CONVERT(NVARCHAR(MAX), workScheduleDay.DayOfPeriod)),
            (N'dbo.WorkScheduleDay.DayTypeId', N'integer',
                CONVERT(NVARCHAR(MAX), workScheduleDay.DayTypeId)),
            (N'dbo.DayType.DayTypeId', N'integer',
                CONVERT(NVARCHAR(MAX), dayType.DayTypeId)),
            (N'dbo.DayType.Code', N'text',
                CONVERT(NVARCHAR(MAX), dayType.Code)),
            (N'dbo.DayType.Name', N'text',
                CONVERT(NVARCHAR(MAX), dayType.Name)),
            (N'dbo.DayType.IsWorkday', N'boolean',
                CONVERT(NVARCHAR(MAX), dayType.IsWorkday)),
            (N'dbo.DayType.StartTime', N'time',
                CONVERT(NVARCHAR(MAX), dayType.StartTime)),
            (N'dbo.DayType.EndTime', N'time',
                CONVERT(NVARCHAR(MAX), dayType.EndTime)),
            (N'dbo.DayType.BreakMinutes', N'integer',
                CONVERT(NVARCHAR(MAX), dayType.BreakMinutes))
    ) AS referenceData(Reference, DataType, Value)
    WHERE EXISTS
    (
        SELECT 1
        FROM dbo.EmploymentWorkSchedule AS workScheduleAssignment
        INNER JOIN dbo.Employment AS employment
            ON employment.EmploymentId =
               workScheduleAssignment.EmploymentId
        WHERE employment.EmployeeId = @EmployeeId
          AND employment.ValidFrom <= @PeriodEnd
          AND
          (
              employment.ValidTo IS NULL
              OR employment.ValidTo >= @PeriodStart
          )
          AND workScheduleAssignment.WorkScheduleId =
              workScheduleDay.WorkScheduleId
          AND workScheduleAssignment.ValidFrom <= @PeriodEnd
          AND
          (
              workScheduleAssignment.ValidTo IS NULL
              OR workScheduleAssignment.ValidTo >= @PeriodStart
          )
    );

    -- A periódussal átfedő távollétek és távolléttípusok.
    SELECT
        N'employee.absences' AS CollectionReference,
        CONVERT(NVARCHAR(100), absence.AbsenceId) AS RowKey,
        referenceData.Reference,
        referenceData.DataType,
        referenceData.Value
    FROM dbo.EmployeeAbsence AS absence
    INNER JOIN dbo.Employment AS employment
        ON employment.EmploymentId = absence.EmploymentId
    INNER JOIN dbo.AbsenceType AS absenceType
        ON absenceType.AbsenceTypeId = absence.AbsenceTypeId
    CROSS APPLY
    (
        VALUES
            (N'dbo.EmployeeAbsence.AbsenceId', N'integer',
                CONVERT(NVARCHAR(MAX), absence.AbsenceId)),
            (N'dbo.EmployeeAbsence.EmploymentId', N'integer',
                CONVERT(NVARCHAR(MAX), absence.EmploymentId)),
            (N'dbo.EmployeeAbsence.AbsenceTypeId', N'integer',
                CONVERT(NVARCHAR(MAX), absence.AbsenceTypeId)),
            (N'dbo.EmployeeAbsence.StartDate', N'date',
                CONVERT(NVARCHAR(MAX), absence.StartDate, 23)),
            (N'dbo.EmployeeAbsence.EndDate', N'date',
                CONVERT(NVARCHAR(MAX), absence.EndDate, 23)),
            (N'dbo.EmployeeAbsence.StartTime', N'time',
                CONVERT(NVARCHAR(MAX), absence.StartTime)),
            (N'dbo.EmployeeAbsence.EndTime', N'time',
                CONVERT(NVARCHAR(MAX), absence.EndTime)),
            (N'dbo.EmployeeAbsence.FullDay', N'boolean',
                CONVERT(NVARCHAR(MAX), absence.FullDay)),
            (N'dbo.AbsenceType.AbsenceTypeId', N'integer',
                CONVERT(NVARCHAR(MAX), absenceType.AbsenceTypeId)),
            (N'dbo.AbsenceType.Code', N'text',
                CONVERT(NVARCHAR(MAX), absenceType.Code)),
            (N'dbo.AbsenceType.Name', N'text',
                CONVERT(NVARCHAR(MAX), absenceType.Name)),
            (N'dbo.AbsenceType.IsPaid', N'boolean',
                CONVERT(NVARCHAR(MAX), absenceType.IsPaid)),
            (N'dbo.AbsenceType.IsActive', N'boolean',
                CONVERT(NVARCHAR(MAX), absenceType.IsActive))
    ) AS referenceData(Reference, DataType, Value)
    WHERE employment.EmployeeId = @EmployeeId
      AND absence.StartDate <= @PeriodEnd
      AND absence.EndDate >= @PeriodStart;

    -- A periódussal átfedő bérelem-hozzárendelések.
    SELECT
        N'employee.employments.payrollElements' AS CollectionReference,
        CONVERT(
            NVARCHAR(100),
            employmentPayrollElement.EmploymentPayrollElementId
        ) AS RowKey,
        referenceData.Reference,
        referenceData.DataType,
        referenceData.Value
    FROM dbo.EmploymentPayrollElement AS employmentPayrollElement
    INNER JOIN dbo.Employment AS employment
        ON employment.EmploymentId =
           employmentPayrollElement.EmploymentId
    INNER JOIN dbo.PayrollElement AS payrollElement
        ON payrollElement.PayrollElementId =
           employmentPayrollElement.PayrollElementId
    CROSS APPLY
    (
        VALUES
            (N'dbo.EmploymentPayrollElement.EmploymentPayrollElementId', N'integer',
                CONVERT(NVARCHAR(MAX), employmentPayrollElement.EmploymentPayrollElementId)),
            (N'dbo.EmploymentPayrollElement.EmploymentId', N'integer',
                CONVERT(NVARCHAR(MAX), employmentPayrollElement.EmploymentId)),
            (N'dbo.EmploymentPayrollElement.PayrollElementId', N'integer',
                CONVERT(NVARCHAR(MAX), employmentPayrollElement.PayrollElementId)),
            (N'dbo.EmploymentPayrollElement.ValidFrom', N'date',
                CONVERT(NVARCHAR(MAX), employmentPayrollElement.ValidFrom, 23)),
            (N'dbo.EmploymentPayrollElement.ValidTo', N'date',
                CONVERT(NVARCHAR(MAX), employmentPayrollElement.ValidTo, 23)),
            (N'dbo.EmploymentPayrollElement.Amount', N'decimal',
                CONVERT(NVARCHAR(MAX), employmentPayrollElement.Amount)),
            (N'dbo.PayrollElement.PayrollElementId', N'integer',
                CONVERT(NVARCHAR(MAX), payrollElement.PayrollElementId)),
            (N'dbo.PayrollElement.Code', N'text',
                CONVERT(NVARCHAR(MAX), payrollElement.Code)),
            (N'dbo.PayrollElement.Name', N'text',
                CONVERT(NVARCHAR(MAX), payrollElement.Name)),
            (N'dbo.PayrollElement.IsActive', N'boolean',
                CONVERT(NVARCHAR(MAX), payrollElement.IsActive))
    ) AS referenceData(Reference, DataType, Value)
    WHERE employment.EmployeeId = @EmployeeId
      AND employment.ValidFrom <= @PeriodEnd
      AND
      (
          employment.ValidTo IS NULL
          OR employment.ValidTo >= @PeriodStart
      )
      AND employmentPayrollElement.ValidFrom <= @PeriodEnd
      AND
      (
          employmentPayrollElement.ValidTo IS NULL
          OR employmentPayrollElement.ValidTo >= @PeriodStart
      );

    -- A hozzárendelt bérelemek historikus dinamikus mezőértékei.
    -- A hivatkozás formája: Csoportkód.Mezőkód.
        -- Minden bérelem számfejtési időszakban érvényes dinamikus mezőértéke.
    -- A PayrollElementId és a Code kapcsolja össze a tulajdonságot a bérelemmel.
    SELECT
        N'payrollElement.customFields' AS CollectionReference,
        CONCAT(
            payrollElement.PayrollElementId,
            N'/',
            fieldValue.FieldId,
            N'/',
            CONVERT(NVARCHAR(10), fieldValue.ValidFrom, 23)
        ) AS RowKey,
        referenceData.Reference,
        referenceData.DataType,
        referenceData.Value
    FROM dbo.PayrollElementFieldValue AS fieldValue
    INNER JOIN dbo.PayrollElement AS payrollElement
        ON payrollElement.PayrollElementId = fieldValue.PayrollElementId
    INNER JOIN dbo.MasterDataField AS field
        ON field.FieldId = fieldValue.FieldId
       AND field.IsActive = 1
    INNER JOIN dbo.MasterDataGroup AS dataGroup
        ON dataGroup.MasterDataGroupId = field.MasterDataGroupId
    INNER JOIN dbo.FieldType AS fieldType
        ON fieldType.FieldTypeId = field.FieldTypeId
    LEFT JOIN dbo.MasterDataFieldOption AS optionValue
        ON optionValue.FieldId = fieldValue.FieldId
       AND optionValue.OptionId = fieldValue.OptionId
    CROSS APPLY
    (
        VALUES
            (N'dbo.PayrollElement.PayrollElementId', N'integer',
                CONVERT(NVARCHAR(MAX), payrollElement.PayrollElementId)),
            (N'dbo.PayrollElement.Code', N'text',
                CONVERT(NVARCHAR(MAX), payrollElement.Code)),
            (N'dbo.PayrollElementFieldValue.ValidFrom', N'date',
                CONVERT(NVARCHAR(MAX), fieldValue.ValidFrom, 23)),
            (N'dbo.PayrollElementFieldValue.ValidTo', N'date',
                CONVERT(NVARCHAR(MAX), fieldValue.ValidTo, 23)),
            (CONCAT(dataGroup.Code, N'.', field.Code),
                CASE fieldType.Code
                    WHEN N'NUMBER' THEN N'decimal'
                    WHEN N'DATE' THEN N'date'
                    WHEN N'BOOLEAN' THEN N'boolean'
                    ELSE N'text'
                END,
                CONVERT(NVARCHAR(MAX),
                    COALESCE(optionValue.OptionCode, fieldValue.FieldValue)))
    ) AS referenceData(Reference, DataType, Value)
    WHERE fieldValue.ValidFrom <= @PeriodEnd
      AND
      (
          fieldValue.ValidTo IS NULL
          OR fieldValue.ValidTo >= @PeriodStart
      )
    ORDER BY payrollElement.Code, field.DisplayOrder, fieldValue.ValidFrom;
	    -- A számfejtési időszakban érvényes eltartottak.
    SELECT
        N'employee.dependents' AS CollectionReference,
        CONVERT(NVARCHAR(100), ed.EmployeeDependentId) AS RowKey,
        referenceData.Reference,
        referenceData.DataType,
        referenceData.Value
    FROM dbo.EmployeeDependent AS ed
    INNER JOIN dbo.Dependent AS dependent
        ON dependent.DependentId = ed.DependentId
    INNER JOIN dbo.RelationshipType AS relationshipType
        ON relationshipType.RelationshipTypeId = ed.RelationshipTypeId
    CROSS APPLY
    (
        VALUES
            (N'dbo.EmployeeDependent.EmployeeDependentId', N'integer',
                CONVERT(NVARCHAR(MAX), ed.EmployeeDependentId)),
            (N'dbo.EmployeeDependent.EmployeeId', N'integer',
                CONVERT(NVARCHAR(MAX), ed.EmployeeId)),
            (N'dbo.EmployeeDependent.DependentId', N'integer',
                CONVERT(NVARCHAR(MAX), ed.DependentId)),
            (N'dbo.EmployeeDependent.RelationshipTypeId', N'integer',
                CONVERT(NVARCHAR(MAX), ed.RelationshipTypeId)),
            (N'dbo.EmployeeDependent.ValidFrom', N'date',
                CONVERT(NVARCHAR(MAX), ed.ValidFrom, 23)),
            (N'dbo.EmployeeDependent.ValidTo', N'date',
                CONVERT(NVARCHAR(MAX), ed.ValidTo, 23)),
            (N'dbo.Dependent.FirstName', N'text',
                CONVERT(NVARCHAR(MAX), dependent.FirstName)),
            (N'dbo.Dependent.LastName', N'text',
                CONVERT(NVARCHAR(MAX), dependent.LastName)),
            (N'dbo.Dependent.BirthDate', N'date',
                CONVERT(NVARCHAR(MAX), dependent.BirthDate, 23)),
            (N'dbo.Dependent.TaxId', N'text',
                CONVERT(NVARCHAR(MAX), dependent.TaxId)),
            (N'dbo.RelationshipType.Name', N'text',
                CONVERT(NVARCHAR(MAX), relationshipType.Name))
    ) AS referenceData(Reference, DataType, Value)
    WHERE ed.EmployeeId = @EmployeeId
      AND (ed.ValidFrom IS NULL OR ed.ValidFrom <= @PeriodEnd)
      AND (ed.ValidTo IS NULL OR ed.ValidTo >= @PeriodStart)
    ORDER BY ed.EmployeeDependentId;
	      -- A számfejtési időszakban érvényes konstansok.
    SELECT
        N'payrollRun.constants' AS CollectionReference,
        CONCAT(
            constant.ConstantId,
            N'/',
            CONVERT(NVARCHAR(10), constant.ValidFrom, 23)
        ) AS RowKey,
        referenceData.Reference,
        referenceData.DataType,
        referenceData.Value
    FROM dbo.Constant AS constant
    CROSS APPLY
    (
        VALUES
            (N'dbo.Constant.ConstantId', N'text',
                CONVERT(NVARCHAR(MAX), constant.ConstantId)),
            (N'dbo.Constant.ConstantName', N'text',
                CONVERT(NVARCHAR(MAX), constant.ConstantName)),
            (N'dbo.Constant.Value', N'decimal',
                CONVERT(NVARCHAR(MAX), constant.Value)),
            (N'dbo.Constant.ValidFrom', N'date',
                CONVERT(NVARCHAR(MAX), constant.ValidFrom, 23)),
            (N'dbo.Constant.ValidTo', N'date',
                CONVERT(NVARCHAR(MAX), constant.ValidTo, 23))
    ) AS referenceData(Reference, DataType, Value)
    WHERE constant.ValidFrom <= @PeriodEnd
      AND
      (
          constant.ValidTo IS NULL
          OR constant.ValidTo >= @PeriodStart
      );
END;
GO
/****** Object:  StoredProcedure [dbo].[usp_PayrollRun_SaveEmployeePeriodResults]    Script Date: 2026. 11. 10. 21:19:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[usp_PayrollRun_SaveEmployeePeriodResults]
    @RunId UNIQUEIDENTIFIER,
    @EmployeeId INT,
    @Period CHAR(6),
    @RunByUserId INT,
    @ResultsJson NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF @RunId IS NULL
       OR @RunId = '00000000-0000-0000-0000-000000000000'
    BEGIN
        ;THROW 50500, N'Érvénytelen futásazonosító.', 1;
    END;

    IF @EmployeeId IS NULL
       OR @EmployeeId <= 0
       OR @RunByUserId IS NULL
       OR @RunByUserId <= 0
    BEGIN
        ;THROW 50501, N'Érvénytelen munkavállaló- vagy felhasználó-azonosító.', 1;
    END;

    DECLARE @PeriodStart DATE =
        TRY_CONVERT(DATE, @Period + '01', 112);

    IF @PeriodStart IS NULL
       OR CONVERT(CHAR(6), @PeriodStart, 112) <> @Period
       OR @PeriodStart = CONVERT(DATE, '99991201', 112)
    BEGIN
        ;THROW 50502, N'Érvénytelen periódus. Az elvárt formátum yyyyMM.', 1;
    END;

    IF @ResultsJson IS NULL
       OR ISJSON(@ResultsJson) <> 1
       OR LEFT(LTRIM(@ResultsJson), 1) <> N'['
    BEGIN
        ;THROW 50503, N'A számfejtési eredményeknek érvényes JSON-tömbnek kell lenniük.', 1;
    END;

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.[User]
        WHERE UserId = @RunByUserId
          AND IsActive = 1
    )
    BEGIN
        ;THROW 50505, N'A felhasználó nem található vagy inaktív.', 1;
    END;

    IF EXISTS
    (
        SELECT 1
        FROM OPENJSON(@ResultsJson) AS item
        WHERE item.[type] <> 5
    )
    BEGIN
        ;THROW 50506, N'Az eredménylista minden elemének JSON-objektumnak kell lennie.', 1;
    END;

    IF EXISTS
    (
        SELECT 1
        FROM OPENJSON(@ResultsJson)
        WITH
        (
            PayrollElementCode NVARCHAR(100) '$.payrollElementCode',
            Amount DECIMAL(18, 2) '$.amount'
        ) AS item
        WHERE NULLIF(LTRIM(RTRIM(item.PayrollElementCode)), N'') IS NULL
           OR item.Amount IS NULL
    )
    BEGIN
        ;THROW 50506, N'Érvénytelen bérelemkód vagy összeg.', 1;
    END;

    DECLARE @Results TABLE
    (
        PayrollElementCode NVARCHAR(100) NOT NULL PRIMARY KEY,
        Amount DECIMAL(18, 2) NOT NULL
    );

    INSERT INTO @Results
    (
        PayrollElementCode,
        Amount
    )
    SELECT
        LTRIM(RTRIM(item.PayrollElementCode)),
        SUM(item.Amount)
    FROM OPENJSON(@ResultsJson)
    WITH
    (
        PayrollElementCode NVARCHAR(100) '$.payrollElementCode',
        Amount DECIMAL(18, 2) '$.amount'
    ) AS item
    GROUP BY LTRIM(RTRIM(item.PayrollElementCode));

    IF EXISTS
    (
        SELECT 1
        FROM @Results AS result
        LEFT JOIN dbo.PayrollElement AS element
            ON element.Code = result.PayrollElementCode
           AND element.IsActive = 1
        WHERE element.PayrollElementId IS NULL
    )
    BEGIN
        ;THROW 50507, N'Egy hivatkozott bérelem nem található vagy inaktív.', 1;
    END;

    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @LockedEmployeeId INT;

        SELECT @LockedEmployeeId = EmployeeId
        FROM dbo.Employee WITH (UPDLOCK, HOLDLOCK)
        WHERE EmployeeId = @EmployeeId;

        IF @LockedEmployeeId IS NULL
        BEGIN
            ;THROW 50504, N'A munkavállaló nem található.', 1;
        END;

        IF EXISTS
        (
            SELECT 1
            FROM dbo.PayrollResult
            WHERE RunId = @RunId
              AND EmployeeId = @EmployeeId
              AND Period = @Period
        )
        BEGIN
            ;THROW 50508, N'Ez a dolgozó-periódus már szerepel ebben a futásban.', 1;
        END;

        DECLARE @HasPriorPeriodResult BIT = 0;

        IF EXISTS
        (
            SELECT 1
            FROM dbo.PayrollResult
            WHERE EmployeeId = @EmployeeId
              AND Period = @Period
        )
        BEGIN
            SET @HasPriorPeriodResult = 1;
        END;

        DECLARE @NewResultType CHAR(1) =
            CASE
                WHEN @HasPriorPeriodResult = 0 THEN 'O'
                ELSE 'A'
            END;

        IF @HasPriorPeriodResult = 1
        BEGIN
            UPDATE dbo.PayrollResult
            SET ResultType = 'P'
            WHERE EmployeeId = @EmployeeId
              AND Period = @Period
              AND ResultType = 'A';
        END;

        DECLARE @RunDate DATETIME2(0) = SYSUTCDATETIME();

        INSERT INTO dbo.PayrollResult
        (
            RunId,
            EmployeeId,
            Period,
            ResultType,
            PayrollElementId,
            Amount,
            RunDate,
            RunByUserId
        )
        SELECT
            @RunId,
            @EmployeeId,
            @Period,
            @NewResultType,
            element.PayrollElementId,
            result.Amount,
            @RunDate,
            @RunByUserId
        FROM @Results AS result
        INNER JOIN dbo.PayrollElement AS element
            ON element.Code = result.PayrollElementCode
           AND element.IsActive = 1;

        DECLARE @NextPeriod DATE =
            DATEADD(MONTH, 1, @PeriodStart);

        UPDATE dbo.Employee
        SET PayrollRunFrom =
            CASE
                WHEN PayrollRunFrom IS NULL
                     OR PayrollRunFrom < @NextPeriod
                    THEN @NextPeriod
                ELSE PayrollRunFrom
            END
        WHERE EmployeeId = @EmployeeId;

        DECLARE @UpdatedEmployeeCount INT = @@ROWCOUNT;

        DECLARE @NextPayrollRunFrom DATE;

        SELECT @NextPayrollRunFrom = PayrollRunFrom
        FROM dbo.Employee
        WHERE EmployeeId = @EmployeeId;

        COMMIT TRANSACTION;

        SELECT
            @RunId AS RunId,
            @EmployeeId AS EmployeeId,
            @Period AS Period,
            @UpdatedEmployeeCount AS UpdatedEmployeeCount,
            @NextPayrollRunFrom AS NextPayrollRunFrom;
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
/****** Object:  StoredProcedure [dbo].[usp_PayrollRun_SelectEmployees]    Script Date: 2026. 11. 10. 21:19:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[usp_PayrollRun_SelectEmployees]
    @PeriodFrom DATE,
    @PeriodTo DATE,
    @EmployeeIdsJson NVARCHAR(MAX) = NULL,
    @EmployeeIdFrom INT = NULL,
    @EmployeeIdTo INT = NULL,
    @CompanyId INT = NULL,
    @IncludeInactive BIT = 0
AS
BEGIN
    SET NOCOUNT ON;

    IF @PeriodFrom IS NULL
       OR @PeriodTo IS NULL
       OR DAY(@PeriodFrom) <> 1
       OR DAY(@PeriodTo) <> 1
       OR @PeriodFrom > @PeriodTo
    BEGIN
        ;THROW 50400, N'Érvénytelen számfejtési időszak. A periódusok első napját kell megadni.', 1;
    END;

    IF @EmployeeIdsJson IS NOT NULL
       AND (@EmployeeIdFrom IS NOT NULL OR @EmployeeIdTo IS NOT NULL)
    BEGIN
        ;THROW 50401, N'Az egyedi dolgozólista és az ID-tartomány együtt nem használható.', 1;
    END;

    IF (@EmployeeIdFrom IS NULL AND @EmployeeIdTo IS NOT NULL)
       OR (@EmployeeIdFrom IS NOT NULL AND @EmployeeIdTo IS NULL)
       OR (@EmployeeIdFrom IS NOT NULL AND @EmployeeIdFrom <= 0)
       OR (@EmployeeIdTo IS NOT NULL AND @EmployeeIdTo <= 0)
       OR (@EmployeeIdFrom IS NOT NULL AND @EmployeeIdFrom > @EmployeeIdTo)
    BEGIN
        ;THROW 50402, N'Érvénytelen dolgozó-ID-tartomány.', 1;
    END;

    IF @CompanyId IS NOT NULL AND @CompanyId <= 0
    BEGIN
        ;THROW 50403, N'Érvénytelen cégazonosító.', 1;
    END;

    CREATE TABLE #SelectedEmployees
    (
        EmployeeId INT NOT NULL PRIMARY KEY
    );

    IF @EmployeeIdsJson IS NOT NULL
    BEGIN
        IF ISJSON(@EmployeeIdsJson) <> 1
        BEGIN
            ;THROW 50404, N'A dolgozóazonosítók listája nem érvényes JSON.', 1;
        END;

        IF EXISTS
        (
            SELECT 1
            FROM OPENJSON(@EmployeeIdsJson) AS item
            WHERE TRY_CONVERT(INT, item.[value]) IS NULL
               OR TRY_CONVERT(INT, item.[value]) <= 0
        )
        BEGIN
            ;THROW 50405, N'A dolgozóazonosítók listája érvénytelen értéket tartalmaz.', 1;
        END;

        INSERT INTO #SelectedEmployees (EmployeeId)
        SELECT DISTINCT TRY_CONVERT(INT, item.[value])
        FROM OPENJSON(@EmployeeIdsJson) AS item;

        IF NOT EXISTS (SELECT 1 FROM #SelectedEmployees)
        BEGIN
            ;THROW 50406, N'A dolgozóazonosítók listája nem lehet üres.', 1;
        END;
    END;

    DECLARE @PeriodToEnd DATE = EOMONTH(@PeriodTo);

    SELECT
        employee.EmployeeId,
        employee.FirstName,
        employee.LastName,
        employee.IsActive,
        employee.JoinDate,
        employee.PayrollRunFrom,
        DATEFROMPARTS(
            YEAR(effectiveStart.EffectiveStartDate),
            MONTH(effectiveStart.EffectiveStartDate),
            1) AS EffectivePeriodFrom,
        employee.TerminationDate
    FROM dbo.Employee AS employee
    CROSS APPLY
    (
        SELECT
            CASE
                WHEN employee.PayrollRunFrom IS NOT NULL
                     AND employee.PayrollRunFrom < @PeriodFrom
                    THEN employee.PayrollRunFrom
                ELSE @PeriodFrom
            END AS RequestedStartDate
    ) AS requestedStart
    CROSS APPLY
    (
        SELECT
            CASE
                WHEN employee.JoinDate IS NOT NULL
                     AND employee.JoinDate > requestedStart.RequestedStartDate
                    THEN employee.JoinDate
                ELSE requestedStart.RequestedStartDate
            END AS EffectiveStartDate
    ) AS effectiveStart
    WHERE
        (
            @EmployeeIdsJson IS NULL
            OR EXISTS
            (
                SELECT 1
                FROM #SelectedEmployees AS selected
                WHERE selected.EmployeeId = employee.EmployeeId
            )
        )
        AND
        (
            @EmployeeIdFrom IS NULL
            OR employee.EmployeeId BETWEEN @EmployeeIdFrom AND @EmployeeIdTo
        )
        AND
        (
            employee.IsActive = 1
            OR
            (
                @IncludeInactive = 1
                AND employee.TerminationDate >= @PeriodFrom
                AND employee.TerminationDate <= @PeriodToEnd
            )
        )
        AND effectiveStart.EffectiveStartDate <= @PeriodToEnd
        AND
        (
            @CompanyId IS NULL
            OR EXISTS
            (
                SELECT 1
                FROM dbo.Employment AS companyEmployment
                WHERE companyEmployment.EmployeeId = employee.EmployeeId
                  AND companyEmployment.CompanyId = @CompanyId
                  AND companyEmployment.ValidFrom <= @PeriodToEnd
                  AND
                  (
                      companyEmployment.ValidTo IS NULL
                      OR companyEmployment.ValidTo >= effectiveStart.EffectiveStartDate
                  )
            )
        )
    ORDER BY employee.EmployeeId;
END;
GO
/****** Object:  StoredProcedure [dbo].[usp_RelationshipType_GetAll]    Script Date: 2026. 11. 10. 21:19:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[usp_RelationshipType_GetAll]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT RelationshipTypeId, Name
    FROM dbo.RelationshipType
    ORDER BY Name, RelationshipTypeId;
END;
GO
