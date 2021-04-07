//
//  ViewController.swift
//  MulTimer
//
//  Created by Елена Ким on 26.02.2021.
//
import Foundation
import UIKit
import CoreData
import UserNotifications

class TimerListViewController: UITableViewController {
    
    lazy var indexPathRowOfCurrentCell = 0
    var timersArray = [Item]()
    let screenWidth = UIScreen.main.bounds.width - 30
    let screenHeight = UIScreen.main.bounds.height / 3
    //Create context CoreData
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadItems()
        tableView.register(UINib(nibName: "TimerCell", bundle: nil), forCellReuseIdentifier: "TimerCell")
    }
    
    //MARK: - ADDING NEW TIMER
    
    @IBAction func addTimerButtonPressed(_ sender: UIBarButtonItem) {
        //Create new VC to put it into the actionSheet of alert
        let vc = AlertViewController()
        vc.preferredContentSize = CGSize(width: screenWidth, height: screenHeight)
        vc.totalSecInHours = 0
        vc.totalSecInMins = 0
        vc.totalSecInSecs = 0
        vc.totalTimeInSecs = 0
        //Create Alert
        let alert = UIAlertController(title: "NEW TIMER", message: "", preferredStyle: .actionSheet)
        let action = UIAlertAction(title: "START TIMER", style: .default) { (action) in
            if vc.totalTimeInSecs != 0 {
                let newItem = Item(context: self.context)
                if vc.timerNameTextField.text == nil || vc.timerNameTextField.text == ""{
                    newItem.nameOfTimer = "Timer"
                } else {
                    newItem.nameOfTimer = vc.timerNameTextField.text
                }
                newItem.time = Int64(vc.totalTimeInSecs)
                newItem.timerID = String(Int.random(in: 0...4000000000))
                newItem.created = round(NSDate().timeIntervalSince1970)
                self.timersArray.append(newItem)
                self.saveItem()
            }
        }
        let cancelAction = UIAlertAction(title: "CANCEL", style: .default) { (cancelAction) in
            vc.dismiss(animated: true, completion: nil)
            vc.timerNameTextField.resignFirstResponder()
        }
        alert.setValue(vc, forKey: "contentViewController")
        alert.view.addSubview(vc.view)
        alert.addAction(action)
        alert.addAction(cancelAction)
        // Constraints for actionSheet
        let width: NSLayoutConstraint = NSLayoutConstraint(item: alert.view!, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 350.0)
        let height: NSLayoutConstraint = NSLayoutConstraint(item: alert.view!, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 450.0)
        alert.view.addConstraint(width)
        alert.view.addConstraint(height)
        self.present(alert, animated: true, completion: nil)
    }
    
    
    //MARK: - TableView Datasource Methods
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return timersArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TimerCell", for: indexPath) as! TimerCell
        cell.editButton.addTarget(self, action: #selector(getIndexPathFromCell), for: .touchDown)
        cell.editButton.tag = indexPath.row //save indexPath.row of specific cell for EditViewDelegate in button's tag
        cell.timerName.text = timersArray[indexPath.row].nameOfTimer
        cell.timerID = timersArray[indexPath.row].timerID!
        cell.createdTime = timersArray[indexPath.row].created
        cell.timerModel.totalTime = Int(timersArray[indexPath.row].time)
        cell.durationSaveConstantTotalTime = Int(timersArray[indexPath.row].time)
        cell.delegate = self
        //Start counting timer after terminating of app
        cell.timerModel.startAppAfterTerminate(cell.durationSaveConstantTotalTime, cell.timerID, cell.timerName, cell.durationLabel)
        //Start Timer when user add new timer in list
        let now = round(NSDate().timeIntervalSince1970)
        if cell.createdTime == now {
            cell.timerModel.startTimer(cell.durationSaveConstantTotalTime, cell.timerID, cell.timerName, cell.durationLabel, cell.startPauseButton)
        } else {
            print("Not new timer")
        }
        return cell
    }
    //when editButton in cell is pressed we get her tag that contain indexPath.row the cell we start to edit
    @objc func getIndexPathFromCell(_ sender: UIButton){
        let indexPathRow = sender.tag
        indexPathRowOfCurrentCell = indexPathRow
    }
    
    //MARK: - TableView Delegate Methods (Swipe to Delete)
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            // handle delete (by removing the data array and updating the tableview)
            context.delete(timersArray[indexPath.row])
            timersArray.remove(at: indexPath.row)
            tableView.reloadData()
        }
    }
    
    //MARK: - CRUD CoreData
    
    func loadItems() {
        let request : NSFetchRequest<Item> = Item.fetchRequest()
        do {
            timersArray = try context.fetch(request)
        } catch {
            print("Error fetching data from context \(error)")
        }
    }
    
    func saveItem() {
        do {
            try context.save()
        } catch {
            print("Error of saving item \(error)")
        }
        self.tableView.reloadData()
    }
}

//MARK: - TimerCellSegueDelegate Methods  -  Go to Edit Screen

extension TimerListViewController: TimerCellSegueDelegate {
    
    func editButtonPressed() {
        performSegue(withIdentifier: "goToEditScreen", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToEditScreen" {
            let destinationVC = segue.destination as! EditViewController
            destinationVC.nameForChange = timersArray[indexPathRowOfCurrentCell].nameOfTimer!
            destinationVC.totalTimeGotten = Int(timersArray[indexPathRowOfCurrentCell].time)
            destinationVC.delegate = self
        }
    }
}

//MARK: - EditViewDelegate Protocol   -  Update/Change Timer from EditViewController

extension TimerListViewController: EditViewDelegate {
    func updateTimer(newName: String, newTime: Int) {
        timersArray[indexPathRowOfCurrentCell].nameOfTimer = newName
        timersArray[indexPathRowOfCurrentCell].time = Int64(newTime)
        saveItem()
        tableView.reloadData()
    }
}
