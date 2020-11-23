
ESLint plugin for React Native
==============================

[![Greenkeeper badge](https://badges.greenkeeper.io/Intellicode/eslint-plugin-react-native.svg)](https://greenkeeper.io/)

[![Maintenance Status][status-image]][status-url] [![NPM version][npm-image]][npm-url] [![Dependency Status][deps-image]][deps-url] [![Coverage Status][coverage-image]][coverage-url] [![Code Climate][climate-image]][climate-url] [![BCH compliance][bettercode-image]][bettercode-url]

React Native specific linting rules for ESLint. This repository is structured like  (and contains code from) the excellent [eslint-plugin-react](http://github.com/yannickcr/eslint-plugin-react).

# Installation

Install [ESLint](https://www.github.com/eslint/eslint) either locally or globally.

```sh
$ npm install --save-dev eslint
```

To make most use of this plugin, its recommended to install [eslint-plugin-react](http://github.com/yannickcr/eslint-plugin-react) in addition to [ESLint](https://www.github.com/eslint/eslint). If you installed `ESLint` globally, you have to install eslint-plugin-react globally too. Otherwise, install it locally.

```sh
$ npm install --save-dev eslint-plugin-react
```

Similarly, install eslint-plugin-react-native


```sh
$ npm install --save-dev eslint-plugin-react-native
```

# Configuration

Add `plugins` section and specify ESLint-plugin-React (optional) and ESLint-plugin-react-native as a plugin.

```json
{
  "plugins": [
    "react",
    "react-native"
  ]
}
```

If it is not already the case you must also configure `ESLint` to support JSX.

```json
{
  "parserOptions": {
      "ecmaFeatures": {
          "jsx": true
      }
  }
}
```

In order to whitelist all *browser-like* globals, add `react-native/react-native` to your config.

```json
{
  "env": {
    "react-native/react-native": true
  }
}
```

To use another stylesheet providers.

```json
settings: {
    'react-native/style-sheet-object-names': ['EStyleSheet', 'OtherStyleSheet', 'PStyleSheet']
}
```

Finally, enable all of the rules that you would like to use.

```json
{
  "rules": {
    "react-native/no-unused-styles": 2,
    "react-native/split-platform-components": 2,
    "react-native/no-inline-styles": 2,
    "react-native/no-color-literals": 2,
    "react-native/no-raw-text": 2,
    "react-native/no-single-element-style-arrays": 2,
  }
}
```

# List of supported rules

* [no-unused-styles](docs/rules/no-unused-styles.md): Detect `StyleSheet` rules which are not used in your React components
* [sort-styles](docs/rules/sort-styles.md): Require style definitions to be sorted alphabetically
* [split-platform-components](docs/rules/split-platform-components.md): Enforce using platform specific filenames when necessary
* [no-inline-styles](docs/rules/no-inline-styles.md): Detect JSX components with inline styles that contain literal values
* [no-color-literals](docs/rules/no-color-literals.md): Detect `StyleSheet` rules and inline styles containing color literals instead of variables
* [no-raw-text](docs/rules/no-raw-text.md): Detect raw text outside of `Text`  component
* [no-single-element-style-arrays](docs/rules/no-raw-text.md): No style arrays that have 1 element only `<View style={[{height: 10}]}/>`

[npm-url]: https://npmjs.org/package/eslint-plugin-react-native
[npm-image]: http://img.shields.io/npm/v/eslint-plugin-react-native.svg?style=flat-square

[deps-url]: https://david-dm.org/Intellicode/eslint-plugin-react-native
[deps-image]: https://img.shields.io/david/dev/Intellicode/eslint-plugin-react-native.svg?style=flat-square

[coverage-url]: https://coveralls.io/r/Intellicode/eslint-plugin-react-native?branch=master
[coverage-image]: http://img.shields.io/coveralls/Intellicode/eslint-plugin-react-native/master.svg?style=flat-square

[climate-url]: https://codeclimate.com/github/Intellicode/eslint-plugin-react-native
[climate-image]: http://img.shields.io/codeclimate/github/Intellicode/eslint-plugin-react-native.svg?style=flat-square

[status-url]: https://github.com/Intellicode/eslint-plugin-react-native/pulse
[status-image]: http://img.shields.io/badge/status-maintained-brightgreen.svg?style=flat-square

[bettercode-image]: https://bettercodehub.com/edge/badge/Intellicode/eslint-plugin-react-native
[bettercode-url]: https://bettercodehub.com
# Shareable configurations

## All

This plugin also exports an `all` configuration that includes every available rule.

```js
{
  "plugins": [
    /* ... */
    "react-native"
  ],
  "extends": [/* ... */, "plugin:react-native/all"]
}
```

**Note**: These configurations will import `eslint-plugin-react-native` and enable JSX in [parser options](http://eslint.org/docs/user-guide/configuring#specifying-parser-options).
