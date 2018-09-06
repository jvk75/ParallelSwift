//
//  ParallelTests.swift
//  ParallelTests
//
//  Created by Jari Kalinainen on 24.04.18.
//  Copyright © 2018 Jari Kalinainen. All rights reserved.
//

import XCTest

class ParallelTests: XCTestCase {
    
    var p: ParallelSwift?
    
    var result = ""

    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        p = nil
        result = ""
    }
    
    func doPhases() {
        p = ParallelSwift()
        result = ""
        p?.timeout = 0
        p?.addPhase { done in
            DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + 1){
                print("1")
                self.result.append("1")
                done()
            }
        }
        p?.addPhase { done in
            DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + 2){
                print("2")
                self.result.append("2")
                done()
            }
        }
        p?.addPhase { done in
            DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + 3){
                print("3")
                self.result.append("3")
                done()
            }
        }
    }
    
    func testTimeoutAll() {
        
        let e = expectation(description: "time")
        doPhases()

        var timeResult = ""

        p?.timeout = 5
        p?.addPhase { done in
            DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + 4){
                print("4")
                timeResult.append("4")
                done()
            }
        }
        p?.addPhase { done in
            DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + 10){
                print("5")
                timeResult.append("5")
                done()
            }
        }
        
        p?.execute(.all) {
            XCTAssert(timeResult == "4")
            e.fulfill()
            print("all done")
        }
        
        waitForExpectations(timeout: 6, handler: { _ in
            print("Test done")
        })
    }

    func testModeAll() {

        let e = expectation(description: "all")
        doPhases()
        
        p?.sufflePhases = true
        
        p?.execute(.all) {
            XCTAssert(self.result == "123")
            e.fulfill()
            print("all done")
        }
        
        waitForExpectations(timeout: 4, handler: { _ in
            print("Test done")
        })
    }
    
    func testModeAny() {
        
        let e = expectation(description: "any")
        doPhases()

        p?.execute(.any) {
            XCTAssert(self.result == "1")
            e.fulfill()
            print("all done")
        }
        
        waitForExpectations(timeout: 2, handler: { _ in
            print("Test done")
        })
    }
    
    func testModeNone() {
        
        let e = expectation(description: "none")
        doPhases()

        p?.execute(.none) {
            XCTAssert(self.result == "")
            e.fulfill()
            print("all done")
        }
        
        waitForExpectations(timeout: 1, handler: { _ in
            print("Test done")
        })
    }
    
    func testMultiParallel() {
        
        let e = expectation(description: "multi")
        
        p = ParallelSwift()
        var multiResult = ""
        var singleResult = ""

        p?.timeout = 0
        p?.addPhase { done in
            let pp = ParallelSwift()
            pp.addPhase { done in
                DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + 1){
                    print("11")
                    multiResult.append("11")
                    done()
                }
            }
            pp.addPhase { done in
                DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + 2){
                    print("12")
                    multiResult.append("12")
                    done()
                }
            }
            pp.execute(.all) {
                XCTAssert(multiResult == "1112")
                print("+")
                singleResult.append("+")
                done()
            }
        }
        p?.addPhase(.main) { done in
            DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + 1.5){
                print("*")
                singleResult.append("*")
                done()
            }
        }
        p?.addPhase(.main) { done in
            DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + 1.5){
                print("-")
                singleResult.append("-")
                done()
            }
        }

        p?.execute(.all) {
            self.checkResult(e, singleResult)
        }
        
        waitForExpectations(timeout: 10, handler: { _ in
            print("Test done")
        })
    }

    private func checkResult(_ e: XCTestExpectation, _ singleResult: String) {
        XCTAssert(singleResult == "*-+")
        e.fulfill()
        print("all done")
    }

    func testMainParallel() {

        let e = expectation(description: "main")

        p = ParallelSwift()

        p?.timeout = 0

        p?.addPhase(.main) { done in
            XCTAssert(Thread.isMainThread)
            done()
        }
        p?.addPhase { done in
            XCTAssert(!Thread.isMainThread)
            done()
        }

        p?.execute(.all) {
            e.fulfill()
        }

        waitForExpectations(timeout: 10, handler: { _ in
            print("Test done")
        })
    }

}
