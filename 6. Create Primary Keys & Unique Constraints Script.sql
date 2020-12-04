SELECT 'IF NOT EXISTS(SELECT * FROM sys.indexes I INNER JOIN sys.tables T ON T.object_id = I.object_id ' +
       'WHERE I.name = '''+ I.name +''' AND T.name = ''' + T.name +''')' + CHAR(13) + CHAR(10) +
       'BEGIN' + CHAR(13) + CHAR(10) +
        '    ALTER TABLE [' + SCHEMA_NAME(T.schema_id) + '].[' + T.name + '] ADD CONSTRAINT ' +
       '[' + I.name + ']' +
       CASE
           WHEN I.is_primary_key = 1 THEN ' PRIMARY KEY '
           WHEN I.is_unique_constraint = 1 THEN ' UNIQUE '
       END +
       I.type_desc COLLATE DATABASE_DEFAULT + ' (' + tmp4.KeyColumns + ')' + ' WITH (' +
       CASE
           WHEN I.is_padded = 1 THEN 'PAD_INDEX = ON'
           ELSE 'PAD_INDEX = OFF'
       END + ', ' +
       IIF(I.fill_factor <> 0, 'FILLFACTOR = ' + CONVERT(VARCHAR(3), I.fill_factor) + ', ', '') +
       'SORT_IN_TEMPDB = OFF' + ', ' +
       CASE
           WHEN I.ignore_dup_key = 1 THEN 'IGNORE_DUP_KEY = ON'
           ELSE 'IGNORE_DUP_KEY = OFF'
       END + ', ' +
       CASE
           WHEN ST.no_recompute = 0 THEN 'STATISTICS_NORECOMPUTE = OFF'
           ELSE 'STATISTICS_NORECOMPUTE = ON'
       END + ', ' +
       'ONLINE = OFF' + ', ' +
       CASE
           WHEN I.allow_row_locks = 1 THEN 'ALLOW_ROW_LOCKS = ON'
           ELSE 'ALLOW_ROW_LOCKS = OFF'
       END + ', ' +
       CASE
           WHEN I.allow_page_locks = 1 THEN 'ALLOW_PAGE_LOCKS = ON'
           ELSE 'ALLOW_PAGE_LOCKS = OFF'
       END + ') ON [' +
       DS.name + ' ]' + CHAR(13) + CHAR(10) +
       'END' + CHAR(13) + CHAR(10) + 'GO' [CreatePrimaryKeyAndUniqueConstraintScript]
FROM sys.indexes I
INNER JOIN sys.tables T
    ON  T.object_id = I.object_id
INNER JOIN sys.sysindexes SI
    ON  I.object_id = SI.id
    AND I.index_id = SI.indid
INNER JOIN (SELECT *
            FROM (
                SELECT IC2.object_id
                       ,IC2.index_id
                       ,STUFF(
                                (
                                    SELECT ', [' + C.name + ']' + CASE
                                                                      WHEN MAX(CONVERT(INT, IC1.is_descending_key)) = 1 THEN 
                                                                          ' DESC'
                                                                      ELSE 
                                                                          ' ASC'
                                                                  END
                                    FROM   sys.index_columns IC1
                                    JOIN sys.columns C
                                        ON  C.object_id = IC1.object_id
                                        AND C.column_id = IC1.column_id
                                        AND IC1.is_included_column = 0
                                    WHERE IC1.object_id = IC2.object_id
                                          AND IC1.index_id = IC2.index_id
                                    GROUP BY
                                        IC1.object_id,
                                        C.name,
                                        index_id
                                    ORDER BY
                                        MAX(IC1.key_ordinal)
                                    FOR XML PATH('')
                                )
                                ,1
                                ,2
                                ,''
                        ) KeyColumns
                FROM sys.index_columns IC2 
                GROUP BY
                    IC2.object_id,
                    IC2.index_id
                ) tmp3
            ) tmp4
ON I.object_id = tmp4.object_id
    AND I.Index_id = tmp4.index_id
    AND tmp4.KeyColumns IS NOT NULL
INNER JOIN sys.stats ST
ON ST.object_id = I.object_id
    AND ST.stats_id = I.index_id
INNER JOIN sys.data_spaces DS
ON I.data_space_id = DS.data_space_id
INNER JOIN sys.filegroups FG
ON I.data_space_id = FG.data_space_id
WHERE I.is_primary_key = 1
      OR I.is_unique_constraint = 1
