#!/usr/bin/env node

/**
 * Module dependencies.
 */

var fs = require('fs');
var os = require('os');
var http = require('http');
var https = require('https');
var program = require('commander');
var clc = require('cli-color');
var pkgv = require('./package.json').version;
var sh = require('shelljs');
var download = require('download-file')
var spawn = require('child_process').spawn;
var platform = os.platform();

var spigotSetup = function (version) {
    // SpigotConfig
    var spigotUrl = "https://hub.spigotmc.org/jenkins/job/BuildTools/lastSuccessfulBuild/artifact/target/BuildTools.jar"
    var winBash = '"C:\\Program Files\\Git\\bin\\bash.exe"';
    var spigotOpts = {
        directory: ".",
        filename: "BuildTools.jar"
    }

    sh.mkdir('tmp');
    sh.cd('tmp');
    console.log('Starting Spigot Build');

    download(spigotUrl, spigotOpts, function (err) {
        if (err) throw err

        var javaCmd = 'java -jar BuildTools.jar --rev ' + version;
        var cmd;

        if (platform === "win32") {
            // build on Windows properly
            cmd = winBash + ' --login -i -c "' + javaCmd + '"';
        } else {
            // build on all other platforms
            cmd = javaCmd;
        }

        sh.exec(cmd, function (code, stdout, stderr) {
            if (code != 0) throw stderr;
            sh.cd('..');
            sh.cp('tmp/spigot-' + version + '.jar', 'server.jar')
            sh.rm('-rf', 'tmp')
        });
    });

}
var vanilaSetup = function (version) {
    var vanilaUrl = 'https://s3.amazonaws.com/Minecraft.Download/versions/' + version + '/minecraft_server.' + version + '.jar'
    var vanilaOpts = {
        directory: ".",
        filename: "server.jar"
    }
    console.log('Starting Vanila Setup');

    download(vanilaUrl, vanilaOpts, function (err) {
        if (err) throw err
        console.log('Download Complete')
    });
}

program
    .version(pkgv)

program
    .command('setup [server]')
    .description('Setup a MC server.')
    .option("-v, --verbose", "Output full log.")
    .option("-m, --minecraft_version <version>", "Minecraft version.")
    .action(function (server, options) {
        var verbose = options.verbose || 'false';
        version = options.minecraft_version || 'latest';
        server = server || 'vanila';
        console.log('Setting up a %s %s Minecraft server. Verbose: %s', server, version, verbose);
        if (server === 'spigot') {
            spigotSetup(version);
        }
        if (server === 'vanila') {
            vanilaSetup(version);
        }
    });

program.parse(process.argv);