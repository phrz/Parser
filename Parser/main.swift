//
//  main.swift
//  Parser
//
//  Created by Paul Herz on 9/24/16.
//  Copyright © 2016 Paul Herz. All rights reserved.
//

// stringValue ::= '"' ~'"' '"'
let stringValue = literal("\"") + not("\"") + literal("\"")

// expression ::= <stringValue>
let expression = stringValue

// identifier ::= [A-Za-z_]{ [A-Za-z0-9_] }
let identifier = (alphabetical() | character("_")) + anyNumber(of: alphanumeric() | character("_"))

// builtInIdentifier ::= 'print'
let builtInIdentifier = literal("print")

// parameterList ::= <expression> { ',' <expression> }
let parameterList = expression + anyNumber(of: literal(",") + expression)

// builtIn ::= <builtInIdentifier> '(' <parameterList> ')'
let builtIn = builtInIdentifier + literal("(") + parameterList + literal(")")

// assignmentStatement ::= <identifier> '=' <expression>
let assignmentStatement = identifier + expression

let statement = (assignmentStatement | builtIn) + literal(";")

// program ::= statement { statement }
let program = anyNumber(of: statement)



let code = "print(\"Hello, world!\");"
let (output, remainder) = program.parse(code)!

if remainder.isEmpty {
    print("Success:")
    print(output)
} else {
    print("Program only partially consumed.")
    print(remainder)
}
