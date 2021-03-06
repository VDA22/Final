//
//  ManagedObjectFromCoreDataService.swift
//  Old MORepositoryService.swift
//  GitRepo
//
//  Created by Дарья Витер on 05/12/2019.
//  Copyright © 2019 Viter. All rights reserved.
//

import Foundation
import CoreData

// No Unit tests

/**
App bases types

```
case projectBase
case repositoryBase
```

*/
/// - Tag: BaseType
enum BaseType {
	case projectBase
	case repositoryBase
}

protocol ManagedObjectServiceProtocol: class {
	func saveCoreDataObjectsFrom(base: Any?, baseType: BaseType)
	func getDataFromCoreData(to baseType: BaseType, completion: @escaping ([Any]?) ->())
}

/**
Manager for CoreData (save and read).
```
func saveCoreDataObjectsFrom(base: Any?, baseType: BaseType)
func getDataFromCoreData(to baseType: BaseType, completion: @escaping ([Any]?) ->())
```

*/
final class ManagedObjectFromCoreDataService {
	
	let writeContext: NSManagedObjectContext!
	let readContext: NSManagedObjectContext!
	
	let repositoryEntityName = "Repository"
	let projectEntityName = "Project"
	
	private var adapter: CoreDataAdapterProtocol!
	
	private var repositoriesInCoreData: [MORepository]? {
		didSet {
			print("set repositoriesInCoreData")
		}
	}
	
	private var projectsInCoreData: [MOProject]? {
		didSet {
			print("set projectsInCoreData")
		}
	}
	
	init(withDeleting: Bool, writeContext: NSManagedObjectContext, readContext: NSManagedObjectContext?) {
		self.adapter = CoreDataAdapter()
		
		self.writeContext = writeContext
		
		if let readContext = readContext {
			self.readContext = readContext
		} else {
			self.readContext = writeContext
		}
		
		if withDeleting {
			self.deleteAllData()
		}
		
	}
	
	private func deleteAllData(){
		
		let arrayOfTypes = ["Project", "Repository","Author", "Branch", "Collaborator", "Commit", "Task"]
		
		readContext.perform {
			for type in arrayOfTypes {
				let DelAllReqVar = NSBatchDeleteRequest(fetchRequest: NSFetchRequest<NSFetchRequestResult>(entityName: type))
				do {
					try self.readContext.execute(DelAllReqVar)
					print("CoreData is empty, type: ", type)
				}
				catch {
					print("Type: ", type, ", error: ", error)
				}
			}
		}
		
		writeContext.perform {
			for type in arrayOfTypes {
				let DelAllReqVar = NSBatchDeleteRequest(fetchRequest: NSFetchRequest<NSFetchRequestResult>(entityName: type))
				do {
					try self.readContext.execute(DelAllReqVar)
					print("CoreData is empty, type: ", type)
				}
				catch {
					print("Type: ", type, ", error: ", error)
				}
			}
		}
	}
	
	/// Async function for save data from base into CoreData
	func saveCoreDataObjectsFrom(base: Any?, baseType: BaseType) {
		
		switch baseType {
		case .repositoryBase:
			
			guard let base = base as? RepositoriesBase else { return }
			
			for repository in base.repositories {
				
				writeContext.perform {
					
					var repositoryObjectStart: NSManagedObject = MORepository(context: self.writeContext)
					if let repositoryObject = self.adapter.translateModelToObject(repository, arrayOfData: nil, dataType: .repository, into: &repositoryObjectStart) as? MORepository {
						
						
						if let branches = repository.branches {
							for branch in branches {
								var branchObject: NSManagedObject = MOBranch(context: self.writeContext)
								if let branchObject = self.adapter.translateModelToObject(branch, arrayOfData: nil, dataType: .branch, into: &branchObject) as? MOBranch {
									branchObject.repository = repositoryObject
								}
							}
						}
						
						if let collaborators = repository.collaborators {
							for collaborator in collaborators {
								var collaboratorObject: NSManagedObject = MOCollaborator(context: self.writeContext)
								if let collaboratorObject = self.adapter.translateModelToObject(collaborator, arrayOfData: nil, dataType: .collaborator, into: &collaboratorObject) as? MOCollaborator {
									collaboratorObject.repository = repositoryObject
								}
							}
						}
						
						if let commits = repository.commits {
							for commit in commits {
								var commitObject: NSManagedObject = MOCommit(context: self.writeContext)
								if let commitObject = self.adapter.translateModelToObject(commit, arrayOfData: nil, dataType: .commit, into: &commitObject) as? MOCommit {
									commitObject.repository = repositoryObject
								}
							}
						}
						
						do {
							try self.writeContext.save()
							print("Success repository with name: ", repositoryObject.name ?? "")
						} catch {
							print(error)
						}
					}
				}
			}
			print("Repositories Saved into CoreData")
			
		case .projectBase :
			
			guard let base = base as? ProjectsBase else { return }
			
			for project in base.projects {
				
				writeContext.perform {
					
					var projectObject: NSManagedObject = MOProject(context: self.writeContext)
					if let projectObject = self.adapter.translateModelToObject(project, arrayOfData: nil, dataType: .project, into: &projectObject) as? MOProject {
						
						if let tasks = project.projectTasks {
							
							for task in tasks {
								var taskObject: NSManagedObject = MOTask(context: self.writeContext)
								if let taskObject = self.adapter.translateModelToObject(task, arrayOfData: nil, dataType: .task, into: &taskObject) as? MOTask {
									taskObject.project = projectObject
								}
							}
						}
						
						do {
							try self.writeContext.save()
							print("Success project with name: ", projectObject.projectName)
						} catch {
							print(error)
						}
					}
				}
			}
			print("Project Saved into CoreData")
			
		}
	}
	
	
	
