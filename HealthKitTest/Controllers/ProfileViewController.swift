//
//  ProfileViewController.swift
//  HealthKitTest
//

import UIKit
import HealthKit

class ProfileViewController: UITableViewController {

    
    
    @IBOutlet var lblAge:UILabel!
    @IBOutlet var lblBloodType:UILabel!
    @IBOutlet var lblBiologicalSex:UILabel!
    @IBOutlet var lblWeight:UILabel!
    @IBOutlet var lblHeight:UILabel!
    @IBOutlet var lblBmi:UILabel!
    
    let UpdateProfileSection = 2
    let SaveBMI = 3
    let kUnknownString   = "Unknown"

    let healthKit:HealthKit = HealthKit()

    
    //var healthKit:HealthKit?
    var bmi:Double?
    var height, weight:HKQuantitySample?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    func authorizeHealthKit()
    {
        self.healthKit.authorizeHealthKit { (authorized,  error) -> Void in
            if authorized {
                print("HealthKit authorization received.")
                NSUserDefaults.standardUserDefaults().setObject("yes", forKey: "authorization")
                NSUserDefaults.standardUserDefaults().synchronize()
                
                self .getHealthInfo()
            }
            else
            {
                print("HealthKit authorization denied!")
                if error != nil {
                    print("\(error)")
                    
                    let myAlert: UIAlertController = UIAlertController(title: "", message: error.localizedDescription, preferredStyle: .Alert)
                    myAlert.addAction(UIAlertAction(title: NSLocalizedString("OKTitle", comment: ""), style: .Cancel, handler: nil))
                    self.presentViewController(myAlert, animated: true, completion: nil)

                    
                }
            }
        }
    }
    
    
    
    //MARK: - Custom methods
    func getHealthInfo() {
        
        
        
        guard let authorization = NSUserDefaults.standardUserDefaults().valueForKey("authorization") as? String else {
            self.authorizeHealthKit()
            return
            
        }
        if authorization == "yes" {
            
            self.getProfileInfo();
            self.getWeight();
            self.getHeight();
        }
    }
    
    func getProfileInfo()
    {
        let profile = healthKit.readProfile()
        
        lblAge.text = profile.age == nil ? kUnknownString : String(profile.age!)
        lblBiologicalSex.text = biologicalSexLiteral(profile.biologicalsex?.biologicalSex)
        lblBloodType.text = bloodTypeLiteral(profile.bloodtype?.bloodType)
        
        
    }
    
    
    func getHeight()
    {
        // 1. Construct an HKSampleType for Height
        let sampleType = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeight)
        
        // 2. Call the method to read the most recent Height sample
        self.healthKit.readMostRecentSample(sampleType!, completion: { (mostRecentHeight, error) -> Void in
            
            if( error != nil )
            {
                print("Error reading height from HealthKit Store: \(error.localizedDescription)")
                return;
            }
            
            var heightLocalizedString = self.kUnknownString;
            self.height = mostRecentHeight as? HKQuantitySample;
            // 3. Format the height to display it on the screen
            if let meters = self.height?.quantity.doubleValueForUnit(HKUnit.meterUnit()) {
                let heightFormatter = NSLengthFormatter()
                heightFormatter.forPersonHeightUse = true;
                heightLocalizedString = heightFormatter.stringFromMeters(meters);
            }
            
            
            // 4. Update UI. HealthKit use an internal queue. We make sure that we interact with the UI in the main thread
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.lblHeight.text = heightLocalizedString
                self.updateBMI()
            });
        })
    }
    
    func getWeight()
    {
        
        // 1. Construct an HKSampleType for weight
        let sampleType = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyMass)
        
        // 2. Call the method to read the most recent weight sample
        self.healthKit.readMostRecentSample(sampleType!, completion: { (mostRecentWeight, error) -> Void in
            
            if( error != nil )
            {
                print("Error reading weight from HealthKit Store: \(error.localizedDescription)")
                return;
            }
            
            var weightLocalizedString = self.kUnknownString;
            // 3. Format the weight to display it on the screen
            self.weight = mostRecentWeight as? HKQuantitySample;
            if let kilograms = self.weight?.quantity.doubleValueForUnit(HKUnit.gramUnitWithMetricPrefix(.Kilo)) {
                let weightFormatter = NSMassFormatter()
                weightFormatter.forPersonMassUse = true;
                weightLocalizedString = weightFormatter.stringFromKilograms(kilograms)
            }
            
            // 4. Update UI in the main thread
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.lblWeight.text = weightLocalizedString
                self.updateBMI()
                
            });
        });
        
    }
    
    func updateBMI()
    {
        if weight != nil && height != nil {
            // 1. Get the weight and height values from the samples read from HealthKit
            let weightInKilograms = weight!.quantity.doubleValueForUnit(HKUnit.gramUnitWithMetricPrefix(.Kilo))
            let heightInMeters = height!.quantity.doubleValueForUnit(HKUnit.meterUnit())
            // 2. Call the method to calculate the BMI
            bmi  = calculateBMIWithWeightInKilograms(weightInKilograms, heightInMeters: heightInMeters)
        }
        // 3. Show the calculated BMI
        var bmiString = kUnknownString
        if bmi != nil {
            lblBmi.text =  String(format: "%.02f", bmi!)
        }
        
    }

    func calculateBMIWithWeightInKilograms(weightInKilograms:Double, heightInMeters:Double) -> Double?
    {
        if heightInMeters == 0 {
            return nil;
        }
        return (weightInKilograms/(heightInMeters*heightInMeters));
    }
    func biologicalSexLiteral(biologicalSex:HKBiologicalSex?)->String
    {
        var biologicalSexText = kUnknownString;
        
        if  biologicalSex != nil {
            
            switch( biologicalSex! )
            {
            case .Female:
                biologicalSexText = "Female"
            case .Male:
                biologicalSexText = "Male"
            default:
                break;
            }
            
        }
        return biologicalSexText;
    }
    
    func bloodTypeLiteral(bloodType:HKBloodType?)->String
    {
        
        var bloodTypeText = kUnknownString;
        
        if bloodType != nil {
            
            switch( bloodType! ) {
            case .APositive:
                bloodTypeText = "A+"
            case .ANegative:
                bloodTypeText = "A-"
            case .BPositive:
                bloodTypeText = "B+"
            case .BNegative:
                bloodTypeText = "B-"
            case .ABPositive:
                bloodTypeText = "AB+"
            case .ABNegative:
                bloodTypeText = "AB-"
            case .OPositive:
                bloodTypeText = "O+"
            case .ONegative:
                bloodTypeText = "O-"
            default:
                break;
            }
            
        }
        return bloodTypeText;
    }
    
    
    func saveUserBMI() {
        
        // Save BMI value with current BMI value
        if bmi != nil {
            healthKit.saveBMISample(bmi!, date: NSDate())
        }
        else {
            print("There is no BMI data to save")
        }
        
        
    }
    
    // MARK: - Table view data source & Delegate Methods
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath , animated: true)
        
        switch (indexPath.section, indexPath.row)
        {
        case (UpdateProfileSection,0):
            getHealthInfo()
        case (SaveBMI,0):
            saveUserBMI()
        default:
            break;
        }
        
        
    }
}
