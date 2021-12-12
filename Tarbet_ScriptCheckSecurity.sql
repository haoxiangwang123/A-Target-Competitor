USE Tarbet
GO

/** Logins and corresponding Usernames **/
SELECT l.name AS Logins, u.name AS UserNames
FROM sys.syslogins AS l JOIN sys.sysusers AS u
    ON l.sid = u.sid;

/** User-defined database roles and their permissions **/
SELECT Princ.name, Princ.type_desc, Perm.permission_name, Perm.state_desc, Perm.class_desc, OBJECT_NAME(Perm.major_id)
FROM sys.database_principals AS Princ LEFT JOIN sys.database_permissions AS Perm
        ON Perm.grantee_principal_id = Princ.principal_id
WHERE Princ.name IN ('Visitor', 'Customer', 'Store', 'Warehouse', 'Supplier', 'TarbetAdministrator');

/** Database roles and their members **/
SELECT Princ1.name AS DatabaseRole, Princ2.name AS DatabaseRoleMember 
FROM sys.database_role_members AS RoleMembers 
    RIGHT OUTER JOIN sys.database_principals AS Princ1
        ON RoleMembers.role_principal_id = Princ1.principal_id  
    LEFT OUTER JOIN sys.database_principals AS Princ2
        ON RoleMembers.member_principal_id = Princ2.principal_id
WHERE Princ1.type = 'R' AND Princ1.name IN ('Visitor', 'Customer', 'Store', 'Warehouse', 'Supplier', 'TarbetAdministrator', 'db_datareader', 'db_datawriter', 'db_owner');
