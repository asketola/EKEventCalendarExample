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
//var newCookingClubCalendar : EKCalendar?


// 1 An EKEventStore object is created. This represents the Calendar's database
let eventStore = EKEventStore()

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
//        // 1 An EKEventStore object is created. This represents the Calendar's database
//        let eventStore = EKEventStore()
        
        // 2 The authorizationStatusForEntityType method returns the authorization status
        switch EKEventStore.authorizationStatusForEntityType(EKEntityTypeEvent) {
        case .Authorized:
//            insertEvent(eventStore)
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
    }
    
    
func insertEvent(store: EKEventStore) {
    // 1 The calendarsForEntityType returns all calendars that supports events
    let calendars = store.calendarsForEntityType(EKEntityTypeEvent)
            as! [EKCalendar]
//    println("All the calendars we have are: \(calendars)")
    
    // 2 We check if the previously created calendar "Cooking Club" exists
    for calendar in calendars {
        if calendar.title == "Cooking Club" {
            cookingClubCalendar = calendar
            doesCalendarExist = true
            println("Cooking Club Calendar exists \(cookingClubCalendar)")
        }
    }
        
        if doesCalendarExist == true {
        // 3 The event has a start date of the current time and an end date of 2 hours from the current time. (2 hours x 60 minutes x 60 seconds)
            let startDate = NSDate()
        // 2 hours standard cooking club time (?) can move this to 3
            let endDate = startDate.dateByAddingTimeInterval(2 * 60 * 60)
                
        // 4 An event is created with a title of "New meeting"
        // Create Event
        var event = EKEvent(eventStore: store)
            event.calendar = cookingClubCalendar
                
            event.title = "Cooking Club: You have \(dish)"
            
            event.startDate = startDate
            println("startDate = \(startDate)")
            event.endDate = endDate
            println("endDate = \(endDate)")
                
        // 5 The event is saved into the current calendar.
        // Save Event in Calendar
        var error: NSError?
        let result = store.saveEvent(event, span: EKSpanThisEvent, error: &error)
                
        if result == false {
            if let theError = error {
                println("An error occured \(theError)")
                }
            } else {
            println("We created an event through the if calendar.title == Cooking Club")
//            self.performSegueWithIdentifier("SHOW_DONE", sender: self)
            let successAlert = UIAlertController(title: "Success", message: "Your event has been saved", preferredStyle: .Alert)
            let OKAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            successAlert.addAction(OKAction)
            self.presentViewController(successAlert, animated: true, completion: nil)
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
                // then add an event
                // The event has a start date of the current time and an end date of 2 hours from the current time. (2 hours x 60 minutes x 60 seconds)
                let startDate = NSDate()
                // 2 hours
                let endDate = startDate.dateByAddingTimeInterval(2 * 60 * 60)
                
                // 4 An event is created with a title of "New meeting"
                // Create Event
                var event = EKEvent(eventStore: store)
                event.calendar = newCalendar
                
                event.title = "Cooking Club: You have \(dish)"
                
                event.startDate = startDate
                println("startDate = \(startDate)")
                event.endDate = endDate
                println("endDate = \(endDate)")
                
                // 5 The event is saved into the current calendar.
                // Save Event in Calendar
                var error: NSError?
                let result = store.saveEvent(event, span: EKSpanThisEvent, error: &error)
                
                if result == false {
                    if let theError = error {
                        println("An error occured \(theError)")
                    }
                } else {
                    println("We saved the event")
//                    self.performSegueWithIdentifier("SHOW_DONE", sender: self)
                    let successAlert = UIAlertController(title: "Success", message: "Your event has been saved", preferredStyle: .Alert)
                    let OKAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                    successAlert.addAction(OKAction)
                    self.presentViewController(successAlert, animated: true, completion: nil)
                }
            }
        }
      }
    
    
    @IBAction func setReminderButtonPressed(sender: AnyObject) {
        insertEvent(eventStore)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "SHOW_DONE" {
            let nextVC = segue.destinationViewController as! ViewControllerV2
        }
    }
}

