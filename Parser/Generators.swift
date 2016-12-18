//
//  Generators.swift
//  Parser
//
//  Created by Paul Herz on 12/17/16.
//  Copyright © 2016 Paul Herz. All rights reserved.
//

import Foundation

func character(passingTest test: @escaping (Character) -> Bool) -> Parser<String> {
    return Parser { input in
        guard let (head, tail) = Parser<String>.splitFront(input) else {
            return ([], input)
        }
        if test(head) {
            return ([String(head)], tail)
        } else {
            return nil
        }
    }
}

func character(in characterArray: [Character]) -> Parser<String> {
    return character(passingTest: { characterArray.contains($0) })
}

func character(_ c: Character) -> Parser<String> {
    return character(passingTest: { $0 == c })
}

// Capture until character
func not(_ avoidedCharacter: Character) -> Parser<String> {
    return Parser { input in
        var output = ""
        var remainder = input
        
        while true {
            guard let (head, tail) = Parser<String>.splitFront(remainder), head != avoidedCharacter else {
                break
            }
            output += String(head)
            remainder = tail
        }
        
        return ([output], remainder)
    }
}
