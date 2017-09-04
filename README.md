# MCPR-CLI [![Build Status](https://travis-ci.org/mcpr/mcpr-cli.svg?branch=master)](https://travis-ci.org/mcpr/mcpr-cli) [![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/mcpr/mcpr-cli/blob/master/LICENSE) [![GitHub issues](https://img.shields.io/github/issues/mcpr/mcpr-cli.svg)](https://github.com/mcpr/mcpr-cli/issues) [![GitHub (pre-)release](https://img.shields.io/github/release/mcpr/mcpr-cli/all.svg)](https://github.com/mcpr/mcpr-cli)

The Official [MCPR](https://registry.hexagonminecraft.com) Command Line Interface.

[![asciicast](https://asciinema.org/a/136232.png)](https://asciinema.org/a/136232)

## DISCLAIMER
This project is in alpha! Most features are either non-existent or don't fully work. 

## Features
- Setup Minecraft Server (**Testing In Progress** [#1](https://github.com/mcpr/mcpr-cli/issues/1))
- Install Plugins (**Testing In Progress** [#2](https://github.com/mcpr/mcpr-cli/issues/2))
- Manage Minecraft Server (**Not started**)

## Usage

### Setup Server
```
$ mcpr setup [servertype] [version]
```

**Example**
```
$ mcpr setup spigot 1.12.1
```

### Search Plugins
```
$ mcpr search [pluginName]
```

**Example**
```
$ mcpr search dynmap
```
### Install Plugin
```
$ mcpr install [pluginID]
```

**Example**
```
$ mcpr install dynmap
```
## Getting Started

These instructions will get you up and running with `MCPR-CLI`.

### Prerequisites

You will need a few prerequisites installed to start. 

* [Java JDK](https://docs.oracle.com/javase/8/docs/technotes/guides/install/install_overview.html)
* Bash ([Git Bash](https://git-scm.com/) or [Windows Subsystem for Linux](https://msdn.microsoft.com/en-us/commandline/wsl/install_guide) will work on Windows)

### Install
#### Linux & macOS
To install `MCPR-CLI`, run the following command.

```
$ curl -sSL http://fsft.us/mcpr-cli | sudo bash
```
#### Windows
To install `MCPR-CLI` on Windows, download and run the [Windows Installer](https://artifacts.filiosoft.com/mcpr-cli/windows/mcpr-cli-setup-stable-latest.exe). 

#### Downloads
- Linux 
    - [Binary](https://artifacts.filiosoft.com/mcpr-cli/linux/mcpr-stable)
    - [RPM Installer](https://artifacts.filiosoft.com/mcpr-cli/linux/mcpr-cli-stable-latest.noarch.rpm)
    - [DEB Installer](https://artifacts.filiosoft.com/mcpr-cli/linux/mcpr-cli_stable_latest_all.deb)
- macOS
    - [Binary](https://artifacts.filiosoft.com/mcpr-cli/darwin/mcpr-stable)
    - [Installer](https://artifacts.filiosoft.com/mcpr-cli/darwin/mcpr-cli-stable-latest.pkg)
- Windows
    - [Binary](https://artifacts.filiosoft.com/mcpr-cli/windows/mcpr-stable.exe)
    - [Installer](https://artifacts.filiosoft.com/mcpr-cli/windows/mcpr-cli-setup-stable-latest.exe)

#### Verify Installation
To verify your installation, run the following.
```
$ mcpr --version
```

### Build from Source
_Go must be installed_
```
# getting:
go get github.com/mcpr/mcpr-cli
cd $GOPATH/src/github.com/mcpr/mcpr-cli
gdm restore

# building
go build -o mcpr
```

## Contributing

Please read [CONTRIBUTING.md](https://github.com/mcpr/mcpr/blob/master/CONTRIBUTING.md) for details on our code of conduct, and the process for submitting pull requests to us.

## Versioning

We use [SemVer](http://semver.org/) for versioning. For the versions available, see the [tags on this repository](https://github.com/mcpr/mcpr-cli/tags). 

## Authors

* **Noah Prail** - *Maintainer* - [@nprail](https://github.com/nprail)

See also the list of [contributors](https://github.com/mcpr/mcpr-cli/contributors) who participated in this project.

## License

This project is licensed under the MIT License - see the [LICENSE](https://github.com/mcpr/mcpr-cli/blob/master/LICENSE) file for details

## Acknowledgments

* Hat tip to anyone who's code was used
* Inspired by [MSCS](https://github.com/MinecraftServerControl/mscs)
