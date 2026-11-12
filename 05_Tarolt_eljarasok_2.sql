USE [PY_2]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Object:  StoredProcedure [dbo].[usp_EmployeeFieldValue_Save]    Script Date: 2026. 11. 10. 21:19:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[usp_EmployeeFieldValue_Save]
    @EmployeeId INT,
    @FieldId INT,
    @UserId INT,
    @ValidFrom DATE,
    @FieldValue NVARCHAR(4000),
    @OptionId INT,
    @RetroPayrollRunFrom DATE
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @AccessDate DATE = CONVERT(DATE, GETDATE());
    DECLARE @JoinDate DATE;
    DECLARE @PayrollRunFrom DATE;
    DECLARE @FieldTypeCode NVARCHAR(30);
    DECLARE @IsRequired BIT;
    DECLARE @IsUnique BIT;
    DECLARE @MasterDataGroupId INT;
    DECLARE @NextValidFrom DATE;
    DECLARE @NewValidTo DATE;
    DECLARE @SuggestedPayrollRunFrom DATE;
    DECLARE @RequiresRetroPayroll BIT = 0;

    IF @EmployeeId <= 0 OR @FieldId <= 0 OR @UserId <= 0
        THROW 50300, N'Érvénytelen munkavállaló-, mező- vagy felhasználó-azonosító.', 1;

    IF @ValidFrom IS NULL
        THROW 50303, N'Az érvényesség kezdete kötelező.', 1;

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

        IF @JoinDate IS NULL OR @ValidFrom < @JoinDate
            THROW 50303, N'Az érték kezdődátuma nem lehet korábbi a belépés dátumánál.', 1;

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
          AND dataGroup.Code NOT LIKE N'PAYROLLELEMENT[_]%';

        IF @FieldTypeCode IS NULL
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
            THROW 50305, N'A felhasználónak nincs szerkesztési joga ehhez a törzsadatcsoporthoz.', 1;

        IF @FieldTypeCode = N'LIST'
        BEGIN
            IF @OptionId IS NULL OR @FieldValue IS NOT NULL
                THROW 50306, N'Lista típusú mezőnél egy listaértéket kell megadni.', 1;

            IF NOT EXISTS
            (
                SELECT 1
                FROM dbo.MasterDataFieldOption
                WHERE FieldId = @FieldId
                  AND OptionId = @OptionId
                  AND IsActive = 1
            )
                THROW 50307, N'A listaérték nem található vagy inaktív.', 1;
        END
        ELSE
        BEGIN
            IF @OptionId IS NOT NULL OR @FieldValue IS NULL
                THROW 50306, N'Ennél a mezőtípusnál szöveges értéket kell megadni.', 1;

            IF @IsRequired = 1
               AND NULLIF(LTRIM(RTRIM(@FieldValue)), N'') IS NULL
                THROW 50306, N'Kötelező mező értéke nem lehet üres.', 1;

            IF @FieldTypeCode = N'NUMBER'
               AND TRY_CONVERT(DECIMAL(18, 6), @FieldValue) IS NULL
                THROW 50306, N'A mező értéke nem érvényes szám.', 1;

            IF @FieldTypeCode = N'DATE'
               AND TRY_CONVERT(DATE, @FieldValue, 23) IS NULL
                THROW 50306, N'A mező értéke nem érvényes dátum. Használj ÉÉÉÉ-HH-NN formátumot.', 1;

            IF @FieldTypeCode = N'BOOLEAN'
               AND LOWER(LTRIM(RTRIM(@FieldValue))) NOT IN (N'0', N'1', N'true', N'false')
                THROW 50306, N'A mező értéke csak 0, 1, true vagy false lehet.', 1;
        END;

        SELECT
            @NextValidFrom = MIN(ValidFrom)
        FROM dbo.EmployeeFieldValue WITH (UPDLOCK, HOLDLOCK)
        WHERE EmployeeId = @EmployeeId
          AND FieldId = @FieldId
          AND ValidFrom > @ValidFrom;

        SET @NewValidTo =
            CASE
                WHEN @NextValidFrom IS NULL THEN NULL
                ELSE DATEADD(DAY, -1, @NextValidFrom)
            END;

        IF @IsUnique = 1
           AND EXISTS
           (
               SELECT 1
               FROM dbo.EmployeeFieldValue AS existingValue WITH (UPDLOCK, HOLDLOCK)
               WHERE existingValue.FieldId = @FieldId
                 AND existingValue.EmployeeId <> @EmployeeId
                 AND
                 (
                     (@OptionId IS NOT NULL AND existingValue.OptionId = @OptionId)
                     OR
                     (@FieldValue IS NOT NULL AND existingValue.FieldValue = @FieldValue)
                 )
                 AND existingValue.ValidFrom <= ISNULL(@NewValidTo, CONVERT(DATE, '99991231'))
                 AND
                 (
                     existingValue.ValidTo IS NULL
                     OR existingValue.ValidTo >= @ValidFrom
                 )
           )
            THROW 50308, N'Ez az egyedi mezőérték másik munkavállalónál már érvényes ebben az időszakban.', 1;

        IF @RetroPayrollRunFrom IS NOT NULL
           AND
           (
               @RetroPayrollRunFrom < @JoinDate
               OR @RetroPayrollRunFrom > @ValidFrom
           )
            THROW 50309, N'A visszamenőleges számfejtés kezdődátuma nem lehet a belépés előtt vagy a módosítás dátuma után.', 1;

        IF @PayrollRunFrom IS NOT NULL
           AND @ValidFrom < @PayrollRunFrom
        BEGIN
            SET @RequiresRetroPayroll = 1;

            DECLARE @MonthStart DATE =
                DATEFROMPARTS(YEAR(@ValidFrom), MONTH(@ValidFrom), 1);

            SET @SuggestedPayrollRunFrom =
                CASE
                    WHEN @MonthStart < @JoinDate THEN @JoinDate
                    ELSE @MonthStart
                END;
        END;

        IF EXISTS
        (
            SELECT 1
            FROM dbo.EmployeeFieldValue WITH (UPDLOCK, HOLDLOCK)
            WHERE EmployeeId = @EmployeeId
              AND FieldId = @FieldId
              AND ValidFrom = @ValidFrom
        )
        BEGIN
            UPDATE dbo.EmployeeFieldValue
            SET FieldValue = @FieldValue,
                OptionId = @OptionId,
                ValidTo = @NewValidTo
            WHERE EmployeeId = @EmployeeId
              AND FieldId = @FieldId
              AND ValidFrom = @ValidFrom;
        END
        ELSE
        BEGIN
            UPDATE dbo.EmployeeFieldValue
            SET ValidTo = DATEADD(DAY, -1, @ValidFrom)
            WHERE EmployeeId = @EmployeeId
              AND FieldId = @FieldId
              AND ValidFrom < @ValidFrom
              AND (ValidTo IS NULL OR ValidTo >= @ValidFrom);

            INSERT INTO dbo.EmployeeFieldValue
            (
                EmployeeId,
                FieldId,
                FieldValue,
                OptionId,
                ValidFrom,
                ValidTo
            )
            VALUES
            (
                @EmployeeId,
                @FieldId,
                @FieldValue,
                @OptionId,
                @ValidFrom,
                @NewValidTo
            );
        END;

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
            @NewValidTo AS ValidTo,
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
/****** Object:  StoredProcedure [dbo].[usp_EmployeePayrollElement_Delete]    Script Date: 2026. 11. 10. 21:19:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[usp_EmployeePayrollElement_Delete]
    @EmployeeId INT,
    @EmploymentPayrollElementId INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @ValidFrom DATE;
    DECLARE @JoinDate DATE;
    DECLARE @NewPayrollRunFrom DATE;

    BEGIN TRY
        BEGIN TRANSACTION;

        SELECT @ValidFrom = epe.ValidFrom
        FROM dbo.EmploymentPayrollElement AS epe
        INNER JOIN dbo.Employment AS e
            ON e.EmploymentId = epe.EmploymentId
        WHERE e.EmployeeId = @EmployeeId
          AND epe.EmploymentPayrollElementId = @EmploymentPayrollElementId;

        IF @ValidFrom IS NULL
        BEGIN
            THROW 50711, 'A bérelem-hozzárendelés nem található ennél a dolgozónál.', 1;
        END;

        SELECT @JoinDate = MIN(ValidFrom)
        FROM dbo.Employment
        WHERE EmployeeId = @EmployeeId;

        IF @JoinDate IS NULL
        BEGIN
            THROW 50712, 'A dolgozó belépési dátuma nem található.', 1;
        END;

        SET @NewPayrollRunFrom =
            DATEFROMPARTS(YEAR(@ValidFrom), MONTH(@ValidFrom), 1);

        IF @JoinDate < @NewPayrollRunFrom
        BEGIN
            SET @NewPayrollRunFrom = @JoinDate;
        END;

        DELETE FROM dbo.EmploymentPayrollElement
        WHERE EmploymentPayrollElementId = @EmploymentPayrollElementId;

        UPDATE dbo.Employee
        SET PayrollRunFrom =
            CASE
                WHEN PayrollRunFrom IS NULL
                     OR PayrollRunFrom > @NewPayrollRunFrom
                    THEN @NewPayrollRunFrom
                ELSE PayrollRunFrom
            END
        WHERE EmployeeId = @EmployeeId;

        COMMIT TRANSACTION;

        SELECT
            @EmployeeId AS EmployeeId,
            @EmploymentPayrollElementId AS EmploymentPayrollElementId,
            @NewPayrollRunFrom AS PayrollRunFrom;
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
/****** Object:  StoredProcedure [dbo].[usp_EmployeePayrollElement_GetByEmployeeId]    Script Date: 2026. 11. 10. 21:19:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[usp_EmployeePayrollElement_GetByEmployeeId]
    @EmployeeId INT
AS
BEGIN
    SET NOCOUNT ON;

    IF @EmployeeId IS NULL OR @EmployeeId <= 0
        THROW 50501, N'Érvénytelen munkavállaló-azonosító.', 1;

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.Employee
        WHERE EmployeeId = @EmployeeId
    )
        THROW 50502, N'A munkavállaló nem található.', 1;

    SELECT
        e.EmployeeId,
        epe.EmploymentPayrollElementId,
        employment.EmploymentId,
        employment.CompanyId,
        company.CompanyName,
        epe.PayrollElementId,
        payrollElement.Code AS PayrollElementCode,
        payrollElement.Name AS PayrollElementName,
        payrollElement.IsActive AS PayrollElementIsActive,
        epe.ValidFrom,
        epe.ValidTo,
        epe.Amount
    FROM dbo.Employee AS e
    INNER JOIN dbo.Employment AS employment
        ON employment.EmployeeId = e.EmployeeId
    INNER JOIN dbo.Company AS company
        ON company.CompanyId = employment.CompanyId
    INNER JOIN dbo.EmploymentPayrollElement AS epe
        ON epe.EmploymentId = employment.EmploymentId
    INNER JOIN dbo.PayrollElement AS payrollElement
        ON payrollElement.PayrollElementId = epe.PayrollElementId
    WHERE e.EmployeeId = @EmployeeId
    ORDER BY
        epe.ValidFrom,
        epe.EmploymentPayrollElementId;
END;
GO
/****** Object:  StoredProcedure [dbo].[usp_EmployeePayrollElement_Set]    Script Date: 2026. 11. 10. 21:19:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[usp_EmployeePayrollElement_Set]
    @EmployeeId INT,
    @EmploymentId INT,
    @PayrollElementId INT,
    @ValidFrom DATE,
    @Amount DECIMAL(18,2),
    @ValidTo DATE = NULL,
    @RetroPayrollRunFrom DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF @EmployeeId IS NULL OR @EmployeeId <= 0
       OR @EmploymentId IS NULL OR @EmploymentId <= 0
       OR @PayrollElementId IS NULL OR @PayrollElementId <= 0
       OR @ValidFrom IS NULL
       OR @Amount IS NULL
    BEGIN
        THROW 50501, N'Érvénytelen vagy hiányzó bérelemadat.', 1;
    END;

    IF @ValidTo IS NOT NULL AND @ValidTo < @ValidFrom
        THROW 50502, N'Az érvényesség vége nem lehet korábbi a kezdeténél.', 1;

    DECLARE @JoinDate DATE;
    DECLARE @PayrollRunFrom DATE;

    SELECT
        @JoinDate = JoinDate,
        @PayrollRunFrom = PayrollRunFrom
    FROM dbo.Employee
    WHERE EmployeeId = @EmployeeId;

    IF @JoinDate IS NULL
        THROW 50503, N'A munkavállaló nem található.', 1;

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.Employment
        WHERE EmploymentId = @EmploymentId
          AND EmployeeId = @EmployeeId
    )
        THROW 50504, N'A munkaviszony nem található ennél a munkavállalónál.', 1;

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.PayrollElement
        WHERE PayrollElementId = @PayrollElementId
          AND IsActive = 1
    )
        THROW 50505, N'Az aktív bérelem nem található.', 1;

    IF @ValidFrom < @JoinDate
        THROW 50506, N'A bérelem kezdődátuma nem lehet korábbi a belépés dátumánál.', 1;

    IF @PayrollRunFrom IS NOT NULL
       AND @ValidFrom < @PayrollRunFrom
       AND @RetroPayrollRunFrom IS NULL
    BEGIN
        DECLARE @SuggestedPayrollRunFrom DATE =
            DATEFROMPARTS(YEAR(@ValidFrom), MONTH(@ValidFrom), 1);

        IF @SuggestedPayrollRunFrom < @JoinDate
            SET @SuggestedPayrollRunFrom = @JoinDate;

        SELECT
            CAST(1 AS BIT) AS RequiresRetroPayroll,
            @SuggestedPayrollRunFrom AS SuggestedPayrollRunFrom,
            CAST(NULL AS INT) AS EmploymentPayrollElementId,
            @EmployeeId AS EmployeeId,
            @EmploymentId AS EmploymentId,
            @PayrollElementId AS PayrollElementId,
            @ValidFrom AS ValidFrom,
            @ValidTo AS ValidTo,
            @Amount AS Amount,
            N'Visszamenőleges számfejtés szükséges.' AS Message;

        RETURN;
    END;

    IF @RetroPayrollRunFrom IS NOT NULL
       AND
       (
           @RetroPayrollRunFrom < @JoinDate
           OR @RetroPayrollRunFrom > @ValidFrom
       )
        THROW 50507, N'Érvénytelen visszaszámfejtési kezdődátum.', 1;

    DECLARE @NextValidFrom DATE;
    DECLARE @EffectiveValidTo DATE = @ValidTo;
    DECLARE @AssignmentId INT;

    SELECT TOP (1)
        @NextValidFrom = ValidFrom
    FROM dbo.EmploymentPayrollElement
    WHERE EmploymentId = @EmploymentId
      AND PayrollElementId = @PayrollElementId
      AND ValidFrom > @ValidFrom
    ORDER BY ValidFrom;

    IF @NextValidFrom IS NOT NULL
    BEGIN
        IF @ValidTo IS NOT NULL AND @ValidTo >= @NextValidFrom
            THROW 50508, N'A megadott időszak átfed egy későbbi bérelem-hozzárendeléssel.', 1;

        IF @ValidTo IS NULL
            SET @EffectiveValidTo = DATEADD(DAY, -1, @NextValidFrom);
    END;

    BEGIN TRY
        BEGIN TRANSACTION;

        SELECT
            @AssignmentId = EmploymentPayrollElementId
        FROM dbo.EmploymentPayrollElement
        WHERE EmploymentId = @EmploymentId
          AND PayrollElementId = @PayrollElementId
          AND ValidFrom = @ValidFrom;

        IF @AssignmentId IS NOT NULL
        BEGIN
            UPDATE dbo.EmploymentPayrollElement
            SET
                Amount = @Amount,
                ValidTo = @EffectiveValidTo
            WHERE EmploymentPayrollElementId = @AssignmentId;
        END
        ELSE
        BEGIN
            UPDATE dbo.EmploymentPayrollElement
            SET ValidTo = DATEADD(DAY, -1, @ValidFrom)
            WHERE EmploymentId = @EmploymentId
              AND PayrollElementId = @PayrollElementId
              AND ValidFrom < @ValidFrom
              AND (ValidTo IS NULL OR ValidTo >= @ValidFrom);

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
                @ValidFrom,
                @EffectiveValidTo,
                @Amount
            );

            SET @AssignmentId = CONVERT(INT, SCOPE_IDENTITY());
        END;

        IF @RetroPayrollRunFrom IS NOT NULL
        BEGIN
            UPDATE dbo.Employee
            SET PayrollRunFrom = @RetroPayrollRunFrom
            WHERE EmployeeId = @EmployeeId;
        END;

        COMMIT TRANSACTION;

        SELECT
            CAST(0 AS BIT) AS RequiresRetroPayroll,
            CAST(NULL AS DATE) AS SuggestedPayrollRunFrom,
            @AssignmentId AS EmploymentPayrollElementId,
            @EmployeeId AS EmployeeId,
            @EmploymentId AS EmploymentId,
            @PayrollElementId AS PayrollElementId,
            @ValidFrom AS ValidFrom,
            @EffectiveValidTo AS ValidTo,
            @Amount AS Amount,
            N'A bérelem-hozzárendelés mentése sikerült.' AS Message;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH;
END;
GO
/****** Object:  StoredProcedure [dbo].[usp_EmployeeWorkSchedule_Change]    Script Date: 2026. 11. 10. 21:19:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[usp_EmployeeWorkSchedule_Change]
    @EmployeeId INT,
    @WorkScheduleId INT,
    @ValidFrom DATE,
    @CycleStartDate DATE,
    @RetroPayrollRunFrom DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE
            @JoinDate DATE,
            @PayrollRunFrom DATE,
            @SuggestedPayrollRunFrom DATE,
            @EmploymentId INT,
            @EmploymentValidFrom DATE,
            @EmploymentValidTo DATE,
            @SegmentStart DATE,
            @CurrentAssignmentId INT,
            @CurrentAssignmentStart DATE,
            @CurrentAssignmentEnd DATE,
            @NextScheduleStart DATE,
            @NewAssignmentEnd DATE,
            @HasCurrentAssignment BIT,
            @FirstEmployment BIT = 1,
            @PeriodLengthDays INT;

        /*
          Az Employee sor zárolása sorosítja az ugyanarra a dolgozóra
          érkező munkarend-váltásokat.
        */
        SELECT
            @JoinDate = JoinDate,
            @PayrollRunFrom = PayrollRunFrom
        FROM dbo.Employee WITH (UPDLOCK, HOLDLOCK)
        WHERE EmployeeId = @EmployeeId;

        IF @JoinDate IS NULL
        BEGIN
            THROW 50110, N'A munkavállaló nem található, vagy nincs belépési dátuma.', 1;
        END;

        IF @ValidFrom < @JoinDate
        BEGIN
            THROW 50111, N'A munkarend kezdődátuma nem lehet korábbi a belépés dátumánál.', 1;
        END;

        IF @CycleStartDate > @ValidFrom
        BEGIN
            THROW 50112, N'A ciklus kezdődátuma nem lehet későbbi a munkarend érvényességének kezdeténél.', 1;
        END;

        SELECT @PeriodLengthDays = PeriodLengthDays
        FROM dbo.WorkSchedule
        WHERE WorkScheduleId = @WorkScheduleId
          AND IsActive = 1;

        IF @PeriodLengthDays IS NULL
        BEGIN
            THROW 50113, N'A munkarend nem található vagy nem aktív.', 1;
        END;

        IF
        (
            SELECT COUNT(*)
            FROM dbo.WorkScheduleDay
            WHERE WorkScheduleId = @WorkScheduleId
        ) <> @PeriodLengthDays
        OR
        (
            SELECT MIN(DayOfPeriod)
            FROM dbo.WorkScheduleDay
            WHERE WorkScheduleId = @WorkScheduleId
        ) <> 1
        OR
        (
            SELECT MAX(DayOfPeriod)
            FROM dbo.WorkScheduleDay
            WHERE WorkScheduleId = @WorkScheduleId
        ) <> @PeriodLengthDays
        BEGIN
            THROW 50114, N'A munkarend ciklusnapjai hiányosak.', 1;
        END;

        IF NOT EXISTS
        (
            SELECT 1
            FROM dbo.Employment
            WHERE EmployeeId = @EmployeeId
              AND ValidFrom <= @ValidFrom
              AND (ValidTo IS NULL OR ValidTo >= @ValidFrom)
        )
        BEGIN
            THROW 50115, N'A megadott napon nincs érvényes munkaviszony.', 1;
        END;

        /*
          A munkaviszonyok a belépéstől kezdődően nem fedhetik át egymást,
          és nem lehet közöttük kihagyott nap.
        */
        IF NOT EXISTS
        (
            SELECT 1
            FROM dbo.Employment
            WHERE EmployeeId = @EmployeeId
              AND ValidFrom = @JoinDate
        )
        BEGIN
            THROW 50116, N'A munkaviszonyok nem a belépés napján kezdődnek.', 1;
        END;

        IF EXISTS
        (
            SELECT 1
            FROM
            (
                SELECT
                    ValidFrom,
                    ValidTo,
                    ROW_NUMBER() OVER
                    (
                        ORDER BY ValidFrom, EmploymentId
                    ) AS RowNumber,
                    LAG(ValidTo) OVER
                    (
                        ORDER BY ValidFrom, EmploymentId
                    ) AS PreviousValidTo
                FROM dbo.Employment
                WHERE EmployeeId = @EmployeeId
            ) AS OrderedEmployment
            WHERE RowNumber > 1
              AND
              (
                  PreviousValidTo IS NULL
                  OR DATEADD(DAY, 1, PreviousValidTo) <> ValidFrom
              )
        )
        BEGIN
            THROW 50117, N'A munkaviszonyok között rés vagy átfedés van.', 1;
        END;

        /*
          Ha a módosítás korábbi a PayrollRunFrom dátumnál, először
          visszaszámfejtési dátumot kell kérni. Ilyenkor nincs módosítás.
        */
        IF @PayrollRunFrom IS NOT NULL
           AND @ValidFrom < @PayrollRunFrom
           AND @RetroPayrollRunFrom IS NULL
        BEGIN
            SET @SuggestedPayrollRunFrom =
                DATEFROMPARTS(YEAR(@ValidFrom), MONTH(@ValidFrom), 1);

            IF @SuggestedPayrollRunFrom < @JoinDate
            BEGIN
                SET @SuggestedPayrollRunFrom = @JoinDate;
            END;

            ROLLBACK TRANSACTION;

            SELECT
                CAST(1 AS BIT) AS RequiresRetroPayroll,
                @SuggestedPayrollRunFrom AS SuggestedPayrollRunFrom,
                N'A módosítás visszamenőleges számfejtést igényel.' AS Message;

            RETURN;
        END;

        IF @RetroPayrollRunFrom IS NOT NULL
           AND
           (
               @RetroPayrollRunFrom < @JoinDate
               OR @RetroPayrollRunFrom > @ValidFrom
           )
        BEGIN
            THROW 50118, N'Érvénytelen visszaszámfejtési kezdődátum.', 1;
        END;

        DECLARE EmploymentCursor CURSOR LOCAL FAST_FORWARD FOR
            SELECT EmploymentId, ValidFrom, ValidTo
            FROM dbo.Employment WITH (UPDLOCK, HOLDLOCK)
            WHERE EmployeeId = @EmployeeId
              AND (ValidTo IS NULL OR ValidTo >= @ValidFrom)
            ORDER BY ValidFrom, EmploymentId;

        OPEN EmploymentCursor;

        FETCH NEXT FROM EmploymentCursor
        INTO @EmploymentId, @EmploymentValidFrom, @EmploymentValidTo;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            SET @SegmentStart =
                CASE
                    WHEN @FirstEmployment = 1 THEN @ValidFrom
                    ELSE @EmploymentValidFrom
                END;

            SET @CurrentAssignmentId = NULL;
            SET @CurrentAssignmentStart = NULL;
            SET @CurrentAssignmentEnd = NULL;
            SET @NextScheduleStart = NULL;
            SET @HasCurrentAssignment = 0;

            IF @FirstEmployment = 1
            BEGIN
                /*
                  Az első munkaviszonyon belül megkeressük a dátumot
                  lefedő munkarend-rekordot.
                */
                SELECT TOP (1)
                    @CurrentAssignmentId = EmploymentWorkScheduleId,
                    @CurrentAssignmentStart = ValidFrom,
                    @CurrentAssignmentEnd = ValidTo,
                    @HasCurrentAssignment = 1
                FROM dbo.EmploymentWorkSchedule WITH (UPDLOCK, HOLDLOCK)
                WHERE EmploymentId = @EmploymentId
                  AND ValidFrom <= @SegmentStart
                  AND (ValidTo IS NULL OR ValidTo >= @SegmentStart)
                ORDER BY ValidFrom DESC;

                SELECT @NextScheduleStart = MIN(ValidFrom)
                FROM dbo.EmploymentWorkSchedule
                WHERE EmploymentId = @EmploymentId
                  AND ValidFrom > @SegmentStart;

                IF @HasCurrentAssignment = 1
                BEGIN
                    IF @CurrentAssignmentStart < @SegmentStart
                    BEGIN
                        UPDATE dbo.EmploymentWorkSchedule
                        SET ValidTo = DATEADD(DAY, -1, @SegmentStart)
                        WHERE EmploymentWorkScheduleId = @CurrentAssignmentId;
                    END;

                    SET @NewAssignmentEnd = @CurrentAssignmentEnd;

                    IF @EmploymentValidTo IS NOT NULL
                       AND
                       (
                           @NewAssignmentEnd IS NULL
                           OR @EmploymentValidTo < @NewAssignmentEnd
                       )
                    BEGIN
                        SET @NewAssignmentEnd = @EmploymentValidTo;
                    END;

                    IF @NextScheduleStart IS NOT NULL
                       AND
                       (
                           @NewAssignmentEnd IS NULL
                           OR DATEADD(DAY, -1, @NextScheduleStart) < @NewAssignmentEnd
                       )
                    BEGIN
                        SET @NewAssignmentEnd =
                            DATEADD(DAY, -1, @NextScheduleStart);
                    END;

                    IF @CurrentAssignmentStart = @SegmentStart
                    BEGIN
                        UPDATE dbo.EmploymentWorkSchedule
                        SET WorkScheduleId = @WorkScheduleId,
                            CycleStartDate = @CycleStartDate,
                            ValidTo = @NewAssignmentEnd
                        WHERE EmploymentWorkScheduleId = @CurrentAssignmentId;
                    END
                    ELSE
                    BEGIN
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
                            @SegmentStart,
                            @NewAssignmentEnd,
                            @CycleStartDate
                        );
                    END;
                END
                ELSE IF @SegmentStart = @EmploymentValidFrom
                BEGIN
                    SET @NewAssignmentEnd = @EmploymentValidTo;

                    IF @NextScheduleStart IS NOT NULL
                       AND
                       (
                           @NewAssignmentEnd IS NULL
                           OR DATEADD(DAY, -1, @NextScheduleStart) < @NewAssignmentEnd
                       )
                    BEGIN
                        SET @NewAssignmentEnd =
                            DATEADD(DAY, -1, @NextScheduleStart);
                    END;

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
                        @SegmentStart,
                        @NewAssignmentEnd,
                        @CycleStartDate
                    );
                END
                ELSE
                BEGIN
                    THROW 50119, N'A munkarend-időszakban rés van a módosítás napján.', 1;
                END;

                SET @FirstEmployment = 0;
            END
            ELSE
            BEGIN
                /*
                  A következő munkaviszonyhoz külön rekord tartozik.
                  A munkarendet továbbvisszük a munkaviszony kezdetére,
                  és a későbbi, már rögzített váltásokat megtartjuk.
                */
                SELECT TOP (1)
                    @CurrentAssignmentId = EmploymentWorkScheduleId,
                    @CurrentAssignmentStart = ValidFrom,
                    @CurrentAssignmentEnd = ValidTo,
                    @HasCurrentAssignment = 1
                FROM dbo.EmploymentWorkSchedule WITH (UPDLOCK, HOLDLOCK)
                WHERE EmploymentId = @EmploymentId
                  AND ValidFrom = @EmploymentValidFrom
                ORDER BY EmploymentWorkScheduleId;

                SELECT @NextScheduleStart = MIN(ValidFrom)
                FROM dbo.EmploymentWorkSchedule
                WHERE EmploymentId = @EmploymentId
                  AND ValidFrom > @EmploymentValidFrom;

                SET @NewAssignmentEnd = @CurrentAssignmentEnd;

                IF @EmploymentValidTo IS NOT NULL
                   AND
                   (
                       @NewAssignmentEnd IS NULL
                       OR @EmploymentValidTo < @NewAssignmentEnd
                   )
                BEGIN
                    SET @NewAssignmentEnd = @EmploymentValidTo;
                END;

                IF @NextScheduleStart IS NOT NULL
                   AND
                   (
                       @NewAssignmentEnd IS NULL
                       OR DATEADD(DAY, -1, @NextScheduleStart) < @NewAssignmentEnd
                   )
                BEGIN
                    SET @NewAssignmentEnd =
                        DATEADD(DAY, -1, @NextScheduleStart);
                END;

                IF @HasCurrentAssignment = 1
                BEGIN
                    UPDATE dbo.EmploymentWorkSchedule
                    SET WorkScheduleId = @WorkScheduleId,
                        CycleStartDate = @CycleStartDate,
                        ValidTo = @NewAssignmentEnd
                    WHERE EmploymentWorkScheduleId = @CurrentAssignmentId;
                END
                ELSE
                BEGIN
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
                        @EmploymentValidFrom,
                        @NewAssignmentEnd,
                        @CycleStartDate
                    );
                END;
            END;

            FETCH NEXT FROM EmploymentCursor
            INTO @EmploymentId, @EmploymentValidFrom, @EmploymentValidTo;
        END;

        CLOSE EmploymentCursor;
        DEALLOCATE EmploymentCursor;

        /*
          Az érintett munkaviszonyokban ellenőrizzük, hogy a munkarendek
          a munkaviszony teljes időszakát rés és átfedés nélkül fedik le.
        */
        IF EXISTS
        (
            SELECT 1
            FROM
            (
                SELECT
                    e.EmploymentId,
                    e.ValidFrom AS EmploymentFrom,
                    e.ValidTo AS EmploymentTo,
                    s.ValidFrom,
                    s.ValidTo,
                    LAG(s.ValidTo) OVER
                    (
                        PARTITION BY e.EmploymentId
                        ORDER BY s.ValidFrom, s.EmploymentWorkScheduleId
                    ) AS PreviousValidTo,
                    ROW_NUMBER() OVER
                    (
                        PARTITION BY e.EmploymentId
                        ORDER BY s.ValidFrom, s.EmploymentWorkScheduleId
                    ) AS FirstRow,
                    ROW_NUMBER() OVER
                    (
                        PARTITION BY e.EmploymentId
                        ORDER BY s.ValidFrom DESC, s.EmploymentWorkScheduleId DESC
                    ) AS LastRow
                FROM dbo.Employment AS e
                LEFT JOIN dbo.EmploymentWorkSchedule AS s
                    ON s.EmploymentId = e.EmploymentId
                WHERE e.EmployeeId = @EmployeeId
                  AND (e.ValidTo IS NULL OR e.ValidTo >= @ValidFrom)
            ) AS A
            WHERE ValidFrom IS NULL
               OR (FirstRow = 1 AND ValidFrom <> EmploymentFrom)
               OR
               (
                   PreviousValidTo IS NOT NULL
                   AND DATEADD(DAY, 1, PreviousValidTo) <> ValidFrom
               )
               OR
               (
                   PreviousValidTo IS NULL
                   AND FirstRow > 1
               )
               OR
               (
                   EmploymentTo IS NOT NULL
                   AND (ValidTo IS NULL OR ValidTo > EmploymentTo)
               )
               OR
               (
                   EmploymentTo IS NOT NULL
                   AND LastRow = 1
                   AND (ValidTo IS NULL OR ValidTo <> EmploymentTo)
               )
               OR
               (
                   EmploymentTo IS NULL
                   AND LastRow = 1
                   AND ValidTo IS NOT NULL
               )
        )
        BEGIN
            THROW 50120, N'A munkarend-időszakok között rés vagy átfedés van, vagy túlnyúlnak a munkaviszonyon.', 1;
        END;

        IF @RetroPayrollRunFrom IS NOT NULL
        BEGIN
            UPDATE dbo.Employee
            SET PayrollRunFrom = @RetroPayrollRunFrom
            WHERE EmployeeId = @EmployeeId;
        END;

        COMMIT TRANSACTION;

        SELECT
            CAST(0 AS BIT) AS RequiresRetroPayroll,
            @EmployeeId AS EmployeeId,
            @WorkScheduleId AS WorkScheduleId,
            @ValidFrom AS ValidFrom,
            @CycleStartDate AS CycleStartDate,
            N'A munkarend módosítása sikerült.' AS Message;
    END TRY
    BEGIN CATCH
        IF CURSOR_STATUS('local', 'EmploymentCursor') >= 0
            CLOSE EmploymentCursor;

        IF CURSOR_STATUS('local', 'EmploymentCursor') > -3
            DEALLOCATE EmploymentCursor;

        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH;
