//
//  EvaluateFormulae.swift
//  Adage
//
//  Created by Pradeep Yadav on 12/12/16.
//  Copyright © 2016 Third I, Inc. All rights reserved.
//

import Foundation

class EvaluateFormulae: NSObject {
    
    //MARK: - *** Functionality Methods ***
    func evaluateFormula (_ formula: String, metrics: Dictionary<String, Any>) -> NSDecimalNumber {
        
        var workingFormula: String = formula.trimmingCharacters(in: .whitespaces)
        var resultValue: NSDecimalNumber = 0
        
        if workingFormula.hasPrefix("if") {
            
            workingFormula = workingFormula.substring(from: workingFormula.index(workingFormula.startIndex, offsetBy: 3))
            workingFormula = workingFormula.substring(to: workingFormula.index(workingFormula.endIndex, offsetBy: -4))
            
            //First level of conditional formula nesting
            var formulaArgs = workingFormula.components(separatedBy: "?")
            
            if formulaArgs.count == 1 {
                //Second level of conditional formula nesting
                formulaArgs = workingFormula.components(separatedBy: ",")
                if formulaArgs.count == 1 {
                    //Third level of conditional formula nesting
                    formulaArgs = workingFormula.components(separatedBy: ";")
                    if formulaArgs.count == 1 {
                        //Fourth level of conditional formula nesting
                        formulaArgs = workingFormula.components(separatedBy: ":")
                    }
                }
            }
            
            let formulaPredicate = NSPredicate (format: formulaArgs[0])
            //Whether the conditional formula's condition was true or false
            let trueFalseFlag: Bool = formulaPredicate.evaluate(with: metrics)
            
            if trueFalseFlag {
                //True conditional statement
                resultValue = self.evaluateFormula(formulaArgs[1], metrics: metrics)
            }
            else {
                //False conditional statement
                resultValue = self.evaluateFormula(formulaArgs[2], metrics: metrics)
            }
            
        }
        else {
            
            let formulaExpression = NSExpression (format: formula)
            resultValue = formulaExpression.expressionValue(with: metrics, context: nil) as! NSDecimalNumber
            
        }
        
        if resultValue == NSDecimalNumber.notANumber {
            resultValue = 0;
        }
        return resultValue
    }
    
    func removeUnwantedChars (_ inputFormula: String) -> String {
        var outputFormula = inputFormula.replacingOccurrences(of: "(", with: "")
        outputFormula = outputFormula.replacingOccurrences(of: ")", with: "")
        outputFormula = outputFormula.replacingOccurrences(of: "break", with: "")
        return outputFormula
    }
    
}
