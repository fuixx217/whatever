DECLARE @Domain NVARCHAR(100)
                        DECLARE @fqdn nvarchar(255)
                        EXEC master.dbo.xp_regread 'HKEY_LOCAL_MACHINE', 'SYSTEM\CurrentControlSet\services\Tcpip\Parameters', N'Domain',@Domain OUTPUT
                        
                        IF OBJECT_ID('master.sys.availability_group_listeners') IS NOT NULL
                        BEGIN
                            IF EXISTS (select 
                                ag.name [availability_group_name]
                                ,agl.dns_name 
                                ,agl.port
                                from sys.availability_group_listeners [agl]
                                inner join sys.availability_groups [ag]
                                on agl.group_id = ag.group_id)
                            BEGIN
                                /* AG Replicas */
                                select
                                ag.name [availability_group_name]
                                ,CASE
                                WHEN ar.replica_server_name LIKE '%\%' THEN LOWER(REPLACE(ar.replica_server_name, '\', '.' + ISNULL(@Domain,'cable.comcast.com') + '\'))
                                ELSE LOWER(ar.replica_server_name + '.' + ISNULL(@Domain,'cable.comcast.com'))
                                END [replica_server_name]
                                ,ar.availability_mode_desc
                                ,ar.failover_mode_desc
                                ,ar.primary_role_allow_connections_desc
                                ,ar.secondary_role_allow_connections_desc
                                ,ar.read_only_routing_url
                                ,ars.role_desc
                                from sys.availability_groups [ag]
                                inner join sys.availability_replicas [ar]
                                on ag.group_id = [ar].[group_id]
                                inner join sys.dm_hadr_availability_group_states [ags]
                                on ag.group_id = [ags].[group_id]
                                inner join sys.dm_hadr_availability_replica_states [ars]
                                on ar.replica_id = ars.replica_id
                                END
							END