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
    
    /// Randomize the order which phases are put to operation queue
    public var sufflePhases: Bool = false
    
    private var phases: [( @escaping () -> () ) -> ()] = []
    private let queue = OperationQueue()
    private let dpQueue = DispatchQueue(label: "com.klubitii.parallelSwift", attributes: .concurrent)
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
        
        queue.maxConcurrentOperationCount = numberOfPhases + 1 
        queue.underlyingQueue = dpQueue
        
        if sufflePhases {
            self.phases.shuffle()
        }
        
        self.phases.forEach({ phase in
            queue.addOperation {
                phase(self.done)
            }
        })
        if executionType == .none {
            self.done()
        }
        self.startTimer()
    }
    
    private func startTimer() {
        guard timeout > 0 else {
            return
        }
        dpQueue.asyncAfter(deadline: DispatchTime.now() + timeout) {
            self.queue.cancelAllOperations()
            self.allDone()
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
            self.allDone()
        }
    }
    
    private func allDone() {
        DispatchQueue.main.async {
            self.complete?()
            self.reset()
        }
    }
    
    private func reset() {
        phases = []
        numberOfPhases = 0
        complete = nil
        executionType = .all
    }
}

extension Array {
    mutating func shuffle() {
        if count < 2 { return }
        for i in 0..<(count - 1) {
            let j = Int(arc4random_uniform(UInt32(count - i))) + i
            self.swapAt(i, j)
        }
    }
}
