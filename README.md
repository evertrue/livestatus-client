# LivestatusClient

This is a very "lightweight" command line client (written in Ruby) for the [MK Livestatus](http://mathias-kettner.de/checkmk_livestatus.html) Nagios module.

It makes simple queries and commands against the Livestatus API and returns slightly parsed JSON responses. Filters and complex queries (beyond just requesting particular data types and columns) are not yet supported.

## Installation

Install it yourself as:

    $ gem install livestatus-client

## Usage

Run the `livestatus` executable:

```bash
$ livestatus --help
Options:
  -h, --host=<s>         Livestatus host
  -p, --port=<s>         Livestatus port
  -q, --query=<s>        The query string
  -l, --columns=<s>      Which columns to display (comma separated)
  -i, --list             List available columns
  -c, --command=<s>      Command to send
  -a, --arguments=<s>    Command argumenets (comma separated)
  -e, --help             Show this message
```

### Listing hosts with any configured downtimes

```bash
$ livestatus -h 10.99.0.1 -p 50000 -q hosts -l downtimes
```

This should return something like this:
```json
{
  "default-ubuntu-1404": {
    "downtimes": [

    ]
  },
  "stage-api": {
    "downtimes": [

    ]
  },
  "test-dns": {
    "downtimes": [
      1483559124159689
    ]
  }
}
```

### Configuring a service downtime

```bash
$ livestatus \
    -h 10.99.0.1 -p 50000 \
    -c SCHEDULE_HOST_DOWNTIME \
    -a 'server-ubuntu-1404,1483644522,1483644523,1,0,0,yourname,Some downtime coment'
```

[Valid Nagios external commands](https://old.nagios.org/developerinfo/externalcommands/commandlist.php) (Click on individual commands for the argument syntax. Note that the script replaces `,` with `;` to prevent conflicts with the shell)

### To get a list of valid columns for a data type

```bash
$ livestatus -h 10.99.0.1 -p 50000 -q hosts --list
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/evertrue/livestatus-client.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
