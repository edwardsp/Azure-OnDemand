# Batch Connect - Theia IDE

An improved file viewer / editor for Open OnDemand that launches Theia IDE.

This is based on the code-server interative app (https://github.com/cdr/code-server)

## Prerequisites

This Batch Connect app requires the following software be installed on the
**compute nodes** that the batch job is intended to run on (**NOT** the
OnDemand node):

- [Theia]

[Theia]: https://theia-ide.org/

## Known Issues

- No authentication so users will be able to access each others sessions
  if they find the host and port.

## Contributing

1. Fork it ( https://github.com/edwardsp/ondemand_bc_theia/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
