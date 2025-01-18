rcmsans@logs-server:/etc/prometheus/rules$ cat mysql-replication-monitoring-alerts.yml
groups:
  - name: mysql-replication-alerts
    rules:
      # MySQL Replication Alerts
      - alert: MySQLReplicationLag
        expr: mysql_slave_lag_seconds > 60
        for: 5m
        labels:
          service: "MySQL Replication"
          severity: "warning"
        annotations:
          description: "Replication lag on the MySQL slave instance {{ $labels.instance }} has exceeded 60 seconds. This means there is a delay in replicating changes from the master, which could lead to data inconsistency or outdated slave data."
          summary: "Replication lag on MySQL slave is more than 60 seconds."

      - alert: MySQLSlaveIORunning
        expr: mysql_slave_io_running == 0
        for: 5m
        labels:
          service: "MySQL Replication"
          severity: "critical"
        annotations:
          description: "The I/O thread for replication on MySQL slave {{ $labels.instance }} is not running. This thread is responsible for fetching updates from the master server. If it's not running, the slave won't receive any data from the master."
          summary: "MySQL Slave I/O thread is not running."

      - alert: MySQLSlaveSQLRunning
        expr: mysql_slave_sql_running == 0
        for: 5m
        labels:
          service: "MySQL Replication"
          severity: "critical"
        annotations:
          description: "The SQL thread for replication on MySQL slave {{ $labels.instance }} is not running. The SQL thread processes the changes fetched from the master and applies them to the slave. If it's down, the replication will not proceed."
          summary: "MySQL Slave SQL thread is not running."

      - alert: MySQLReplicationStatusDown
        expr: mysql_slave_status{slave_status="Down"} == 1
        for: 5m
        labels:
          service: "MySQL Replication"
          severity: "critical"
        annotations:
          description: "Replication on the MySQL slave {{ $labels.instance }} is down. This indicates that the replication process has failed or was disconnected. Investigate possible connection issues or configuration problems."
          summary: "MySQL Replication is down."

      - alert: MySQLRelayLogSpaceTooLarge
        expr: mysql_slave_relay_log_space > 1073741824  # 1 GB
        for: 5m
        labels:
          service: "MySQL Replication"
          severity: "warning"
        annotations:
          description: "The relay log space on the MySQL slave {{ $labels.instance }} has exceeded 1 GB. Relay logs are used to store changes from the master, and if they grow too large, they can cause disk space issues or delays in replication."
          summary: "MySQL Relay Log Space Too Large."

      - alert: MySQLSlaveIOError
        expr: mysql_slave_io_error == 1
        for: 5m
        labels:
          service: "MySQL Replication"
          severity: "critical"
        annotations:
          description: "An I/O error has occurred on the replication thread for the MySQL slave {{ $labels.instance }}. This could be caused by issues like network connectivity, disk failures, or permission problems."
          summary: "MySQL Slave I/O Thread Error."

      - alert: MySQLSlaveSQLError
        expr: mysql_slave_sql_error == 1
        for: 5m
        labels:
          service: "MySQL Replication"
          severity: "critical"
        annotations:
          description: "An SQL error has occurred on the replication thread for the MySQL slave {{ $labels.instance }}. This could be caused by issues like query conflicts or data inconsistencies."
          summary: "MySQL Slave SQL Thread Error."

      - alert: MySQLReplicationDelayHigh
        expr: mysql_slave_lag_seconds > 300  # 5 minutes
        for: 5m
        labels:
          service: "MySQL Replication"
          severity: "warning"
        annotations:
          description: "The replication delay on the MySQL slave {{ $labels.instance }} has exceeded 5 minutes. This could be caused by network latency, resource constraints, or heavy workload on the slave."
          summary: "MySQL Replication Delay is too high."

      - alert: MySQLReplicationCatchingUp
        expr: mysql_slave_lag_seconds > 600  # 10 minutes
        for: 10m
        labels:
          service: "MySQL Replication"
          severity: "critical"
        annotations:
          description: "The replication on MySQL slave {{ $labels.instance }} is not catching up. The delay has exceeded 10 minutes, which could result in major inconsistencies between the master and slave."
          summary: "MySQL Slave Replication is not catching up."

      - alert: MySQLRelayLogTooLarge
        expr: mysql_slave_relay_log_space > 2e9  # 2 GB
        for: 5m
        labels:
          service: "MySQL Replication"
          severity: "warning"
        annotations:
          description: "The relay log space on the MySQL slave {{ $labels.instance }} has exceeded 2 GB. Large relay logs may lead to performance degradation and disk space issues."
          summary: "MySQL Relay Log Too Large."

      - alert: MySQLReplicationInconsistencies
        expr: mysql_slave_status{slave_status="Error"} == 1
        for: 5m
        labels:
          service: "MySQL Replication"
          severity: "critical"
        annotations:
          description: "There are inconsistencies in the replication process on MySQL slave {{ $labels.instance }}. This could be due to data divergence or errors in replication threads."
          summary: "MySQL Replication Inconsistencies Detected."


  - name: mysql-server-health-alerts
    rules:
      # MySQL Server Health Alerts
      - alert: MySQLHighCPUUsage
        expr: (rate(process_cpu_seconds_total{job="mysql"}[1m]) > 0.85)
        for: 5m
        labels:
          service: "MySQL Server Health"
          severity: "warning"
        annotations:
          description: "The CPU usage for MySQL server {{ $labels.instance }} has exceeded 85%. This could indicate a heavy workload, inefficient queries, or resource contention."
          summary: "High CPU usage on MySQL server."

      - alert: MySQLHighMemoryUsage
        expr: (mysql_global_status_memory_used / mysql_global_status_memory_total) > 0.85
        for: 5m
        labels:
          service: "MySQL Server Health"
          severity: "warning"
        annotations:
          description: "Memory usage for MySQL server {{ $labels.instance }} has exceeded 85%. This may indicate memory leaks, inefficient queries, or a lack of memory resources."
          summary: "High memory usage on MySQL server."

      - alert: MySQLDiskSpaceLow
        expr: (node_filesystem_free_bytes{fstype="ext4", mountpoint="/"} / node_filesystem_size_bytes{fstype="ext4", mountpoint="/"}) < 0.1
        for: 5m
        labels:
          service: "MySQL Server Health"
          severity: "critical"
        annotations:
          description: "Disk space on MySQL server {{ $labels.instance }} is below 10% free. Low disk space can cause MySQL performance issues or even lead to server crashes."
          summary: "Low disk space on MySQL server."

      - alert: MySQLTooManyConnections
        expr: mysql_global_status_threads_connected > 200
        for: 5m
        labels:
          service: "MySQL Server Health"
          severity: "warning"
        annotations:
          description: "MySQL server {{ $labels.instance }} has more than 200 active connections. This can lead to performance degradation, query timeouts, or even server instability."
          summary: "Too many active MySQL connections."

      - alert: MySQLSlowQueries
        expr: mysql_global_status_slow_queries > 100
        for: 5m
        labels:
          service: "MySQL Server Health"
          severity: "warning"
        annotations:
          description: "The number of slow queries on MySQL server {{ $labels.instance }} has exceeded 100. This may indicate inefficient queries or lack of proper indexing."
          summary: "High number of slow queries on MySQL server."

      - alert: MySQLQueryExecutionTimeHigh
        expr: mysql_global_status_queries / mysql_global_status_uptime > 1000
        for: 5m
        labels:
          service: "MySQL Server Health"
          severity: "warning"
        annotations:
          description: "The query execution rate on MySQL server {{ $labels.instance }} is over 1000 queries per second. This could result in high load or resource contention."
          summary: "High query execution rate on MySQL server."

      - alert: MySQLInnoDBBufferPoolUsage
        expr: mysql_innodb_buffer_pool_bytes_data / mysql_innodb_buffer_pool_size > 0.85
        for: 5m
        labels:
          service: "MySQL Server Health"
          severity: "warning"
        annotations:
          description: "InnoDB buffer pool usage on MySQL server {{ $labels.instance }} is over 85%. This may cause performance degradation if the buffer pool is unable to handle the workload."
          summary: "High InnoDB Buffer Pool usage on MySQL server."

      - alert: MySQLAbortedConnections
        expr: mysql_global_status_aborted_connects > 10
        for: 5m
        labels:
          service: "MySQL Server Health"
          severity: "warning"
        annotations:
          description: "The number of aborted connections on MySQL server {{ $labels.instance }} has exceeded 10. This could indicate network issues, authentication problems, or resource limitations."
          summary: "Too many aborted connections on MySQL server."

      - alert: MySQLReplicationNotRunning
        expr: mysql_slave_status{slave_status="Up"} == 0
        for: 5m
        labels:
          service: "MySQL Replication"
          severity: "critical"
        annotations:
          description: "Replication on the MySQL server {{ $labels.instance }} is not running. This could be due to a configuration issue or an error in the replication process."
          summary: "MySQL Replication is not running."

      - alert: MySQLQueryCacheUsage
        expr: mysql_query_cache_size / mysql_global_status_queries > 0.75
        for: 5m
        labels:
          service: "MySQL Server Health"
          severity: "warning"
        annotations:
          description: "The query cache usage on MySQL server {{ $labels.instance }} is over 75%. If query cache is not optimized, it could negatively affect performance."
          summary: "High Query Cache usage on MySQL server."

      - alert: MySQLMaxConnections
        expr: mysql_global_status_max_connections > 500
        for: 5m
        labels:
          service: "MySQL Server Health"
          severity: "critical"
        annotations:
          description: "The maximum number of allowed MySQL connections on server {{ $labels.instance }} is over 500. This could indicate resource exhaustion or inefficient query handling."
          summary: "MySQL server is reaching maximum connections."
