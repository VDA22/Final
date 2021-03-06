
//
//  RepositoryModel.swift
//  GitRepo
//
//  Created by Дарья Витер on 25/11/2019.
//  Copyright © 2019 Viter. All rights reserved.
//

import UIKit

// Unit tests as part of RepositoriesBaseTests

/// Class for Repository from GitHub
public final class Repository: Codable {
	
	/// Name of repository
	public var name: String?
	/// Link to repository
	public var repoLink: String?
	/// Link for list of collaborators of repository
	public var collaboratorsLink: String?
	/// Array of Collaborators of repository
	public var collaborators: [User]?
	
	/// Link for events of repository
	var changes: String?
	/// Language of repository
	var languageOfProject: String?
	/// Field for **Owner** of repository
	var owner: User?
	/// Id of repository
	var id: Int?
	
	var lastChange: String?
	
	var branchesLink: String?
	
	var branches: [Branch]?
	
	var commits: [Commit]?
	
	/**
	Keys for decode GitHub Api Response.
	
	````
	case name
	case repoLink
	case collaborators
	case changes
	case languageOfProject
	case owner
	case id
	````
	*/
	private enum GitHubApiResponseCodingKeys: String, CodingKey {
		
		case name
		case repositoryLink = "html_url"
		case collaborators = "collaborators_url"
		
		case changes = "events_url"
		case languageOfProject = "language"
		case owner
		case id
		case lastChange = "pushed_at"
		case branchesUrl = "branches_url"
	}
	
	/**
	Initializes a new repository with the provided fields.
	
	- Parameters:
		- decoder: Decoder for decode values.
	*/
	required public init(from decoder: Decoder) throws {
		
		let container = try decoder.container(keyedBy: GitHubApiResponseCodingKeys.self)
		
		do {
			self.name = try container.decode(String?.self, forKey: .name)
		} catch {
			print(error)
			self.name = nil
		}
		
		do {
			self.repoLink = try container.decode(String?.self, forKey: .repositoryLink)
		} catch {
			print(error)
			self.repoLink = nil
		}
		
		do {
			self.collaboratorsLink = try container.decode(String?.self, forKey: .collaborators)
		} catch {
			print(error)
			self.collaboratorsLink = nil
		}
		
		do {
			self.changes = try container.decode(String?.self, forKey: .changes)
		} catch {
			print(error)
			self.changes = nil
		}
		
		do {
			self.languageOfProject = try container.decode(String?.self, forKey: .languageOfProject)
		} catch {
			print(error)
			self.languageOfProject = nil
		}
		
		do {
			self.owner = try container.decode(User?.self, forKey: .owner)
		} catch {
			print(error)
			self.owner = nil
		}
		
		do {
			self.id = try container.decode(Int?.self, forKey: .id)
		} catch {
			print(error)
			self.id = nil
		}
		
		do {
			self.lastChange = try container.decode(String.self, forKey: .lastChange)
		} catch {
			print(error)
			self.lastChange = nil
		}
		
		do {
			self.branchesLink = try container.decode(String.self, forKey: .branchesUrl)
		} catch {
			print(error)
			self.branchesLink = nil
		}
	}
	
	public init() {	}
	
	/// Get date from self.lastChange and create String with date format "yyyy-MM-dd' 'HH:mm:ss", time zone MSK
	func getRepositoryDateString() -> String? {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
		dateFormatter.timeZone = TimeZone(abbreviation: "MSK")
		guard let date = dateFormatter.date(from: self.lastChange ?? "") else { return nil }
		dateFormatter.dateFormat = "yyyy-MM-dd' 'HH:mm:ss"
		return dateFormatter.string(from: date)
	}
	
}
