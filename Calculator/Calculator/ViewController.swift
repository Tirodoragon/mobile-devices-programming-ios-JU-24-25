//
//  ViewController.swift
//  Calculator
//
//  Created by Tirodoragon on 11/17/24.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet var buttons: [UIButton]!
    
    var currentNumber: String = "0"
    var previousNumber: Double = 0
    var currentOperation: String? = nil
    var previousOperation: String? = nil
    var lastOperand: Double? = nil
    var isTypingNumber = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        clearCalculator()
        adjustFontSize()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        configureButtons()
    }
    
    @IBAction func buttonTapped(_ sender: UIButton) {
        guard let buttonTitle = sender.titleLabel?.text else {
            return
        }
        
        if resultLabel.text == "Error" && buttonTitle != "C" {
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
            
        case "+", "-", "x", "/", "^":
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
                previousOperation = currentOperation
            } else if let operand = lastOperand {
                repeatLastOperation(operand: operand)
            }
            
            currentOperation = nil
            isTypingNumber = false
            
        case "%":
            if let value = Double(currentNumber) {
                currentNumber = formatNumber(value / 100)
                resultLabel.text = currentNumber
            }
            
        case "+|-":
            if currentNumber == "0" {
                return
            }
            if let value = Double(currentNumber) {
                currentNumber = formatNumber(-value)
                resultLabel.text = currentNumber
            }
            
        case "log":
            if let value = Double(currentNumber), value > 0 {
                currentNumber = formatNumber(log10(value))
                resultLabel.text = currentNumber
            } else {
                resultLabel.text = "Error"
            }
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
        case "-":
            previousNumber -= current
        case "x":
            previousNumber *= current
        case "/":
            if current != 0 {
                previousNumber /= current
            } else {
                resultLabel.text = "Error"
                return
            }
        case "^":
            previousNumber = pow(previousNumber, current)
        default:
            break
        }
        
        currentNumber = formatNumber(previousNumber)
        resultLabel.text = currentNumber
    }
    
    func repeatLastOperation(operand: Double) {
        switch previousOperation {
        case "+":
            previousNumber += operand
        case "-":
            previousNumber -= operand
        case "x":
            previousNumber *= operand
        case "/":
            if operand != 0 {
                previousNumber /= operand
            } else {
                resultLabel.text = "Error"
                return
            }
        case "^":
            previousNumber = pow(previousNumber, operand)
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
        previousOperation = nil
        lastOperand = nil
        isTypingNumber = false
        resultLabel.text = "0"
    }
    
    func adjustFontSize() {
        let screenWidth = UIScreen.main.bounds.width
        let fontSize = screenWidth / 5
        resultLabel.font = UIFont.systemFont(ofSize: fontSize, weight: .medium)
        resultLabel.minimumScaleFactor = 0.5
        resultLabel.adjustsFontSizeToFitWidth = true
        
        if let superview = resultLabel.superview {
            resultLabel.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                resultLabel.leadingAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.leadingAnchor),
                resultLabel.trailingAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.trailingAnchor),
                resultLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 100)
            ])
        }
    }
    
    func configureButtons() {
        let screenWidth = UIScreen.main.bounds.width
        let baseMultiplier: CGFloat = 0.1
        let heightMultiplier: CGFloat = 0.5
            
        for button in buttons {
            let scaledFontSize = min(screenWidth * baseMultiplier, button.frame.height * heightMultiplier)
            button.titleLabel?.font = UIFont.systemFont(ofSize: scaledFontSize, weight: .medium)
            button.titleLabel?.minimumScaleFactor = 0.5
            button.titleLabel?.adjustsFontSizeToFitWidth = true
            button.titleLabel?.lineBreakMode = .byClipping
            button.titleLabel?.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                button.titleLabel!.leadingAnchor.constraint(equalTo: button.leadingAnchor),
                button.titleLabel!.trailingAnchor.constraint(equalTo: button.trailingAnchor),
                button.titleLabel!.topAnchor.constraint(equalTo: button.topAnchor),
                button.titleLabel!.bottomAnchor.constraint(equalTo: button.bottomAnchor)
            ])
            button.contentHorizontalAlignment = .center
            button.contentVerticalAlignment = .center
            button.titleLabel?.textAlignment = .center
        }
    }
    
    func formatNumber(_ number: Double) -> String {
        return String(format: "%g", number)
    }
}
