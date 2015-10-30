//
//  CreateNewEvent.swift
//  TapglueSample
//
//  Created by Özgür Celebi on 24.10.15.
//  Copyright © 2015 Özgür Celebi. All rights reserved.
//

import Foundation
import Tapglue

class CreateNewEvent {
    
    func pushEvent(type: String, objectId: String ) {
        // Tapglue Event
        let event = TGEvent()
        event.type = type
        event.visibility = TGEventVisibility.Connection
        // Tapglue Event Object
        let eventObject = TGEventObject()
        eventObject.objectId = objectId
        event.object = eventObject
        
        Tapglue.createEvent(event)
    }
}