# `sbanken.sh`

Retrieve bank details via the [Public Open API](https://publicapi.sbanken.no/openapi/apibeta/index.html?urls.primaryName=API%20Beta%20V2#/) from [Sbanken](https://sbanken.no).

Inspired by [Sbanken's example](https://github.com/Sbanken/api-examples/blob/master/ShellScripts/bash_script.sh).

## Setup

### Environment variables

1. Copy `config.example` to your `$XDG_CONFIG_HOME`: `cp config.example $XDG_CONFIG_HOME/sbanken/config`
2. Update the variables with your own credentials

## Usage

```sh
chmod +x sbanken.sh
./sbanken.sh -h # for help
```

PS: You can also add the `sbanken.sh` to your `$PATH` and run it from anywhere.
