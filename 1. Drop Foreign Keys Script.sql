SELECT 'IF EXISTS(SELECT * FROM sys.foreign_keys FK INNER JOIN sys.tables T ON T.object_id = FK.parent_object_id ' +
       'WHERE FK.name = '''+ FK.name +''' AND T.name = ''' + T1.name +''')' + CHAR(13) + CHAR(10) +
       'BEGIN' + CHAR(13) + CHAR(10) +
       '    ALTER TABLE [' + SCHEMA_NAME(T1.schema_id) + '].[' + T1.name + '] ' +
       'DROP CONSTRAINT [' + FK.name + ']' + CHAR(13) + CHAR(10) +
       'END' + CHAR(13) + CHAR(10) + 'GO' [DropForeignKeyScript]
FROM
    sys.foreign_keys FK
INNER JOIN sys.tables T1
ON T1.object_id = FK.parent_object_id