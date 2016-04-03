/*jslint node: true */
'use strict';

var PurescriptWebpackPlugin = require('purescript-webpack-plugin');

var src = [
  'bower_components/purescript-*/src/**/*.purs',
  'src/*.purs'
];

var ffi = [
  'bower_components/purescript-*/src/**/*.js',
];

var modulesDirectories = [
  'node_modules',
  'bower_components'
];

var purescriptWebpackPlugin = new PurescriptWebpackPlugin({
  src: src,
  ffi: ffi,
  bundle: false,
  // psc: 'psa',
  pscArgs: {
    sourceMaps: true
  }
});

var config = {
  entry: './src/entry',
  debug: true,
  devtool: 'source-map',
  output: {
    path: './src/js',
    pathinfo: true,
    filename: 'app.js'
  },
  module: {
    loaders: [
      {
        test: /\.purs$/,
        loader: 'purs-loader'
      },
      {
        test: /\.js$/,
        loader: 'source-map-loader',
        exclude: /node_modules|bower_components/
      }
    ]
  },
  resolve: {
    modulesDirectories: modulesDirectories,
    extensions: [ '', '.js', '.purs']
  },
  plugins: [
    purescriptWebpackPlugin
  ]
};

module.exports = config;
