//
//  CollaboratorsTableViewControllerTests.swift
//  GitRepoTests
//
//  Created by Дарья Витер on 09/12/2019.
//  Copyright © 2019 Viter. All rights reserved.
//

import XCTest
@testable import GitRepo

class CollaboratorsTableViewControllerTests: XCTestCase {
	
	class FakeCollaboratorsPresenter: CollaboratorsTablePresenterProtocol {
		
		weak var view: CollaboratorsTableViewProtocol!
		var testRepository: Repository!
		
		required init(view: CollaboratorsTableViewProtocol, repository: Repository) {
			self.view = view
			self.testRepository = repository
		}
		
		func setRepository() {
			view.setupRepository(testRepository)
		}
	}
	
	var view: CollaboratorsTableViewController!
	var presenter: FakeCollaboratorsPresenter!
	var testRepository: Repository!

    override func setUp() {
		super.setUp()
		
		view = CollaboratorsTableViewController()
		testRepository = Repository()
		presenter = FakeCollaboratorsPresenter(view: view, repository: testRepository)
		view.presenter = presenter
    }

    override func tearDown() {
		super.tearDown()
		
		view = nil
		presenter = nil
    }
	
	func testIsNameOfCollaboratorIsNotNilIfSetRepository () {
		// arrange
		let testTable = UITableView()
		testTable.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
		// act
		testRepository.collaborators = [User(login: "Foo")]
		presenter.setRepository()
		
		let testName = view.tableView(testTable, cellForRowAt: IndexPath(row: 0, section: 0)).textLabel?.text
		
		// assert
		
		XCTAssertNotNil(testName)
	}
	
	func testIsNameOfCollaboratorIsEqualIfSetRepository () {
		// arrange
		let testTable = UITableView()
		testTable.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
		// act
		testRepository.collaborators = [User(login: "Foo")]
		presenter.setRepository()
		
		let testName = view.tableView(testTable, cellForRowAt: IndexPath(row: 0, section: 0)).textLabel?.text
		
		// assert
		
		XCTAssertEqual(testName, "Foo")
	}
	
	func testCountOfCollaboratorIsEqualIfSetRepository () {
		// arrange
		let testTable = UITableView()
		testTable.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
		// act
		testRepository.collaborators = [User(login: "Foo")]
		presenter.setRepository()
		let testCount = view.tableView(testTable, numberOfRowsInSection: 0)
		
		// assert
		XCTAssertEqual(testCount, 1)
	}
	
	func testCountOfCollaboratorIsEqualIfSetedRepositoryCollaboratorsIsNil () {
		// arrange
		let testTable = UITableView()
		testTable.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
		// act
		presenter.setRepository()
		let testCount = view.tableView(testTable, numberOfRowsInSection: 0)
		
		// assert
		XCTAssertEqual(testCount, 0)
	}

}