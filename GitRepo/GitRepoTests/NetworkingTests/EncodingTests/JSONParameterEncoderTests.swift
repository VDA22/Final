//
//  JSONParameterEncoderTests.swift
//  GitRepoTests
//
//  Created by Дарья Витер on 02/12/2019.
//  Copyright © 2019 Viter. All rights reserved.
//

import XCTest
@testable import GitRepo

/// - Tag: JSONParameterEncoderTests
class JSONParameterEncoderTests: XCTestCase {

	var parameters: Parameters!
	var url: URL!
	
	override func setUp() {
		super.setUp()
		
		url = URL(string: "testJSONEncoder")
		parameters = Parameters(dictionaryLiteral: ("Baz", "Bar"))
	}
	
	override func tearDown() {
		super.tearDown()
		
		parameters = nil
		url = nil
	}
	
	func testCreateRequestWithUrlWithoutError() {
		// arrange
		var testRequest = URLRequest(url: url)
		// act
		do {
			try JSONParameterEncoder.encode(urlRequest: &testRequest, with: parameters)
		} catch {
			// assert
			XCTAssertNil(error)
		}
		
		// assert
		XCTAssertNotNil(testRequest)
	}
	
	func testCreateRequestErrorIfURLIsNil () {
		// arrange
		var testRequest = URLRequest(url: url)
		// act
		testRequest.url = nil
		
		do {
			try JSONParameterEncoder.encode(urlRequest: &testRequest, with: parameters)
		} catch {
			// assert
			XCTAssertEqual(error.localizedDescription, "The operation couldn’t be completed. (GitRepoTests.NetworkError error 2.)")
		}
	}
	
	func testURLRequestContainsAtLeastOneHeader() {
		// arrange
		var testRequest = URLRequest(url: url)
		// act
		do {
			try JSONParameterEncoder.encode(urlRequest: &testRequest, with: parameters)
		} catch {
			// assert
			XCTAssertEqual(testRequest.allHTTPHeaderFields?.count, 1)
		}
		
	}
	
	func testURLRequestContainsContentTypeHeader() {
		// arrange
		var testRequest = URLRequest(url: url)
		// act
		do {
			try JSONParameterEncoder.encode(urlRequest: &testRequest, with: parameters)
		} catch {
			// assert
			XCTAssertEqual(testRequest.allHTTPHeaderFields?.first?.key, "Content-Type")
			XCTAssertEqual(testRequest.allHTTPHeaderFields?.first?.value, "application/json")
		}
	}
	
	func testWithEmptyParameters () {
		// arrange
		var testRequest = URLRequest(url: url)
		let emptyParameters = [String : Any]()
		// act
		do {
			try JSONParameterEncoder.encode(urlRequest: &testRequest, with: emptyParameters)
		} catch {
			// assert
			XCTAssertNil(error)
		}
		
		// assert
		XCTAssertNotNil(testRequest)
	}

}
