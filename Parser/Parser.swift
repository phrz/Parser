//
//  Parser.swift
//  Parser
//
//  Created by Paul Herz on 12/5/16.
//  Copyright © 2016 Paul Herz. All rights reserved.
//

import Foundation

typealias Parser<T> = (String) -> (output: [T], remainder: String)?

func splitFront(_ string: String) -> (head: Character, tail: String)? {
	if string.isEmpty {
		return nil
	}
	
	let tail = string.substring(from: string.index(after: string.startIndex))
	return (head: string.characters.first!, tail: tail)
}

func fmap<U,V,W>(_ a: @escaping (U)->V, _ b: @escaping (V)->W) -> (U)->W {
	return { input in
		return b(a(input))
	}
}

// PARSERS - return a tuple of ([output], remainder). If failing, returns nil.

// a parser generator that takes a character predicate and captures any
// matching characters.
func characterCondition(test: @escaping (Character) -> Bool) -> Parser<String> {
	return { input in
		guard let (head, tail) = splitFront(input) else {
			return ([], input)
		}
		if test(head) {
			return ([String(head)], tail)
		} else {
			return nil
		}
	}
}

// a parser generator that will capture any character
func any() -> Parser<String> {
	return characterCondition(test: { _ in true })
}

// a parser generator that will capture lowercase letters
func lowercase() -> Parser<String> {
	return anyOf("a"..."z")
}

// a parser generator that will capture uppercase letters
func uppercase() -> Parser<String> {
	return anyOf("A"..."Z")
}

// a parser generator that will capture any digit
func digit() -> Parser<String> {
	return characterCondition(test: { "0"..."9" ~= $0 })
}

func alphabet() -> Parser<String> {
	return or(lowercase(),uppercase())
}

func alphanumeric() -> Parser<String> {
	return or(alphabet(),digit())
}

// a parser generator that will capture the given character
func character(_ c: Character) -> Parser<String> {
	return characterCondition(test: { $0 == c })
}

// a parser generator that will capture any of the given characters
func anyOf(_ characterRange: ClosedRange<Character>) -> Parser<String> {
	return characterCondition(test: { characterRange ~= $0 })
}

func anyOf(_ characterString: String) -> Parser<String> {
	return anyOf(Array(characterString.characters))
}

func anyOf(_ characters: [Character]) -> Parser<String> {
	return characterCondition(test: { characters.contains($0) })
}

// a parser generator that takes `n` parsers (n>0) and only returns
// output if all parsers return output. If successful, it returns the
// concatenation of their outputs. Otherwise, returns nil.
func and<T>(_ parsers: @escaping Parser<T>...) -> Parser<T> {
	return { input in
		var output = [T]()
		var remainder = input
		
		for parser in parsers {
			guard let (thisOutput, thisRemainder) = parser(remainder) else {
				return nil
			}
			output.append(contentsOf: thisOutput)
			remainder = thisRemainder
		}
		
		return (output, remainder)
	}
}

func ignore<T>(_ parser: @escaping Parser<T>) -> Parser<T> {
	return { input in
		if let (_, remainder) = parser(input) {
			return ([], remainder)
		} else {
			return nil
		}
	}
}

func andIgnoreLast<T>(_ parsers: @escaping Parser<T>...) -> Parser<T> {
	return { input in
		var output = [T]()
		var remainder = input
		
		for parser in parsers {
			guard let (thisOutput, thisRemainder) = parser(remainder) else {
				return nil
			}
			// if index is last, don't append input!
			output.append(contentsOf: thisOutput)
			remainder = thisRemainder
		}
		
		return (output, remainder)
	}
}

// a parser generator that wraps a parser so that it never returns nil,
// but instead an empty set and the full input when it fails, making it optional
// in chaining like and().
func optional<T>(_ parser: @escaping Parser<T>) -> Parser<T> {
	return { input in
		if let (output, remainder) = parser(input) {
			return (output, remainder)
		} else {
			return ([], input)
		}
		
	}
}

// A parser generator that takes `n` parsers (n>0) and returns the output
// of the first successful parser or fails if none succeed.
func or<T>(_ parsers: @escaping Parser<T>...) -> Parser<T> {
	return { input in
		for parser in parsers {
			if let (output, remainder) = parser(input) {
				return (output, remainder)
			}
		}
		
		return nil
	}
}

// Given a parser and a numeric condition, repeat the parser until its first
// failure, then check the success count with the condition. If the condition
// is met, return the combined output. Otherwise, return nil.
func number<T>(of parser: @escaping Parser<T>, meetsCondition condition: @escaping (Int) -> Bool) -> Parser<T> {
	return { input in
		// repeat parser until failure, if success count meets condition,
		// return output set. Otherwise, return nil.
		var count = 0
		var successful = true
		
		var output = [T]()
		var remainder = input
		
		// repeat parser until first failure
		while successful {
			// consider empty output sets to be failure to prevent infinite loop
			if let (thisOutput, thisRemainder) = parser(remainder), !thisOutput.isEmpty {
				count += 1
				output.append(contentsOf: thisOutput)
				remainder = thisRemainder
			} else {
				successful = false
			}
		}
		
		// check if the count meets the condition
		if condition(count) {
			return (output, remainder)
		} else {
			return nil
		}
	}
}

func anyNumber<T>(of parser: @escaping Parser<T>) -> Parser<T> {
	return number(of: parser, meetsCondition: { _ in true })
}

func atLeast<T>(_ minimum: Int, of parser: @escaping Parser<T>) -> Parser<T> {
	return number(of: parser, meetsCondition: { $0 >= minimum })
}

func between<T>(_ range: ClosedRange<Int>, of parser: @escaping Parser<T>) -> Parser<T> {
	return number(of: parser, meetsCondition: { range ~= $0 })
}

func string(_ s: String) -> Parser<String> {
	return { input in
		// input must be at least as long as search string to contain it.
		guard input.characters.count >= s.characters.count else {
			return nil
		}
		
		var remainder = input
		for char in s.characters {
			guard let (_, thisRemainder) = character(char)(remainder) else {
				return nil
			}
			remainder = thisRemainder
		}
		return ([s], remainder)
	}
}
