const UglifyJSPlugin = require('uglifyjs-webpack-plugin');
const {IgnorePlugin} = require('webpack');
module.exports = {
  entry: './src/drag-listener.coffee',
  output: {
    path: __dirname + '/dist',
    filename: 'drag-listener.min.js'
  },
  module: {
    rules: [
      { test: /\.coffee$/,
        use: ['coffee-loader'] }
    ]
  },
  plugins: [
    new IgnorePlugin(/jquery/),
    new UglifyJSPlugin()
  ]
};