	/// Sync function for read data from CoreData
	public func getDataFromCoreData(to baseType: BaseType, completion: @escaping ([Decodable]?, String?) ->()) {
		
		switch baseType {
		case .repositoryBase:
			
			readContext.performAndWait {
				let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: repositoryEntityName)
				let sortDescriptor = NSSortDescriptor(key: "lastChange", ascending: false)
				fetch.sortDescriptors = [sortDescriptor]
				var repositories = [Repository]()
				
				do {
					let results = try fetch.execute() as? [MORepository]
					if let results = results {
						print(results.count)
						repositoriesInCoreData = results
					}
				} catch {
					print("Error reading data by FetchRequest, error: ", error)
				}
				
				guard let repositoriesInCoreData = repositoriesInCoreData else { return }
				
				for repositoryObject in repositoriesInCoreData {
					
					if let repository = self.adapter.translate(objects: nil, oneObject: repositoryObject, dataType: .repository)?[0] as? Repository {
						repository.branches = self.adapter.translate(objects: repositoryObject.branches?.allObjects as? [NSManagedObject], oneObject: nil, dataType: .branch) as? [Branch]
						
						
						repository.collaborators = self.adapter.translate(objects: repositoryObject.collaborators?.allObjects as? [NSManagedObject], oneObject: nil, dataType: .collaborator) as? [User]
						
						repository.commits = self.adapter.translate(objects: repositoryObject.commits?.allObjects as? [NSManagedObject], oneObject: nil, dataType: .commit) as? [Commit]
						
						repositories.append(repository)
					}
				}
				
				completion(repositories, nil)
			}
			
		case .projectBase:
			
			readContext.performAndWait {
				let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: projectEntityName)
				
				var projects = [Project]()
				
				do {
					let results = try fetch.execute() as? [MOProject]
					if let results = results {
						print(results.count)
						projectsInCoreData = results
					}
				} catch {
					print("Error reading data by FetchRequest, error: ", error)
				}
				
				guard let projectsInCoreData = projectsInCoreData else { return }
				
				for projectObject in projectsInCoreData {
					
					if let project = self.adapter.translate(objects: nil, oneObject: projectObject, dataType: .project)?[0] as? Project {
						project.projectTasks = self.adapter.translate(objects: projectObject.tasks?.allObjects as? [NSManagedObject], oneObject: nil, dataType: .task)?[0] as? [String]
						
						projects.append(project)
					}
				}
				
				completion(projects, nil)
			}
		}
	}
}

//MARK: CoreDataServiceProtocol
extension ManagedObjectFromCoreDataService: CoreDataServiceProtocol {
	func getData(baseType: BaseType, _ completion: @escaping (Decodable?, String?) -> ()) {
		self.getDataFromCoreData(to: baseType) {
			result, error in
			
			if let result = result as? [Project] {
				completion(ProjectsBase(with: result), nil)
			} else if let result = result as? [Repository] {
				completion(RepositoriesBase(with: result), nil)
			}
		}
	}
	
	
}
