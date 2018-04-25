# ParallelSwift
Wrapper to simplify parallel execution of methods. With three different excution modes and optional timeout to prevent locking app.

## Modes
### All
Execution closure is executed after all phase closures are finnished.

 ![all](https://github.com/jvk75/ParallelSwift/raw/master/img/all.png "all")

### Any
Execution closure is executed after first phase closure is finnished.

![any](https://github.com/jvk75/ParallelSwift/raw/master/img/any.png "any")

### None
Execution closure is executed immediately after phases are started.

![none](https://github.com/jvk75/ParallelSwift/raw/master/img/none.png "none")


## Usage 

Add methods to be executed as  closure with ```addPhases``` 
Once excute is called all phases are launch simultaneusly (in parallel). 

Methods will mark themself finnished a by calling  ```done``` .

Execution completion closure is always executed in main thread. See modes.

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
## Issues and contribution

If you find any issues please open an issue to this repository.

Improvements and/or fixes as pull requests are more than welcome.

## Author

Jari Kalinainen, jari(a)klubitii.com

## License

ParallelSwift is available under the MIT license. See the LICENSE file for more info.
