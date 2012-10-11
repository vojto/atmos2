{print} = require('sys')
{spawn} = require('child_process')

stitch = require('stitch')
fs     = require('fs')

build = (callback) ->
  coffee = spawn 'coffee', ['-c', '-o', 'lib', 'src']
  coffee.stderr.on 'data', (data) ->
    process.stderr.write data.toString()
  coffee.stdout.on 'data', (data) ->
    print data.toString()
  coffee.on 'exit', (code) ->
    callback?() if code is 0

task 'build', 'Build lib/ from src/', ->
  build()

task 'stitch', 'Stitch atmos2.js', ->
  build ->
    console.log 'expecting lib/ to contain all we need'
    pkg = stitch.createPackage
      paths: [__dirname + '/lib']
    
    pkg.compile (err, src) ->
      fs.writeFile 'atmos2.js', src, (err) ->
        throw err if err
        console.log 'compiled atmos2.js'