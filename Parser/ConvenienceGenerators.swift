//
//  ConvenienceGenerators.swift
//  Parser
//
//  Created by Paul Herz on 12/17/16.
//  Copyright © 2016 Paul Herz. All rights reserved.
//

import Foundation

// MARK: Character matching

func anyCharacter() -> Parser<String> {
    return character(passingTest: { _ in true })
}

func character(in characterRange: ClosedRange<Character>) -> Parser<String> {
    return character(passingTest: { characterRange ~= $0 })
}

func character(in characterString: String) -> Parser<String> {
    return character(in: Array(characterString.characters))
}

// MARK: Character classes

func lowercase() -> Parser<String> {
    return character(in: "a"..."z")
}

func uppercase() -> Parser<String> {
    return character(in: "A"..."Z")
}

func digit() -> Parser<String> {
    return character(in: "0"..."9")
}

func alphabetical() -> Parser<String> {
    return or(lowercase(),uppercase())
}

func alphanumeric() -> Parser<String> {
    return or(alphabetical(),digit())
}

func whitespace() -> Parser<String> {
    return or(character(" "),character("\t"),character("\n"))
}

func skip(_ parser: Parser<String>) -> Parser<String> {
    return anyNumber(of: parser).ignoringOutput()
}

func literal(_ s: String) -> Parser<String> {
    return Parser({ input in
        // input must be at least as long as search string to contain it.
        guard input.characters.count >= s.characters.count else {
            return nil
        }
        
        var remainder = input
        for char in s.characters {
            guard let (_, thisRemainder) = character(char).parse(remainder) else {
                return nil
            }
            remainder = thisRemainder
        }
        return ([s], remainder)
    })
}
