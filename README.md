# MC-CLI

[![Greenkeeper badge](https://badges.greenkeeper.io/HexagonMinecraft/mc-cli.svg)](https://greenkeeper.io/)
[![Build Status](https://travis-ci.org/HexagonMinecraft/mc-cli.svg?branch=master)](https://travis-ci.org/HexagonMinecraft/mc-cli)

A CLI for setting up and controlling Minecraft servers.

## DISCLAIMER
This project is in heavy development still! Most features are either non-existent or don't fully work. 

## Features
* Setup Minecraft Server (**In Progress**)
* Manage Minecraft Server (**Not Started**)

## Usage

#### Setup Server
`mc setup [servertype] -m [version]`

##### Example
`mc setup spigot -m 1.11.2`

## Getting Started

These instructions will get you up and running with `MC-CLI`.

### Prerequisites

You will need a few prerequisites installed to start. 

* Java JDK
* Git Bash or Bash on Ubuntu on Windows (Optional)
* Docker (Recommended but Optional)

### Installing
_Node.js must be installed_
```
npm install -g minecraft-cli
```

#### Ubuntu Install (Node.js not required)
To install `mc-cli` on Ubuntu without Node.js preinstalled, run the following.
```
# Add the PackageCloud repository
curl -s https://packagecloud.io/install/repositories/nprail/mc-cli/script.deb.sh | sudo bash

# Install mc-cli!
sudo apt-get install mc-cli
```
#### Verify Installation
To verify your installation, run the following.
```
mc --version
```

## Contributing

Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct, and the process for submitting pull requests to us.

## Versioning

We use [SemVer](http://semver.org/) for versioning. For the versions available, see the [tags on this repository](https://github.com/HexagonMinecraft/mc-cli/tags). 

## Authors

* **Noah Prail** - *Maintainer* - [nprail](https://github.com/nprail)

See also the list of [contributors](https://github.com/HexagonMinecraft/mc-cli/contributors) who participated in this project.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details

## Acknowledgments

* Hat tip to anyone who's code was used
* Inspired by [MSCS](https://github.com/MinecraftServerControl/mscs)
