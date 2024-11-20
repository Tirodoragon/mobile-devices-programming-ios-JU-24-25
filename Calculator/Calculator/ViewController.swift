//
//  ViewController.swift
//  Calculator
//
//  Created by Tirodoragon on 11/17/24.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var resultLabel: UILabel!
    
    var currentNumber: String = "0"
    var previousNumber: Double = 0
    var currentOperation: String? = nil
    var lastOperand: Double? = nil
    var isTypingNumber = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        clearCalculator()
    }
    
    @IBAction func buttonTapped(_ sender: UIButton) {
        guard let buttonTitle = sender.titleLabel?.text else {
            return
        }
        
        switch buttonTitle {
        case "0"..."9", ".":
            if isTypingNumber {
                if buttonTitle == "." && currentNumber.contains(".") {
                    return
                }
                currentNumber += buttonTitle
            } else {
                currentNumber = buttonTitle == "." ? "0." : buttonTitle
                isTypingNumber = true
            }
            resultLabel.text = currentNumber
            
        case "+":
            if isTypingNumber {
                performOperation()
            }
            currentOperation = buttonTitle
            previousNumber = Double(currentNumber) ?? 0
            lastOperand = nil
            isTypingNumber = false
            
        case "=":
            if currentOperation != nil {
                let current = Double(currentNumber) ?? 0
                performOperation()
                lastOperand = current
            } else if let operand = lastOperand {
                previousNumber += operand
                currentNumber = formatNumber(previousNumber)
                resultLabel.text = currentNumber
            }
            currentOperation = nil
            isTypingNumber = false
            
        case "C":
            clearCalculator()
            
        default:
            return
        }
    }

    
    func performOperation() {
        guard let operation = currentOperation else { return }
        let current = Double(currentNumber) ?? 0
        
        switch operation {
        case "+":
            previousNumber += current
        default:
            break
        }
        
        currentNumber = formatNumber(previousNumber)
        resultLabel.text = currentNumber
    }
    
    func clearCalculator() {
        currentNumber = "0"
        previousNumber = 0
        currentOperation = nil
        lastOperand = nil
        isTypingNumber = false
        resultLabel.text = "0"
    }
    
    func formatNumber(_ number: Double) -> String {
        return String(format: "%g", number)
    }
}
