# The PyPi visualizer

This project is a simple webapp to visualize information about PyPi packages. It can be seen live [here](https://pypi.cel.so).

It is currently limited to three of them: `requests`, `Pendulum`, and `xhtml2pdf`, but more can be added by editing `Config.elm`.

## Running locally

To run this project locally, you need `node >= 8` and install `create-elm-app`. Then, run `elm-app start` in the project's root folder.

## Building for production

Simply run `yarn build`.

## Running tests

To run the tests, you're going to need [`elm-test`](https://github.com/rtfeldman/node-test-runner) installed. Then, run `elm-test` in the project's root folder.
