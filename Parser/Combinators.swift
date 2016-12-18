//
//  ParserCombinator.swift
//  Parser
//
//  Created by Paul Herz on 12/17/16.
//  Copyright © 2016 Paul Herz. All rights reserved.
//

import Foundation

func and<OutputType>(_ parsers: Parser<OutputType>...) -> Parser<OutputType> {
    return Parser { input in
        var output = [OutputType]()
        var remainder = input
        
        for parser in parsers {
            guard let (thisOutput, thisRemainder) = parser.parse(remainder) else {
                return nil
            }
            output.append(contentsOf: thisOutput)
            remainder = thisRemainder
        }
        
        return (output, remainder)
    }
}

func +<OutputType>(left: Parser<OutputType>, right: Parser<OutputType>) -> Parser<OutputType> {
    return and(left, right)
}

func or<OutputType>(_ parsers: Parser<OutputType>...) -> Parser<OutputType> {
    return Parser { input in
        for parser in parsers {
            if let (output, remainder) = parser.parse(input) {
                return (output, remainder)
            }
        }
        
        return nil
    }
}

func |<OutputType>(left: Parser<OutputType>, right: Parser<OutputType>) -> Parser<OutputType> {
    return or(left, right)
}


// Repetition-related combinators

func repeating<OutputType>(_ parser: Parser<OutputType>, byCountPassing test: @escaping (Int) -> Bool) -> Parser<OutputType> {
    return Parser { input in
        // repeat parser until failure, if success count meets condition,
        // return output set. Otherwise, return nil.
        var count = 0
        var successful = true
        
        var output = [OutputType]()
        var remainder = input
        
        // repeat parser until first failure
        while successful {
            // consider empty output sets to be failure to prevent infinite loop
            if let (thisOutput, thisRemainder) = parser.parse(remainder), !thisOutput.isEmpty {
                count += 1
                output.append(contentsOf: thisOutput)
                remainder = thisRemainder
            } else {
                successful = false
            }
        }
        
        // check if the count meets the condition
        if test(count) {
            return (output, remainder)
        } else {
            return nil
        }
    }
}

func anyNumber<OutputType>(of parser: Parser<OutputType>) -> Parser<OutputType> {
    return repeating(parser, byCountPassing: { _ in true })
}

func repeating<OutputType>(_ parser: Parser<OutputType>, atLeast minimum: Int) -> Parser<OutputType> {
    return repeating(parser, byCountPassing: { count in count >= minimum })
}

func repeating<OutputType>(_ parser: Parser<OutputType>, between range: ClosedRange<Int>) -> Parser<OutputType> {
    return repeating(parser, byCountPassing: { count in range ~= count })
}
