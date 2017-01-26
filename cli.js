#!/usr/bin/env node

/**
 * Module dependencies.
 */

var fs = require('fs');
var http = require('http');
var https = require('https');
var program = require('commander');
var clc = require('cli-color');
var pkgv = require('./package.json').version;
var sh = require('shelljs');
var download = require('download-file')
var spawn = require('child_process').spawn;

var spigotUrl = "https://hub.spigotmc.org/jenkins/job/BuildTools/lastSuccessfulBuild/artifact/target/BuildTools.jar"

var spigotOpts = {
    directory: ".",
    filename: "BuildTools.jar"
}

var spigotSetup = function (version) {
    sh.mkdir('tmp');
    sh.cd('tmp');
    console.log('Starting Spigot Build');

    download(spigotUrl, spigotOpts, function (err) {
        if (err) throw err
        console.log('Done')
        //spawn('java -jar BuildTools.jar --rev ' + version, function (code, stdout, stderr) {
        //   if (code != 0) throw stderr;
        //});

        spawn('java', ['-jar', 'BuildTools.jar', '--rev', version]);
    })


    //sh.rm('-r', 'tmp')
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
    });

program.parse(process.argv);
