//
//  MOCollaborator.swift
//  GitRepo
//
//  Created by Дарья Витер on 05/12/2019.
//  Copyright © 2019 Viter. All rights reserved.
//

import Foundation
import CoreData

@objc(MOCollaborator)
internal class MOCollaborator: NSManagedObject {
	
	@NSManaged var name: String
	
	// Relationships
	@NSManaged var repository: MORepository
}
