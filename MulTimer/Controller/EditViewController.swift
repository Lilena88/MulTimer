//
//  EditViewController.swift
//  MulTimer
//
//  Created by Елена Ким on 22.03.2021.
//

import UIKit
import CoreData

protocol EditViewDelegate {
    func updateTimer(newName: String, totalTime: Int, new: Bool)
}

class EditViewController: UIViewController {
    
    var delegate: EditViewDelegate?
    
    let contextEdit = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var totalTime: Int = 0
    var nameForChange: String = ""
    var new: Bool = false
    
    private var totalSecInHRS = 0
    private var totalSecInMin = 0
    private var totalSecInSec = 0
    
    var arrayForPicker: [Int] {
        get {
            let hours = totalTime / 3600 % 60
            let minutes = totalTime / 60 % 60
            let seconds = totalTime % 60
            return [hours, minutes, seconds]
        }
    }
    
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var newNameTextField: UITextField!
    @IBOutlet weak var setTimePickerView: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        newNameTextField.delegate = self
        newNameTextField.text = nameForChange
        setTimePickerView.dataSource = self
        setTimePickerView.delegate = self
        //set picker with current timer values
        setTimePickerView.selectRow(arrayForPicker [0], inComponent: 0, animated: false)
        setTimePickerView.selectRow(arrayForPicker[1], inComponent: 1, animated: false)
        setTimePickerView.selectRow(arrayForPicker[2], inComponent: 2, animated: false)
        //total time in seconds
        totalSecInHRS = arrayForPicker[0] * 3600
        totalSecInMin = arrayForPicker[1] * 60
        totalSecInSec = arrayForPicker[2]
        
        saveButton.layer.cornerRadius = 5
        cancelButton.layer.cornerRadius = 5
        
        newNameTextField.placeholder = "Add name"
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        dismiss (animated: true, completion: nil)
    }
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        newNameTextField.endEditing(true)
        if nameForChange == "" {
            nameForChange = "Timer"
        }
        //delegate - TimerListViewController updates Item(timer) in timersArray and saves in DataModel
        if let delegate = self.delegate {
            delegate.updateTimer(newName: nameForChange, totalTime: totalTime, new: new)
        }
        dismiss (animated: true, completion: nil)
    }
}

//MARK: - UIPickerView DataSource and Delegate

extension EditViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0:
            return (0...23).map {($0)}.count
        case 1:
            return (0...59).map {($0)}.count
        default:
            return (0...59).map {($0)}.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch component {
        case 0:
            return String((0...23).map {($0)}[row])
        case 1:
            return String((0...59).map {($0)}[row])
        default:
            return String((0...59).map {($0)}[row])
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch component {
        case 0:
            totalSecInHRS = pickerView.selectedRow(inComponent: 0) * 3600
        case 1:
            totalSecInMin = pickerView.selectedRow(inComponent: 1) * 60
        default:
            totalSecInSec = pickerView.selectedRow(inComponent: 2)
        }
        totalTime = totalSecInHRS + totalSecInMin + totalSecInSec
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let pickerLabel = UILabel()
        pickerLabel.textColor = UIColor.black
        switch component {
        case 0:
            pickerLabel.text = "        \(String((0...23).map {($0)}[row]))"
            pickerLabel.textAlignment = NSTextAlignment.left
        case 1:
            pickerLabel.text = "        \(String((0...59).map {($0)}[row]))"
            pickerLabel.textAlignment = NSTextAlignment.left
        default:
            pickerLabel.text = "        \(String((0...59).map {($0)}[row]))"
            pickerLabel.textAlignment = NSTextAlignment.left
        }
        pickerLabel.font = UIFont.systemFont(ofSize: 18)
        return pickerLabel
    }
}

//MARK: - UITextField Delegate

extension EditViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField.text != ""{
            textField.endEditing(true)
            nameForChange = newNameTextField.text!
            return true
        } else {
            textField.placeholder = "Type something"
            return true
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let timerName = newNameTextField.text {
            nameForChange = timerName
        } else {
            textField.resignFirstResponder()
        }
    }
}
