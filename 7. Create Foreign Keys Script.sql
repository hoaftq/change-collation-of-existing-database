SELECT
    'IF NOT EXISTS(SELECT * FROM sys.foreign_keys FK INNER JOIN sys.tables T ON T.object_id = FK.parent_object_id ' +
    'WHERE FK.name = '''+ FK.name +''' AND T.name = ''' + T1.name +''')' + CHAR(13) + CHAR(10) +
    'BEGIN' + CHAR(13) + CHAR(10) +
    '    ALTER TABLE [' + SCHEMA_NAME(T1.schema_id) + '].[' + T1.name + ']' +
    ' WITH CHECK ADD CONSTRAINT [' + FK.name + ']' +
    ' FOREIGN KEY (' +
        STUFF(
        (SELECT
            ', [' + C1.name + ']'
         FROM
             sys.columns C1
         INNER JOIN sys.foreign_key_columns FKC1
         ON C1.object_id = FKC1.parent_object_id
            AND C1.column_id = FKC1.parent_column_id
         WHERE
             FKC1.constraint_object_id = FK.object_id
         FOR XML PATH('')),
         1,
         2,
         '') +
    ')' + CHAR(13) + CHAR(10) +
    '    REFERENCES [' + SCHEMA_NAME(T2.schema_id) + '].[' + T2.name + ']' +
    '(' + 
        STUFF(
        (SELECT
            ', [' + C2.name + ']'
         FROM
             sys.columns C2
         INNER JOIN sys.foreign_key_columns FKC2
         ON C2.object_id = FKC2.referenced_object_id
            AND C2.column_id = FKC2.referenced_column_id
         WHERE
             FKC2.constraint_object_id = FK.object_id
         FOR XML PATH('')),
         1,
         2,
         '') +
    ')' + 
    CASE FK.delete_referential_action
       WHEN 1 THEN CHAR(13) + CHAR(10) + '    ON DELETE CASCADE'
       WHEN 2 THEN CHAR(13) + CHAR(10) + '    ON DELETE SET NULL'
       WHEN 3 THEN CHAR(13) + CHAR(10) + '    ON DELETE SET DEFAULT'
       ELSE ''
    END +
    CASE FK.update_referential_action
       WHEN 1 THEN CHAR(13) + CHAR(10) + '    ON UPDATE CASCADE'
       WHEN 2 THEN CHAR(13) + CHAR(10) + '    ON UPDATE SET NULL'
       WHEN 3 THEN CHAR(13) + CHAR(10) + '    ON UPDATE SET DEFAULT'
       ELSE ''
    END + CHAR(13) + CHAR(10) +
    '    ALTER TABLE [' + SCHEMA_NAME(T1.schema_id) + '].[' + T1.name + '] ' +
    'CHECK CONSTRAINT [' + FK.name + ']' + CHAR(13) + CHAR(10) +
    'END' + CHAR(13) + CHAR(10) + 'GO' [CreateForeignKeyScript]
FROM
    sys.foreign_keys FK
INNER JOIN sys.tables T1
ON T1.object_id = FK.parent_object_id
INNER JOIN sys.tables T2
ON T2.object_id = FK.referenced_object_id