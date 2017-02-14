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

var winBash;
var windows = platform === "win32";

function bash(callback) {
    function bash64(callback) {
        var winBash64 = 'C:\\Program Files\\Git\\bin\\bash.exe';
        fs.stat(winBash64, function (err, stats) {
            // If 64bit Bash exists, use it. 
            return callback(err, winBash64)
        });
    }

    function bash32(callback) {
        var winBash86 = 'C:\\Program Files (x86)\\Git\\bin\\bash.exe';
        fs.stat(winBash86, function (err, stats) {
            // If 64bit Bash exists, use it. 
            return callback(err, winBash86)
        });
    }

    function bashUbuntuWin(callback) {
        var bashOnUbuntuOnWindows = 'C:\\Windows\\System32\\bash.exe';
        fs.stat(bashOnUbuntuOnWindows, function (err, stats) {
            // If 64bit Bash exists, use it. 
            return callback(err, bashOnUbuntuOnWindows)
        });
    }

    bashUbuntuWin(function (err, path) {
        if (err) {
            bash64(function (err, path) {
                if (err) {
                    bash32(function (err, path) {
                        if (err) return callback(path, err);
                        return callback(path, err);
                    });
                }
                return callback(path, err);
            });
        }
        return callback(path, err);
    });
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
            sh.exec(cmd, function (code, stdout, stderr) {
                if (code != 0) throw stderr;
                winBash = sh.pwd(); + '\\PortableGit\\git-bash.exe';
                console.log(winBash);
            });
        })
        .catch(function (e) {
            console.error('Error downloading Portable Git:', e)
        });
}

function checkDocker() {
    return new Promise(function (resolve, reject) {
        sh.exec('docker version', function (code, stdout, stderr) {
            if (code != 0) throw stderr;
            return true;
        })
    })
}

function checkDeps() {
    return new Promise(function (resolve, reject) {
        checkDocker().then(function (docker) {
        });
    })
}

function spigotSetup(version) {
    var tmpDir = 'tmp'
    var spigotUrl = "https://hub.spigotmc.org/jenkins/job/BuildTools/lastSuccessfulBuild/artifact/target/BuildTools.jar"

    if (!fs.existsSync(tmpDir)) {
        fs.mkdirSync(tmpDir);
    }
    sh.cd(tmpDir);
    console.log('Starting Spigot Build');
    checkDeps();

    portableBash(function (err) {
        if (err) throw err;
    });

    downloadFile(spigotUrl, 'BuildTools.jar', function (err) {
        if (err) throw err

        var javaCmd = 'java -jar BuildTools.jar --rev ' + version;
        var cmd;

        if (windows) {
            // build on Windows properly
            console.log('Using Bash.exe found at:', winBash);
            cmd = winBash + ' --login -i -c "' + javaCmd + '"';
            console.log(cmd);
        } else {
            // build on all other platforms
            cmd = javaCmd;
        }

        sh.exec(cmd, function (code, stdout, stderr) {
            if (code != 0) throw stderr;
            sh.cd('..');
            sh.cp(tmpDir + '/spigot-' + version + '.jar', 'server.jar')

            del(tmpDir).then(paths => {
                console.log('Removed', paths, 'folder');
            });
        });
    });
};

function vanillaSetup(version) {
    var vanillaUrl = 'https://s3.amazonaws.com/Minecraft.Download/versions/' + version + '/minecraft_server.' + version + '.jar'

    console.log('Starting Vanilla Setup');
    downloadFile(vanillaUrl, 'server.jar', function (err) {
        if (err) throw err
    });
};

function downloadFile(url, output, callback) {
    var opts = {
        directory: ".",
        filename: output
    }
    download(url, opts, function (err) {
        callback(err);
        console.log('Download Complete')
    });
};

module.exports = function (version, type, verbose) {
    console.log('Setting up a %s %s Minecraft server. Verbose: %s', type, version, verbose);
    if (type === 'spigot') {
        spigotSetup(version);
    }
    if (type === 'vanilla') {
        vanillaSetup(version);
    }
}