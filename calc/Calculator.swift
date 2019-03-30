//
//  Calculator.swift
//  calc
//
//  Created by Jesse Clark on 2019/3/30.
//  Copyright © 2019 UTS. All rights reserved.
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
    /// - Parameter expressions: the expressions for calculating
    func calculate(_ expressions: [String]) throws -> Int {
        
        // I. Check the count of expressions, and count must be odd
        guard expressions.count % 2 == 1 else {
            // count is not odd, throw error
            throw CalculatorError.invalidParamsCount(count: expressions.count)
        }
        
        // II. Check the type of all expressions
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
        
        // III. declare variable
        
        // the pending oprator for addtion or subtraction; 1 represent addtion(+), -1 represent subtraction(-)
        var addSubtractSign: Int = 1
        // the pending oprator for multiplication,division or modulus; 1 represent multiplication(x), -1 represent division(/), and 0 represent modulus(%)
        var multDivideModulusSign: Int = 1
        // the processed result for addtion and subtraction
        var resultForAddSubtract: Int = 0
        // the processed result for multiplication, division and modulus
        var resultForMultDivideModulus: Int = 1
        // the pending number
        var number: Int = 0
        
        // IV. add a "+" operator to process the last number
        let targetExpressions = expressions + ["+"]
        
        // V. process all expression
        for expression in targetExpressions {
            if expression == "+" || expression == "-" {
                // process "+" or "-"
                // 1. handle the pending oprator for multiplication, division or modulus
                if multDivideModulusSign == 1 { // multiplication
                    if isMultiplicationOverflow(a: resultForMultDivideModulus, b: number) {
                        throw CalculatorError.outOfBounds
                    }
                    resultForMultDivideModulus *= number
                } else if multDivideModulusSign == -1 { // division
                    if number == 0 {
                        // can not division by zero, throw error
                        throw CalculatorError.divisionByZero
                    } else {
                        if isDivisionOverflow(a: resultForMultDivideModulus, b: number) {
                            throw CalculatorError.outOfBounds
                        }
                        resultForMultDivideModulus /= number
                    }
                } else { // modulus
                    resultForMultDivideModulus %= number
                }
                // 2. handle the pending oprator for addtion or subtraction
                if addSubtractSign == 1 {
                    if isAddtionOverflow(a: resultForAddSubtract, b: resultForMultDivideModulus) {
                        throw CalculatorError.outOfBounds
                    }
                    resultForAddSubtract += resultForMultDivideModulus
                } else {
                    if isSubtractionOverflow(a: resultForAddSubtract, b: resultForMultDivideModulus) {
                        throw CalculatorError.outOfBounds
                    }
                    resultForAddSubtract -= resultForMultDivideModulus
                }
                // 3. set new addSubtractSign
                addSubtractSign = expression == "+" ? 1 : -1
                // 4. reset multDivideModulusSign and resultForMultDivideModulus to default
                multDivideModulusSign = 1
                resultForMultDivideModulus = 1
            } else if expression == "x" || expression == "/" || expression == "%" {
                // process "x", "/" or "%"
                // 1. handle the pending oprator for multiplication, division or modulus
                if multDivideModulusSign == 1 { // multiplication
                    if isMultiplicationOverflow(a: resultForMultDivideModulus, b: number) {
                        throw CalculatorError.outOfBounds
                    }
                    resultForMultDivideModulus *= number
                } else if multDivideModulusSign == -1 { // division
                    if number == 0 {
                        // can not division by zero, throw error
                        throw CalculatorError.divisionByZero
                    } else {
                        if isDivisionOverflow(a: resultForMultDivideModulus, b: number) {
                            throw CalculatorError.outOfBounds
                        }
                        resultForMultDivideModulus /= number
                    }
                } else { // modulus
                    resultForMultDivideModulus %= number
                }
                // 2. set new multDivideModulusSign
                multDivideModulusSign = expression == "x" ? 1 : (expression == "/" ? -1 : 0)
            } else {
                // process the number
                number = Int(expression)!
            }
        }
        
        // VI. return the result
        return resultForAddSubtract
    }
    
    /// return true represent a x b will overflow, else false
    private func isMultiplicationOverflow(a: Int, b: Int) -> Bool {
        if a >= 0 && b >= 0 {
            // greater than Int.max
            return Int.max / a < b
        }
        if a < 0 && b < 0 {
            // greater than Int.max
            return Int.max / a > b
        }
        if (a == Int.min && b == -1) || (a == -1 && b == Int.min) {
            // greater than Int.max
            return true
        }
        return a < 0
            ? isMultiplicationOverflow(a: -a, b: b)
            : isMultiplicationOverflow(a: a, b: -b)
    }
    
    /// return true represent a / b will overflow, else false
    private func isDivisionOverflow(a: Int, b: Int) -> Bool {
        if a == Int.min && b == -1 {
            // greater than Int.max
            return true
        }
        return false
    }
    
    /// return true represent a + b will overflow, else false
    private func isAddtionOverflow(a: Int, b: Int) -> Bool {
        if b > 0 && a > Int.max - b {
            // greater than Int.max
            return true
        }
        if b < 0 && a < Int.min - b {
            // less than Int.min
            return true
        }
        return false
    }
    
    /// return true represent a - b will overflow, else false
    private func isSubtractionOverflow(a: Int, b: Int) -> Bool {
        if b < 0 && a > Int.max + b {
            // greater than Int.max
            return false
        }
        if b > 0 && a < Int.min + b {
            // less than Int.min
            return true
        }
        return false
    }
    
}
