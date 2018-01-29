# ParallelSwift
Simple parallel function executer

## Usage 

Add functions to be run with ```addPhases``` Once excute is called all functions are launch parallel. 
When all functions have call ```done``` execution completion is run.

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
    p.execute() {
        print("all done")
    }
```
