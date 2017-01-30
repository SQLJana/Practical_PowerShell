--http://www.databasejournal.com/features/mssql/article.php/3914366/Collecting-Performance-Metrics-Using-SQL-Server-DMV.htm

--Collecting Performance Metrics Using SQL Server DMV
--By Gregory A. Larsen 


DECLARE @SQLProcessUtilization INT; 
DECLARE @PageReadsPerSecond BIGINT 
DECLARE @PageWritesPerSecond BIGINT 
DECLARE @CheckpointPagesPerSecond BIGINT 
DECLARE @LazyWritesPerSecond BIGINT 
DECLARE @BatchRequestsPerSecond BIGINT 
DECLARE @CompilationsPerSecond BIGINT 
DECLARE @ReCompilationsPerSecond BIGINT 
DECLARE @PageLookupsPerSecond BIGINT 
DECLARE @TransactionsPerSecond BIGINT 
DECLARE @stat_date DATETIME 
-- Table for First Sample 
DECLARE @RatioStatsX TABLE 
  ( 
     [object_name]   VARCHAR(128), 
     [counter_name]  VARCHAR(128), 
     [instance_name] VARCHAR(128), 
     [cntr_value]    BIGINT, 
     [cntr_type]     INT 
  ) 
-- Table for Second Sample 
DECLARE @RatioStatsY TABLE 
  ( 
     [object_name]   VARCHAR(128), 
     [counter_name]  VARCHAR(128), 
     [instance_name] VARCHAR(128), 
     [cntr_value]    BIGINT, 
     [cntr_type]     INT 
  ) 

INSERT INTO @RatioStatsX 
            ([object_name], 
             [counter_name], 
             [instance_name], 
             [cntr_value], 
             [cntr_type]) 
SELECT [object_name], 
       [counter_name], 
       [instance_name], 
       [cntr_value], 
       [cntr_type] 
FROM   sys.dm_os_performance_counters 

SET @stat_date = Getdate() 

SELECT TOP 1 @PageReadsPerSecond = cntr_value 
FROM   @RatioStatsX 
WHERE  counter_name = 'Page reads/sec' 
       AND object_name = CASE 
                           WHEN @@SERVICENAME = 'MSSQLSERVER' THEN 
                           'SQLServer:Buffer Manager' 
                           ELSE 'MSSQL$' + Rtrim(@@SERVICENAME) 
                                + ':Buffer Manager' 
                         END 

SELECT TOP 1 @PageWritesPerSecond = cntr_value 
FROM   @RatioStatsX 
WHERE  counter_name = 'Page writes/sec' 
       AND object_name = CASE 
                           WHEN @@SERVICENAME = 'MSSQLSERVER' THEN 
                           'SQLServer:Buffer Manager' 
                           ELSE 'MSSQL$' + Rtrim(@@SERVICENAME) 
                                + ':Buffer Manager' 
                         END 

SELECT TOP 1 @CheckpointPagesPerSecond = cntr_value 
FROM   @RatioStatsX 
WHERE  counter_name = 'Checkpoint pages/sec' 
       AND object_name = CASE 
                           WHEN @@SERVICENAME = 'MSSQLSERVER' THEN 
                           'SQLServer:Buffer Manager' 
                           ELSE 'MSSQL$' + Rtrim(@@SERVICENAME) 
                                + ':Buffer Manager' 
                         END 

SELECT TOP 1 @LazyWritesPerSecond = cntr_value 
FROM   @RatioStatsX 
WHERE  counter_name = 'Lazy writes/sec' 
       AND object_name = CASE 
                           WHEN @@SERVICENAME = 'MSSQLSERVER' THEN 
                           'SQLServer:Buffer Manager' 
                           ELSE 'MSSQL$' + Rtrim(@@SERVICENAME) 
                                + ':Buffer Manager' 
                         END 

SELECT TOP 1 @BatchRequestsPerSecond = cntr_value 
FROM   @RatioStatsX 
WHERE  counter_name = 'Batch Requests/sec' 
       AND object_name = CASE 
                           WHEN @@SERVICENAME = 'MSSQLSERVER' THEN 
                           'SQLServer:SQL Statistics' 
                           ELSE 'MSSQL$' + Rtrim(@@SERVICENAME) 
                                + ':SQL Statistics' 
                         END 

