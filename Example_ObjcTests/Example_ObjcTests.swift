//
//  Example
//  man
//
//  Created by man on 11/11/2018.
//  Copyright © 2018 man. All rights reserved.
//

import XCTest

class Example_ObjcTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    var callbackFlag = false
    func testChallenge() {
        let expectation = self.expectation(description: "Test after 5 seconds")
        
        let url = URL(string: "https://foo.com/")!
        let request = URLRequest(url: url)
        let session = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: nil)

        let task = session.dataTask(with: request, completionHandler: {(data, response, error) in
            expectation.fulfill()
        });
        task.resume()
        
        waitForExpectations(timeout: 7, handler: nil)
        XCTAssertTrue(callbackFlag)
    }
}

extension Example_ObjcTests: URLSessionDelegate {
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        callbackFlag = true
        completionHandler(.performDefaultHandling, nil)
    }
}
