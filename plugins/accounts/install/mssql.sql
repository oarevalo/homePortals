/*** SQL script to create Account table for HomePortals ***/

if exists (select * from dbo.sysobjects where id = object_id(N'dbo.cfe_user') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table dbo.cfe_user
GO
			
CREATE TABLE dbo.[cfe_user] (
	[userID] [nvarchar] (35) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[username] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[password] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[firstName] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[middleName] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[lastName] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[email] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[CreateDate] [datetime] NOT NULL CONSTRAINT [DF_cfe_user_CreateDate] DEFAULT (getdate()),
	CONSTRAINT [PK__cfe_user__4E5E8EA2] PRIMARY KEY  CLUSTERED 
	(
		[userID]
	)  ON [PRIMARY] 
) ON [PRIMARY]
GO
			