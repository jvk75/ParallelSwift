# ParallelSwift
Simple parallel function executer with three execution modes.

## Modes
### All
![all](https://github.com/jvk75/ParallelSwift/raw/master/img/all.png "all")

### Any
![any](https://github.com/jvk75/ParallelSwift/raw/master/img/any.png "any")

### None
![none](https://github.com/jvk75/ParallelSwift/raw/master/img/none.png "none")


## Usage 

Add functions to be run with ```addPhases``` Once excute is called all functions are launch parallel. 
When all functions have call ```done``` execution completion closure is executed in main thread.

```
    let p = ParallelSwift()

    p.addPhase { done in
       print("1")
       done()
    }
    p.addPhase { done in
       print("2")
       done()
    }
    p.addPhase { done in
        print("3")
        done()
    }
    p.execute(.all) {
        print("all done")
    }
```
