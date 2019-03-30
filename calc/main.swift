//
//  main.swift
//  calc
//
//  Created by Jesse Clark on 12/3/18.
//  Copyright © 2018 UTS. All rights reserved.
//

import Foundation

var args = ProcessInfo.processInfo.arguments
args.removeFirst() // remove the name of the program

// create an instance for Calculator
let calc = Calculator()
do {
    // input the special args, and invoke the method calculate(_:)
    let result = try calc.calculate(args)
    print(result)
} catch {
    switch error {
    case CalculatorError.invalidParamsCount(let count):
        print("invalid count: \(count)")
    case CalculatorError.invalidParamsOperator(let oprator):
        print("invalid operator: \(oprator)")
    case CalculatorError.invalidParamsNumber(let number):
        print("invalid number: \(number)")
    case CalculatorError.divisionByZero:
        print("Can not division by zero")
    default:// an unknow error occured
        print(error.localizedDescription)
    }
    exit(-1)
}

