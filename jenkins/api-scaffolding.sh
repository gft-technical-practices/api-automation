#!/usr/bin/env node
const shell = require('shelljs');
const swg = require('api-scaffolding');
const fs = require('fs-extra');
const path = require('path');
const asciify = require('asciify');

const spec = fs.readJsonSync(path.resolve('./users_api.json'));

// Criando as apis na versão server
shell.echo(swg.createServer(spec, 'nodejs-server'));

asciify('Scaffolding', {font:'small'}, (err, res) => {shell.echo(res)});
asciify('Create APIs', {font:'standard', color: 'blue'}, (err, res) => {shell.echo(res)});
