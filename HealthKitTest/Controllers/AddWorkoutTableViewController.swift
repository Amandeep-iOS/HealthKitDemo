//
//  AddWorkoutTableViewController.swift
//  HealthKitTest
//

import UIKit

class AddWorkoutTableViewController: UITableViewController {

    
    
    @IBOutlet var cellDate:DatePickerCell!
    @IBOutlet var cellStartTime:DatePickerCell!
    
    @IBOutlet var cellDurationTime:NumberCell!
    @IBOutlet var cellCalories:NumberCell!
    @IBOutlet var cellDistance:NumberCell!
    
    
    
    let kSecondsInMinute=60.0
    let kDefaultWorkoutDuration:NSTimeInterval=(1.0*60.0*60.0) // One hour by default
    let lengthFormatter = NSLengthFormatter()
    var distanceUnit = DistanceUnit.Miles
    
    func datetimeWithDate(date:NSDate , time:NSDate) -> NSDate? {
        
        let currentCalendar = NSCalendar.currentCalendar()
        let dateComponents = currentCalendar.components([.Day, .Month, .Year], fromDate: date)
        let hourComponents = currentCalendar.components([.Hour, .Minute], fromDate: time)
        
        let dateWithTime = currentCalendar.dateByAddingComponents(hourComponents, toDate:currentCalendar.dateFromComponents(dateComponents)!, options:NSCalendarOptions(rawValue: 0))
        
        return dateWithTime;
        
    }
    
    
    var startDate:NSDate? {
        get {
            
            return datetimeWithDate(cellDate.date, time: cellStartTime.date )
        }
    }
    
    var endDate:NSDate? {
        get {
            let endDate = startDate?.dateByAddingTimeInterval(durationInMinutes*kSecondsInMinute)
            return endDate
        }
    }
    
    var distance:Double {
        get {
            return cellDistance.doubleValue
        }
    }
    
    
    var durationInMinutes:Double {
        get {
            return cellDurationTime.doubleValue
        }
    }
    
    var energyBurned:Double? {
        return cellCalories.doubleValue
        
    }
    
    func updateOKButtonStatus() {
        
        self.navigationItem.rightBarButtonItem?.enabled = ( cellDistance.doubleValue > 0 && cellCalories.doubleValue > 0 && cellDistance.doubleValue > 0);
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cellDate.inputMode = .Date
        cellStartTime.inputMode = .Time
        
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let endDate = NSDate()
        let startDate = endDate.dateByAddingTimeInterval(-kDefaultWorkoutDuration)
        
        cellDate.date = startDate;
        cellStartTime.date = startDate
        
        let formatter = NSLengthFormatter()
        formatter.unitStyle = .Long
        let unit = distanceUnit == DistanceUnit.Kilometers ? NSLengthFormatterUnit.Kilometer : NSLengthFormatterUnit.Mile
        let unitString = formatter.unitStringFromValue(2.0, unit: unit)
        cellDistance.textLabel?.text = "Distance (" + unitString.capitalizedString + ")"
        
        self.navigationItem.rightBarButtonItem?.enabled  = false
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    
    @IBAction func textFieldValueChanged(sender:AnyObject ) {
        updateOKButtonStatus()
    }
    

}
