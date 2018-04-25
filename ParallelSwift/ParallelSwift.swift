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

    public enum ExecutionType {
        /// Execution closure is executed after all phase closures are finnished.
        case all
        /// Execution closure is executed after first phase closure is finnished.
        case any
        /// Execution closure is executed immediately after phases are started.
        case none
    }

    /// Timeout which after execute closeure is called no matter what.
    public var timeout: TimeInterval = 0
    
    private var phases: [( @escaping () -> () ) -> ()] = []
    private var barrier: DispatchQueue?

    private var executionType: ExecutionType = .all

    private var numberOfPhases: Int = 0
    
    private var complete: (() -> ())?
    
    /// Add execution phase as closure. Once input closure is called phase in considered finnished.
    public func addPhase(_ phase: @escaping ( @escaping () -> () ) -> ())  {
        phases.append(phase)
    }
    
    /// Start all phases in parallel. ExecutionMode defines when completion is called (see documentation)
    public func execute(_ type: ExecutionType = .all,  complete: @escaping () -> ()) {
        self.numberOfPhases = phases.count
        self.complete = complete
        self.executionType = type
        
        barrier = DispatchQueue(label: "com.klubitii.parallelSwift.\(type).\(timeout)", attributes: .concurrent)
        
        self.phases.forEach({ phase in
            barrier?.sync(flags: .barrier) {
                phase(done)
            }
        })
        if executionType == .none {
            done()
        }
        startTimer()
    }
    
    private func startTimer() {
        guard timeout > 0 else {
            return
        }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + timeout) {
            self.barrier?.suspend()
            self.complete?()
            self.reset()
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
