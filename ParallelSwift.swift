//
//  ParallelSwift.swift
//
//  Created by Jari Kalinainen on 29.01.18.
//  Copyright © 2018 Jari Kalinainen. All rights reserved.
//
// https://github.com/jvk75/ParallelSwift

import Foundation

class ParallelSwift {
    private var phases: [(@escaping () -> ()) -> ()] = []
    private let barrier = DispatchQueue(label: "jk.paralleSwift.fi", attributes: .concurrent)
    
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
            complete?()
            reset()
        }
    }
    
    private func reset() {
        phases = []
        numberOfPhases = 0
        complete = nil
    }
}
