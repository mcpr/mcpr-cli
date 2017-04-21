const os = require('os');
const https = require('https');
const Q = require('q');
const fs = require('fs');
const ProgressBar = require('progress');
const request = require('request');
const progress = require('request-progress');
const decompress = require('decompress');

const tmpDir = 'tmp';

// config
let nodeStable;
let extension;
let currentOs = os.platform();
let nodeDownloadUrl
let isWin;

if (os.platform() === 'win32') {
    extension = '.zip';
    currentOs = 'win'
    isWin = true;
} else {
    extension = '.tar.gz';
}

function latestNode() {
    const defer = Q.defer();

    https.get('https://semver.io/node/stable', (res) => {
        res.on('data', (d) => {
            nodeStable = d;
            defer.resolve(d);
        });

    }).on('error', (e) => {
        console.error(e);
        defer.reject(e);
    });

    return defer.promise;
}

function downloadNode() {
    const defer = Q.defer();
    if (!fs.existsSync(tmpDir)) {
        fs.mkdirSync(tmpDir);
    }
    console.log(`Downloading Node.js from ${nodeDownloadUrl}`);

    progress(request(nodeDownloadUrl), {})
        .on('response', res => {
            var len = parseInt(res.headers['content-length'], 10);

            console.log();
            var bar = new ProgressBar('  downloading [:bar] :rate/bps :percent :etas', {
                complete: '=',
                incomplete: ' ',
                width: 20,
                total: len
            });

            res.on('data', function (chunk) {
                bar.tick(chunk.length);
            });

            res.on('end', function () {
                console.log('\n');
            });
        })
        .on('error', function (err) {
            defer.reject(err);
        })
        .on('end', function () {
            defer.resolve('Download complete!');
        })
        .pipe(fs.createWriteStream(`${tmpDir}/node${extension}`));

    return defer.promise;
}

function decompressNode() {
    const defer = Q.defer();
    decompress(`${tmpDir}/node${extension}`, tmpDir).then(files => {
        defer.resolve('Done!');
    }).catch(err => {
        defer.reject(err);
    });
    return defer.promise;
}

latestNode().then((res) => {
    nodeDownloadUrl = `https://nodejs.org/dist/v${res}/node-v${res}-${currentOs}-${os.arch()}${extension}`
    downloadNode().then(res => {
        console.log(res);
        decompressNode().then(res => {
            console.log(res);
        }).catch(err => {
            console.log(err);
        })
    });
});