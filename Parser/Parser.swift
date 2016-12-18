//
//  Parser.swift
//  Parser
//
//  Created by Paul Herz on 12/5/16.
//  Copyright © 2016 Paul Herz. All rights reserved.
//

import Foundation

class Parser<OutputType> {
    
    typealias ParserFunction = (String) -> (output: [OutputType], remainder: String)?
    
    let parse: ParserFunction
    
    init(_ function: @escaping ParserFunction) {
        self.parse = function
    }
    
    // MARK: Utility functions
    
    static func splitFront(_ string: String) -> (head: Character, tail: String)? {
        if string.isEmpty {
            return nil
        }
        
        let tail = string.substring(from: string.index(after: string.startIndex))
        return (head: string.characters.first!, tail: tail)
    }
    
    static func fmap<U,V,W>(_ a: @escaping (U)->V, _ b: @escaping (V)->W) -> (U)->W {
        return { input in
            return b(a(input))
        }
    }
    
    func asOptional() -> Parser<OutputType> {
        return Parser { input in
            if let (output, remainder) = self.parse(input) {
                return (output, remainder)
            } else {
                return ([], input)
            }
        }
    }
    
    func ignoringOutput() -> Parser<OutputType> {
        return Parser { input in
            if let (_, remainder) = self.parse(input) {
                return ([], remainder)
            } else {
                return nil
            }
        }
    }
}



