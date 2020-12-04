SELECT 'IF EXISTS(SELECT * FROM sys.indexes I INNER JOIN sys.tables T ON T.object_id = I.object_id ' +
       'WHERE I.name = '''+ I.name +''' AND T.name = ''' + T.name +''')' + CHAR(13) + CHAR(10) +
       'BEGIN' + CHAR(13) + CHAR(10) +
       '    DROP INDEX [' + I.name + '] ON [' + SCHEMA_NAME(T.schema_id) + '].[' + T.name + ']' + CHAR(13) + CHAR(10) +
       'END' + CHAR(13) + CHAR(10) + 'GO' [DropIndexScript]
FROM sys.indexes I
INNER JOIN sys.tables T
    ON  T.object_id = I.object_id
INNER JOIN sys.sysindexes SI
    ON  I.object_id = SI.id
    AND I.index_id = SI.indid
WHERE I.is_primary_key = 0
      AND I.is_unique_constraint = 0
      AND I.name IS NOT NULL