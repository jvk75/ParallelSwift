//
//  ParallelSwift.swift
//
//  Created by Jari Kalinainen on 29.01.18.
//  Copyright © 2018 Jari Kalinainen. All rights reserved.
//
//  MIT Licensed
//  
//  https://github.com/jvk75/ParallelSwift

import Foundation

class ParallelSwift {
    private var phases: [( @escaping () -> () ) -> ()] = []
    private let barrier = DispatchQueue(label: "jk.parallelSwift.fi", attributes: .concurrent)
    
    private var numberOfPhases: Int = 0
    
    private var complete: (() -> ())?
    
    public func addPhase(_ phase: @escaping ( @escaping () -> () ) -> ())  {
        phases.append(phase)
    }
    
    public func execute(_ complete: @escaping () -> ()) {
        self.numberOfPhases = phases.count
        self.complete = complete
        self.phases.forEach({ phase in
            self.barrier.sync(flags: .barrier) {
                phase(done)
            }
        })
    }
    
    private func done() -> () {
        numberOfPhases -= 1
        if numberOfPhases == 0 {
            DispatchQueue.main.async {
                self.complete?()
                self.reset()
            }
        }
    }
    
    private func reset() {
        phases = []
        numberOfPhases = 0
        complete = nil
    }
}
