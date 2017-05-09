# MC-CLI (Go Version)

[![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](https://raw.githubusercontent.com/HexagonMinecraft/mc-cli/go/LICENSE)
[![GitHub issues](https://img.shields.io/github/issues/HexagonMinecraft/mc-cli.svg)](https://github.com/HexagonMinecraft/mc-cli/issues)

A CLI for setting up and controlling Minecraft servers.

## DISCLAIMER
This project is in heavy development still! Most features are either non-existent or don't fully work. 

[![asciicast](https://asciinema.org/a/3hfvoqmm9jr1erycj48hmpdoa.png)](https://asciinema.org/a/3hfvoqmm9jr1erycj48hmpdoa)

## Features
- Setup Minecraft Server (**In Progress** #1)
- Manage Minecraft Server (**In Progress** #2)

## Usage

#### Setup Server
```
$ mc setup [servertype] [version]
```

##### Example
```
$ mc setup spigot 1.11.2
```

## Getting Started

These instructions will get you up and running with `MC-CLI`.

### Prerequisites

You will need a few prerequisites installed to start. 

* Java JDK
* Bash (Git Bash or Bash on Ubuntu on Windows work on Windows)
* Docker (Recommended but Optional)

### Installing
_Go must be installed_
```
# Clone the repo
git clone -b go github.com/HexagonMinecraft/mc-cli.go

cd mc-cli

# Build the CLI
go build
```
Then move `mc-cli` (or `mc-cli.exe` on Windows) to your path.

#### Install (Go not required)
To install `mc-cli` on Ubuntu without Go preinstalled, download the latest dev build from [here](https://s3.amazonaws.com/artifacts.filiosoft.com/mc-cli/go/mc-cli) for Linux and [here](https://s3.amazonaws.com/artifacts.filiosoft.com/mc-cli/go/mc-cli.exe) for Windows.

Then move `mc-cli` (or `mc-cli.exe` on Windows) to your path.

```
$ [sudo] mv mc-cli /usr/local/bin/mc
```
Lastly, make the file executable. 
```
$ [sudo] chmod +x /usr/local/bin/mc
```

#### Verify Installation
To verify your installation, run the following.
```
$ mc --version
```

## Contributing

Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct, and the process for submitting pull requests to us.

## Versioning

We use [SemVer](http://semver.org/) for versioning. For the versions available, see the [tags on this repository](https://github.com/HexagonMinecraft/mc-cli/tags). 

## Authors

* **Noah Prail** - *Maintainer* - [@nprail](https://github.com/nprail)

See also the list of [contributors](https://github.com/HexagonMinecraft/mc-cli/contributors) who participated in this project.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details

## Acknowledgments

* Hat tip to anyone who's code was used
* Inspired by [MSCS](https://github.com/MinecraftServerControl/mscs)
