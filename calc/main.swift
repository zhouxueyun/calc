//
//  main.swift
//  calc
//
//  Created by Jesse Clark on 12/3/18.
//  Copyright © 2018 UTS. All rights reserved.
//

import Foundation

/// a enum CalculatorError for error type during calculating
enum CalculatorError: Error {
    case invalidParamsCount(count: Int)
    case invalidParamsOperator(oprator: String)
    case invalidParamsNumber(number: String)
    case divisionByZero
    case outOfBounds
}

/// a class Calculator for calculate
class Calculator {
    
    /// a method can implement calculate special expressions
    ///
    /// - Parameter expressions: the expression for calculating
    func calculate(_ expressions: [String]) throws -> Int {
        
        // Check the count of expressions, and count must be odd
        guard expressions.count % 2 != 1 else {
            // count is not odd, throw error
            throw CalculatorError.invalidParamsCount(count: expressions.count)
        }
        
        // Check the type of all expressions
        // the expression at even index must be an integer number
        // the expression at odd index must be an operator
        let allOperators: Set = ["+", "-", "x", "/", "%"]
        for (index, expression) in expressions.enumerated() {
            if index % 2 == 0 {
                guard let _ = Int(expression) else {
                    // expression can not cast to integer number, throw error
                    throw CalculatorError.invalidParamsNumber(number: expression)
                }
            } else {
                guard allOperators.contains(expression) else {
                    // expression is not a valid operator, throw error
                    throw CalculatorError.invalidParamsOperator(oprator: expression)
                }
            }
        }
        
        // declare variable
        
        // the pending oprator for addtion or subtraction; 1 represent addtion(+), -1 represent subtraction(-)
        var addSubSign: Int = 1
        // the pending oprator for multiplication,division or modulus; 1 represent multiplication(x), -1 represent division(/), and 0 represent modulus(%)
        var mulDivModSign: Int = 1
        // the processed result for addtion and subtraction
        var resultForAddSub: Int = 0
        // the processed result for multiplication, division and modulus
        var resultForMulDivMod: Int = 1
        // the pending number
        var number: Int = 0

        // add a "+" operator to process the last number
        let targetExpressions = expressions + ["+"]
        
        // process all expression
        for expression in targetExpressions {
            if expression == "+" || expression == "-" {
                // process "+" or "-"
                // 1. handle the pending oprator for multiplication,division or modulus
                if mulDivModSign == 1 { // multiplication
                    resultForMulDivMod *= number
                } else if mulDivModSign == -1 { // division
                    if number == 0 {
                        // can not division by zero, throw error
                        throw CalculatorError.divisionByZero
                    } else {
                        resultForMulDivMod /= number
                    }
                } else { // modulus
                    resultForMulDivMod %= number
                }
                // 2. handle the pending oprator for addtion or subtraction
                resultForAddSub += resultForMulDivMod * addSubSign
                // 3. set new addSubSign
                addSubSign = expression == "+" ? 1 : -1
                // 4. reset mulDivModSign and resultForMulDivMod to default
                mulDivModSign = 1
                resultForMulDivMod = 1
            } else if expression == "x" || expression == "/" || expression == "%" {
                // process "x", "/" or "%"
                // 1. handle the pending oprator for multiplication,division or modulus
                if mulDivModSign == 1 { // multiplication
                    resultForMulDivMod *= number
                } else if mulDivModSign == -1 { // division
                    if number == 0 {
                        // can not division by zero, throw error
                        throw CalculatorError.divisionByZero
                    } else {
                        resultForMulDivMod /= number
                    }
                } else { // modulus
                    resultForMulDivMod %= number
                }
                // 2. set new mulDivModSign
                mulDivModSign = expression == "x" ? 1 : (expression == "/" ? -1 : 0)
            } else {
                // process the number
                number = Int(expression)!
            }
        }
        
        return resultForAddSub
    }
    
}

var args = ProcessInfo.processInfo.arguments
args.removeFirst() // remove the name of the program

// create an instance for Calculator
let calc = Calculator()
do {
    // input the special args, and invoke the method calculate(_:)
    let result = try calc.calculate(args)
    print(result)
} catch CalculatorError.invalidParamsCount(let count) {
    print("invalid count: \(count)")
} catch CalculatorError.invalidParamsOperator(let oprator) {
    print("invalid operator: \(oprator)")
} catch CalculatorError.invalidParamsNumber(let number) {
    print("invalid number: \(number)")
} catch CalculatorError.divisionByZero {
    print("Can not division by zero")
} catch {// an unknow error occured
    print(error.localizedDescription)
}

