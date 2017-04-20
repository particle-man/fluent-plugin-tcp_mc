# fluent-plugin-tcp_multi

[Fluentd](http://fluentd.org/) output to send to generic tcp endpoints

This plugin was based on work from the rawtcp output from Uken Games.

The plugin currently only supports JSON output and I think buffering is kinda wonky. The plugin does support multi-worker however...

## Installation

### RubyGems

```
$ gem install fluent-plugin-tcp_multi
```

### Bundler

Add following line to your Gemfile:

```ruby
gem "fluent-plugin-tcp_multi"
```

And then execute:

```
$ bundle
```

## Configuration

You can generate configuration template:

```
$ fluent-plugin-format-config output tcp_multi
```

You can copy and paste generated documents here.

## Todo
* Try and leverage standard formatter and helpers
* Change to async writes 
* Test/Configure buffering
* Support other output types (like kv)
* Make more things configurable in general

## Copyright

* Copyright(c) 2017- David Pippenger
* License
  * Apache License, Version 2.0

## Acknowledgements

Inspired by the rawtcp plugin by Uken Games 

https://github.com/uken/fluent-plugin-out_rawtcp
