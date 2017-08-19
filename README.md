# MCPR-CLI [![Build Status](https://travis-ci.org/mcpr/cli.svg?branch=master)](https://travis-ci.org/mcpr/cli) [![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/mcpr/cli/blob/master/LICENSE) [![GitHub issues](https://img.shields.io/github/issues/mcpr/cli.svg)](https://github.com/mcpr/cli/issues) [![GitHub (pre-)release](https://img.shields.io/github/release/mcpr/cli/all.svg)](https://github.com/mcpr/cli)

The official [MCPR](https://registry.hexagonminecraft.com) CLI.

[![asciicast](https://asciinema.org/a/99aybb8tez0pnvkh339ti9z41.png)](https://asciinema.org/a/99aybb8tez0pnvkh339ti9z41)

## DISCLAIMER
This project is in alpha! Most features are either non-existent or don't fully work. 

## Features
- Setup Minecraft Server (**Testing In Progress** #1)
- Install Plugins (**In Progress** #2)
- Manage Minecraft Server (**Not started**)

## Usage

### Setup Server
```
$ mcpr setup [servertype] [version]
```

##### Example
```
$ mcpr setup spigot 1.12.1
```

### Search Plugins
```
$ mcpr search [pluginName]
```

##### Example
```
$ mcpr search dynmap
```
### Install Plugin
```
$ mcpr install [pluginID]
```

##### Example
```
$ mcpr install 274
```
## Getting Started

These instructions will get you up and running with `MCPR-CLI`.

### Prerequisites

You will need a few prerequisites installed to start. 

* Java JDK
* Bash (Git Bash or Bash on Ubuntu on Windows will work on Windows)

### Install
To install `MCPR-CLI`, run the following command.

```
$ curl -sSL http://fsft.us/mcpr-cli | sudo bash
```

If you are on Windows, download the Windows `.exe` from below and put that in your path. 

#### Downloads
- [Linux](https://artifacts.filiosoft.com/mcpr-cli/linux/mcpr)
- [Darwin](https://artifacts.filiosoft.com/mcpr-cli/darwin/mcpr)
- [Windows](https://artifacts.filiosoft.com/mcpr-cli/windows/mcpr.exe)

#### Verify Installation
To verify your installation, run the following.
```
$ mcpr --version
```

### Build from Source
_Go must be installed_
```
# getting:
go get github.com/mcpr/cli
cd $GOPATH/src/github.com/mcpr/cli
gdm restore

# building
go build -o mcpr
```

## Contributing

Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct, and the process for submitting pull requests to us.

## Versioning

We use [SemVer](http://semver.org/) for versioning. For the versions available, see the [tags on this repository](https://github.com/mcpr/cli/tags). 

## Authors

* **Noah Prail** - *Maintainer* - [@nprail](https://github.com/nprail)

See also the list of [contributors](https://github.com/mcpr/cli/contributors) who participated in this project.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details

## Acknowledgments

* Hat tip to anyone who's code was used
* Inspired by [MSCS](https://github.com/MinecraftServerControl/mscs)
