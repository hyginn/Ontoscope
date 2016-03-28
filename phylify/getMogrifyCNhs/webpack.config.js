module.exports = {
  entry: ['babel-polyfill', './getJaspar.js'],
  target: 'node',
  output: {
    filename: 'get.js'
  },
  // devtool: 'sourcemap',
  // was throwing module not found error, we don't need it anyways
  externals: ['cls-bluebird'],
  module: {
    loaders: [{
      test: /\.js?$/,
      // exclude: /(node_modules)/,
      loader: 'babel'
    }, {
      test: /\.json$/,
      loader: 'json'
    }],
    // https://github.com/webpack/webpack/issues/138#issuecomment-160638284
    noParse: /node_modules\/json-schema\/lib\/validate\.js/
  }
}