SELECT TOP 1 @CompilationsPerSecond = cntr_value 
FROM   @RatioStatsX 
WHERE  counter_name = 'SQL Compilations/sec' 
       AND object_name = CASE 
                           WHEN @@SERVICENAME = 'MSSQLSERVER' THEN 
                           'SQLServer:SQL Statistics' 
                           ELSE 'MSSQL$' + Rtrim(@@SERVICENAME) 
                                + ':SQL Statistics' 
                         END 

SELECT TOP 1 @ReCompilationsPerSecond = cntr_value 
FROM   @RatioStatsX 
WHERE  counter_name = 'SQL Re-Compilations/sec' 
       AND object_name = CASE 
                           WHEN @@SERVICENAME = 'MSSQLSERVER' THEN 
                           'SQLServer:SQL Statistics' 
                           ELSE 'MSSQL$' + Rtrim(@@SERVICENAME) 
                                + ':SQL Statistics' 
                         END 

SELECT TOP 1 @PageLookupsPerSecond = cntr_value 
FROM   @RatioStatsX 
WHERE  counter_name = 'Page lookups/sec' 
       AND object_name = CASE 
                           WHEN @@SERVICENAME = 'MSSQLSERVER' THEN 
                           'SQLServer:Buffer Manager' 
                           ELSE 'MSSQL$' + Rtrim(@@SERVICENAME) 
                                + ':Buffer Manager' 
                         END 

SELECT TOP 1 @TransactionsPerSecond = cntr_value 
FROM   @RatioStatsX 
WHERE  counter_name = 'Transactions/sec' 
       AND instance_name = '_Total' 
       AND object_name = CASE 
                           WHEN @@SERVICENAME = 'MSSQLSERVER' THEN 
                           'SQLServer:Databases' 
                           ELSE 'MSSQL$' + Rtrim(@@SERVICENAME) + ':Databases' 
                         END 

-- Wait for 5 seconds before taking second sample 
WAITFOR delay '00:00:05' 

-- Table for second sample 
INSERT INTO @RatioStatsY 
            ([object_name], 
             [counter_name], 
             [instance_name], 
             [cntr_value], 
             [cntr_type]) 
SELECT [object_name], 
       [counter_name], 
       [instance_name], 
       [cntr_value], 
       [cntr_type] 
FROM   sys.dm_os_performance_counters 

SELECT ( a.cntr_value * 1.0 / b.cntr_value ) * 100.0 [BufferCacheHitRatio], 
       c.[pagereadpersec]                            [PageReadsPerSec], 
       d.[pagewritespersecond]                       [PageWritesPerSecond], 
       e.cntr_value                                  [UserConnections], 
       f.cntr_value                                  [PageLifeExpectency], 
       g.[checkpointpagespersecond]                  [CheckpointPagesPerSecond], 
       h.[lazywritespersecond]                       [LazyWritesPerSecond], 
       i.cntr_value                                  [FreeSpaceInTempdbKB], 
       j.[batchrequestspersecond]                    [BatchRequestsPerSecond], 
       k.[sqlcompilationspersecond]                  [SQLCompilationsPerSecond], 
       l.[sqlrecompilationspersecond] 
       [SQLReCompilationsPerSecond], 
       m.cntr_value                                  [Target Server Memory (KB)] 
       , 
       n.cntr_value 
       [Total Server Memory (KB)], 
       Getdate()                                     AS [MeasurementTime], 
       o.[avgtaskcount], 
       o.[avgrunnabletaskcount], 
       o.[avgpendingdiskiocount], 
       p.percentsignalwait                           AS [PercentSignalWait], 
       q.pagelookupspersecond                        AS [PageLookupsPerSecond], 
       r.transactionspersecond                       AS [TransactionsPerSecond], 
       s.cntr_value                                  [MemoryGrantsPending] 
