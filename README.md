# fluent-plugin-tcp_mc

[![Gem Version](https://badge.fury.io/rb/fluent-plugin-tcp_mc.svg)](https://badge.fury.io/rb/fluent-plugin-tcp_mc)
[![CI](https://github.com/particle-man/fluent-plugin-tcp_mc/actions/workflows/ci.yml/badge.svg)](https://github.com/particle-man/fluent-plugin-tcp_mc/actions/workflows/ci.yml)
[![Anchore CVE Scan](https://github.com/particle-man/fluent-plugin-tcp_mc/actions/workflows/anchore-cve-scan.yml/badge.svg)](https://github.com/particle-man/fluent-plugin-tcp_mc/actions/workflows/anchore-cve-scan.yml)

[Fluentd](http://fluentd.org/) output plugin to send JSON-formatted logs to generic TCP endpoints.

## Features

- **Multi-worker support** - Efficiently handles high-volume log streams
- **Automatic failover** - Cycles through multiple configured servers on connection failure
- **Configurable timeouts** - Fine-tune connection and send timeouts
- **Modern Fluentd API** - Built on the latest Fluentd plugin architecture
- **Production-ready** - Used in production environments

This plugin was inspired by the rawtcp output from Uken Games.

## Installation

### RubyGems

```
$ gem install fluent-plugin-tcp_mc
```

### Bundler

Add following line to your Gemfile:

```ruby
gem "fluent-plugin-tcp_mc"
```

And then execute:

```
$ bundle
```

## Configuration

### Basic Configuration

Add this to your Fluentd configuration file:

```apache
<match pattern>
  @type tcp_mc

  # Connection timeouts
  connect_timeout 5s    # Time to wait for connection (default: 5s)
  send_timeout 60s      # Time to wait for send operation (default: 60s)

  # Server configuration
  <server>
    host 192.168.1.100
    port 5000
    name primary-server  # Optional friendly name
  </server>

  # Optional: Add multiple servers for failover
  <server>
    host 192.168.1.101
    port 5000
    name backup-server
  </server>

  # Buffer configuration
  <buffer tag>
    @type memory
    flush_interval 10s
    retry_type exponential_backoff
    retry_wait 1s
    retry_max_interval 60s
  </buffer>
</match>
```

### Configuration Options

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `connect_timeout` | time | 5s | Maximum time to wait for TCP connection |
| `send_timeout` | time | 60s | Maximum time to wait for send operation |

### Server Block

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `host` | string | Yes | Hostname or IP address of the TCP endpoint |
| `port` | integer | Yes | Port number of the TCP endpoint |
| `name` | string | No | Friendly name for the server (defaults to "host:port") |

### Examples

See the [examples/](examples/) directory for complete configuration examples.

## Development Roadmap

Potential future enhancements:

- [ ] Async writes for improved performance
- [ ] Support for additional output formats (key-value, msgpack, etc.)
- [ ] Connection pooling and keep-alive support
- [ ] Custom formatter support
- [ ] Compression support (gzip, zstd)
- [ ] TLS/SSL encryption support

Contributions welcome! See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## Copyright

* Copyright(c) 2017-2025 David Pippenger
* License
  * Apache License, Version 2.0

## Acknowledgements

Inspired by the rawtcp plugin by Uken Games 

https://github.com/uken/fluent-plugin-out_rawtcp
