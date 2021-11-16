# `sbanken.sh`

Retrieve bank details via the [Public Open API](https://publicapi.sbanken.no/openapi/apibeta/index.html?urls.primaryName=API%20Beta%20V2#/) from [Sbanken](https://sbanken.no).

Inspired by [Sbanken's example](https://github.com/Sbanken/api-examples/blob/master/ShellScripts/bash_script.sh).

## Setup

### Environment variables

1. Copy `.env.example`: `cp .env.example .env`
2. Update the variables with your own credentials

## Usage

```sh
chmod +x sbanken.sh
./sbanken.sh -h # for help
```
