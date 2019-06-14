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

    public enum ExecutionThread {
        case main
        case background
    }

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
    
    private var phases: [(executionThread: ExecutionThread, phase:( @escaping () -> () ) -> ())] = []
    private let queue = OperationQueue()
    private var dpQueue: DispatchQueue?
    private var executionType: ExecutionType = .all
    private var numberOfPhases: Int = 0
    private var complete: (() -> ())?

    public init() {
        dpQueue = DispatchQueue(label: "com.klubitii.parallelSwift.\(Date().timeIntervalSince1970)", attributes: .concurrent)
    }

    /// Add execution phase as closure. Once input closure is called phase in considered finnished.
    ///
    /// With optional parameter.
    /// - .main : phase is executed in main thread
    /// - .background (default) : phase is excuted at background
    public func addPhase(_ executionThread: ExecutionThread = .background,  phase: @escaping ( @escaping () -> () ) -> ()) {
        phases.append((executionThread, phase))
    }

    /// Add execution phases as array (variadic function). Once the input closure of a phase is called phase in considered finnished.
    ///
    /// With optional thread parameter (all phases in the iput array are executed in the same way.
    /// - .main : phase is executed in main thread
    /// - .background (default) : phase is excuted at background
    public func addPhases(_ executionThread: ExecutionThread = .background, phases: ( @escaping () -> () ) -> ()...) {
        phases.forEach {
            self.phases.append((executionThread, $0))
        }
    }

    /// Start all phases in parallel. ExecutionMode defines when completion is called (see documentation)
    public func execute(_ type: ExecutionType = .all,  complete: @escaping () -> ()) {
        self.numberOfPhases = phases.count
        self.complete = complete
        self.executionType = type
        
        guard self.numberOfPhases > 0 else {
            // exit if no phases are set
            self.allDone()
        }
        
        queue.maxConcurrentOperationCount = numberOfPhases + 1
        queue.underlyingQueue = dpQueue
        
        if sufflePhases {
            self.phases.shuffle()
        }
        
        self.phases.forEach({ phase in
            queue.addOperation {
                if phase.executionThread == .main {
                    DispatchQueue.main.async {
                        phase.phase(self.done)
                    }
                } else {
                    phase.phase(self.done)
                }
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
        dpQueue?.asyncAfter(deadline: DispatchTime.now() + timeout) {
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
