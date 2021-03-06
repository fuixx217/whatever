/* S.Kusen Feb 6, 2015

This script will do the following:
1. Create the [DEMO_DBAInventory] and [DEMO_DBARepository] databases if they don't exist
2. Drop and create the [dbo].[instances] table in [DEMO_DBAInventory]
	*Use the second script to populate the instances table
3. Drop and create the [dbo].[database_information] table in [DEMO_DBARepository]

*/



/*Create the Inventory database*/
IF NOT EXISTS (select name from sys.databases where name = 'DEMO_DBAInventory')
BEGIN
	CREATE DATABASE [DEMO_DBAInventory];
END
GO

/*Create the Repository database*/
IF NOT EXISTS (select name from sys.databases where name = 'DEMO_DBARepository')
BEGIN
	CREATE DATABASE [DEMO_DBARepository];
END
GO


/*create the instances table in the inventory database*/
USE [DEMO_DBAInventory]
GO

IF EXISTS (select name from sys.tables where name = 'instances')
BEGIN
	DROP TABLE [dbo].[instances]
END

CREATE TABLE [dbo].[instances](
	[instance_name] [varchar](255) NOT NULL,
 CONSTRAINT [PK_instances] PRIMARY KEY CLUSTERED 
(
	[instance_name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO




/*create the database_information table in the repository database*/
USE [DEMO_DBARepository]
GO

IF EXISTS (select name from sys.tables where name = 'database_information')
BEGIN
	DROP TABLE [dbo].[database_information]
END

CREATE TABLE [dbo].[database_information](
	[instance_name] [varchar](255) NOT NULL,
	[database_name] [varchar](255) NOT NULL,
	[insert_date_time] datetime NULL
 CONSTRAINT [PK_database_information] PRIMARY KEY CLUSTERED 
(
	[instance_name] ASC,
	[database_name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

--add default value to insert_date_time
ALTER TABLE dbo.database_information ADD CONSTRAINT
	DF_database_information_insert_date_time DEFAULT getdate() FOR insert_date_time
GO