# getJaspar.js FFID

Install [node and npm](https://gist.github.com/thejmazz/72456e3f29cf0bf56d4a).
Install dependencies (be where `package.json` is) with

```bash
npm install
```

Then you can do

```r
library(jsonlite)
fromJSON(system("node getJaspar.js FF:10017-101C8", intern=TRUE))
```

We need `intern=TRUE` so that the output gets stored. Else we get the code from the process exit (`0`).

This will require that `node_modules` is accessible from where `node` is run
(i.e. from where `R` is ran). Alternatively, you can bundle the script and
all its dependencies using [webpack](https://webpack.github.io/). To do this
run

```bash
npm run build
```

which if you look into the `scripts` in `package.json`, is just running `webpack`.
However, when running from `scripts`, `node_modules/bin` is added to the path,
whereas running `webpack` yourself will only work if you installed webpack
globally (i.e. `npm install -g webpack`) or have `./node_modules/.bin` in your path. I prefer to avoid global
installs, this way when someone comes along they just need to `npm install` and
are set.

Then you will be able to do

```r
fromJSON(system("node some/where/getJaspar_bundle.js FF:10017-101C8", intern=TRUE))
```

and it won't matter where the `getJaspar_bundle.js` file is, as all of its
dependencies will be packed in.

You could also do

```bash
node getJaspar_bundle.js FF:10017-101C8 > output.json
```

and then using jsonlite,

```r
fromJSON("output.json")
```

## Sample Output

Makes a data frame from JSON with structure `[{motif: 'XXX', pval: 'YYY'}]`:

```
motif         pVal
1   MA0002.2        0.052
2   MA0003.1        0.192
3   MA0004.1        0.323
4   MA0006.1       0.0422
5   MA0007.1        0.275
6   MA0009.1        0.666
7   MA0014.1        0.172
8   MA0017.1  4.21675e-11
9   MA0018.2       0.0559
10  MA0019.1       0.0222
```


## A note on the CRAN V8 package

Unfortunately I was not able to get this working. It worked for a small, simple
test, but gave an error when sourcing the bundled script. Script needed to be
bundled since `require` is not available in the V8 context provided.

```r
> ctx <- v8()
> ctx$source("getJaspar_bundle.js")
Error: TypeError: undefined is not an object!
```

which is quite odd as `undefined` is a pretty core.. It works here though

```r
> ctx$console()
This is V8 version 3.15.11.18. Press ESC or CTRL+C to exit.
~ var foo
~ foo === undefined
true
```

so probably something to do with bundling.
