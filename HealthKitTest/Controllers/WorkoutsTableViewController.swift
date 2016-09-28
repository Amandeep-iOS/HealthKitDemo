//
//  WorkoutsTableViewController.swift
//  HealthKitTest
//

import UIKit
import HealthKit

public enum DistanceUnit:Int {
    case Miles=0, Kilometers=1
}



class WorkoutsTableViewController: UITableViewController {

    
    let kAddWorkoutReturnOKSegue = "addWorkoutOKSegue"
    let kAddWorkoutSegue  = "addWorkout"
    
    var distanceUnit = DistanceUnit.Miles
    var healthKit:HealthKit = HealthKit()
    
    var workouts = [HKWorkout]()

    // MARK: - Formatters
    lazy var dateFormatter:NSDateFormatter = {
        
        let formatter = NSDateFormatter()
        formatter.timeStyle = .ShortStyle
        formatter.dateStyle = .MediumStyle
        return formatter;
        
    }()
    
    
    let durationFormatter = NSDateComponentsFormatter()
    let energyFormatter = NSEnergyFormatter()
    let distanceFormatter = NSLengthFormatter()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.clearsSelectionOnViewWillAppear = false

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        
        self.healthKit.readRunningWorkOuts({ (results, error) -> Void in
            if( error != nil )
            {
                print("Error reading workouts: \(error.localizedDescription)")
                return;
            }
            else
            {
                print("Workouts read successfully!")
            }
            
            //Keep workouts and refresh tableview in main thread
            self.workouts = results as! [HKWorkout]
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.tableView.reloadData()
            });
            
        })
    }

    
    

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if( segue.identifier == kAddWorkoutSegue )
        {
//            if let nextScene = segue.destinationViewController as? UINavigationController {
//                if let arrVc: NSArray = nextScene.viewControllers {
//                    
//                    if let addViewController = arrVc.objectAtIndex(0) as? AddWorkoutTableViewController {
//                        
//                        addViewController.distanceUnit = distanceUnit
//                        
//                    }
//                }
//            }
            
           
        }
        
    }
    
    @IBAction func unitsChanged(sender:UISegmentedControl) {
        
        distanceUnit  = DistanceUnit(rawValue: sender.selectedSegmentIndex)!
        tableView.reloadData()
        
    }
    
    // MARK: - Segues
    @IBAction func unwindToSegue (segue : UIStoryboardSegue) {
        
        if( segue.identifier == kAddWorkoutReturnOKSegue )
        {
            if let addViewController:AddWorkoutTableViewController = segue.sourceViewController as? AddWorkoutTableViewController {
                
                // 1. Set the Unit type
                var hkUnit = HKUnit.meterUnitWithMetricPrefix(.Kilo)
                if distanceUnit == .Miles {
                    hkUnit = HKUnit.mileUnit()
                }
                let now   = NSDate()
                
                // 2. Save the workout
                self.healthKit.saveRunningWorkout(addViewController.startDate!, endDate: addViewController.endDate!, distance: addViewController.distance , distanceUnit:hkUnit, kiloCalories: addViewController.energyBurned!, completion: { (success, error ) -> Void in
                    if( success )
                    {
                        print("Workout saved!")
                        
                        
                        
                    }
                    else if( error != nil ) {
                        print("\(error)")
                    }
                })
            }
        }
        
    }
    
    
    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  workouts.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("workoutcell", forIndexPath: indexPath)
        
        
        // 1. Get workout for the row. Cell text: Workout Date
        let workout  = workouts[indexPath.row]
        let startDate = dateFormatter.stringFromDate(workout.startDate)
        cell.textLabel!.text = startDate
        
        // 2. Detail text: Duration - Distance
        // Duration
        var detailText = "Duration: " + durationFormatter.stringFromTimeInterval(workout.duration)!
        // Distance in Km or miles depending on user selection
        detailText += " Distance: "
        if distanceUnit == .Kilometers {
            let distanceInKM = workout.totalDistance!.doubleValueForUnit(HKUnit.meterUnitWithMetricPrefix(HKMetricPrefix.Kilo))
            detailText += distanceFormatter.stringFromValue(distanceInKM, unit: NSLengthFormatterUnit.Kilometer)
        }
        else {
            let distanceInMiles = workout.totalDistance!.doubleValueForUnit(HKUnit.mileUnit())
            detailText += distanceFormatter.stringFromValue(distanceInMiles, unit: NSLengthFormatterUnit.Mile)
            
        }
        // 3. Detail text: Energy Burned
        let energyBurned = workout.totalEnergyBurned!.doubleValueForUnit(HKUnit.jouleUnit())
        detailText += " Energy: " + energyFormatter.stringFromJoules(energyBurned)
        cell.detailTextLabel?.text = detailText;
        
        return cell
    }


    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
