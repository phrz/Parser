//
//  ParserTest.swift
//  ParserTest
//
//  Created by Paul Herz on 12/10/16.
//  Copyright © 2016 Paul Herz. All rights reserved.
//

import XCTest

extension String {
	static func *(_ s: String, _ i: Int) -> String {
		guard i > 0 else { return "" }
		return String(repeating: s, count: i)
	}
}

class ParserTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Called before the invocation of each test method.
	}
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func splitFrontPerformance() {
		var string = "a"*50
        self.measure {
			while string.characters.count > 0 {
				(_, string) = Parser<String>.splitFront(string)!
			}
        }
    }
    
}
