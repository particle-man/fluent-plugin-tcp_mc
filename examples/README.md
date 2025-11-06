# Configuration Examples

This directory contains example Fluentd configurations for the `fluent-plugin-tcp_mc` plugin.

## Examples

### [basic.conf](basic.conf)
A simple single-server configuration suitable for:
- Development environments
- Low-to-medium volume logging
- Simple use cases

Features:
- Single TCP endpoint
- Memory buffer
- Timestamp and tag injection

### [failover.conf](failover.conf)
High-availability configuration with automatic failover:
- Production environments requiring reliability
- Critical logging pipelines
- Multi-datacenter deployments

Features:
- Three-tier failover (primary, secondary, tertiary)
- File-based buffering for persistence
- Fast failover with 3s connection timeout
- Hostname injection for tracking log sources

### [high-throughput.conf](high-throughput.conf)
Optimized for high-volume log processing:
- Large-scale deployments
- High-traffic applications
- Distributed systems

Features:
- Multi-worker support (4 workers)
- Load balancing across multiple servers
- Large memory buffers (16MB chunks)
- Aggressive flush settings for low latency
- Multiple flush threads for parallel processing

## Testing Configurations

Before deploying to production, test your configuration:

```bash
# Validate configuration syntax
fluentd -c examples/basic.conf --dry-run

# Run with verbose logging
fluentd -c examples/basic.conf -vv
```

## Creating a TCP Test Server

For testing, you can create a simple TCP server to receive logs:

```bash
# Using netcat
nc -l 5000

# Using Python
python3 -c "import socket; s=socket.socket(); s.bind(('0.0.0.0',5000)); s.listen(1); c,a=s.accept(); print('Connected:',a); [print(c.recv(4096).decode()) for _ in range(100)]"
```

## Buffer Types

The plugin supports different buffer types:

- **memory**: Fastest, but data lost on restart (good for development)
- **file**: Persistent across restarts (recommended for production)

## Performance Tuning

Key parameters to adjust for performance:

1. **flush_interval**: Lower = lower latency, higher CPU usage
2. **chunk_limit_size**: Larger = better throughput, more memory usage
3. **flush_thread_count**: More threads = better throughput with multiple servers
4. **workers**: More workers = better CPU utilization on multi-core systems

## Production Recommendations

For production deployments:

1. Use **file-based buffers** for reliability
2. Configure **multiple servers** for failover
3. Set appropriate **retry_timeout** (hours, not minutes)
4. Monitor buffer directory disk space
5. Use **overflow_action block** to prevent data loss
6. Enable **hostname injection** for debugging
7. Set **connect_timeout** low (2-5s) for fast failover

## See Also

- [Fluentd Buffer Plugin Documentation](https://docs.fluentd.org/buffer)
- [Fluentd Inject Plugin Documentation](https://docs.fluentd.org/plugin-helper-overview/api-plugin-helper-inject)
- [Plugin README](../README.md)
