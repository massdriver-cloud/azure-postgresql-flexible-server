## Azure PostgreSQL Flexible Server

Azure PostgreSQL Flexible Server is a fully managed relational database service provided by Microsoft Azure. It offers flexible server configurations and scaling options tailored to meet the needs of diverse workloads. This service is designed for high availability with fast failover capabilities, providing options for geo-redundant backups, and a rich set of compliance certifications ensuring data security and integrity.

### Design Decisions

1. **Private Network Setup**: The PostgreSQL Flexible Server is deployed in a private subnet within a specified virtual network to ensure network security and isolation.
2. **High Availability**: High availability is guaranteed by optionally enabling zone redundant configurations.
3. **PgBouncer**: Integration with PgBouncer is supported for managing idle connections, which can be enabled based on user preference.
4. **Monitoring and Alerts**: Auto-configured CPU, memory, and storage alerts to proactively manage resource utilization and ensure application performance.
5. **Backup Policies**: Geo-redundant backups are enabled to ensure data resilience and availability in the event of a regional failure.
6. **DNS Setup**: A private DNS zone is configured for simplifying database connection management within the virtual network.

### Runbook

#### Server Connection Issues

**Note:** PostgresQL bundle is configured to be isolated on the virtual network. By design, it refuses connection attempts made from outside of the virtual network. To connect, you may need to configure VPN or a jump box.

If you are having trouble connecting to your PostgreSQL Flexible Server, you can troubleshoot using the following Azure CLI commands:

Check the server status:

```sh
az postgres flexible-server show --resource-group <resource-group-name> --name <server-name> --query "{status: userVisibleState}"
```

Verify that the server is in the `Ready` state. If not, further investigate why the server is not ready.

#### PgBouncer Connection Issues

If PgBouncer is enabled and you are experiencing connection issues, verify that the settings are correct:

Check PgBouncer configuration:

```sh
az postgres flexible-server parameter show --resource-group <resource-group-name> --server-name <server-name> --name pgbouncer.enabled
```

Ensure that the value is set to `true`. If not, you may need to enable PgBouncer.

```sh
az postgres flexible-server parameter set --resource-group <resource-group-name> --server-name <server-name> --name pgbouncer.enabled --value true
```

#### Database Performance Issues

To check for performance-related issues such as high CPU, memory, or storage usage:

List all metric alerts:

```sh
az monitor metrics alert list --resource-group <resource-group-name>
```

Review any active alerts related to CPU, memory, or storage usage.

#### PostgreSQL Command-Line Troubleshooting

If you need to troubleshoot at the PostgreSQL level, you can use the following commands:

Connect to the PostgreSQL server:

```sh
psql -h <hostname> -U <username> -d <database-name>
```

Check the database connections:

```sql
SELECT * FROM pg_stat_activity;
```

Monitor the lock conflicts:

```sql
SELECT * FROM pg_locks;
```

Inspect slow running queries:

```sql
SELECT * FROM pg_stat_statements WHERE total_time > 1000 ORDER BY total_time DESC;
```

Ensure that you replace placeholders (`<hostname>`, `<username>`, `<database-name>`, etc.) with actual values relevant to your PostgreSQL server configuration. This will help in diagnosing and resolving performance-related issues more accurately.

