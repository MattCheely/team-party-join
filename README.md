# How it works

This application was built with

- [Lamdera](https://lamdera.com), a delightful platform
  for full-stack web apps
- [elm-spa](https://elm-spa.dev), a friendly tool for building SPAs with Elm!

Check out the [the source code](./src) to get a feel for the project structure!

# Getting started

Clone the project and boot the Lamdera local dev environment:

in the project directory run:

```
lamdera reset
lamdera live
```

You may also need to run `elm-spa watch` to automatically pick up any changes
`elm-spa` needs to generate code for.

For any `elm-spa` changes, such as vendoring one of the `.elm-spa` defaults, re-run `elm-spa make`.

Note: the `.elm-spa` folder currently needs to be committed to successfully deploy, as Lamdera doesn't run elm-spa build commands.

See [Getting Started](https://lamdera.com/start) if you're new to Lamdera.
