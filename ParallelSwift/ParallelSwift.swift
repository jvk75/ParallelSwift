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

public class ParallelSwift {

    enum ExecutionType {
        case all
        case any
        case none
    }

    private var phases: [( @escaping () -> () ) -> ()] = []
    private let barrier = DispatchQueue(label: "com.klubitii.parallelSwift", attributes: .concurrent)

    private var executionType: ExecutionType = .all

    private var numberOfPhases: Int = 0
    
    private var complete: (() -> ())?
    
    public func addPhase(_ phase: @escaping ( @escaping () -> () ) -> ())  {
        phases.append(phase)
    }
    
    public func execute(_ type: ExecutionType = .all,  complete: @escaping () -> ()) {
        self.numberOfPhases = phases.count
        self.complete = complete
        self.executionType = type

        self.phases.forEach({ phase in
            self.barrier.sync(flags: .barrier) {
                phase(done)
            }
        })
        if executionType == .none {
            done()
        }
    }
    
    private func done() -> () {
        guard complete != nil else {
            return
        }
        numberOfPhases -= 1

        var executionDone = false

        switch executionType {
        case .none:
            executionDone = true
        case .any:
            executionDone = true
        default:
            break
        }

        if numberOfPhases == 0 || executionDone {
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
        executionType = .all
    }
}