FROM   (SELECT *, 
               1 x 
        FROM   @RatioStatsY 
        WHERE  counter_name = 'Buffer cache hit ratio' 
               AND object_name = CASE 
                                   WHEN @@SERVICENAME = 'MSSQLSERVER' THEN 
                                   'SQLServer:Buffer Manager' 
                                   ELSE 'MSSQL$' + Rtrim(@@SERVICENAME) 
                                        + ':Buffer Manager' 
                                 END) a 
       JOIN (SELECT *, 
                    1 x 
             FROM   @RatioStatsY 
             WHERE  counter_name = 'Buffer cache hit ratio base' 
                    AND object_name = CASE 
                                        WHEN @@SERVICENAME = 'MSSQLSERVER' THEN 
                                        'SQLServer:Buffer Manager' 
                                        ELSE 'MSSQL$' + Rtrim(@@SERVICENAME) 
                                             + ':Buffer Manager' 
                                      END) b 
         ON a.x = b.x 
       JOIN (SELECT ( cntr_value - @PageReadsPerSecond ) / ( CASE 
                                                               WHEN 
                                        Datediff(ss, @stat_date, Getdate 
                                        ()) = 0 THEN 1 
                                                               ELSE 
                                        Datediff(ss, @stat_date, Getdate 
                                        ()) 
                                                             END ) AS 
                    [PageReadPerSec], 
                    1                                              x 
             FROM   @RatioStatsY 
             WHERE  counter_name = 'Page reads/sec' 
                    AND object_name = CASE 
                                        WHEN @@SERVICENAME = 'MSSQLSERVER' THEN 
                                        'SQLServer:Buffer Manager' 
                                        ELSE 'MSSQL$' + Rtrim(@@SERVICENAME) 
                                             + ':Buffer Manager' 
                                      END)c 
         ON a.x = c.x 
       JOIN (SELECT ( cntr_value - @PageWritesPerSecond ) / ( CASE 
                                                                WHEN 
                                        Datediff(ss, @stat_date, 
                                        Getdate()) = 0 THEN 1 
                                                                ELSE 
                                        Datediff(ss, @stat_date, 
                                        Getdate()) 
                                                              END ) AS 
                                   [PageWritesPerSecond] 
                                        , 
                    1 
                                        x 
             FROM   @RatioStatsY 
             WHERE  counter_name = 'Page writes/sec' 
                    AND object_name = CASE 
                                        WHEN @@SERVICENAME = 'MSSQLSERVER' THEN 
                                        'SQLServer:Buffer Manager' 
                                        ELSE 'MSSQL$' + Rtrim(@@SERVICENAME) 
                                             + ':Buffer Manager' 
                                      END) d 
         ON a.x = d.x 
       JOIN (SELECT *, 
                    1 x 
             FROM   @RatioStatsY 
             WHERE  counter_name = 'User Connections' 
                    AND object_name = CASE 
                                        WHEN @@SERVICENAME = 'MSSQLSERVER' THEN 
                                        'SQLServer:General Statistics' 
                                        ELSE 'MSSQL$' + Rtrim(@@SERVICENAME) 
                                             + ':General Statistics' 
                                      END) e 
         ON a.x = e.x 
       JOIN (SELECT *, 
                    1 x 
             FROM   @RatioStatsY 
             WHERE  counter_name = 'Page life expectancy ' 
                    AND object_name = CASE 
                                        WHEN @@SERVICENAME = 'MSSQLSERVER' THEN 
                                        'SQLServer:Buffer Manager' 
                                        ELSE 'MSSQL$' + Rtrim(@@SERVICENAME) 
                                             + ':Buffer Manager' 
                                      END) f 
         ON a.x = f.x 
       JOIN (SELECT ( cntr_value - @CheckpointPagesPerSecond ) / ( CASE 
                                        WHEN 
                                                Datediff(ss, @stat_date, Getdate 
                                                ()) = 0 
                                   THEN 
                                        1 
                                                                     ELSE 
                                                Datediff(ss, @stat_date, Getdate 
                                                ()) 
                                                                   END ) AS 
                    [CheckpointPagesPerSecond], 
                    1                                                    x 
             FROM   @RatioStatsY 
             WHERE  counter_name = 'Checkpoint pages/sec' 
                    AND object_name = CASE 
                                        WHEN @@SERVICENAME = 'MSSQLSERVER' THEN 
                                        'SQLServer:Buffer Manager' 
                                        ELSE 'MSSQL$' + Rtrim(@@SERVICENAME) 
                                             + ':Buffer Manager' 
                                      END) g 
         ON a.x = g.x 
       JOIN (SELECT ( cntr_value - @LazyWritesPerSecond ) / ( CASE 
                                                                WHEN 
                                        Datediff(ss, @stat_date, 
                                        Getdate()) = 0 THEN 1 
                                                                ELSE 
                                        Datediff(ss, @stat_date, 
                                        Getdate()) 
                                                              END ) AS 
                                   [LazyWritesPerSecond] 
                                        , 
                    1 
                                        x 
             FROM   @RatioStatsY 
             WHERE  counter_name = 'Lazy writes/sec' 
                    AND object_name = CASE 
                                        WHEN @@SERVICENAME = 'MSSQLSERVER' THEN 
                                        'SQLServer:Buffer Manager' 
                                        ELSE 'MSSQL$' + Rtrim(@@SERVICENAME) 
                                             + ':Buffer Manager' 
                                      END) h 
         ON a.x = h.x 
       JOIN (SELECT *, 
                    1 x 
             FROM   @RatioStatsY 
             WHERE  counter_name = 'Free Space in tempdb (KB)' 
                    AND object_name = CASE 
                                        WHEN @@SERVICENAME = 'MSSQLSERVER' THEN 
                                        'SQLServer:Transactions' 
                                        ELSE 'MSSQL$' + Rtrim(@@SERVICENAME) 
                                             + ':Transactions' 
                                      END) i 
         ON a.x = i.x 
       JOIN (SELECT ( cntr_value - @BatchRequestsPerSecond ) / ( CASE 
                                                                   WHEN 
                                        Datediff(ss, @stat_date, 
                                        Getdate()) = 0 THEN 1 
                                                                   ELSE 
                                        Datediff(ss, @stat_date, 
                                        Getdate()) 
                                                                 END ) AS 
                                        [BatchRequestsPerSecond], 
                    1                                                  x 
             FROM   @RatioStatsY 
             WHERE  counter_name = 'Batch Requests/sec' 
                    AND object_name = CASE 
                                        WHEN @@SERVICENAME = 'MSSQLSERVER' THEN 
                                        'SQLServer:SQL Statistics' 
                                        ELSE 'MSSQL$' + Rtrim(@@SERVICENAME) 
                                             + ':SQL Statistics' 
                                      END) j 
         ON a.x = j.x 
       JOIN (SELECT ( cntr_value - @CompilationsPerSecond ) / ( CASE 
                                                                  WHEN 
                                        Datediff(ss, @stat_date, 
                                        Getdate()) = 0 THEN 1 
                                                                  ELSE 
                                        Datediff(ss, @stat_date, 
                                        Getdate()) 
                                                                END ) AS 
                                        [SQLCompilationsPerSecond], 
                    1                                                 x 
             FROM   @RatioStatsY 
             WHERE  counter_name = 'SQL Compilations/sec' 
                    AND object_name = CASE 
                                        WHEN @@SERVICENAME = 'MSSQLSERVER' THEN 
                                        'SQLServer:SQL Statistics' 
                                        ELSE 'MSSQL$' + Rtrim(@@SERVICENAME) 
                                             + ':SQL Statistics' 
                                      END) k 
         ON a.x = k.x 
       JOIN (SELECT ( cntr_value - @ReCompilationsPerSecond ) / ( CASE 
                                                                    WHEN 
                                        Datediff(ss, @stat_date, 
                                        Getdate()) = 0 THEN 1 
                                                                    ELSE 
                                        Datediff(ss, @stat_date, 
                                        Getdate()) 
                                                                  END ) AS 
                    [SQLReCompilationsPerSecond], 
                    1                                                   x 
             FROM   @RatioStatsY 
             WHERE  counter_name = 'SQL Re-Compilations/sec' 
                    AND object_name = CASE 
                                        WHEN @@SERVICENAME = 'MSSQLSERVER' THEN 
                                        'SQLServer:SQL Statistics' 
                                        ELSE 'MSSQL$' + Rtrim(@@SERVICENAME) 
                                             + ':SQL Statistics' 
                                      END) l 
         ON a.x = l.x 
       JOIN (SELECT *, 
                    1 x 
             FROM   @RatioStatsY 
             WHERE  counter_name = 'Target Server Memory (KB)' 
                    AND object_name = CASE 
                                        WHEN @@SERVICENAME = 'MSSQLSERVER' THEN 
                                        'SQLServer:Memory Manager' 
                                        ELSE 'MSSQL$' + Rtrim(@@SERVICENAME) 
                                             + ':Memory Manager' 
                                      END) m 
         ON a.x = m.x 
       JOIN (SELECT *, 
                    1 x 
             FROM   @RatioStatsY 
             WHERE  counter_name = 'Total Server Memory (KB)' 
                    AND object_name = CASE 
                                        WHEN @@SERVICENAME = 'MSSQLSERVER' THEN 
                                        'SQLServer:Memory Manager' 
                                        ELSE 'MSSQL$' + Rtrim(@@SERVICENAME) 
                                             + ':Memory Manager' 
                                      END) n 
         ON a.x = n.x 
       JOIN (SELECT 1                          AS x, 
                    Avg(current_tasks_count)   AS [AvgTaskCount], 
                    Avg(runnable_tasks_count)  AS [AvgRunnableTaskCount], 
                    Avg(pending_disk_io_count) AS [AvgPendingDiskIOCount] 
             FROM   sys.dm_os_schedulers 
             WHERE  scheduler_id < 255) o 
         ON a.x = o.x 
       JOIN (SELECT 1                                             AS x, 
                    Sum(signal_wait_time_ms) / Sum (wait_time_ms) AS 
                    PercentSignalWait 
             FROM   sys.dm_os_wait_stats) p 
         ON a.x = p.x 
       JOIN (SELECT ( cntr_value - @PageLookupsPerSecond ) / ( CASE 
                                                                 WHEN 
                                        Datediff(ss, @stat_date, 
                                        Getdate()) = 0 THEN 1 
                                                                 ELSE 
                                        Datediff(ss, @stat_date, 
                                        Getdate()) 
                                                               END ) AS 
                                        [PageLookupsPerSecond], 
                    1                                                x 
             FROM   @RatioStatsY 
             WHERE  counter_name = 'Page Lookups/sec' 
                    AND object_name = CASE 
                                        WHEN @@SERVICENAME = 'MSSQLSERVER' THEN 
                                        'SQLServer:Buffer Manager' 
                                        ELSE 'MSSQL$' + Rtrim(@@SERVICENAME) 
                                             + ':Buffer Manager' 
                                      END) q 
         ON a.x = q.x 
       JOIN (SELECT ( cntr_value - @TransactionsPerSecond ) / ( CASE 
                                                                  WHEN 
                                        Datediff(ss, @stat_date, 
                                        Getdate()) = 0 THEN 1 
                                                                  ELSE 
                                        Datediff(ss, @stat_date, 
                                        Getdate()) 
                                                                END ) AS 
                                        [TransactionsPerSecond], 
                    1                                                 x 
             FROM   @RatioStatsY 
             WHERE  counter_name = 'Transactions/sec' 
                    AND instance_name = '_Total' 
                    AND object_name = CASE 
                                        WHEN @@SERVICENAME = 'MSSQLSERVER' THEN 
                                        'SQLServer:Databases' 
                                        ELSE 'MSSQL$' + Rtrim(@@SERVICENAME) + 
                                             ':Databases' 
                                      END) r 
         ON a.x = r.x 
       JOIN (SELECT *, 
                    1 x 
             FROM   @RatioStatsY 
             WHERE  counter_name = 'Memory Grants Pending' 
                    AND object_name = CASE 
                                        WHEN @@SERVICENAME = 'MSSQLSERVER' THEN 
                                        'SQLServer:Memory Manager' 
                                        ELSE 'MSSQL$' + Rtrim(@@SERVICENAME) 
                                             + ':Memory Manager' 
                                      END) s 
         ON a.x = s.x   