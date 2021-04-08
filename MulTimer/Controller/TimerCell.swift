//
//  TimerCell.swift
//  MulTimer
//
//  Created by Елена Ким on 01.03.2021.
//

import UIKit
import UserNotifications
import CoreData
import AVFoundation

protocol TimerCellSegueDelegate: AnyObject {
    func editButtonPressed()
}

class TimerCell: UITableViewCell {
    
    var delegate: TimerCellSegueDelegate?
    var durationSaveConstantTotalTime = 0
    var isTimerRunning: Bool = false
    var timerID: String = ""
    var createdTime: TimeInterval = 0
    var timerModel = TimerModel()
    
    @IBOutlet weak var timerName: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var startPauseButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let tap = UITapGestureRecognizer(target: self, action: #selector(durationLabelTapComplete))
        durationLabel.addGestureRecognizer(tap)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: false)
        if timerModel.timer.isValid {
            isTimerRunning = true
            setPauseTitleOnButton()
        }
        if timerModel.restTime != 0 {
            timerModel.totalTime = timerModel.restTime
            setResumeTitleOnButton()
        }
    }
    
    //MARK: - Button Pressed Methods
    
    @IBAction func startPauseTimerButtonPressed(_ sender: UIButton) {
        if timerModel.timer.isValid == false {
            isTimerRunning = true
            durationLabel.text = timerModel.timeToHoursMinSecFormat(time: timerModel.totalTime)
            timerModel.startTimer(durationSaveConstantTotalTime, timerID, timerName, durationLabel, sender)
            setPauseTitleOnButton()
        } else {
            isTimerRunning = false
            timerModel.pauseTimer(timerID, durationLabel)
            setResumeTitleOnButton()
        }
    }
    
    @IBAction func stopTimerButtonPressed(_ sender: UIButton) {
        isTimerRunning = false
        timerModel.stopTimer(timerID)
        timerModel.totalTime = durationSaveConstantTotalTime
        durationLabel.text = timerModel.timeToHoursMinSecFormat(time: durationSaveConstantTotalTime)
        setStartTitleOnButton()
    }
    
    @IBAction func editButtonPressed(_ sender: UIButton) {
        // stop timer
        isTimerRunning = false
        timerModel.stopTimer(timerID)
        timerModel.restTime = 0
        timerModel.totalTime = durationSaveConstantTotalTime
        durationLabel.text = timerModel.timeToHoursMinSecFormat(time: durationSaveConstantTotalTime)
        setStartTitleOnButton()
        // delegate - TimerListViewController perform segue from TimerListViewController to EditVC
        if let delegate = self.delegate {
            delegate.editButtonPressed()
        }
    }
    
    @objc func durationLabelTapComplete() {
        durationLabel.isUserInteractionEnabled = false
        durationLabel.text = timerModel.timeToHoursMinSecFormat(time: durationSaveConstantTotalTime)
        isTimerRunning = false
        setStartTitleOnButton()
        AudioServicesRemoveSystemSoundCompletion(timerModel.systemSoundID)
    }
    
    func setStartTitleOnButton() {
        startPauseButton.setTitle("Start", for: .normal)
        startPauseButton.setTitleColor(.systemGreen, for: .normal)
    }
    
    func setPauseTitleOnButton() {
        startPauseButton.setTitle("Pause", for: .normal)
        startPauseButton.setTitleColor(.systemOrange, for: .normal)
    }
    
    func setResumeTitleOnButton() {
        startPauseButton.setTitle("Resume", for: .normal)
        startPauseButton.setTitleColor(.systemGreen, for: .normal)
    }
}
