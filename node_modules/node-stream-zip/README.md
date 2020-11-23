# node-stream-zip [![Build status](https://travis-ci.org/antelle/node-stream-zip.svg?branch=master)](https://travis-ci.org/antelle/node-stream-zip)

node.js library for reading and extraction of ZIP archives.  
Features:

- it never loads entire archive into memory, everything is read by chunks
- large archives support
- all operations are non-blocking, no sync i/o
- fast initialization
- no dependencies, no binary addons
- decompression with built-in zlib module
- deflate, sfx, macosx/windows built-in archives
- ZIP64 support

# Installation

`$ npm install node-stream-zip`

# Usage

Open a zip file
```javascript
const StreamZip = require('node-stream-zip');
const zip = new StreamZip({
    file: 'archive.zip',
    storeEntries: true
});

// Handle errors
zip.on('error', err => { /*...*/ });
```

List entries
```javascript
zip.on('ready', () => {
    console.log('Entries read: ' + zip.entriesCount);
    for (const entry of Object.values(zip.entries())) {
        const desc = entry.isDirectory ? 'directory' : `${entry.size} bytes`;
        console.log(`Entry ${entry.name}: ${desc}`);
    }
    // Do not forget to close the file once you're done
    zip.close()
});
```

Stream one entry to stdout
```javascript
zip.on('ready', () => {
    zip.stream('path/inside/zip.txt', (err, stm) => {
        stm.pipe(process.stdout);
        stm.on('end', () => zip.close());
    });
});
```

Extract one file to disk
```javascript
zip.on('ready', () => {
    zip.extract('path/inside/zip.txt', './extracted.txt', err => {
        console.log(err ? 'Extract error' : 'Extracted');
        zip.close();
    });
});
```

Extract a folder from archive to disk
```javascript
zip.on('ready', () => {
    fs.mkdirSync('extracted');
    zip.extract('path/inside/zip/', './extracted', err => {
        console.log(err ? 'Extract error' : 'Extracted');
        zip.close();
    });
});
```

Extract everything
```javascript
zip.on('ready', () => {
    fs.mkdirSync('extracted');
    zip.extract(null, './extracted', (err, count) => {
        console.log(err ? 'Extract error' : `Extracted ${count} entries`);
        zip.close();
    });
});
```

Read a file as buffer in sync way
```javascript
zip.on('ready', () => {
    const data = zip.entryDataSync('path/inside/zip.txt');
    zip.close();
});
```

When extracting a folder, you can listen to `extract` event
```javascript
zip.on('extract', (entry, file) => {
    console.log(`Extracted ${entry.name} to ${file}`);
});
```

`entry` event is generated for every entry during loading
```javascript
zip.on('entry', entry => {
    // you can already stream this entry,
    // without waiting until all entry descriptions are read (suitable for very large archives)
    console.log(`Read entry ${entry.name}`);
});
```

# Options

You can pass these options to the constructor
- `storeEntries: true` - you will be able to work with entries inside zip archive, otherwise the only way to access them is `entry` event
- `skipEntryNameValidation: true` - by default, entry name is checked for malicious characters, like `../` or `c:\123`, pass this flag to disable validation errors

# Methods

- `zip.entries()` - get all entries description
- `zip.entry(name)` - get entry description by name
- `zip.stream(entry, function(err, stm) { })` - get entry data reader stream
- `zip.entryDataSync(entry)` - get entry data in sync way
- `zip.close()` - cleanup after all entries have been read, streamed, extracted, and you don't need the archive

# Building

The project doesn't require building. To run unit tests with [nodeunit](https://github.com/caolan/nodeunit):  
`$ npm test`

# Known issues

- [utf8](https://github.com/rubyzip/rubyzip/wiki/Files-with-non-ascii-filenames) file names
- AES encrypted files

# Contributors

ZIP parsing code has been partially forked from [cthackers/adm-zip](https://github.com/cthackers/adm-zip) (MIT license).
