//
//  GitHubEndPoint.swift
//  GitRepo
//
//  Created by Дарья Витер on 01/12/2019.
//  Copyright © 2019 Viter. All rights reserved.
//

import Foundation

// Unit Tests

/**
[GitHubApi](x-source-tag://GitHubApi) options.
Tests - [GitHubApiTests](x-source-tag://URLParameterEncoderTests).

````
/// for get user info
case user
/// for get repos
case repos
/// for get information about concrete repository
case oneRepo(url: String)
/// for get array of collaborators
case collaborators(url: String)
/// for get array of branches
case branches(url: String)
/// for get array of commits
case commits(url: String)
/// for get one commit
case oneCommit(url: String)

````
*/
/// - Tag: GitHubApi
public enum GitHubApi {
	
	/// for get user info
	case user
	/// for get repos
	case repos
	/// for get information about concrete repository
	case oneRepo(repositoryName: String)
	/// for get array of collaborators
	case collaborators(repositoryName: String)
	/// for get array of branches
	case branches(repositoryName: String)
	/// for get array of commits
	case commits(repositoryName: String)
	/// for get one commit
	case oneCommit(repositoryName: String)
	
}


extension GitHubApi: EndPointType {
	
	/// Base URL for connecting GitHub : https://api.github.com/user
	var baseURL: URL {
		
		switch self {
		case .oneRepo:
			let userName = UserDefaults.standard.get(with: .oauth_user_login)
			guard let url = URL(string: "https://api.github.com/repos/\(userName)") else {fatalError("baseURL could not be configured")}
			return url
			
		case .collaborators(let url):
			let trimmedUrl = url.replacingOccurrences(of: "{/collaborator}", with: "")
			guard let url = URL(string: trimmedUrl) else { fatalError("baseURL could not be configured") }
			return url
			
		case .branches(let url):
			let trimmedUrl = url.replacingOccurrences(of: "{/branch}", with: "")
			guard let url = URL(string: trimmedUrl) else { fatalError("baseURL could not be configured") }
			return url
			
		case .commits(let url):
			guard let url = URL(string: url) else { fatalError("baseURL could not be configured") }
			return url
			
		case .oneCommit(let url):
			guard let url = URL(string: url) else { fatalError("baseURL could not be configured") }
			return url
			
		default:
			guard let url = URL(string: "https://api.github.com/user") else { fatalError("baseURL could not be configured") }
			return url
		}
	}
	
	/// Path to adding for **baseURL**
	var path: String {
		switch self {
		/// Path to user login
		case .user: return ""
		/// Path to users repositories
		case .repos: return "/repos"
		/// Path to one repository with repository name
		case .oneRepo(let repoName): return "/\(repoName)"
			
		case .collaborators(_ ), .branches(_ ), .commits(_ ), .oneCommit(_ ):
			return ""
		}
	}
	
	/// Http Get Method
	var httpMethod: HTTPMethod {
		return .get
	}
	
	/**
	
	Choosing HttpTask
	
	-Parameters:
	- token: from UserDefaults.standard
	- HttpTask: type of request
	
	*/
	var task: HTTPTask {
		return .requestParametersAndHeaders(bodyParameters: nil, urlParameters: nil, additionHeaders: self.headers)
	}
	
	/// HttpHeaders for Auth at GitHub
	var headers: HTTPHeaders? {
		let token = UserDefaults.standard.get(with: .oauth_access_token)
		let header = HTTPHeaders(dictionaryLiteral: ("Authorization", "token \(token)"))
		return header
	}
}
