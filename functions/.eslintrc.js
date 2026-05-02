module.exports = {
  env: {
    es6: true,
    node: true,
  },
  parserOptions: {
    "ecmaVersion": 2020,
  },
  extends: [
    "eslint:recommended",
  ],
  rules: {
    "no-console": "off",
    "indent": "off",
    "quotes": ["error", "double", {"allowTemplateLiterals": true}],
    "semi": ["error", "always"],
    "no-unused-vars": "warn",
    "object-curly-spacing": "off",
    "max-len": "off",
    "eol-last": "off",
  },
  globals: {
    "logger": "readonly",
  },
};
