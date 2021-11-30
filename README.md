# How it works

This application was built with

- [Lamdera](https://lamdera.com), a delightful platform for full-stack web apps
- [elm-spa](https://elm-spa.dev), a friendly tool for building SPAs with Elm!
- [halfmoon](https://www.gethalfmoon.com), a responsive front-end CSS framework

Check out the [the source code](./src) to get a feel for the project structure!

# Getting started

Clone the project.

in the project directory run:

```sh
lamdera reset
```

to setup lamdera. Then run:

```sh
elm-spa watch
```

This will cause elm-spa to rebuild it's generated code when pages are added or
updated.

In another terminal run:

```sh
lamdera live
```

this will start the local lamdera server and make the app available in your
browser.

Note: the `.elm-spa` folder needs to be committed to successfully deploy, as
Lamdera doesn't run elm-spa build commands.

See [Getting Started](https://lamdera.com/start) if you're new to Lamdera.
