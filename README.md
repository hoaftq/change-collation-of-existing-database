### Change collation of an existing SQL Server database including tables' columns

Since we can not change collation of database's columns if they are referenced by one of the following
- An index so does a primary key because a primary key is always indexed
- A foreign key
- A statistic
- A computed column
- A CHECK constrain
So in order to change column's collation we have to drop these references. Before doing that we need properly save these constrains and then restore them after changing the collation.

In my case I have a database with just primary key, index and foreign key constrains. I created scripts to generate dropping and creating scripts for these objects below
- [1. Drop Foreign Keys Script.sql](1.%20Drop%20Foreign%20Keys%20Script.sql)
- [2. Drop Primary Keys & Unique Constraints Script.sql](2.%20Drop%20Primary%20Keys%20&%20Unique%20Constraints%20Script.sql)
- [3. Drop Indexes Script.sql](3.%20Drop%20Indexes%20Script.sql)

And 3 corresponding creating scripts
- [5. Create Indexes Script.sql](5.%20Create%20Indexes%20Script.sql)
- [6. Create Primary Keys & Unique Constraints Script.sql](6.%20Create%20Primary%20Keys%20&%20Unique%20Constraints%20Script.sql)
- [7. Create Foreign Keys Script.sql](7.%20Create%20Foreign%20Keys%20Script.sql)

To generate changing columns' collation script use [4. Change Collumns Collation Script.sql](/4.%20Change%20Collumns%20Collation%20Script.sql)

Notice that dropping foreign keys must be executed before dropping primary keys so these sripts should be executed in the order specified by the prefix number in their name
