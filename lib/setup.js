/**
 * Module dependencies.
 */

var fs = require('fs');
var os = require('os');
var clc = require('cli-color');
var sh = require('shelljs');
var download = require('download-file')
var spawn = require('child_process').spawn;
var platform = os.platform();
var del = require('del');
var commandExists = require('command-exists');
var request = require('request');
var path = require('path');
var wd = process.cwd();
var tmpDir = `${wd}/tmp`;
var shell = sh.exec;

function green(t) {
    console.log(clc.green(t));
}

function verbose(t, v) {
    if (v === true) {
        console.log(clc.yellow(t));
    }
}

var winBash;
var windows = platform === "win32";

var bashPaths = {
    win64: 'C:\\Program Files\\Git\\bin\\bash.exe',
    win86: 'C:\\Program Files (x86)\\Git\\bin\\bash.exe',
    wsl: 'C:\\Windows\\System32\\bash.exe'
}

function checkFile(path) {
    return new Promise(function (resolve, reject) {
        fs.stat(path, function (err, stats) {
            if (err) return reject(err)
            return resolve(stats);
        });
    });
}

function bash() {
    return new Promise(function (resolve, reject) {
        // Check WSL
        checkFile(bashPaths.wsl)
            .then(result => {
                winBash = bashPaths.wsl
                return resolve(bashPaths.wsl)
            })
            .catch(err => {
                // Check Bash Win64
                checkFile(bashPaths.win64)
                    .then(result => {
                        winBash = bashPaths.win64
                        return resolve(bashPaths.win64)
                    })
                    .catch(err => {
                        // Check Bash Win86
                        checkFile(bashPaths.win86)
                            .then(result => {
                                winBash = bashPaths.win86
                                console.log(result)
                                return resolve(bashPaths.win86)
                            })
                            .catch(err => {
                                return reject(err);
                            });
                    });
            });
    })
}

function portableBash() {
    console.log('Installing portable Git Bash...');
    var version = '2.11.1';
    var url = 'https://github.com/git-for-windows/git/releases/download/v' + version + '.windows.1/PortableGit-' + version + '-64-bit.7z.exe';
    var betterUrl;

    function getUrl() {
        return new Promise(function (resolve, reject) {
            var r = request(url, function (e, response) {
                betterUrl = response.request.uri.href;
            })
        });
    }

    function getFile() {
        return new Promise(function (resolve, reject) {
            getUrl()
                .then(function () {
                    console.log(betterUrl)
                    downloadFile(betterUrl, 'git.7z.exe', function (err) {
                        if (err) throw err
                    });
                })
                .catch(function (e) {
                    console.error('Error downloading Portable Git:', e)
                });
        });

    }

    getFile()
        .then(function () {
            var cmd = 'git.7z.exe -y -gm2'
            console.log(cmd);
            shell(cmd, function (code, stdout, stderr) {
                if (code != 0) throw stderr;
                winBash = sh.pwd(); + '\\PortableGit\\git-bash.exe';
                console.log(winBash);
            });
        })
        .catch(function (e) {
            console.error('Error downloading Portable Git:', e)
        });
}

function checkJava() {
    return new Promise(function (resolve, reject) {
        shell('java -version', {
            silent: true
        }, function (code, stdout, stderr) {
            if (code != 0) {
                reject(stderr)
                console.log(stderr);
                throw 'The Java JDK Needs to be installed to run a Minecraft server. '
            }

            return resolve(stdout);
        })
    })
}

function checkDeps(v) {
    return new Promise(function (resolve, reject) {
        checkJava()
            .then(res => {
                verbose('Java is installed!', v);
            })
            .catch(err => {
                console.error('The Java JDK Needs to be installed to run a Minecraft server. ', err)
            });
        bash()
            .then(res => {
                verbose('Using Bash found at', path.normalize(res), v);
            })
            .catch(err => {

            });
    })
}

// BuildTools Setup
function buildTools(version, type, v) {
    var absolutePath = path.resolve(tmpDir);
    verbose('Using temporary directory located at:', path.normalize(tmpDir), v);

    var buildToolsUrl = "https://hub.spigotmc.org/jenkins/job/BuildTools/lastSuccessfulBuild/artifact/target/BuildTools.jar"

    if (!fs.existsSync(tmpDir)) {
        fs.mkdir(tmpDir, err => {
            if (err) {
                return console.log('Failed to write directory', err);
            }
        });
    }
    verbose('Starting BuildTools', v);

    checkDeps(v)
        .then(res => {
            console.log('Dependency checks complete', res)
        })
        .catch(err => {
            throw err;
        });

    function build(version) {
        return new Promise(function (resolve, reject) {
            var javaCmd = 'ls && java -jar BuildTools.jar --rev ' + version;
            var cmd;

            if (windows) {
                // build on Windows properly
                cmd = winBash + ' --login -i -c "' + javaCmd + '"';
                verbose(cmd, v);
            } else {
                // build on all other platforms
                cmd = javaCmd;
            }

            shell(cmd, function (code, stdout, stderr) {
                if (code != 0) {
                    throw stderr;
                }
                return resolve('Build Complete');
            });
        })
    }

    function postBuild(type) {
        return new Promise(function (resolve, reject) {
            sh.cd('..')

            sh.cp(tmpDir + '/' + type + '-' + version + '.jar', 'server.jar')


            del(tmpDir).then(paths => {
                console.log('Removed', paths[0], 'folder')
                return resolve('Post-Build Complete')
            }).catch(err => {
                return reject(err)
            });
        })
    }

    downloadFile(buildToolsUrl, 'BuildTools.jar').then(res => {
        process.chdir(tmpDir);
        console.log(res)
        // Run BuildTools
        build(version)
            .then(res => {
                console.log(res);
                // Run post-build steps
                postBuild(type)
                    .then(res => {

                    })
                    .catch(err => {
                        console.error(err)
                    })
            })
            .catch(err => {
                console.error(err)
            })
    }).catch(err => {
        console.error(err)
    });
};

// Vanilla Setup
function vanillaSetup(version) {
    var vanillaUrl = 'https://s3.amazonaws.com/Minecraft.Download/versions/' + version + '/minecraft_server.' + version + '.jar'

    console.log('Starting Vanilla Setup');
    downloadFile(vanillaUrl, 'server.jar').then(res => {
        console.log(res);
    }).catch(err => {
        throw err
    });
};

// File Downloader
function downloadFile(url, output) {
    return new Promise(function (resolve, reject) {
        var opts = {
            directory: tmpDir,
            filename: output
        }
        download(url, opts, function (err) {
            if (err) return reject(err);
            return resolve('Download Complete')
        });
    })
};

// Export Module
module.exports = function (version, type, v) {
    green(`Setting up a ${type} ${version} Minecraft server.`);
    verbose('Verbose is on!', v);

    if (type === 'spigot' || 'craftbukkit') {
        buildTools(version, type, v);
    }
    if (type === 'vanilla') {
        vanillaSetup(version);
    }
}