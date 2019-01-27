// https://prettier.io/docs/en/options.html

module.exports = {
  arrowParens: 'always',
  endOfLine: 'lf',
  singleQuote: true,
  trailingComma: 'es5',
  overrides: [
    {
      files: '*.html',
      options: {
        requirePragma: true,
      },
    },
  ],
};
