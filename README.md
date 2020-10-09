# ParallelSwift

Wrapper to simplify parallel execution of methods. With three different excution modes. 
Plus optional timeout to prevent locking app, and possibility to shuffle queue order.
Made purely in Swift. See Test folder for usege examples.

## Install
ParallelSwift is available through [CocoaPods](http://cocoapods.org). and via Swift Package Manager.

### Cocoapods

To install it, simply add the following line to your Podfile:

```
pod 'ParallelSwift'
```

### Swift Package Manager

Add link to this repository in Xcode to projects Swift Packages. 
```https://github.com/jvk75/ParallelSwift```

### Manually

Add Sources folder to your project


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

Add methods to be executed as  closure with ```addPhase``` (one by one) or with ```addPhases``` (as array).
Both methods take one parameter that defines where the phase/s are executed (.main or .background (default)) 
Once excute is called all phases are launch simultaneusly (in parallel). 

Methods will mark themself finnished a by calling input closure (e.g. ```done``` in the example) .

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
    p.addPhase(.main) { done in
        print("3")
        done()
    }
    p.execute(.all) {
        print("all done")
    }
```

See tests for more use cases.

### Parameters

```timeout``` : Time in seconds after which execute completion is called even if phases are still running. *Default: 0 (no timeout)*

```shufflePhases```: If true the order which phases are put to operation queue is randomized. *Default: false*

## Issues and contribution

If you find any issues please open an issue to this repository.

Improvements and/or fixes as pull requests are more than welcome.

## Author

Jari Kalinainen, jari(a)klubitii.com

## License

ParallelSwift is available under the MIT license. See the LICENSE file for more info.
