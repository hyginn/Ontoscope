# nicePath

Use `nicePath("filename")` to ensure loading files will
work when your script is sourced from elsewhere.

```r
nicePath <- function (filename) {
  tryCatch({
    return(file.path(getwd(), dirname(sys.frame(1)$ofile), filename))
  }, error = function (error) {
    return(filename)
  })
}
```

We can't source this function because then that path will need to made nice
too..

If you come up with a better solution, post it!.

As a one liner:

```r
nicePath <- function (filename) { tryCatch({ return(file.path(getwd(), dirname(sys.frame(1)$ofile), filename))}, error = function (error) { return(filename) }) }
```

### How it works

See [this comment](http://stackoverflow.com/a/9138397/1409233) and
[this question](http://stackoverflow.com/questions/1815606/rscript-determine-path-of-the-executing-script).

We have the following directory structure:

```
.
├── README.md
├── level1
│   ├── hot.csv
│   └── level2
│       ├── cool.csv
│       └── nestee.R
└── runner.r
```

Within `nestee.R` we want to read files using a relative path. For example,
`cool.csv` and `../hot.csv`.

If we start with the following in `nestee.R`:

```r
setwd("/Users/jmazz/Desktop/nicePath/level1/level2")
print(read.csv("cool.csv"))
print(read.csv("../hot.csv"))
```

And then run from there, everything works fine.

*Note:* I am explicitly running `setwd()` to make it clear where commands are
being ran from. In another workflow, you might `cd level1/level2`, run `R`, and
then `source('nestee.R')`; this would have the same effect. There is no actual
`setwd()` command in my `nestee.R` file - this would break on others machines.

However, doing the following inside `runner.R`:

```r
setwd("/Users/jmazz/Desktop/nicePath")
source('level1/level2/nestee.R')
```

will throw file not found errors since there is no `cool.csv` and `../hot.csv`
*relative to `runner.R`*:

```
Error in file(file, "rt") : cannot open the connection
In addition: Warning message:
In file(file, "rt") :
  cannot open file 'cool.csv': No such file or directory
```

So, we need a way to inform `nestee.R` where it is, so that it can use a path
that will work from `runner.R`.

### A First Try

Your first idea may be to use `getwd()`:

```r
> setwd("/Users/jmazz/Desktop/nicePath")
> getwd()
[1] "/Users/jmazz/Desktop/nicePath"
```

This will return the same as we passed into `setwd()`. If `setwd()` was never
called, it returns the location of the current R process. So depending on where
you `cd` to before running `R`, you will get the path of the place where you
ran `R`:

```bash
$ cd ~/Desktop
$ R
R version 3.x.x. ...

> getwd()
[1] "/Users/jmazz/Desktop"
```

You might think, OK, just `getwd()` from inside `nestee.R` and we are good to
go! *Not so fast*, the location of the R process does not change when sourcing
scripts. A `getwd()` *anywhere* will return the same value.

### Another (of many) Way

We can use `sys.frame` to find out where we are within a script:

```
These functions provide access to ‘environment’s (‘frames’ in S terminology)
associated with functions further up the calling stack.
```

It takes two arguments:

```
   which: the frame number if non-negative, the number of frames to go
          back if negative.

       n: the number of generations to go back.  (See the ‘Details’
          section.)
```

Consider the following, when running R in an arbitrary place:

```r
> sys.frame(0)
<environment: R_GlobalEnv>
> sys.frame(1)
Error in sys.frame(1) : not that many frames on the stack
```

However, if we have `print(sys.frame(1))` within `nestee.R` and then
have the following in `runner.R`:

```
> source('level1/level2/nestee.R')
<environment: 0x7f817e0b0e70>
```

Now instead of an error, we get a specific environment. Then `sys.frame(1)`
**will only work when the script is sourced, and will error otherwise**.

We can expand upon this to get the directory of where the sourced file lives:

`print(dirname(sys.frame(1)$ofile))` in `nestee.R`, and then

```
> source('level1/level2/nestee.R')
[1] "level1/level2"
```

In `nestee.R`:

```r
nicePath <- function (filename) {
  return(file.path(getwd(), dirname(sys.frame(1)$ofile), filename))
}

print(read.csv(nicePath("cool.csv")))
print(read.csv(nicePath("../hot.csv")))
```

and then sourced from `runner.R` works. But inside `nestee.R` it will error.

So we can just catch the error, and in that case, use the given `filename`:

```r
nicePath <- function (filename) {
  tryCatch({
    return(file.path(getwd(), dirname(sys.frame(1)$ofile), filename))
  }, error = function (error) {
    return(filename)
  })
}
```
