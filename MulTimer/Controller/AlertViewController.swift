//
//  AlertViewController.swift
//  MulTimer
//
//  Created by Елена Ким on 26.03.2021.
//

import UIKit

class AlertViewController: UIViewController {
    
    let hoursArray = (0...23).map {($0)}
    let minutesArray = (0...59).map {($0)}
    let secondsArray = (0...59).map {($0)}
    
    var totalSecInHours = 0
    var totalSecInMins = 0
    var totalSecInSecs = 0
    var totalTimeInSecs = 0

 
    @IBOutlet var alertView: UIView!
    @IBOutlet weak var timePickerView: UIPickerView!
    @IBOutlet weak var timerNameTextField: UITextField!
   
    override func viewDidLoad() {
        super.viewDidLoad()
        timePickerView.delegate = self
        timerNameTextField.delegate = self
    }
}
//MARK: - TextFieldDelegate Methods

extension AlertViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField.text != ""{
            return true
        } else {
            textField.placeholder = "Type something"
            return true
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        // до того как сбросить значение, нужно его использовать
        textField.resignFirstResponder()
    }

}

//MARK: - UIPicker

extension AlertViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0:
            return hoursArray.count
        case 1:
            return minutesArray.count
        default:
            return secondsArray.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch component {
        case 0:
            return String(hoursArray[row])
        case 1:
            return String(minutesArray[row])
        default:
            return String(secondsArray[row])
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch component {
        case 0:
             totalSecInHours = hoursArray[row] * 3600
        case 1:
             totalSecInMins = minutesArray[row] * 60
        default:
             totalSecInSecs = secondsArray[row]
        }
        totalTimeInSecs = totalSecInHours + totalSecInMins + totalSecInSecs
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView
    {
        let pickerLabel = UILabel()
        pickerLabel.textColor = UIColor.black
        
        switch component {
        case 0:
            pickerLabel.text = "      \(String(hoursArray[row]))"
            pickerLabel.textAlignment = NSTextAlignment.left
        case 1:
            pickerLabel.text = "      \(String(minutesArray[row]))"
            pickerLabel.textAlignment = NSTextAlignment.left
        default:
            pickerLabel.text = "      \(String(secondsArray[row]))"
            pickerLabel.textAlignment = NSTextAlignment.left
        }
        pickerLabel.font = UIFont.systemFont(ofSize: 18)
        return pickerLabel
    }
}

