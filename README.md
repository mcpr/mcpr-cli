# MC-CLI

[![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](https://raw.githubusercontent.com/HexagonMinecraft/mc-cli/go/LICENSE)
[![GitHub issues](https://img.shields.io/github/issues/HexagonMinecraft/mc-cli.svg)](https://github.com/HexagonMinecraft/mc-cli/issues)
[![GitHub (pre-)release](https://img.shields.io/github/release/HexagonMinecraft/mc-cli/all.svg)](https://github.com/HexagonMinecraft/mc-cli)

A CLI for setting up and controlling Minecraft servers.

## DISCLAIMER
This project is in heavy development still! Most features are either non-existent or don't fully work. 

[![asciicast](https://asciinema.org/a/3hfvoqmm9jr1erycj48hmpdoa.png)](https://asciinema.org/a/3hfvoqmm9jr1erycj48hmpdoa)

## Features
- Setup Minecraft Server (**In Progress** #1)
- Install Plugins (**In Progress** #2)
- Manage Minecraft Server (**Not started**)

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

### Install
To install `MC-CLI`, run the following command.

```
$ curl -sSL https://git.io/v9PVI | sudo bash
```

If you are on Windows, download the Windows `.exe` from below and put that in your path. 

#### Downloads
- [Linux](https://artifacts.filiosoft.com/mc-cli/linux/mc)
- [Darwin](https://artifacts.filiosoft.com/mc-cli/darwin/mc)
- [Windows](https://artifacts.filiosoft.com/mc-cli/windows/mc.exe)

#### Verify Installation
To verify your installation, run the following.
```
$ mc --version
```

### Build from Source
_Go must be installed_
```
# Clone the repo
git clone -b go github.com/HexagonMinecraft/mc-cli

cd mc-cli

# Build the CLI
go get
go build
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
