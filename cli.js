#!/usr/bin/env node

/**
 * Module dependencies.
 */

var fs = require('fs');
var os = require('os');
var program = require('commander');
var clc = require('cli-color');
var pkgv = require('./package.json').version;
var sh = require('shelljs');
var download = require('download-file')
var spawn = require('child_process').spawn;
var platform = os.platform();
var del = require('del');
var setup = require('./lib/setup.js');

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
        setup(version, server, verbose);
    });

program.parse(process.argv);