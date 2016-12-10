//
//  main.swift
//  Parser
//
//  Created by Paul Herz on 9/24/16.
//  Copyright © 2016 Paul Herz. All rights reserved.
//

import Foundation

// typealias Parser<T> = (String) -> (output: [T], remainder: String)?

let s = "aabc"
let p = and( string("aa"), any(), character("c"))
if let (output, remainder) = p(s) {
	print("Success")
	print("Output: \(output)")
	print("Remainder: '\(remainder)'")
} else {
	print("Failure")
}