END;
GO
/****** Object:  StoredProcedure [dbo].[usp_EmployeeWorkSchedule_Delete]    Script Date: 2026. 11. 10. 21:19:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[usp_EmployeeWorkSchedule_Delete]
    @EmployeeId INT,
    @EmploymentWorkScheduleId INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF @EmployeeId <= 0 OR @EmploymentWorkScheduleId <= 0
    BEGIN
        THROW 50901, 'Érvénytelen munkavállaló- vagy munkarend-hozzárendelés-azonosító.', 1;
    END;

    BEGIN TRY
        BEGIN TRANSACTION;

        DELETE ews
        FROM dbo.EmploymentWorkSchedule AS ews
        INNER JOIN dbo.Employment AS e
            ON e.EmploymentId = ews.EmploymentId
        WHERE e.EmployeeId = @EmployeeId
          AND ews.EmploymentWorkScheduleId = @EmploymentWorkScheduleId;

        IF @@ROWCOUNT = 0
        BEGIN
            THROW 50902, 'A munkarend-hozzárendelés nem található ennél a dolgozónál.', 1;
        END;

        COMMIT TRANSACTION;

        SELECT
            @EmployeeId AS EmployeeId,
            @EmploymentWorkScheduleId AS EmploymentWorkScheduleId;
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
/****** Object:  StoredProcedure [dbo].[usp_EmployeeWorkSchedule_List]    Script Date: 2026. 11. 10. 21:19:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[usp_EmployeeWorkSchedule_List]
    @EmployeeId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        ews.EmploymentWorkScheduleId,
        ws.WorkScheduleId,
        ws.Name AS WorkScheduleName,
        ws.PeriodLengthDays,
        ews.ValidFrom,
        ews.ValidTo,
        ews.CycleStartDate
    FROM dbo.EmploymentWorkSchedule AS ews
    INNER JOIN dbo.Employment AS e
        ON e.EmploymentId = ews.EmploymentId
    INNER JOIN dbo.WorkSchedule AS ws
        ON ws.WorkScheduleId = ews.WorkScheduleId
    WHERE e.EmployeeId = @EmployeeId
    ORDER BY ews.ValidFrom DESC;
END;
GO
/****** Object:  StoredProcedure [dbo].[usp_Employment_ChangeCompany]    Script Date: 2026. 11. 10. 21:19:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[usp_Employment_ChangeCompany]
    @EmployeeId INT,
    @CompanyId INT,
    @ValidFrom DATE,
    @RetroPayrollRunFrom DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE
            @JoinDate DATE,
            @PayrollRunFrom DATE,
            @SuggestedPayrollRunFrom DATE,
            @EmploymentId INT,
            @EmploymentValidFrom DATE,
            @EmploymentValidTo DATE,
            @CurrentCompanyId INT,
            @NewEmploymentId INT,
            @WorkScheduleAssignmentId INT,
            @WorkScheduleId INT,
            @ScheduleValidFrom DATE,
            @ScheduleValidTo DATE,
            @NewScheduleValidTo DATE,
            @CycleStartDate DATE;

        SELECT
            @JoinDate = JoinDate,
            @PayrollRunFrom = PayrollRunFrom
        FROM dbo.Employee WITH (UPDLOCK, HOLDLOCK)
        WHERE EmployeeId = @EmployeeId;

        IF @JoinDate IS NULL
        BEGIN
            THROW 50201, N'A munkavállaló nem található, vagy nincs belépési dátuma.', 1;
        END;

        IF @ValidFrom < @JoinDate
        BEGIN
            THROW 50202, N'Az új munkaviszony kezdődátuma nem lehet korábbi a belépés dátumánál.', 1;
        END;

        IF NOT EXISTS
        (
            SELECT 1
            FROM dbo.Company
            WHERE CompanyId = @CompanyId
        )
        BEGIN
            THROW 50203, N'A megadott cég nem található.', 1;
        END;

        SELECT TOP (1)
            @EmploymentId = EmploymentId,
            @EmploymentValidFrom = ValidFrom,
            @EmploymentValidTo = ValidTo,
            @CurrentCompanyId = CompanyId
        FROM dbo.Employment WITH (UPDLOCK, HOLDLOCK)
        WHERE EmployeeId = @EmployeeId
          AND ValidFrom <= @ValidFrom
          AND (ValidTo IS NULL OR ValidTo >= @ValidFrom)
        ORDER BY ValidFrom DESC, EmploymentId DESC;

      IF @EmploymentId IS NULL
BEGIN
    -- Ha már van munkaviszony, de a megadott napon egyik sem érvényes,
    -- ez továbbra is hiba: valószínűleg dátumrés van az időszakok között.
    IF EXISTS
    (
        SELECT 1
        FROM dbo.Employment
        WHERE EmployeeId = @EmployeeId
    )
    BEGIN
        THROW 50204, N'A megadott napon nincs érvényes munkaviszony.', 1;
    END;

    -- Még nincs munkaviszony: rögzítsük az elsőt.
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
        @ValidFrom,
        NULL
    );

    SET @EmploymentId = CONVERT(INT, SCOPE_IDENTITY());
    SET @NewEmploymentId = @EmploymentId;
    SET @EmploymentValidFrom = @ValidFrom;
    SET @EmploymentValidTo = NULL;
    SET @CurrentCompanyId = NULL;
END;

        SELECT TOP (1)
            @WorkScheduleAssignmentId = EmploymentWorkScheduleId,
            @WorkScheduleId = WorkScheduleId,
            @ScheduleValidFrom = ValidFrom,
            @ScheduleValidTo = ValidTo,
            @CycleStartDate = CycleStartDate
        FROM dbo.EmploymentWorkSchedule WITH (UPDLOCK, HOLDLOCK)
        WHERE EmploymentId = @EmploymentId
          AND ValidFrom <= @ValidFrom
          AND (ValidTo IS NULL OR ValidTo >= @ValidFrom)
        ORDER BY ValidFrom DESC, EmploymentWorkScheduleId DESC;

        IF @CurrentCompanyId = @CompanyId
        BEGIN
            COMMIT TRANSACTION;

            SELECT
                CAST(0 AS BIT) AS RequiresRetroPayroll,
                CAST(NULL AS DATE) AS SuggestedPayrollRunFrom,
                @EmployeeId AS EmployeeId,
                @EmploymentId AS EmploymentId,
                @CompanyId AS CompanyId,
                @EmploymentValidFrom AS ValidFrom,
                @EmploymentValidTo AS ValidTo,
                N'A megadott cég már érvényes ezen a napon.' AS Message;

            RETURN;
        END;

        IF @PayrollRunFrom IS NOT NULL
           AND @ValidFrom < @PayrollRunFrom
           AND @RetroPayrollRunFrom IS NULL
        BEGIN
            SET @SuggestedPayrollRunFrom =
                DATEFROMPARTS(YEAR(@ValidFrom), MONTH(@ValidFrom), 1);

            IF @SuggestedPayrollRunFrom < @JoinDate
            BEGIN
                SET @SuggestedPayrollRunFrom = @JoinDate;
            END;

            ROLLBACK TRANSACTION;

            SELECT
                CAST(1 AS BIT) AS RequiresRetroPayroll,
                @SuggestedPayrollRunFrom AS SuggestedPayrollRunFrom,
                CAST(NULL AS INT) AS EmployeeId,
                CAST(NULL AS INT) AS EmploymentId,
                CAST(NULL AS INT) AS CompanyId,
                CAST(NULL AS DATE) AS ValidFrom,
                CAST(NULL AS DATE) AS ValidTo,
                N'A munkaviszony módosítása visszamenőleges számfejtést igényel.' AS Message;

            RETURN;
        END;

        IF @RetroPayrollRunFrom IS NOT NULL
           AND
           (
               @RetroPayrollRunFrom < @JoinDate
               OR @RetroPayrollRunFrom > @ValidFrom
           )
        BEGIN
            THROW 50206, N'Érvénytelen visszaszámfejtési kezdődátum.', 1;
        END;

        IF @ValidFrom = @EmploymentValidFrom
        BEGIN
            UPDATE dbo.Employment
            SET CompanyId = @CompanyId
            WHERE EmploymentId = @EmploymentId;

            SET @NewEmploymentId = @EmploymentId;
        END
        ELSE
        BEGIN
            UPDATE dbo.Employment
            SET ValidTo = DATEADD(DAY, -1, @ValidFrom)
            WHERE EmploymentId = @EmploymentId;

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
                @ValidFrom,
                @EmploymentValidTo
            );

            SET @NewEmploymentId = CONVERT(INT, SCOPE_IDENTITY());

            IF @WorkScheduleAssignmentId IS NOT NULL
            BEGIN
                SET @NewScheduleValidTo = @ScheduleValidTo;

                IF @EmploymentValidTo IS NOT NULL
                   AND
                   (
                       @NewScheduleValidTo IS NULL
                       OR @NewScheduleValidTo > @EmploymentValidTo
                   )
                BEGIN
                    SET @NewScheduleValidTo = @EmploymentValidTo;
                END;

                IF @ScheduleValidFrom < @ValidFrom
                BEGIN
                    UPDATE dbo.EmploymentWorkSchedule
                    SET ValidTo = DATEADD(DAY, -1, @ValidFrom)
                    WHERE EmploymentWorkScheduleId = @WorkScheduleAssignmentId;

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
                        @NewEmploymentId,
                        @WorkScheduleId,
                        @ValidFrom,
                        @NewScheduleValidTo,
                        @CycleStartDate
                    );
                END
                ELSE
                BEGIN
                    UPDATE dbo.EmploymentWorkSchedule
                    SET EmploymentId = @NewEmploymentId,
                        ValidTo = @NewScheduleValidTo
                    WHERE EmploymentWorkScheduleId = @WorkScheduleAssignmentId;
                END;
            END;

            UPDATE dbo.EmploymentWorkSchedule
            SET EmploymentId = @NewEmploymentId
            WHERE EmploymentId = @EmploymentId
              AND ValidFrom > @ValidFrom;
        END;

        IF EXISTS
        (
            SELECT 1
            FROM
            (
                SELECT
                    ValidFrom,
                    ValidTo,
                    ROW_NUMBER() OVER
                        (ORDER BY ValidFrom, EmploymentId) AS RowNumber,
                    LAG(ValidTo) OVER
                        (ORDER BY ValidFrom, EmploymentId) AS PreviousValidTo
                FROM dbo.Employment
                WHERE EmployeeId = @EmployeeId
            ) AS OrderedEmployment
            WHERE RowNumber = 1
              AND ValidFrom <> @JoinDate
               OR RowNumber > 1
              AND
              (
                  PreviousValidTo IS NULL
                  OR DATEADD(DAY, 1, PreviousValidTo) <> ValidFrom
              )
        )
        BEGIN
            THROW 50207, N'A munkaviszonyok között rés vagy átfedés van, vagy nem a belépés napján kezdődnek.', 1;
        END;

        IF @RetroPayrollRunFrom IS NOT NULL
        BEGIN
            UPDATE dbo.Employee
            SET PayrollRunFrom = @RetroPayrollRunFrom
            WHERE EmployeeId = @EmployeeId;
        END;

        COMMIT TRANSACTION;

        SELECT
            CAST(0 AS BIT) AS RequiresRetroPayroll,
            CAST(NULL AS DATE) AS SuggestedPayrollRunFrom,
            @EmployeeId AS EmployeeId,
            @NewEmploymentId AS EmploymentId,
            @CompanyId AS CompanyId,
            @ValidFrom AS ValidFrom,
            @EmploymentValidTo AS ValidTo,
            N'A munkaviszony módosítása sikerült.' AS Message;
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
/****** Object:  StoredProcedure [dbo].[usp_Employment_Delete]    Script Date: 2026. 11. 10. 21:19:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[usp_Employment_Delete]
    @EmployeeId INT,
    @EmploymentId INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF NOT EXISTS
        (
            SELECT 1
            FROM dbo.Employment
            WHERE EmployeeId = @EmployeeId
              AND EmploymentId = @EmploymentId
        )
        BEGIN
            THROW 50801, 'A munkaviszony nem található ennél a dolgozónál.', 1;
        END;

        IF EXISTS
        (
            SELECT 1
            FROM dbo.EmploymentPayrollElement
            WHERE EmploymentId = @EmploymentId
        )
        OR EXISTS
        (
            SELECT 1
            FROM dbo.EmploymentWorkSchedule
            WHERE EmploymentId = @EmploymentId
        )
        OR EXISTS
        (
            SELECT 1
            FROM dbo.EmployeeAbsence
            WHERE EmploymentId = @EmploymentId
        )
        BEGIN
            THROW 50802, 'A munkaviszonyhoz még bérelem, munkarend vagy távollét tartozik. Ezeket előbb töröld.', 1;
        END;

        DELETE FROM dbo.Employment
        WHERE EmployeeId = @EmployeeId
          AND EmploymentId = @EmploymentId;

        DECLARE @NewPayrollRunFrom DATE;

        SELECT @NewPayrollRunFrom = MIN(ValidFrom)
        FROM dbo.Employment
        WHERE EmployeeId = @EmployeeId;

        UPDATE dbo.Employee
        SET PayrollRunFrom = @NewPayrollRunFrom
        WHERE EmployeeId = @EmployeeId;

        COMMIT TRANSACTION;

        SELECT
            @EmployeeId AS EmployeeId,
            @EmploymentId AS EmploymentId,
            @NewPayrollRunFrom AS PayrollRunFrom;
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
/****** Object:  StoredProcedure [dbo].[usp_Employment_GetByEmployeeId]    Script Date: 2026. 11. 10. 21:19:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[usp_Employment_GetByEmployeeId]
    @EmployeeId INT
AS
BEGIN
    SET NOCOUNT ON;

    IF @EmployeeId <= 0
    BEGIN
        THROW 50209, N'Érvénytelen munkavállaló-azonosító.', 1;
    END;

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.Employee
        WHERE EmployeeId = @EmployeeId
    )
    BEGIN
        THROW 50201, N'A munkavállaló nem található.', 1;
    END;

    SELECT
        e.EmployeeId,
        e.EmploymentId,
        e.CompanyId,
        c.CompanyName,
        e.ValidFrom,
        e.ValidTo
    FROM dbo.Employment AS e
    INNER JOIN dbo.Company AS c
        ON c.CompanyId = e.CompanyId
    WHERE e.EmployeeId = @EmployeeId
    ORDER BY e.ValidFrom, e.EmploymentId;
END;
GO
/****** Object:  StoredProcedure [dbo].[usp_EmploymentWorkSchedule_Create]    Script Date: 2026. 11. 10. 21:19:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[usp_EmploymentWorkSchedule_Create]
    @EmploymentId INT,
    @WorkScheduleId INT,
    @ValidFrom DATE,
    @ValidTo DATE = NULL,
    @CycleStartDate DATE
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF @EmploymentId <= 0 OR @WorkScheduleId <= 0
    BEGIN
        THROW 50080, N'Érvénytelen jogviszony- vagy munkarend-azonosító.', 1;
    END;

    IF @ValidFrom IS NULL OR @CycleStartDate IS NULL
    BEGIN
        THROW 50081, N'A kezdő dátum és a ciklus kezdő dátuma kötelező.', 1;
    END;

    IF @ValidTo IS NOT NULL AND @ValidTo < @ValidFrom
    BEGIN
        THROW 50082, N'Az érvényesség vége nem lehet korábbi a kezdeténél.', 1;
    END;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF NOT EXISTS
        (
            SELECT 1
            FROM dbo.Employment WITH (UPDLOCK, HOLDLOCK)
            WHERE EmploymentId = @EmploymentId
        )
        BEGIN
            THROW 50083, N'A jogviszony nem található.', 1;
        END;

        IF NOT EXISTS
        (
            SELECT 1
            FROM dbo.WorkSchedule WITH (UPDLOCK, HOLDLOCK)
            WHERE WorkScheduleId = @WorkScheduleId
              AND IsActive = 1
        )
        BEGIN
            THROW 50084, N'Az aktív munkarend nem található.', 1;
        END;

        IF EXISTS
        (
            SELECT 1
            FROM dbo.EmploymentWorkSchedule WITH (UPDLOCK, HOLDLOCK)
            WHERE EmploymentId = @EmploymentId
              AND ValidFrom <= ISNULL(@ValidTo, CONVERT(date, '99991231', 112))
              AND ISNULL(ValidTo, CONVERT(date, '99991231', 112)) >= @ValidFrom
        )
        BEGIN
            THROW 50085, N'Erre az időszakra már van munkarend rendelve a jogviszonyhoz.', 1;
        END;

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
            @ValidFrom,
            @ValidTo,
            @CycleStartDate
        );

        DECLARE @EmploymentWorkScheduleId INT =
            CONVERT(INT, SCOPE_IDENTITY());

        COMMIT TRANSACTION;

        SELECT @EmploymentWorkScheduleId AS EmploymentWorkScheduleId;
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
/****** Object:  StoredProcedure [dbo].[usp_FieldType_GetAll]    Script Date: 2026. 11. 10. 21:19:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[usp_FieldType_GetAll]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        FieldTypeId,
        Code,
        Name
    FROM dbo.FieldType
    ORDER BY FieldTypeId;
END;
GO
/****** Object:  StoredProcedure [dbo].[usp_MasterDataField_Create]    Script Date: 2026. 11. 10. 21:19:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[usp_MasterDataField_Create]
    @MasterDataGroupId INT,
    @Code NVARCHAR(50),
    @DisplayName NVARCHAR(100),
    @FieldTypeId INT,
    @IsRequired BIT,
    @IsUnique BIT,
    @DisplayOrder INT
AS
BEGIN
    SET NOCOUNT ON;

    IF @MasterDataGroupId <= 0
        THROW 50090, N'Érvénytelen törzsadatcsoport-azonosító.', 1;

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.MasterDataGroup
        WHERE MasterDataGroupId = @MasterDataGroupId
    )
        THROW 50091, N'A törzsadatcsoport nem található.', 1;

    IF @FieldTypeId <= 0
        THROW 50092, N'Érvénytelen mezőtípus-azonosító.', 1;

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.FieldType
        WHERE FieldTypeId = @FieldTypeId
    )
        THROW 50092, N'A mezőtípus nem található.', 1;

    IF NULLIF(LTRIM(RTRIM(@Code)), N'') IS NULL
       OR LEN(@Code) > 50
        THROW 50093, N'A mezőkód nem lehet üres, és legfeljebb 50 karakter lehet.', 1;

    IF NULLIF(LTRIM(RTRIM(@DisplayName)), N'') IS NULL
       OR LEN(@DisplayName) > 100
        THROW 50093, N'A mező megjelenített neve nem lehet üres, és legfeljebb 100 karakter lehet.', 1;

    INSERT INTO dbo.MasterDataField
    (
        MasterDataGroupId,
        Code,
        DisplayName,
        FieldTypeId,
        IsRequired,
        IsUnique,
        DisplayOrder,
        IsActive
    )
    OUTPUT INSERTED.FieldId
    VALUES
    (
        @MasterDataGroupId,
        LTRIM(RTRIM(@Code)),
        LTRIM(RTRIM(@DisplayName)),
        @FieldTypeId,
        @IsRequired,
        @IsUnique,
        @DisplayOrder,
        1
    );
END;
GO
/****** Object:  StoredProcedure [dbo].[usp_MasterDataField_GetById]    Script Date: 2026. 11. 10. 21:19:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[usp_MasterDataField_GetById]
    @FieldId INT
AS
BEGIN
    SET NOCOUNT ON;

    IF @FieldId <= 0
        THROW 50090, N'Érvénytelen mezőazonosító.', 1;

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.MasterDataField
        WHERE FieldId = @FieldId
    )
        THROW 50094, N'A dinamikus mező nem található.', 1;

    SELECT
        field.FieldId,
        field.MasterDataGroupId,
        groupData.Code AS MasterDataGroupCode,
        groupData.Name AS MasterDataGroupName,
        field.Code,
        field.DisplayName,
        field.FieldTypeId,
        fieldType.Code AS FieldTypeCode,
        fieldType.Name AS FieldTypeName,
        field.IsRequired,
        field.IsUnique,
        field.DisplayOrder,
        field.IsActive
    FROM dbo.MasterDataField AS field
    INNER JOIN dbo.MasterDataGroup AS groupData
        ON groupData.MasterDataGroupId = field.MasterDataGroupId
    INNER JOIN dbo.FieldType AS fieldType
        ON fieldType.FieldTypeId = field.FieldTypeId
    WHERE field.FieldId = @FieldId;
END;
GO
/****** Object:  StoredProcedure [dbo].[usp_MasterDataField_Search]    Script Date: 2026. 11. 10. 21:19:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[usp_MasterDataField_Search]
    @MasterDataGroupId INT = NULL,
    @FieldTypeId INT = NULL,
    @IsActive BIT = NULL,
    @Search NVARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        field.FieldId,
        field.MasterDataGroupId,
        groupData.Code AS MasterDataGroupCode,
        groupData.Name AS MasterDataGroupName,
        field.Code,
        field.DisplayName,
        field.FieldTypeId,
        fieldType.Code AS FieldTypeCode,
        fieldType.Name AS FieldTypeName,
        field.IsRequired,
        field.IsUnique,
        field.DisplayOrder,
        field.IsActive
    FROM dbo.MasterDataField AS field
    INNER JOIN dbo.MasterDataGroup AS groupData
        ON groupData.MasterDataGroupId = field.MasterDataGroupId
    INNER JOIN dbo.FieldType AS fieldType
        ON fieldType.FieldTypeId = field.FieldTypeId
    WHERE
        (@MasterDataGroupId IS NULL
            OR field.MasterDataGroupId = @MasterDataGroupId)
        AND (@FieldTypeId IS NULL
            OR field.FieldTypeId = @FieldTypeId)
        AND (@IsActive IS NULL
            OR field.IsActive = @IsActive)
        AND
        (
            NULLIF(LTRIM(RTRIM(@Search)), N'') IS NULL
            OR field.Code LIKE N'%' + LTRIM(RTRIM(@Search)) + N'%'
            OR field.DisplayName LIKE N'%' + LTRIM(RTRIM(@Search)) + N'%'
        )
    ORDER BY
        groupData.Name,
        field.DisplayOrder,
        field.DisplayName;
END;
GO
/****** Object:  StoredProcedure [dbo].[usp_MasterDataField_Update]    Script Date: 2026. 11. 10. 21:19:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[usp_MasterDataField_Update]
    @FieldId INT,
    @MasterDataGroupId INT,
    @Code NVARCHAR(50),
    @DisplayName NVARCHAR(100),
    @FieldTypeId INT,
    @IsRequired BIT,
    @IsUnique BIT,
    @DisplayOrder INT,
    @IsActive BIT
AS
BEGIN
    SET NOCOUNT ON;

    IF @FieldId <= 0
        THROW 50090, N'Érvénytelen mezőazonosító.', 1;

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.MasterDataField
        WHERE FieldId = @FieldId
    )
        THROW 50094, N'A dinamikus mező nem található.', 1;

    IF @MasterDataGroupId <= 0
       OR NOT EXISTS
       (
           SELECT 1
           FROM dbo.MasterDataGroup
           WHERE MasterDataGroupId = @MasterDataGroupId
       )
        THROW 50091, N'A törzsadatcsoport nem található.', 1;

    IF @FieldTypeId <= 0
       OR NOT EXISTS
       (
           SELECT 1
           FROM dbo.FieldType
           WHERE FieldTypeId = @FieldTypeId
       )
        THROW 50092, N'A mezőtípus nem található.', 1;

    IF NULLIF(LTRIM(RTRIM(@Code)), N'') IS NULL
       OR LEN(@Code) > 50
        THROW 50093, N'A mezőkód nem lehet üres, és legfeljebb 50 karakter lehet.', 1;

    IF NULLIF(LTRIM(RTRIM(@DisplayName)), N'') IS NULL
       OR LEN(@DisplayName) > 100
        THROW 50093, N'A mező megjelenített neve nem lehet üres, és legfeljebb 100 karakter lehet.', 1;

    UPDATE dbo.MasterDataField
    SET
        MasterDataGroupId = @MasterDataGroupId,
        Code = LTRIM(RTRIM(@Code)),
        DisplayName = LTRIM(RTRIM(@DisplayName)),
        FieldTypeId = @FieldTypeId,
        IsRequired = @IsRequired,
        IsUnique = @IsUnique,
        DisplayOrder = @DisplayOrder,
        IsActive = @IsActive
    WHERE FieldId = @FieldId;
END;
GO
/****** Object:  StoredProcedure [dbo].[usp_MasterDataFieldOption_Create]    Script Date: 2026. 11. 10. 21:19:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[usp_MasterDataFieldOption_Create]
    @FieldId INT,
    @OptionCode NVARCHAR(50),
    @DisplayName NVARCHAR(100),
    @SortOrder INT
AS
BEGIN
    SET NOCOUNT ON;

    IF @FieldId <= 0
        THROW 50100, N'Érvénytelen mezőazonosító.', 1;

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.MasterDataField AS field
        INNER JOIN dbo.FieldType AS fieldType
            ON fieldType.FieldTypeId = field.FieldTypeId
        WHERE field.FieldId = @FieldId
          AND fieldType.Code = N'LIST'
    )
        THROW 50101, N'A mező nem található vagy nem lista típusú.', 1;

    IF NULLIF(LTRIM(RTRIM(@OptionCode)), N'') IS NULL
       OR LEN(@OptionCode) > 50
        THROW 50102, N'A listaelem kódja nem lehet üres, és legfeljebb 50 karakter lehet.', 1;

    IF NULLIF(LTRIM(RTRIM(@DisplayName)), N'') IS NULL
       OR LEN(@DisplayName) > 100
        THROW 50103, N'A listaelem neve nem lehet üres, és legfeljebb 100 karakter lehet.', 1;

    INSERT INTO dbo.MasterDataFieldOption
    (
        FieldId,
        OptionCode,
        DisplayName,
        SortOrder,
        IsActive
    )
    OUTPUT INSERTED.OptionId
    VALUES
    (
        @FieldId,
        LTRIM(RTRIM(@OptionCode)),
        LTRIM(RTRIM(@DisplayName)),
        @SortOrder,
        1
    );
END;
GO
/****** Object:  StoredProcedure [dbo].[usp_MasterDataFieldOption_GetById]    Script Date: 2026. 11. 10. 21:19:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[usp_MasterDataFieldOption_GetById]
    @OptionId INT
AS
BEGIN
    SET NOCOUNT ON;

    IF @OptionId <= 0
        THROW 50104, N'Érvénytelen listaelem-azonosító.', 1;

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.MasterDataFieldOption
        WHERE OptionId = @OptionId
    )
        THROW 50105, N'A listaelem nem található.', 1;

    SELECT
        OptionId,
        FieldId,
        OptionCode,
        DisplayName,
        SortOrder,
        IsActive
    FROM dbo.MasterDataFieldOption
    WHERE OptionId = @OptionId;
END;
GO
/****** Object:  StoredProcedure [dbo].[usp_MasterDataFieldOption_Search]    Script Date: 2026. 11. 10. 21:19:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[usp_MasterDataFieldOption_Search]
    @FieldId INT,
    @Search NVARCHAR(100) = NULL,
    @IsActive BIT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @FieldId <= 0
        THROW 50100, N'Érvénytelen mezőazonosító.', 1;

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.MasterDataField AS field
        INNER JOIN dbo.FieldType AS fieldType
            ON fieldType.FieldTypeId = field.FieldTypeId
        WHERE field.FieldId = @FieldId
          AND fieldType.Code = N'LIST'
    )
        THROW 50101, N'A mező nem található vagy nem lista típusú.', 1;

    SELECT
        OptionId,
        FieldId,
        OptionCode,
        DisplayName,
        SortOrder,
        IsActive
    FROM dbo.MasterDataFieldOption
    WHERE FieldId = @FieldId
      AND (@IsActive IS NULL OR IsActive = @IsActive)
      AND
      (
          NULLIF(LTRIM(RTRIM(@Search)), N'') IS NULL
          OR OptionCode LIKE N'%' + LTRIM(RTRIM(@Search)) + N'%'
          OR DisplayName LIKE N'%' + LTRIM(RTRIM(@Search)) + N'%'
      )
    ORDER BY SortOrder, DisplayName;
END;
GO
/****** Object:  StoredProcedure [dbo].[usp_MasterDataFieldOption_Update]    Script Date: 2026. 11. 10. 21:19:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[usp_MasterDataFieldOption_Update]
    @OptionId INT,
    @OptionCode NVARCHAR(50),
    @DisplayName NVARCHAR(100),
    @SortOrder INT,
    @IsActive BIT
AS
BEGIN
    SET NOCOUNT ON;

    IF @OptionId <= 0
        THROW 50104, N'Érvénytelen listaelem-azonosító.', 1;

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.MasterDataFieldOption
        WHERE OptionId = @OptionId
    )
        THROW 50105, N'A listaelem nem található.', 1;

    IF NULLIF(LTRIM(RTRIM(@OptionCode)), N'') IS NULL
       OR LEN(@OptionCode) > 50
        THROW 50102, N'A listaelem kódja nem lehet üres, és legfeljebb 50 karakter lehet.', 1;

    IF NULLIF(LTRIM(RTRIM(@DisplayName)), N'') IS NULL
       OR LEN(@DisplayName) > 100
        THROW 50103, N'A listaelem neve nem lehet üres, és legfeljebb 100 karakter lehet.', 1;

    UPDATE dbo.MasterDataFieldOption
    SET
        OptionCode = LTRIM(RTRIM(@OptionCode)),
        DisplayName = LTRIM(RTRIM(@DisplayName)),
        SortOrder = @SortOrder,
        IsActive = @IsActive
    WHERE OptionId = @OptionId;
END;
GO
