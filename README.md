### Change collation of an existing SQL Server database including tables' columns
#### Why do we need to change a database collation
This is one situation. We already have a database server with collation A and a system that use temporary tables to increase performance. When creating temporary tables, you usualy do not specify collation for each column, so server collation is used as default collation for those columns (text columns). You then restore a database with a different collation B. Your system possibly needs something like a join select between a temporary table with column collation of A and a table from the restored database with collation of B. And this is where a collation conflict error occured
```
Cannot resolve the collation conflict between "<A>" and "<B>" in the equal to operation.
```
If you cannot change server collation, you have to change database collation in order for the system to work

#### Database collation
Changing database collation is pretty simple. We can use SQL Server Management Studio or an alter command 
```sql
ALTER DATABASE <Database Name> COLLATION <New Collation>
```
However this does not affect columns' collation on existing table. Database is used as default collation for new tables and columns if no collation is specified when creating them.

#### Column collation
Column collation is different. We can not change collation of database's columns if they are referenced by one of the following
- An index so does a primary key because a primary key is always indexed
- A foreign key
- A statistic
- A computed column
- A CHECK constrain

So in order to change column's collation we have to drop these references first. Before doing that we need properly to save these constrains and then restore them after changing the collation.

In my case I have a database with just primary key, index and foreign key constrains. I created scripts to generate dropping and creating scripts for these objects below
- [1. Drop Foreign Keys Script.sql](1.%20Drop%20Foreign%20Keys%20Script.sql)
- [2. Drop Primary Keys & Unique Constraints Script.sql](2.%20Drop%20Primary%20Keys%20&%20Unique%20Constraints%20Script.sql)
- [3. Drop Indexes Script.sql](3.%20Drop%20Indexes%20Script.sql)

Corresponding creating scripts
- [5. Create Indexes Script.sql](5.%20Create%20Indexes%20Script.sql)
- [6. Create Primary Keys & Unique Constraints Script.sql](6.%20Create%20Primary%20Keys%20&%20Unique%20Constraints%20Script.sql)
- [7. Create Foreign Keys Script.sql](7.%20Create%20Foreign%20Keys%20Script.sql)

If you have more kind of constrains you would have to create new scripts to generate creating and droping scripts for them.

To generate changing columns' collation script use [4. Change Collumns Collation Script.sql](/4.%20Change%20Collumns%20Collation%20Script.sql)

Notice that dropping foreign keys must be executed before dropping primary keys so these scripts should be executed in the order specified by the prefix number in their name
