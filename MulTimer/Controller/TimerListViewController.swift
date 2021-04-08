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
        performSegue(withIdentifier: "addNewGoToEdit", sender: self)
    }
    
    //MARK: - TableView Datasource Methods
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
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

//MARK: - Segue to EditVC when editButton pressed in the cell

extension TimerListViewController: TimerCellSegueDelegate {
    
    func editButtonPressed() {
        performSegue(withIdentifier: "goToEditScreen", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToEditScreen" {
            let destinationVC = segue.destination as! EditViewController
            destinationVC.nameForChange = timersArray[indexPathRowOfCurrentCell].nameOfTimer!
            destinationVC.totalTime = Int(timersArray[indexPathRowOfCurrentCell].time)
            destinationVC.new = false
            destinationVC.delegate = self
        } else if segue.identifier == "addNewGoToEdit" {
            let destinationVC = segue.destination as! EditViewController
            destinationVC.new = true
            destinationVC.delegate = self
        }
    }
}

//MARK: - EditViewDelegate Protocol   -  Update/Change Timer from EditViewController

extension TimerListViewController: EditViewDelegate {
    func updateTimer(newName: String, totalTime: Int, new: Bool) {
        if new {
            if totalTime != 0 {
                let newItem = Item(context: context)
                newItem.nameOfTimer = newName
                newItem.time = Int64(totalTime)
                newItem.timerID = String(Int.random(in: 0...4000000000))
                newItem.created = round(NSDate().timeIntervalSince1970)
            }
            saveItem()
            loadItems()
            tableView.reloadData()
        } else {
            timersArray[indexPathRowOfCurrentCell].nameOfTimer = newName
                  timersArray[indexPathRowOfCurrentCell].time = Int64(totalTime)
                  saveItem()
                  tableView.reloadData()
        }
    }
}
