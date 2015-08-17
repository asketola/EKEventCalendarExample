//
//  ViewController.swift
//  addEventCalendarExample
//
//  Created by Annemarie Ketola on 8/16/15.
//  Copyright (c) 2015 Annemarie Ketola. All rights reserved.
//

import UIKit
import EventKit

var dish = "entree"
var doesCalendarExist : Bool = false
var cookingClubCalendar : EKCalendar?
var startDate : NSDate!
var alarmDate : NSDate!

// An EKEventStore object is created. This represents the Calendar's database
let eventStore = EKEventStore()
let calendarDatabase = EKEventStore()

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // The authorizationStatusForEntityType method returns the authorization status
        switch EKEventStore.authorizationStatusForEntityType(EKEntityTypeEvent) {
        case .Authorized:
            println("We are authorized")
        case .Denied:
            println("Access denied")
            
        case .NotDetermined:
            // 3 If the status is not yet determined the user is prompted to deny or grant access using the requestAccessToEntityType(entityType:completion) method.
            eventStore.requestAccessToEntityType(EKEntityTypeEvent, completion:
                {[weak self] (granted: Bool, error: NSError!) -> Void in
                    if granted {
                        self!.insertEvent(eventStore)
                        println("Permission granted")
                    } else {
                        println("Access denied")
                    }
                })
        default:
            println("Case Default")
        }
        println("doesCalendarExist \(doesCalendarExist) ")
        
        // check for status for alarm
        calendarDatabase.requestAccessToEntityType(EKEntityTypeReminder, completion: { (granted: Bool, error:NSError!) -> Void in
            if !granted {
                println("Access to store not granted")
            }
        })
        
        var dataString = "August 16, 2015 22:03"
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy HH:mm"
        dateFormatter.timeZone = NSTimeZone.localTimeZone()
        startDate = dateFormatter.dateFromString(dataString) as NSDate!
        alarmDate = startDate.dateByAddingTimeInterval(-60*60)
    }
    
    
func insertEvent(store: EKEventStore) {
    // The calendarsForEntityType returns all calendars that supports events
    let calendars = store.calendarsForEntityType(EKEntityTypeEvent)
            as! [EKCalendar]
    
    // We check if the previously created calendar "Cooking Club" exists
    for calendar in calendars {
        if calendar.title == "Cooking Club" {
            cookingClubCalendar = calendar
            doesCalendarExist = true
            println("Cooking Club Calendar exists \(cookingClubCalendar)")
        }
    }
        
        if doesCalendarExist == true {
        // 3 The event has a start date of the current time and an end date of 2 hours from the current time. (2 hours x 60 minutes x 60 seconds
        // 2 hours standard cooking club time (?) can move this to 3
            let endDate = startDate.dateByAddingTimeInterval(2 * 60 * 60)
                
        // An event is created with a title of CookingClub's name and the dish you are bringing
        var event = EKEvent(eventStore: store)
            event.calendar = cookingClubCalendar
            event.title = "Cooking Club: You have \(dish)"
            
            event.startDate = startDate
            println("startDate = \(startDate)")
            event.endDate = endDate
            println("endDate = \(endDate)")
                
        // 5 The event is saved into the current calendar
        var error: NSError?
        let result = store.saveEvent(event, span: EKSpanThisEvent, error: &error)
                
        if result == false {
            if let theError = error {
                println("An error occured \(theError)")
                }
            } else {
            successAlertController()
            
            }
        } else {
            // create the new calendar
            let newCalendar = EKCalendar(forEntityType: EKEntityTypeEvent, eventStore: eventStore)
            newCalendar.title = "Cooking Club"
            newCalendar.source = eventStore.defaultCalendarForNewEvents.source
            var error: NSError? = nil
            // Save the calendar using the Event Store instance
            let calendarWasSaved = eventStore.saveCalendar(newCalendar, commit: true, error: &error)
            // Handle situation if the calendar could not be saved
            if calendarWasSaved == false {
                let alert = UIAlertController(title: "Calendar could not save", message: error?.localizedDescription, preferredStyle: .Alert)
                let OKAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                alert.addAction(OKAction)
                
                self.presentViewController(alert, animated: true, completion: nil)
            
            } else {
                println("The newCalendar was saved")
                NSUserDefaults.standardUserDefaults().setObject(newCalendar.calendarIdentifier, forKey: "addEventCalendarExample")
                // The event has a start date of the current time and an end date of 2 hours from the current time. (2 hours x 60 minutes x 60 seconds)
                let startDate = NSDate()
                let endDate = startDate.dateByAddingTimeInterval(2 * 60 * 60)
                
                // An event is created with a title of CookingClub's name and the dish you are bringing
                var event = EKEvent(eventStore: store)
                event.calendar = newCalendar
                event.title = "Cooking Club: You have \(dish)"
                
                event.startDate = startDate
                println("startDate = \(startDate)")
                event.endDate = endDate
                println("endDate = \(endDate)")
                
                // The event is saved into the current calendar
                var error: NSError?
                let result = store.saveEvent(event, span: EKSpanThisEvent, error: &error)
                
                if result == false {
                    if let theError = error {
                        println("An error occured \(theError)")
                    }
                } else {
                    successAlertController()
                }
            }
        }
      }
    
    func successAlertController() {
        println("We saved the event")
        //                    self.performSegueWithIdentifier("SHOW_DONE", sender: self)
        let successAlert = UIAlertController(title: "Success", message: "Your event has been added to your Calendar", preferredStyle: .Alert)
        let OKAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        successAlert.addAction(OKAction)
        let AddAlarmAction = UIAlertAction(title: "Add alarm 1hr prior to event", style: .Default) { (AddAlarmAction) -> Void in
            self.createReminder("reminderset", reminderDate: alarmDate)
        }
        successAlert.addAction(AddAlarmAction)
        self.presentViewController(successAlert, animated: true, completion: nil)
    }
    
    func accessCalendarInTheDatabase() {
        var calendars = calendarDatabase.calendarsForEntityType(EKEntityTypeReminder)
        
        for calendar in calendars as! [EKCalendar] {
            println("Calendar = \(calendar.title)")
        }
    }
    
    func createReminder(reminderTitle: String, reminderDate: NSDate) {
        let reminder = EKReminder(eventStore: calendarDatabase)
        
        reminder.title = "Cooking Club tonight! You have \(dish)"
        let date = reminderDate
        let alarm = EKAlarm(absoluteDate: date)
        
        reminder.addAlarm(alarm)
        
        reminder.calendar = calendarDatabase.defaultCalendarForNewReminders()
        
        var error = NSError?()
        
        if error != nil {
            println("errors: \(error?.localizedDescription)")
        }
        
        calendarDatabase.saveReminder(reminder, commit: true, error: &error)
    }
    
    @IBAction func setReminderForAlarm(sender: AnyObject) {
        
        calendarDatabase.requestAccessToEntityType(EKEntityTypeReminder, completion: { (granted, error) -> Void in
            if !granted {
                println("Access to store not granted")
                println("\(error.localizedDescription)")
            } else {
                println("We have permission to make an alarm")
                println("Reminder entered: \(alarmDate)")
            }
            
        })
        
        var alarmDate = startDate.dateByAddingTimeInterval(-60*60)
        createReminder("reminderset", reminderDate: startDate)
        
    }
    
    
    @IBAction func setReminderButtonPressed(sender: AnyObject) {
        insertEvent(eventStore)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "SHOW_DONE" {
            let nextVC = segue.destinationViewController as! ViewControllerV2
        }
    }
}

