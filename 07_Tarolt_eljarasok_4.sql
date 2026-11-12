USE [PY_2]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Object:  StoredProcedure [dbo].[usp_ReportBuilder_ExecuteQuery]    Script Date: 2026. 11. 10. 21:19:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[usp_ReportBuilder_ExecuteQuery]
    @QueryJson NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    IF @QueryJson IS NULL OR ISJSON(@QueryJson) <> 1
    BEGIN
        ;THROW 50600, N'A lekérdezési terv nem érvényes JSON.', 1;
    END;

    DECLARE @AllowedTables TABLE
    (
        TableName SYSNAME NOT NULL PRIMARY KEY
    );

    INSERT INTO @AllowedTables (TableName)
    VALUES
        (N'Employee'),
        (N'Employment'),
        (N'Company'),
        (N'EmployeeBankAccount'),
        (N'EmployeeAbsence'),
        (N'AbsenceType'),
        (N'Dependent'),
        (N'EmployeeDependent'),
        (N'RelationshipType'),
        (N'WorkSchedule'),
        (N'WorkScheduleDay'),
        (N'DayType'),
        (N'EmploymentWorkSchedule'),
        (N'PayrollElement'),
        (N'EmploymentPayrollElement'),
        (N'PayrollResult'),
        (N'Constant'),
        (N'MasterDataGroup'),
        (N'MasterDataField'),
        (N'FieldType'),
        (N'MasterDataFieldOption'),
        (N'EmployeeFieldValue'),
        (N'PayrollElementFieldValue');

    CREATE TABLE #ReportEntities
    (
        SequenceNumber INT NOT NULL PRIMARY KEY,
        SchemaName NVARCHAR(128) NOT NULL,
        TableName NVARCHAR(128) NOT NULL,
        EntityAlias NVARCHAR(128) NOT NULL UNIQUE,
        JoinType NVARCHAR(10) NULL,
        ObjectId INT NULL,
        OnSql NVARCHAR(MAX) NULL
    );

    INSERT INTO #ReportEntities
    (
        SequenceNumber,
        SchemaName,
        TableName,
        EntityAlias
    )
    SELECT
        0,
        SchemaName,
        TableName,
        EntityAlias
    FROM OPENJSON(@QueryJson, '$.root')
    WITH
    (
        SchemaName NVARCHAR(128) '$.schema',
        TableName NVARCHAR(128) '$.entity',
        EntityAlias NVARCHAR(128) '$.alias'
    );

    IF @@ROWCOUNT <> 1
    BEGIN
        ;THROW 50601, N'Pontosan egy kiinduló táblát kell megadni.', 1;
    END;

    INSERT INTO #ReportEntities
    (
        SequenceNumber,
        SchemaName,
        TableName,
        EntityAlias,
        JoinType
    )
    SELECT
        CONVERT(INT, item.[key]) + 1,
        definition.SchemaName,
        definition.TableName,
        definition.EntityAlias,
        UPPER(definition.JoinType)
    FROM OPENJSON(@QueryJson, '$.joins') AS item
    CROSS APPLY OPENJSON(item.[value])
    WITH
    (
        SchemaName NVARCHAR(128) '$.target.schema',
        TableName NVARCHAR(128) '$.target.entity',
        EntityAlias NVARCHAR(128) '$.target.alias',
        JoinType NVARCHAR(10) '$.joinType'
    ) AS definition;

    IF EXISTS
    (
        SELECT 1
        FROM #ReportEntities AS entity
        WHERE entity.SchemaName <> N'dbo'
           OR NOT EXISTS
           (
               SELECT 1
               FROM @AllowedTables AS allowed
               WHERE allowed.TableName = entity.TableName
           )
           OR entity.EntityAlias = N''
           OR entity.EntityAlias COLLATE Latin1_General_100_BIN2
                LIKE N'%[^A-Za-z0-9_]%'
           OR LEFT(entity.EntityAlias, 1) COLLATE Latin1_General_100_BIN2
                LIKE N'[0-9]'
           OR
           (
               entity.SequenceNumber > 0
               AND
               (
                   entity.JoinType IS NULL
                   OR entity.JoinType NOT IN (N'LEFT', N'INNER')
               )
           )
    )
    BEGIN
        ;THROW 50602, N'Nem engedélyezett tábla, alias vagy kapcsolástípus.', 1;
    END;

    UPDATE #ReportEntities
    SET ObjectId = OBJECT_ID(
        QUOTENAME(SchemaName) + N'.' + QUOTENAME(TableName),
        N'U');

    IF EXISTS
    (
        SELECT 1
        FROM #ReportEntities
        WHERE ObjectId IS NULL
    )
    BEGIN
        ;THROW 50603, N'A lekérdezésben megadott tábla nem létezik.', 1;
    END;

    CREATE TABLE #ReportJoinConditions
    (
        JoinSequence INT NOT NULL,
        LeftAlias NVARCHAR(128) NOT NULL,
        LeftColumn NVARCHAR(128) NOT NULL,
        RightAlias NVARCHAR(128) NOT NULL,
        RightColumn NVARCHAR(128) NOT NULL
    );

    INSERT INTO #ReportJoinConditions
    SELECT
        CONVERT(INT, item.[key]) + 1,
        condition.LeftAlias,
        condition.LeftColumn,
        condition.RightAlias,
        condition.RightColumn
    FROM OPENJSON(@QueryJson, '$.joins') AS item
    CROSS APPLY OPENJSON(item.[value], '$.conditions')
    WITH
    (
        LeftAlias NVARCHAR(128) '$.leftEntityAlias',
        LeftColumn NVARCHAR(128) '$.leftColumn',
        RightAlias NVARCHAR(128) '$.rightEntityAlias',
        RightColumn NVARCHAR(128) '$.rightColumn'
    ) AS condition;

    IF EXISTS
    (
        SELECT 1
        FROM #ReportEntities AS entity
        WHERE entity.SequenceNumber > 0
          AND NOT EXISTS
          (
              SELECT 1
              FROM #ReportJoinConditions AS condition
              WHERE condition.JoinSequence = entity.SequenceNumber
          )
    )
    BEGIN
        ;THROW 50604, N'Hiányzó kapcsolási feltétel.', 1;
    END;

    IF EXISTS
    (
        SELECT 1
        FROM #ReportJoinConditions AS condition
        LEFT JOIN #ReportEntities AS leftEntity
            ON leftEntity.EntityAlias = condition.LeftAlias
        LEFT JOIN #ReportEntities AS rightEntity
            ON rightEntity.EntityAlias = condition.RightAlias
        WHERE leftEntity.SequenceNumber IS NULL
           OR rightEntity.SequenceNumber IS NULL
           OR leftEntity.SequenceNumber >= condition.JoinSequence
           OR rightEntity.SequenceNumber <> condition.JoinSequence
           OR NOT EXISTS
           (
               SELECT 1
               FROM sys.columns
               WHERE object_id = leftEntity.ObjectId
                 AND name = condition.LeftColumn
           )
           OR NOT EXISTS
           (
               SELECT 1
               FROM sys.columns
               WHERE object_id = rightEntity.ObjectId
                 AND name = condition.RightColumn
           )
    )
    BEGIN
        ;THROW 50605, N'Érvénytelen kapcsolási mező vagy kapcsolási sorrend.', 1;
    END;

    UPDATE entity
    SET OnSql = conditions.SqlText
    FROM #ReportEntities AS entity
    CROSS APPLY
    (
        SELECT STRING_AGG(
            CONVERT(
                NVARCHAR(MAX),
                QUOTENAME(condition.LeftAlias) + N'.'
                + QUOTENAME(condition.LeftColumn) + N' = '
                + QUOTENAME(condition.RightAlias) + N'.'
                + QUOTENAME(condition.RightColumn)),
            N' AND ') AS SqlText
        FROM #ReportJoinConditions AS condition
        WHERE condition.JoinSequence = entity.SequenceNumber
    ) AS conditions
    WHERE entity.SequenceNumber > 0;

    CREATE TABLE #ReportFields
    (
        SequenceNumber INT NOT NULL PRIMARY KEY,
        Reference NVARCHAR(128) NOT NULL UNIQUE,
        EntityAlias NVARCHAR(128) NOT NULL,
        ColumnName NVARCHAR(128) NOT NULL,
        DynamicDefinition NVARCHAR(MAX) NULL,
        SqlExpression NVARCHAR(MAX) NULL
    );

    INSERT INTO #ReportFields
    (
        SequenceNumber,
        Reference,
        EntityAlias,
        ColumnName,
        DynamicDefinition
    )
    SELECT
        CONVERT(INT, item.[key]),
        field.Reference,
        field.EntityAlias,
        field.ColumnName,
        field.DynamicDefinition
    FROM OPENJSON(@QueryJson, '$.fields') AS item
    CROSS APPLY OPENJSON(item.[value])
    WITH
    (
        Reference NVARCHAR(128) '$.reference',
        EntityAlias NVARCHAR(128) '$.entityAlias',
        ColumnName NVARCHAR(128) '$.column',
        DynamicDefinition NVARCHAR(MAX) '$.dynamicField' AS JSON
    ) AS field;

    IF NOT EXISTS (SELECT 1 FROM #ReportFields)
    BEGIN
        ;THROW 50606, N'Legalább egy lekérdezési mező szükséges.', 1;
    END;

    IF EXISTS
    (
        SELECT 1
        FROM #ReportFields AS field
        LEFT JOIN #ReportEntities AS entity
            ON entity.EntityAlias = field.EntityAlias
        WHERE field.Reference = N''
           OR entity.ObjectId IS NULL
           OR
           (
               field.DynamicDefinition IS NULL
               AND NOT EXISTS
               (
                   SELECT 1
                   FROM sys.columns
                   WHERE object_id = entity.ObjectId
                     AND name = field.ColumnName
               )
           )
    )
    BEGIN
        ;THROW 50607, N'Ismeretlen lekérdezési mező.', 1;
    END;

    UPDATE #ReportFields
    SET SqlExpression =
        QUOTENAME(EntityAlias) + N'.' + QUOTENAME(ColumnName)
    WHERE DynamicDefinition IS NULL;

    CREATE TABLE #ReportFilters
    (
        FilterId INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        ScopeSequence INT NOT NULL,
        FilterJson NVARCHAR(MAX) NOT NULL,
        EntityAlias NVARCHAR(128) NULL,
        ColumnName NVARCHAR(128) NULL,
        Operation NVARCHAR(40) NULL,
        IncludeNull BIT NOT NULL DEFAULT 0,
        DynamicDefinition NVARCHAR(MAX) NULL,
        SqlType NVARCHAR(100) NULL,
        ColumnExpression NVARCHAR(MAX) NULL,
        PredicateSql NVARCHAR(MAX) NULL
    );

    INSERT INTO #ReportFilters
    (
        ScopeSequence,
        FilterJson
    )
    SELECT 0, item.[value]
    FROM OPENJSON(@QueryJson, '$.filters') AS item;

    INSERT INTO #ReportFilters
    (
        ScopeSequence,
        FilterJson
    )
    SELECT
        CONVERT(INT, joinItem.[key]) + 1,
        filterItem.[value]
    FROM OPENJSON(@QueryJson, '$.joins') AS joinItem
    CROSS APPLY OPENJSON(joinItem.[value], '$.filters') AS filterItem;

    UPDATE filter
    SET
        EntityAlias = definition.EntityAlias,
        ColumnName = definition.ColumnName,
        Operation = UPPER(definition.Operation),
        IncludeNull = ISNULL(definition.IncludeNull, 0),
        DynamicDefinition = definition.DynamicDefinition
    FROM #ReportFilters AS filter
    CROSS APPLY OPENJSON(filter.FilterJson)
    WITH
    (
        EntityAlias NVARCHAR(128) '$.entityAlias',
        ColumnName NVARCHAR(128) '$.column',
        Operation NVARCHAR(40) '$.operator',
        IncludeNull BIT '$.includeNull',
        DynamicDefinition NVARCHAR(MAX) '$.dynamicField' AS JSON
    ) AS definition;

    IF EXISTS
    (
        SELECT 1
        FROM #ReportFilters AS filter
        LEFT JOIN #ReportEntities AS entity
            ON entity.EntityAlias = filter.EntityAlias
        WHERE entity.ObjectId IS NULL
           OR filter.Operation IS NULL
           OR filter.Operation NOT IN
           (
               N'EQUALS', N'NOT_EQUALS',
               N'GREATER_THAN', N'GREATER_THAN_OR_EQUAL',
               N'LESS_THAN', N'LESS_THAN_OR_EQUAL',
               N'CONTAINS', N'STARTS_WITH',
               N'IS_NULL', N'IS_NOT_NULL',
               N'IN', N'NOT_IN'
           )
           OR
           (
               filter.ScopeSequence > 0
               AND filter.ScopeSequence <> entity.SequenceNumber
           )
           OR
           (
               filter.DynamicDefinition IS NULL
               AND NOT EXISTS
               (
                   SELECT 1
                   FROM sys.columns
                   WHERE object_id = entity.ObjectId
                     AND name = filter.ColumnName
               )
           )
    )
    BEGIN
        ;THROW 50609, N'Érvénytelen szűrőfeltétel.', 1;
    END;

    UPDATE filter
    SET
        ColumnExpression =
            QUOTENAME(filter.EntityAlias) + N'.'
            + QUOTENAME(filter.ColumnName),
        SqlType =
            CASE
                WHEN sqlType.name IN
                    (N'char', N'varchar', N'nchar', N'nvarchar')
                    THEN N'nvarchar(max)'
                WHEN sqlType.name IN
                    (N'decimal', N'numeric')
                    THEN sqlType.name + N'('
                        + CONVERT(NVARCHAR(3), columnInfo.precision)
                        + N','
                        + CONVERT(NVARCHAR(3), columnInfo.scale)
                        + N')'
                WHEN sqlType.name IN
                    (
                        N'bit', N'tinyint', N'smallint', N'int', N'bigint',
                        N'money', N'smallmoney', N'float', N'real',
                        N'date', N'datetime', N'smalldatetime',
                        N'uniqueidentifier'
                    )
                    THEN sqlType.name
                WHEN sqlType.name IN
                    (N'time', N'datetime2', N'datetimeoffset')
                    THEN sqlType.name + N'('
                        + CONVERT(NVARCHAR(3), columnInfo.scale)
                        + N')'
                ELSE NULL
            END
    FROM #ReportFilters AS filter
    INNER JOIN #ReportEntities AS entity
        ON entity.EntityAlias = filter.EntityAlias
    INNER JOIN sys.columns AS columnInfo
        ON columnInfo.object_id = entity.ObjectId
       AND columnInfo.name = filter.ColumnName
    INNER JOIN sys.types AS sqlType
        ON sqlType.user_type_id = columnInfo.system_type_id
       AND sqlType.user_type_id = sqlType.system_type_id
    WHERE filter.DynamicDefinition IS NULL;

    CREATE TABLE #ReportDynamicInputs
    (
        InputId INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        EntityAlias NVARCHAR(128) NOT NULL,
        ColumnName NVARCHAR(128) NOT NULL,
        DefinitionJson NVARCHAR(MAX) NOT NULL,
        MasterDataFieldId INT NULL,
        OwnerAlias NVARCHAR(128) NULL,
        OwnerIdColumn NVARCHAR(128) NULL,
        ValueSchema NVARCHAR(128) NULL,
        ValueTable NVARCHAR(128) NULL,
        OwnerForeignKeyColumn NVARCHAR(128) NULL,
        FieldIdColumn NVARCHAR(128) NULL,
        ValueColumn NVARCHAR(128) NULL,
        ValidFromColumn NVARCHAR(128) NULL,
        ValidToColumn NVARCHAR(128) NULL
    );

    INSERT INTO #ReportDynamicInputs
    (
        EntityAlias,
        ColumnName,
        DefinitionJson
    )
    SELECT
        EntityAlias,
        ColumnName,
        DynamicDefinition
    FROM #ReportFields
    WHERE DynamicDefinition IS NOT NULL
    UNION ALL
    SELECT
        EntityAlias,
        ColumnName,
        DynamicDefinition
    FROM #ReportFilters
    WHERE DynamicDefinition IS NOT NULL;

    UPDATE input
    SET
        MasterDataFieldId = definition.MasterDataFieldId,
        OwnerAlias = definition.OwnerAlias,
        OwnerIdColumn = definition.OwnerIdColumn,
        ValueSchema = definition.ValueSchema,
        ValueTable = definition.ValueTable,
        OwnerForeignKeyColumn = definition.OwnerForeignKeyColumn,
        FieldIdColumn = definition.FieldIdColumn,
        ValueColumn = definition.ValueColumn,
        ValidFromColumn = definition.ValidFromColumn,
        ValidToColumn = definition.ValidToColumn
    FROM #ReportDynamicInputs AS input
    CROSS APPLY OPENJSON(input.DefinitionJson)
    WITH
    (
        MasterDataFieldId INT '$.masterDataFieldId',
        OwnerAlias NVARCHAR(128) '$.ownerEntityAlias',
        OwnerIdColumn NVARCHAR(128) '$.ownerIdColumn',
        ValueSchema NVARCHAR(128) '$.valueEntity.schema',
        ValueTable NVARCHAR(128) '$.valueEntity.entity',
        OwnerForeignKeyColumn NVARCHAR(128) '$.ownerForeignKeyColumn',
        FieldIdColumn NVARCHAR(128) '$.fieldIdColumn',
        ValueColumn NVARCHAR(128) '$.valueColumn',
        ValidFromColumn NVARCHAR(128) '$.validFromColumn',
        ValidToColumn NVARCHAR(128) '$.validToColumn'
    ) AS definition;

    IF EXISTS
    (
        SELECT 1
        FROM #ReportDynamicInputs AS input
        LEFT JOIN #ReportEntities AS entity
            ON entity.EntityAlias = input.EntityAlias
        LEFT JOIN dbo.MasterDataField AS fieldDefinition
            ON fieldDefinition.FieldId = input.MasterDataFieldId
        LEFT JOIN dbo.MasterDataGroup AS fieldGroup
            ON fieldGroup.MasterDataGroupId =
                fieldDefinition.MasterDataGroupId
        WHERE input.MasterDataFieldId IS NULL
           OR input.MasterDataFieldId <= 0
           OR fieldDefinition.FieldId IS NULL
           OR fieldDefinition.IsActive <> 1
           OR fieldGroup.MasterDataGroupId IS NULL
           OR input.OwnerAlias IS NULL
           OR input.OwnerAlias <> input.EntityAlias
           OR input.ValueSchema IS NULL
           OR input.ValueSchema <> N'dbo'
           OR input.FieldIdColumn IS NULL
           OR input.FieldIdColumn <> N'FieldId'
           OR input.ValueColumn IS NULL
           OR input.ValueColumn <> N'FieldValue'
           OR input.ColumnName <> N'FieldValue'
           OR input.ValidFromColumn IS NULL
           OR input.ValidFromColumn <> N'ValidFrom'
           OR input.ValidToColumn IS NULL
           OR input.ValidToColumn <> N'ValidTo'
           OR entity.SchemaName <> N'dbo'
           OR NOT
           (
               (
                   LEFT(
                       UPPER(fieldGroup.Code),
                       LEN(N'PAYROLLELEMENT_')
                   ) = N'PAYROLLELEMENT_'
                   AND entity.TableName = N'PayrollElement'
                   AND input.OwnerIdColumn = N'PayrollElementId'
                   AND input.OwnerForeignKeyColumn = N'PayrollElementId'
                   AND input.ValueTable = N'PayrollElementFieldValue'
               )
               OR
               (
                   LEFT(
                       UPPER(fieldGroup.Code),
                       LEN(N'PAYROLLELEMENT_')
                   ) <> N'PAYROLLELEMENT_'
                   AND entity.TableName = N'Employee'
                   AND input.OwnerIdColumn = N'EmployeeId'
                   AND input.OwnerForeignKeyColumn = N'EmployeeId'
                   AND input.ValueTable = N'EmployeeFieldValue'
               )
           )
           OR input.OwnerIdColumn IS NULL
           OR input.OwnerForeignKeyColumn IS NULL
           OR input.ValueTable IS NULL
    )
    BEGIN
        ;THROW 50608, N'Érvénytelen dinamikusmező-definíció.', 1;
    END;

    DECLARE @DynamicFieldAsOfDate DATE =
        TRY_CONVERT(
            DATE,
            JSON_VALUE(@QueryJson, '$.dynamicFieldAsOfDate'),
            23);

    IF EXISTS (SELECT 1 FROM #ReportDynamicInputs)
       AND @DynamicFieldAsOfDate IS NULL
    BEGIN
        ;THROW 50616, N'A dinamikus mezőkhöz érvényességi dátum szükséges.', 1;
    END;

    CREATE TABLE #ReportDynamicFields
    (
        OwnerAlias NVARCHAR(128) NOT NULL,
        MasterDataFieldId INT NOT NULL,
        OwnerIdColumn NVARCHAR(128) NOT NULL,
        ValueTable NVARCHAR(128) NOT NULL,
        OwnerForeignKeyColumn NVARCHAR(128) NOT NULL,
        FieldTypeCode NVARCHAR(30) NOT NULL,
        SqlType NVARCHAR(100) NOT NULL,
        SqlExpression NVARCHAR(MAX) NULL,
        PRIMARY KEY (OwnerAlias, MasterDataFieldId)
    );

    INSERT INTO #ReportDynamicFields
    (
        OwnerAlias,
        MasterDataFieldId,
        OwnerIdColumn,
        ValueTable,
        OwnerForeignKeyColumn,
        FieldTypeCode,
        SqlType
    )
    SELECT DISTINCT
        input.OwnerAlias,
        input.MasterDataFieldId,
        input.OwnerIdColumn,
        input.ValueTable,
        input.OwnerForeignKeyColumn,
        UPPER(fieldType.Code),
        CASE UPPER(fieldType.Code)
            WHEN N'NUMBER' THEN N'decimal(38,10)'
            WHEN N'DECIMAL' THEN N'decimal(38,10)'
            WHEN N'NUMERIC' THEN N'decimal(38,10)'
            WHEN N'INTEGER' THEN N'bigint'
            WHEN N'INT' THEN N'bigint'
            WHEN N'DATE' THEN N'date'
            WHEN N'DATETIME' THEN N'datetime2(7)'
            WHEN N'DATETIMEOFFSET' THEN N'datetimeoffset(7)'
            WHEN N'TIME' THEN N'time(7)'
            WHEN N'BOOLEAN' THEN N'bit'
            WHEN N'BOOL' THEN N'bit'
            WHEN N'GUID' THEN N'uniqueidentifier'
            ELSE N'nvarchar(max)'
        END
    FROM #ReportDynamicInputs AS input
    INNER JOIN dbo.MasterDataField AS fieldDefinition
        ON fieldDefinition.FieldId = input.MasterDataFieldId
    INNER JOIN dbo.FieldType AS fieldType
        ON fieldType.FieldTypeId = fieldDefinition.FieldTypeId;

    UPDATE dynamicField
    SET SqlExpression =
        N'(SELECT TOP (1) '
        + CASE
            WHEN dynamicField.FieldTypeCode = N'LIST'
                THEN
                    N'CONVERT(nvarchar(max), '
                    + N'COALESCE([__rdo].[DisplayName], [__rdv].[FieldValue]))'
            WHEN dynamicField.SqlType = N'bit'
                THEN
                    N'TRY_CONVERT(bit, CASE '
                    + N'WHEN LOWER(LTRIM(RTRIM([__rdv].[FieldValue]))) '
                    + N'= N''true'' THEN N''1'' '
                    + N'WHEN LOWER(LTRIM(RTRIM([__rdv].[FieldValue]))) '
                    + N'= N''false'' THEN N''0'' '
                    + N'ELSE NULLIF(LTRIM(RTRIM([__rdv].[FieldValue])), N'''') END)'
            WHEN dynamicField.SqlType = N'nvarchar(max)'
                THEN N'CONVERT(nvarchar(max), [__rdv].[FieldValue])'
            ELSE
                N'TRY_CONVERT(' + dynamicField.SqlType
                + N', NULLIF(LTRIM(RTRIM([__rdv].[FieldValue])), N''''))'
          END
        + N' FROM [dbo].' + QUOTENAME(dynamicField.ValueTable)
        + N' AS [__rdv]'
        + CASE
            WHEN dynamicField.FieldTypeCode = N'LIST'
                THEN
                    N' LEFT JOIN [dbo].[MasterDataFieldOption] AS [__rdo]'
                    + N' ON [__rdo].[OptionId] = [__rdv].[OptionId]'
                    + N' AND [__rdo].[FieldId] = [__rdv].[FieldId]'
            ELSE N''
          END
        + N' WHERE [__rdv].'
        + QUOTENAME(dynamicField.OwnerForeignKeyColumn)
        + N' = ' + QUOTENAME(dynamicField.OwnerAlias)
        + N'.' + QUOTENAME(dynamicField.OwnerIdColumn)
        + N' AND [__rdv].[FieldId] = '
        + CONVERT(NVARCHAR(12), dynamicField.MasterDataFieldId)
        + N' AND [__rdv].[ValidFrom] <= @DynamicFieldAsOfDate'
        + N' AND ([__rdv].[ValidTo] IS NULL'
        + N' OR [__rdv].[ValidTo] >= @DynamicFieldAsOfDate)'
        + N' ORDER BY [__rdv].[ValidFrom] DESC)'
    FROM #ReportDynamicFields AS dynamicField;

    UPDATE field
    SET SqlExpression = dynamicField.SqlExpression
    FROM #ReportFields AS field
    INNER JOIN #ReportDynamicFields AS dynamicField
        ON dynamicField.OwnerAlias = field.EntityAlias
       AND dynamicField.MasterDataFieldId = TRY_CONVERT(
            INT,
            JSON_VALUE(
                field.DynamicDefinition,
                '$.masterDataFieldId'))
    WHERE field.DynamicDefinition IS NOT NULL;

    UPDATE filter
    SET
        SqlType = dynamicField.SqlType,
        ColumnExpression = dynamicField.SqlExpression
    FROM #ReportFilters AS filter
    INNER JOIN #ReportDynamicFields AS dynamicField
        ON dynamicField.OwnerAlias = filter.EntityAlias
       AND dynamicField.MasterDataFieldId = TRY_CONVERT(
            INT,
            JSON_VALUE(
                filter.DynamicDefinition,
                '$.masterDataFieldId'))
    WHERE filter.DynamicDefinition IS NOT NULL;

    IF EXISTS
    (
        SELECT 1
        FROM #ReportFields
        WHERE SqlExpression IS NULL
    )
    BEGIN
        ;THROW 50617, N'Nem állítható össze valamelyik riportmező.', 1;
    END;

    IF EXISTS
    (
        SELECT 1
        FROM #ReportFilters
        WHERE SqlType IS NULL
           OR ColumnExpression IS NULL
           OR
           (
               Operation IN (N'CONTAINS', N'STARTS_WITH')
               AND SqlType <> N'nvarchar(max)'
           )
    )
    BEGIN
        ;THROW 50610, N'A szűrés nem támogatott az adott oszloptípuson.', 1;
    END;

    CREATE TABLE #ReportFilterValues
    (
        FilterId INT NOT NULL,
        ValueOrder INT NOT NULL,
        Value NVARCHAR(MAX) NULL,
        JsonType INT NOT NULL
    );

    INSERT INTO #ReportFilterValues
    SELECT
        filter.FilterId,
        0,
        property.[value],
        property.[type]
    FROM #ReportFilters AS filter
    CROSS APPLY OPENJSON(filter.FilterJson) AS property
    WHERE property.[key] = N'value'
      AND filter.Operation NOT IN
          (N'IN', N'NOT_IN', N'IS_NULL', N'IS_NOT_NULL');

    IF EXISTS
    (
        SELECT 1
        FROM #ReportFilters AS filter
        WHERE filter.Operation IN (N'IN', N'NOT_IN')
          AND NOT EXISTS
          (
              SELECT 1
              FROM OPENJSON(filter.FilterJson) AS property
              WHERE property.[key] = N'value'
                AND property.[type] = 4
          )
    )
    BEGIN
        ;THROW 50611, N'A listás szűrés JSON-tömböt vár.', 1;
    END;

    INSERT INTO #ReportFilterValues
    SELECT
        filter.FilterId,
        CONVERT(INT, item.[key]),
        item.[value],
        item.[type]
    FROM #ReportFilters AS filter
    CROSS APPLY OPENJSON(filter.FilterJson, '$.value') AS item
    WHERE filter.Operation IN (N'IN', N'NOT_IN');

    IF EXISTS
    (
        SELECT 1
        FROM #ReportFilters AS filter
        WHERE filter.Operation NOT IN (N'IS_NULL', N'IS_NOT_NULL')
          AND NOT EXISTS
          (
              SELECT 1
              FROM #ReportFilterValues AS filterValue
              WHERE filterValue.FilterId = filter.FilterId
          )
    )
    OR EXISTS
    (
        SELECT 1
        FROM #ReportFilterValues
        WHERE JsonType NOT IN (1, 2, 3)
           OR Value IS NULL
    )
    BEGIN
        ;THROW 50612, N'Hiányzó vagy érvénytelen szűrési érték.', 1;
    END;

    UPDATE filterValue
    SET Value =
        CASE LOWER(filterValue.Value)
            WHEN N'true' THEN N'1'
            WHEN N'false' THEN N'0'
            ELSE filterValue.Value
        END
    FROM #ReportFilterValues AS filterValue
    INNER JOIN #ReportFilters AS filter
        ON filter.FilterId = filterValue.FilterId
    WHERE filter.SqlType = N'bit';

    DECLARE
        @FilterId INT,
        @Operation NVARCHAR(40),
        @SqlType NVARCHAR(100),
        @IncludeNull BIT,
        @ColumnExpression NVARCHAR(MAX),
        @ValueExpression NVARCHAR(MAX),
        @Predicate NVARCHAR(MAX),
        @ValidationSql NVARCHAR(MAX);

    DECLARE filterCursor CURSOR LOCAL FAST_FORWARD FOR
        SELECT
            FilterId,
            Operation,
            SqlType,
            IncludeNull,
            ColumnExpression
        FROM #ReportFilters
        ORDER BY FilterId;

    OPEN filterCursor;

    FETCH NEXT FROM filterCursor INTO
        @FilterId,
        @Operation,
        @SqlType,
        @IncludeNull,
        @ColumnExpression;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        IF @Operation NOT IN (N'IS_NULL', N'IS_NOT_NULL')
        BEGIN
            SET @ValidationSql =
                N'IF EXISTS
                (
                    SELECT 1
                    FROM #ReportFilterValues
                    WHERE FilterId = ' + CONVERT(NVARCHAR(12), @FilterId) + N'
                      AND TRY_CONVERT(' + @SqlType + N', Value) IS NULL
                )
                BEGIN
                    ;THROW 50613,
                        N''A szűrési érték nem alakítható az oszlop adattípusára.'',
                        1;
                END;';

            EXEC sys.sp_executesql @ValidationSql;
        END;

        SET @ValueExpression =
            N'(SELECT CONVERT(' + @SqlType + N', filterValue.Value)
               FROM #ReportFilterValues AS filterValue
               WHERE filterValue.FilterId = '
            + CONVERT(NVARCHAR(12), @FilterId) + N')';

        SET @Predicate =
            CASE @Operation
                WHEN N'IS_NULL'
                    THEN @ColumnExpression + N' IS NULL'
                WHEN N'IS_NOT_NULL'
                    THEN @ColumnExpression + N' IS NOT NULL'
                WHEN N'EQUALS'
                    THEN @ColumnExpression + N' = ' + @ValueExpression
                WHEN N'NOT_EQUALS'
                    THEN @ColumnExpression + N' <> ' + @ValueExpression
                WHEN N'GREATER_THAN'
                    THEN @ColumnExpression + N' > ' + @ValueExpression
                WHEN N'GREATER_THAN_OR_EQUAL'
                    THEN @ColumnExpression + N' >= ' + @ValueExpression
                WHEN N'LESS_THAN'
                    THEN @ColumnExpression + N' < ' + @ValueExpression
                WHEN N'LESS_THAN_OR_EQUAL'
                    THEN @ColumnExpression + N' <= ' + @ValueExpression
                WHEN N'IN'
                    THEN @ColumnExpression + N' IN ' + @ValueExpression
                WHEN N'NOT_IN'
                    THEN @ColumnExpression + N' NOT IN ' + @ValueExpression
                ELSE NULL
            END;

        IF @Operation IN (N'CONTAINS', N'STARTS_WITH')
        BEGIN
            SET @ValueExpression =
                N'REPLACE(REPLACE(REPLACE(REPLACE('
                + @ValueExpression
                + N', N''~'', N''~~''), N''%'', N''~%''),
                    N''_'', N''~_''), N''['', N''~['')';

            SET @Predicate =
                @ColumnExpression + N' LIKE '
                + CASE
                    WHEN @Operation = N'CONTAINS'
                        THEN N'N''%'' + '
                    ELSE N''
                  END
                + @ValueExpression
                + N' + N''%'' ESCAPE N''~''';
        END;

        IF @IncludeNull = 1
        BEGIN
            SET @Predicate =
                N'(' + @Predicate
                + N' OR ' + @ColumnExpression + N' IS NULL)';
        END;

        UPDATE #ReportFilters
        SET PredicateSql = N'(' + @Predicate + N')'
        WHERE FilterId = @FilterId;

        FETCH NEXT FROM filterCursor INTO
            @FilterId,
            @Operation,
            @SqlType,
            @IncludeNull,
            @ColumnExpression;
    END;

    CLOSE filterCursor;
    DEALLOCATE filterCursor;

    UPDATE entity
    SET OnSql = entity.OnSql + N' AND ' + filters.SqlText
    FROM #ReportEntities AS entity
    CROSS APPLY
    (
        SELECT STRING_AGG(
            CONVERT(NVARCHAR(MAX), filter.PredicateSql),
            N' AND ') AS SqlText
        FROM #ReportFilters AS filter
        WHERE filter.ScopeSequence = entity.SequenceNumber
    ) AS filters
    WHERE entity.SequenceNumber > 0
      AND filters.SqlText IS NOT NULL;

    DECLARE
        @RootSchema NVARCHAR(128),
        @RootTable NVARCHAR(128),
        @RootAlias NVARCHAR(128),
        @RootObjectId INT,
        @RootFrom NVARCHAR(MAX),
        @PrefixSql NVARCHAR(MAX) = N'',
        @LatestPredicate NVARCHAR(MAX) = NULL,
        @SelectSql NVARCHAR(MAX),
        @JoinSql NVARCHAR(MAX),
        @WhereSql NVARCHAR(MAX),
        @OrderSql NVARCHAR(MAX),
        @Sql NVARCHAR(MAX);

    SELECT
        @RootSchema = SchemaName,
        @RootTable = TableName,
        @RootAlias = EntityAlias,
        @RootObjectId = ObjectId
    FROM #ReportEntities
    WHERE SequenceNumber = 0;

    SET @RootFrom =
        QUOTENAME(@RootSchema) + N'.' + QUOTENAME(@RootTable);

    IF JSON_QUERY(@QueryJson, '$.latestRecords') IS NOT NULL
    BEGIN
        DECLARE @PartitionColumns TABLE
        (
            SequenceNumber INT NOT NULL,
            ColumnName NVARCHAR(128) NOT NULL
        );

        DECLARE @LatestOrder TABLE
        (
            SequenceNumber INT NOT NULL,
            ColumnName NVARCHAR(128) NOT NULL,
            Direction NVARCHAR(4) NOT NULL
        );

        INSERT INTO @PartitionColumns
        SELECT CONVERT(INT, [key]), [value]
        FROM OPENJSON(@QueryJson, '$.latestRecords.partitionColumns');

        INSERT INTO @LatestOrder
        SELECT
            CONVERT(INT, item.[key]),
            definition.ColumnName,
            UPPER(definition.Direction)
        FROM OPENJSON(@QueryJson, '$.latestRecords.orderBy') AS item
        CROSS APPLY OPENJSON(item.[value])
        WITH
        (
            ColumnName NVARCHAR(128) '$.column',
            Direction NVARCHAR(4) '$.direction'
        ) AS definition;

        IF NOT EXISTS (SELECT 1 FROM @PartitionColumns)
           OR NOT EXISTS (SELECT 1 FROM @LatestOrder)
           OR EXISTS
           (
               SELECT 1
               FROM @PartitionColumns AS partitionColumn
               WHERE NOT EXISTS
               (
                   SELECT 1
                   FROM sys.columns
                   WHERE object_id = @RootObjectId
                     AND name = partitionColumn.ColumnName
               )
           )
           OR EXISTS
           (
               SELECT 1
               FROM @LatestOrder AS orderColumn
               WHERE orderColumn.Direction NOT IN (N'ASC', N'DESC')
                  OR NOT EXISTS
                  (
                      SELECT 1
                      FROM sys.columns
                      WHERE object_id = @RootObjectId
                        AND name = orderColumn.ColumnName
                  )
           )
           OR EXISTS
           (
               SELECT 1
               FROM sys.columns
               WHERE object_id = @RootObjectId
                 AND name = N'__ReportRowNumber'
           )
        BEGIN
            ;THROW 50614, N'Érvénytelen legutolsórekord-kiválasztás.', 1;
        END;

        DECLARE
            @PartitionSql NVARCHAR(MAX),
            @LatestOrderSql NVARCHAR(MAX);

        SELECT @PartitionSql = STRING_AGG(
            CONVERT(NVARCHAR(MAX), QUOTENAME(ColumnName)),
            N', ')
            WITHIN GROUP (ORDER BY SequenceNumber)
        FROM @PartitionColumns;

        SELECT @LatestOrderSql = STRING_AGG(
            CONVERT(
                NVARCHAR(MAX),
                QUOTENAME(ColumnName) + N' ' + Direction),
            N', ')
            WITHIN GROUP (ORDER BY SequenceNumber)
        FROM @LatestOrder;

        SET @PrefixSql =
            N';WITH [__ReportRoot] AS
            (
                SELECT *,
                    ROW_NUMBER() OVER
                    (
                        PARTITION BY ' + @PartitionSql + N'
                        ORDER BY ' + @LatestOrderSql + N'
                    ) AS [__ReportRowNumber]
                FROM ' + @RootFrom + N'
            ) ';

        SET @RootFrom = N'[__ReportRoot]';

        SET @LatestPredicate =
            QUOTENAME(@RootAlias) + N'.[__ReportRowNumber] = 1';
    END;

    SELECT @SelectSql = STRING_AGG(
        CONVERT(
            NVARCHAR(MAX),
            SqlExpression + N' AS ' + QUOTENAME(Reference)),
        N', ')
        WITHIN GROUP (ORDER BY SequenceNumber)
    FROM #ReportFields;

    SELECT @JoinSql = STRING_AGG(
        CONVERT(
            NVARCHAR(MAX),
            JoinType + N' JOIN '
            + QUOTENAME(SchemaName) + N'.' + QUOTENAME(TableName)
            + N' AS ' + QUOTENAME(EntityAlias)
            + N' ON ' + OnSql),
        N' ')
        WITHIN GROUP (ORDER BY SequenceNumber)
    FROM #ReportEntities
    WHERE SequenceNumber > 0;

    SELECT @WhereSql = STRING_AGG(
        CONVERT(NVARCHAR(MAX), PredicateSql),
        N' AND ')
    FROM #ReportFilters
    WHERE ScopeSequence = 0;

    IF @LatestPredicate IS NOT NULL
    BEGIN
        SET @WhereSql =
            @LatestPredicate
            + CASE
                WHEN @WhereSql IS NULL THEN N''
                ELSE N' AND ' + @WhereSql
              END;
    END;

    DECLARE @Sorts TABLE
    (
        SequenceNumber INT NOT NULL,
        Reference NVARCHAR(128) NOT NULL,
        Direction NVARCHAR(4) NOT NULL
    );

    INSERT INTO @Sorts
    SELECT
        CONVERT(INT, item.[key]),
        definition.Reference,
        UPPER(definition.Direction)
    FROM OPENJSON(@QueryJson, '$.sorts') AS item
    CROSS APPLY OPENJSON(item.[value])
    WITH
    (
        Reference NVARCHAR(128) '$.reference',
        Direction NVARCHAR(4) '$.direction'
    ) AS definition;

    IF EXISTS
    (
        SELECT 1
        FROM @Sorts AS sort
        WHERE sort.Direction NOT IN (N'ASC', N'DESC')
           OR NOT EXISTS
           (
               SELECT 1
               FROM #ReportFields AS field
               WHERE field.Reference = sort.Reference
           )
    )
    BEGIN
        ;THROW 50615, N'Érvénytelen rendezési beállítás.', 1;
    END;

    SELECT @OrderSql = STRING_AGG(
        CONVERT(
            NVARCHAR(MAX),
            QUOTENAME(Reference) + N' ' + Direction),
        N', ')
        WITHIN GROUP (ORDER BY SequenceNumber)
    FROM @Sorts;

    SET @Sql =
        @PrefixSql
        + N'SELECT ' + @SelectSql
        + N' FROM ' + @RootFrom
        + N' AS ' + QUOTENAME(@RootAlias)
        + CASE
            WHEN @JoinSql IS NULL THEN N''
            ELSE N' ' + @JoinSql
          END
        + CASE
            WHEN @WhereSql IS NULL THEN N''
            ELSE N' WHERE ' + @WhereSql
          END
        + CASE
            WHEN @OrderSql IS NULL THEN N''
            ELSE N' ORDER BY ' + @OrderSql
          END
        + N';';

    EXEC sys.sp_executesql
        @Sql,
        N'@DynamicFieldAsOfDate date',
        @DynamicFieldAsOfDate = @DynamicFieldAsOfDate;
END;
GO
/****** Object:  StoredProcedure [dbo].[usp_ReportBuilder_GetCompanyEmployeeIds]    Script Date: 2026. 11. 10. 21:19:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[usp_ReportBuilder_GetCompanyEmployeeIds]
    @CompanyId INT,
    @DateFrom DATE = NULL,
    @DateTo DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @CompanyId IS NULL OR @CompanyId <= 0
    BEGIN
        ;THROW 50620, N'A cégazonosítónak pozitív számnak kell lennie.', 1;
    END;

    IF
    (
        @DateFrom IS NULL AND @DateTo IS NOT NULL
    )
    OR
    (
        @DateFrom IS NOT NULL AND @DateTo IS NULL
    )
    BEGIN
        ;THROW 50621, N'A kezdő és záró dátumot együtt kell megadni.', 1;
    END;

    IF @DateFrom > @DateTo
    BEGIN
        ;THROW 50622, N'A kezdő dátum nem lehet későbbi a záró dátumnál.', 1;
    END;

    SELECT DISTINCT
        employment.EmployeeId
    FROM dbo.Employment AS employment
    WHERE employment.CompanyId = @CompanyId
      AND
      (
          @DateFrom IS NULL
          OR
          (
              employment.ValidFrom <= @DateTo
              AND
              (
                  employment.ValidTo IS NULL
                  OR employment.ValidTo >= @DateFrom
              )
          )
      )
    ORDER BY employment.EmployeeId;
END;
GO
/****** Object:  StoredProcedure [dbo].[usp_ReportBuilder_GetDatabaseMetadata]    Script Date: 2026. 11. 10. 21:19:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[usp_ReportBuilder_GetDatabaseMetadata]
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @AllowedTables TABLE
    (
        TableName SYSNAME NOT NULL PRIMARY KEY,
        DisplayName NVARCHAR(150) NOT NULL
    );

    INSERT INTO @AllowedTables
    (
        TableName,
        DisplayName
    )
    VALUES
        (N'Employee', N'Munkavállalók'),
        (N'Employment', N'Munkaviszonyok'),
        (N'Company', N'Cégek'),
        (N'EmployeeBankAccount', N'Dolgozói bankszámlák'),
        (N'EmployeeAbsence', N'Dolgozói távollétek'),
        (N'AbsenceType', N'Távolléttípusok'),
        (N'Dependent', N'Eltartottak'),
        (N'EmployeeDependent', N'Dolgozó és eltartott kapcsolatok'),
        (N'RelationshipType', N'Hozzátartozói kapcsolattípusok'),
        (N'WorkSchedule', N'Munkarendek'),
        (N'WorkScheduleDay', N'Munkarend ciklusnapjai'),
        (N'DayType', N'Naptípusok'),
        (N'EmploymentWorkSchedule', N'Munkarend-hozzárendelések'),
        (N'PayrollElement', N'Bérelemek'),
        (N'EmploymentPayrollElement', N'Bérelem-hozzárendelések'),
        (N'PayrollResult', N'Számfejtési eredmények'),
        (N'Constant', N'Konstansok'),
        (N'MasterDataGroup', N'Törzsadatcsoportok'),
        (N'MasterDataField', N'Dinamikus mezők definíciói'),
        (N'FieldType', N'Mezőtípusok'),
        (N'MasterDataFieldOption', N'Választólista-értékek'),
        (N'EmployeeFieldValue', N'Dolgozói dinamikus mezőértékek'),
        (N'PayrollElementFieldValue', N'Bérelemek dinamikus mezőértékei');

    SELECT
        schemaInfo.name AS SchemaName,
        tableInfo.name AS TableName,
        allowed.DisplayName AS TableDisplayName,
        columnInfo.column_id AS ColumnOrder,
        columnInfo.name AS ColumnName,
        sqlType.name AS SqlType,
        CASE
            WHEN sqlType.name IN
                (N'bit')
                THEN N'boolean'
            WHEN sqlType.name IN
                (N'tinyint', N'smallint', N'int', N'bigint')
                THEN N'integer'
            WHEN sqlType.name IN
                (N'decimal', N'numeric', N'money', N'smallmoney',
                 N'float', N'real')
                THEN N'decimal'
            WHEN sqlType.name = N'date'
                THEN N'date'
            WHEN sqlType.name = N'time'
                THEN N'time'
            WHEN sqlType.name IN
                (N'datetime', N'datetime2', N'smalldatetime')
                THEN N'datetime'
            WHEN sqlType.name = N'datetimeoffset'
                THEN N'datetimeoffset'
            WHEN sqlType.name = N'uniqueidentifier'
                THEN N'guid'
            WHEN sqlType.name IN
                (N'binary', N'varbinary', N'image', N'timestamp', N'rowversion')
                THEN N'binary'
            ELSE N'text'
        END AS DataType,
        columnInfo.is_nullable AS IsNullable,
        columnInfo.is_identity AS IsIdentity,
        CAST(
            CASE
                WHEN primaryKeyInfo.KeyOrdinal IS NULL THEN 0
                ELSE 1
            END
            AS BIT
        ) AS IsPrimaryKey,
        primaryKeyInfo.KeyOrdinal AS PrimaryKeyOrder,
        columnInfo.max_length AS MaxLengthBytes,
        columnInfo.precision AS NumericPrecision,
        columnInfo.scale AS NumericScale
    FROM sys.tables AS tableInfo
    INNER JOIN sys.schemas AS schemaInfo
        ON schemaInfo.schema_id = tableInfo.schema_id
    INNER JOIN @AllowedTables AS allowed
        ON allowed.TableName = tableInfo.name
    INNER JOIN sys.columns AS columnInfo
        ON columnInfo.object_id = tableInfo.object_id
    INNER JOIN sys.types AS sqlType
        ON sqlType.user_type_id = columnInfo.system_type_id
       AND sqlType.user_type_id = sqlType.system_type_id
    OUTER APPLY
    (
        SELECT
            indexColumn.key_ordinal AS KeyOrdinal
        FROM sys.indexes AS indexInfo
        INNER JOIN sys.index_columns AS indexColumn
            ON indexColumn.object_id = indexInfo.object_id
           AND indexColumn.index_id = indexInfo.index_id
        WHERE indexInfo.object_id = tableInfo.object_id
          AND indexInfo.is_primary_key = 1
          AND indexColumn.column_id = columnInfo.column_id
          AND indexColumn.key_ordinal > 0
    ) AS primaryKeyInfo
    WHERE schemaInfo.name = N'dbo'
      AND tableInfo.is_ms_shipped = 0
    ORDER BY
        tableInfo.name,
        columnInfo.column_id;

    SELECT
        foreignKey.object_id AS ForeignKeyId,
        foreignKey.name AS ForeignKeyName,
        foreignKeyColumn.constraint_column_id AS ColumnOrder,
        parentSchema.name AS ParentSchemaName,
        parentTable.name AS ParentTableName,
        parentColumn.name AS ParentColumnName,
        referencedSchema.name AS ReferencedSchemaName,
        referencedTable.name AS ReferencedTableName,
        referencedColumn.name AS ReferencedColumnName,
        parentColumn.is_nullable AS IsNullable,
        foreignKey.is_disabled AS IsDisabled,
        foreignKey.is_not_trusted AS IsNotTrusted
    FROM sys.foreign_keys AS foreignKey
    INNER JOIN sys.foreign_key_columns AS foreignKeyColumn
        ON foreignKeyColumn.constraint_object_id = foreignKey.object_id
    INNER JOIN sys.tables AS parentTable
        ON parentTable.object_id = foreignKey.parent_object_id
    INNER JOIN sys.schemas AS parentSchema
        ON parentSchema.schema_id = parentTable.schema_id
    INNER JOIN sys.columns AS parentColumn
        ON parentColumn.object_id = parentTable.object_id
       AND parentColumn.column_id = foreignKeyColumn.parent_column_id
    INNER JOIN sys.tables AS referencedTable
        ON referencedTable.object_id = foreignKey.referenced_object_id
    INNER JOIN sys.schemas AS referencedSchema
        ON referencedSchema.schema_id = referencedTable.schema_id
    INNER JOIN sys.columns AS referencedColumn
        ON referencedColumn.object_id = referencedTable.object_id
       AND referencedColumn.column_id =
           foreignKeyColumn.referenced_column_id
    INNER JOIN @AllowedTables AS allowedParent
        ON allowedParent.TableName = parentTable.name
    INNER JOIN @AllowedTables AS allowedReferenced
        ON allowedReferenced.TableName = referencedTable.name
    WHERE parentSchema.name = N'dbo'
      AND referencedSchema.name = N'dbo'
      AND parentTable.is_ms_shipped = 0
      AND referencedTable.is_ms_shipped = 0
    ORDER BY
        parentTable.name,
        foreignKey.name,
        foreignKeyColumn.constraint_column_id;
END;
GO
/****** Object:  StoredProcedure [dbo].[usp_ReportBuilder_GetDynamicFieldMetadata]    Script Date: 2026. 11. 10. 21:19:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[usp_ReportBuilder_GetDynamicFieldMetadata]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        fieldDefinition.FieldId AS MasterDataFieldId,
        fieldDefinition.Code AS FieldCode,
        fieldDefinition.DisplayName,
        fieldDefinition.DisplayOrder,
        fieldDefinition.IsRequired,
        fieldDefinition.IsUnique,
        fieldGroup.MasterDataGroupId,
        fieldGroup.Code AS GroupCode,
        fieldGroup.Name AS GroupName,
        fieldType.Code AS FieldTypeCode,
        fieldType.Name AS FieldTypeName,
        CASE
            WHEN LEFT(
                UPPER(fieldGroup.Code),
                LEN(N'PAYROLLELEMENT_')
            ) = N'PAYROLLELEMENT_'
                THEN N'PAYROLL_ELEMENT'
            ELSE N'EMPLOYEE'
        END AS OwnerType,
        N'dbo' AS OwnerSchema,
        CASE
            WHEN LEFT(
                UPPER(fieldGroup.Code),
                LEN(N'PAYROLLELEMENT_')
            ) = N'PAYROLLELEMENT_'
                THEN N'PayrollElement'
            ELSE N'Employee'
        END AS OwnerEntity,
        CASE
            WHEN LEFT(
                UPPER(fieldGroup.Code),
                LEN(N'PAYROLLELEMENT_')
            ) = N'PAYROLLELEMENT_'
                THEN N'PayrollElementId'
            ELSE N'EmployeeId'
        END AS OwnerIdColumn,
        N'dbo' AS ValueSchema,
        CASE
            WHEN LEFT(
                UPPER(fieldGroup.Code),
                LEN(N'PAYROLLELEMENT_')
            ) = N'PAYROLLELEMENT_'
                THEN N'PayrollElementFieldValue'
            ELSE N'EmployeeFieldValue'
        END AS ValueEntity,
        CASE
            WHEN LEFT(
                UPPER(fieldGroup.Code),
                LEN(N'PAYROLLELEMENT_')
            ) = N'PAYROLLELEMENT_'
                THEN N'PayrollElementId'
            ELSE N'EmployeeId'
        END AS OwnerForeignKeyColumn,
        N'FieldId' AS FieldIdColumn,
        N'FieldValue' AS ValueColumn,
        N'OptionId' AS OptionIdColumn,
        N'ValidFrom' AS ValidFromColumn,
        N'ValidTo' AS ValidToColumn
    FROM dbo.MasterDataField AS fieldDefinition
    INNER JOIN dbo.MasterDataGroup AS fieldGroup
        ON fieldGroup.MasterDataGroupId =
            fieldDefinition.MasterDataGroupId
    INNER JOIN dbo.FieldType AS fieldType
        ON fieldType.FieldTypeId =
            fieldDefinition.FieldTypeId
    WHERE fieldDefinition.IsActive = 1
    ORDER BY
        fieldGroup.Name,
        fieldDefinition.DisplayOrder,
        fieldDefinition.DisplayName,
        fieldDefinition.FieldId;
END;
GO
/****** Object:  StoredProcedure [dbo].[usp_ReportBuilder_LoadPayrollResults]    Script Date: 2026. 11. 10. 21:19:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[usp_ReportBuilder_LoadPayrollResults]
    @PeriodFrom CHAR(6),
    @PeriodTo CHAR(6),
    @EmployeeIdsJson NVARCHAR(MAX) = NULL,
    @CompanyId INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @PeriodFromDate DATE =
        TRY_CONVERT(DATE, @PeriodFrom + '01', 112);

    DECLARE @PeriodToDate DATE =
        TRY_CONVERT(DATE, @PeriodTo + '01', 112);

    IF @PeriodFromDate IS NULL
        OR @PeriodToDate IS NULL
        OR @PeriodFrom > @PeriodTo
    BEGIN
        ;THROW 50500, N'Érvénytelen havi időszak. A periódust yyyyMM formátumban kell megadni.', 1;
    END;

    IF @CompanyId IS NOT NULL AND @CompanyId <= 0
    BEGIN
        ;THROW 50501, N'Érvénytelen cégazonosító.', 1;
    END;

    CREATE TABLE #SelectedEmployees
    (
        EmployeeId INT NOT NULL PRIMARY KEY
    );

    IF @EmployeeIdsJson IS NOT NULL
    BEGIN
        IF ISJSON(@EmployeeIdsJson) <> 1
        BEGIN
            ;THROW 50502, N'A dolgozóazonosítók listája nem érvényes JSON.', 1;
        END;

        IF EXISTS
        (
            SELECT 1
            FROM OPENJSON(@EmployeeIdsJson) AS item
            WHERE TRY_CONVERT(INT, item.[value]) IS NULL
               OR TRY_CONVERT(INT, item.[value]) <= 0
        )
        BEGIN
            ;THROW 50503, N'A dolgozóazonosítók listája érvénytelen értéket tartalmaz.', 1;
        END;

        INSERT INTO #SelectedEmployees (EmployeeId)
        SELECT DISTINCT TRY_CONVERT(INT, item.[value])
        FROM OPENJSON(@EmployeeIdsJson) AS item;

        IF NOT EXISTS (SELECT 1 FROM #SelectedEmployees)
        BEGIN
            ;THROW 50504, N'A dolgozóazonosítók listája nem lehet üres.', 1;
        END;
    END;

    DECLARE @PeriodToEnd DATE = EOMONTH(@PeriodToDate);

    ;WITH RankedResults AS
    (
        SELECT
            result.PayrollResultId,
            result.RunId,
            result.EmployeeId,
            result.Period,
            result.ResultType,
            result.PayrollElementId,
            result.Amount,
            result.RunDate,
            result.RunByUserId,
            ROW_NUMBER() OVER
            (
                PARTITION BY
                    result.EmployeeId,
                    result.Period,
                    result.PayrollElementId,
                    result.ResultType
                ORDER BY
                    result.RunDate DESC,
                    result.PayrollResultId DESC
            ) AS RowNumber
        FROM dbo.PayrollResult AS result
        WHERE result.Period BETWEEN @PeriodFrom AND @PeriodTo
          AND
          (
              @EmployeeIdsJson IS NULL
              OR EXISTS
              (
                  SELECT 1
                  FROM #SelectedEmployees AS selected
                  WHERE selected.EmployeeId = result.EmployeeId
              )
          )
          AND
          (
              @CompanyId IS NULL
              OR EXISTS
              (
                  SELECT 1
                  FROM dbo.Employment AS employment
                  WHERE employment.EmployeeId = result.EmployeeId
                    AND employment.CompanyId = @CompanyId
                    AND employment.ValidFrom <= @PeriodToEnd
                    AND
                    (
                        employment.ValidTo IS NULL
                        OR employment.ValidTo >= @PeriodFromDate
                    )
              )
          )
    )
    SELECT
        result.PayrollResultId,
        result.RunId,
        result.EmployeeId,
        employee.FirstName,
        employee.LastName,
        result.Period,
        result.ResultType,
        result.PayrollElementId,
        payrollElement.Code AS PayrollElementCode,
        payrollElement.Name AS PayrollElementName,
        result.Amount,
        result.RunDate,
        result.RunByUserId
    FROM RankedResults AS result
    INNER JOIN dbo.Employee AS employee
        ON employee.EmployeeId = result.EmployeeId
    INNER JOIN dbo.PayrollElement AS payrollElement
        ON payrollElement.PayrollElementId = result.PayrollElementId
    WHERE result.RowNumber = 1
    ORDER BY
        result.Period,
        result.EmployeeId,
        payrollElement.Code,
        result.ResultType;
END;
GO
/****** Object:  StoredProcedure [dbo].[usp_Role_Create]    Script Date: 2026. 11. 10. 21:19:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[usp_Role_Create]
    @Code NVARCHAR(50),
    @RoleName NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.[Role] (Code, RoleName, IsActive)
    VALUES (@Code, @RoleName, 1);

    SELECT CONVERT(INT, SCOPE_IDENTITY()) AS RoleId;
END;
GO
/****** Object:  StoredProcedure [dbo].[usp_Role_Search]    Script Date: 2026. 11. 10. 21:19:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[usp_Role_Search]
    @Search NVARCHAR(100) = NULL,
    @IsActive BIT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        RoleId,
        Code,
        RoleName,
        IsActive
    FROM dbo.[Role]
    WHERE
        (
            @Search IS NULL
            OR Code LIKE N'%' + @Search + N'%'
            OR RoleName LIKE N'%' + @Search + N'%'
        )
        AND (@IsActive IS NULL OR IsActive = @IsActive)
    ORDER BY Code, RoleId;
END;
GO
/****** Object:  StoredProcedure [dbo].[usp_Role_Update]    Script Date: 2026. 11. 10. 21:19:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[usp_Role_Update]
    @RoleId INT,
    @Code NVARCHAR(50),
    @RoleName NVARCHAR(100),
    @IsActive BIT,
    @CurrentUserId INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Today DATE = CONVERT(DATE, GETDATE());

    IF @IsActive = 0
       AND EXISTS
       (
           SELECT 1
           FROM dbo.RoleToUser
           WHERE UserId = @CurrentUserId
             AND RoleId = @RoleId
             AND ValidFrom <= @Today
             AND (ValidTo IS NULL OR ValidTo >= @Today)
       )
    BEGIN
        THROW 50006, 'The current user cannot deactivate their assigned role.', 1;
    END;

    UPDATE dbo.[Role]
    SET Code = @Code,
        RoleName = @RoleName,
        IsActive = @IsActive
    WHERE RoleId = @RoleId;

    IF @@ROWCOUNT = 0
    BEGIN
        THROW 50003, 'Role not found.', 1;
    END;
END;
GO
/****** Object:  StoredProcedure [dbo].[usp_RoleToUser_Assign]    Script Date: 2026. 11. 10. 21:19:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[usp_RoleToUser_Assign]
    @UserId INT,
    @RoleId INT,
    @ValidFrom DATE,
    @ValidTo DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @ValidTo IS NOT NULL AND @ValidTo < @ValidFrom
    BEGIN
        THROW 50004, 'ValidTo cannot be earlier than ValidFrom.', 1;
    END;

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.[Role]
        WHERE RoleId = @RoleId
          AND IsActive = 1
    )
    BEGIN
        THROW 50007, 'Role not found or inactive.', 1;
    END;

    IF EXISTS
    (
        SELECT 1
        FROM dbo.RoleToUser
        WHERE UserId = @UserId
          AND RoleId = @RoleId
          AND ValidFrom = @ValidFrom
    )
    BEGIN
        UPDATE dbo.RoleToUser
        SET ValidTo = @ValidTo
        WHERE UserId = @UserId
          AND RoleId = @RoleId
          AND ValidFrom = @ValidFrom;
    END
    ELSE
    BEGIN
        INSERT INTO dbo.RoleToUser (UserId, RoleId, ValidFrom, ValidTo)
        VALUES (@UserId, @RoleId, @ValidFrom, @ValidTo);
    END;
END;
GO
/****** Object:  StoredProcedure [dbo].[usp_RoleToUser_Delete]    Script Date: 2026. 11. 10. 21:19:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[usp_RoleToUser_Delete]
    @UserId INT,
    @RoleId INT,
    @ValidFrom DATE
AS
BEGIN
    SET NOCOUNT ON;

    IF @UserId <= 0 OR @RoleId <= 0 OR @ValidFrom IS NULL
        THROW 50700, N'Érvénytelen felhasználó, szerep vagy érvényességi dátum.', 1;

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.[User]
        WHERE UserId = @UserId
    )
        THROW 50701, N'A felhasználó nem található.', 1;

    DELETE FROM dbo.RoleToUser
    WHERE UserId = @UserId
      AND RoleId = @RoleId
      AND ValidFrom = @ValidFrom;

    IF @@ROWCOUNT = 0
        THROW 50702, N'A szerep-hozzárendelés nem található.', 1;
END;
GO
/****** Object:  StoredProcedure [dbo].[usp_RoleToUser_GetByUserId]    Script Date: 2026. 11. 10. 21:19:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[usp_RoleToUser_GetByUserId]
    @UserId INT,
    @AsOfDate DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SET @AsOfDate = COALESCE(@AsOfDate, CONVERT(DATE, GETDATE()));

    SELECT
        rtu.UserId,
        rtu.RoleId,
        r.Code,
        r.RoleName,
        rtu.ValidFrom,
        rtu.ValidTo
    FROM dbo.RoleToUser AS rtu
    INNER JOIN dbo.[Role] AS r
        ON r.RoleId = rtu.RoleId
    WHERE rtu.UserId = @UserId
      AND rtu.ValidFrom <= @AsOfDate
      AND (rtu.ValidTo IS NULL OR rtu.ValidTo >= @AsOfDate)
      AND r.IsActive = 1
    ORDER BY r.Code;
END;
GO
/****** Object:  StoredProcedure [dbo].[usp_RoleToUser_GetForMaintenance]    Script Date: 2026. 11. 10. 21:19:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[usp_RoleToUser_GetForMaintenance]
    @UserId INT
AS
BEGIN
    SET NOCOUNT ON;

    IF @UserId <= 0
        THROW 50600, N'Érvénytelen felhasználó-azonosító.', 1;

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.[User]
        WHERE UserId = @UserId
    )
        THROW 50601, N'A felhasználó nem található.', 1;

    SELECT
        roleToUser.UserId,
        userRole.RoleId,
        userRole.Code,
        userRole.RoleName,
        userRole.IsActive AS RoleIsActive,
        roleToUser.ValidFrom,
        roleToUser.ValidTo
    FROM dbo.RoleToUser AS roleToUser
    INNER JOIN dbo.[Role] AS userRole
        ON userRole.RoleId = roleToUser.RoleId
    WHERE roleToUser.UserId = @UserId
    ORDER BY
        roleToUser.ValidFrom DESC,
        userRole.RoleName;
END;
GO
/****** Object:  StoredProcedure [dbo].[usp_RuleDataCatalog_GetDynamicFields]    Script Date: 2026. 11. 10. 21:19:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[usp_RuleDataCatalog_GetDynamicFields]
    @Search NVARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        dataGroup.MasterDataGroupId,
        dataGroup.Code AS MasterDataGroupCode,
        dataGroup.Name AS MasterDataGroupName,
        field.FieldId,
        field.Code AS FieldCode,
        field.DisplayName,
        field.FieldTypeId,
        fieldType.Code AS FieldTypeCode,
        fieldType.Name AS FieldTypeName,
        field.IsRequired,
        field.IsUnique,
        field.DisplayOrder,
        field.IsActive
    FROM dbo.MasterDataField AS field
    INNER JOIN dbo.MasterDataGroup AS dataGroup
        ON dataGroup.MasterDataGroupId = field.MasterDataGroupId
    INNER JOIN dbo.FieldType AS fieldType
        ON fieldType.FieldTypeId = field.FieldTypeId
    WHERE field.IsActive = 1
      AND
      (
          @Search IS NULL
          OR @Search = N''
          OR dataGroup.Code LIKE N'%' + @Search + N'%'
          OR dataGroup.Name LIKE N'%' + @Search + N'%'
          OR field.Code LIKE N'%' + @Search + N'%'
          OR field.DisplayName LIKE N'%' + @Search + N'%'
          OR fieldType.Code LIKE N'%' + @Search + N'%'
          OR fieldType.Name LIKE N'%' + @Search + N'%'
      )
    ORDER BY
        dataGroup.Name,
        field.DisplayOrder,
        field.DisplayName;
END;
GO
/****** Object:  StoredProcedure [dbo].[usp_RuleDataCatalog_GetSchema]    Script Date: 2026. 11. 10. 21:19:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[usp_RuleDataCatalog_GetSchema]
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ExcludedTables TABLE
    (
        TableName SYSNAME NOT NULL PRIMARY KEY
    );

    INSERT INTO @ExcludedTables (TableName)
    VALUES
        (N'User'),
        (N'Role'),
        (N'RoleToUser'),
        (N'App'),
        (N'AppToRole'),
        (N'MDGToRole'),
        (N'sysdiagrams'),
        (N'MasterDataGroup'),
        (N'MasterDataField'),
        (N'MasterDataFieldOption'),
        (N'FieldType'),
        (N'EmployeeFieldValue'),
        (N'PayrollElementFieldValue');

    SELECT
        schemaInfo.name AS SchemaName,
        tableInfo.name AS TableName,
        columnInfo.column_id AS ColumnOrder,
        columnInfo.name AS ColumnName,
        typeInfo.name AS DataType,
        CASE
            WHEN typeInfo.name IN (N'nchar', N'nvarchar')
                 AND columnInfo.max_length <> -1
                THEN columnInfo.max_length / 2
            ELSE columnInfo.max_length
        END AS MaxLength,
        columnInfo.precision AS NumericPrecision,
        columnInfo.scale AS NumericScale,
        columnInfo.is_nullable AS IsNullable,
        columnInfo.is_identity AS IsIdentity,
        CONVERT(BIT, CASE WHEN EXISTS
        (
            SELECT 1
            FROM sys.index_columns AS indexColumn
            INNER JOIN sys.indexes AS indexInfo
                ON indexInfo.object_id = indexColumn.object_id
               AND indexInfo.index_id = indexColumn.index_id
            WHERE indexColumn.object_id = columnInfo.object_id
              AND indexColumn.column_id = columnInfo.column_id
              AND indexInfo.is_primary_key = 1
        ) THEN 1 ELSE 0 END) AS IsPrimaryKey,
        CONVERT(BIT, CASE WHEN EXISTS
        (
            SELECT 1
            FROM sys.foreign_key_columns AS foreignKeyColumn
            WHERE foreignKeyColumn.parent_object_id = columnInfo.object_id
              AND foreignKeyColumn.parent_column_id = columnInfo.column_id
        ) THEN 1 ELSE 0 END) AS IsForeignKey
    FROM sys.tables AS tableInfo
    INNER JOIN sys.schemas AS schemaInfo
        ON schemaInfo.schema_id = tableInfo.schema_id
    INNER JOIN sys.columns AS columnInfo
        ON columnInfo.object_id = tableInfo.object_id
    INNER JOIN sys.types AS typeInfo
        ON typeInfo.user_type_id = columnInfo.user_type_id
    WHERE tableInfo.is_ms_shipped = 0
      AND NOT EXISTS
      (
          SELECT 1
          FROM @ExcludedTables AS excluded
          WHERE excluded.TableName = tableInfo.name
      )
    ORDER BY
        schemaInfo.name,
        tableInfo.name,
        columnInfo.column_id;

    SELECT
        foreignKey.name AS ForeignKeyName,
        sourceSchema.name AS SourceSchema,
        sourceTable.name AS SourceTable,
        sourceColumn.name AS SourceColumn,
        targetSchema.name AS TargetSchema,
        targetTable.name AS TargetTable,
        targetColumn.name AS TargetColumn
    FROM sys.foreign_keys AS foreignKey
    INNER JOIN sys.foreign_key_columns AS foreignKeyColumn
        ON foreignKeyColumn.constraint_object_id = foreignKey.object_id
    INNER JOIN sys.tables AS sourceTable
        ON sourceTable.object_id = foreignKeyColumn.parent_object_id
    INNER JOIN sys.schemas AS sourceSchema
        ON sourceSchema.schema_id = sourceTable.schema_id
    INNER JOIN sys.columns AS sourceColumn
        ON sourceColumn.object_id = foreignKeyColumn.parent_object_id
       AND sourceColumn.column_id = foreignKeyColumn.parent_column_id
    INNER JOIN sys.tables AS targetTable
        ON targetTable.object_id = foreignKeyColumn.referenced_object_id
    INNER JOIN sys.schemas AS targetSchema
        ON targetSchema.schema_id = targetTable.schema_id
    INNER JOIN sys.columns AS targetColumn
        ON targetColumn.object_id = foreignKeyColumn.referenced_object_id
       AND targetColumn.column_id = foreignKeyColumn.referenced_column_id
    WHERE NOT EXISTS
      (
          SELECT 1
          FROM @ExcludedTables AS excluded
          WHERE excluded.TableName = sourceTable.name
      )
      AND NOT EXISTS
      (
          SELECT 1
          FROM @ExcludedTables AS excluded
          WHERE excluded.TableName = targetTable.name
      )
    ORDER BY
        sourceSchema.name,
        sourceTable.name,
        foreignKey.name;
END;
GO
/****** Object:  StoredProcedure [dbo].[usp_User_Create]    Script Date: 2026. 11. 10. 21:19:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[usp_User_Create]
    @UserName NVARCHAR(100),
    @PasswordHash NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.[User] (UserName, PasswordHash, IsActive)
    VALUES (@UserName, @PasswordHash, 1);

    SELECT CONVERT(INT, SCOPE_IDENTITY()) AS UserId;
END;
GO
