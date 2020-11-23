eslint-plugin-react-native-globals
==================================

ESLint Environment for React Native.

## Installation

```sh
yarn add --dev eslint eslint-plugin-react-native-globals
```

**Note:** If you installed ESLint globally then you must also install `eslint-plugin-react-native-globals` globally.

## Usage

Add `react-native-globals` to the `plugins` section of your `.eslintrc` configuration file, and then add `react-native-globals/all` to the `env` section:

```json
{
  "plugins": [
    "react-native-globals"
  ],

  "env": {
    "react-native-globals/all": true
  }
}
```
