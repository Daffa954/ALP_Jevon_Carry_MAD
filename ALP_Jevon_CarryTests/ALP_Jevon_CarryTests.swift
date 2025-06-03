//
//  ALP_Jevon_CarryTests.swift
//  ALP_Jevon_CarryTests
//
//  Created by Daffa Khoirul on 16/05/25.
//

import XCTest
@testable import ALP_Jevon_Carry
struct User {
    var uid: String
}



class journalRepository : FirebaseJournalRepository {
    
}
class MockFirebaseJournalRepository: FirebaseJournalRepository {
    
}
//    var sessionsToReturn: [BreathingSession] = []
//    var fetchCalled = false
//    var listenCallback: (([BreathingSession]) -> Void)?
//
//    override func fetchAllSessions(for userID: String, completion: @escaping ([BreathingSession]) -> Void) {
//        fetchCalled = true
//        completion(sessionsToReturn)
//    }
//
//    override func startListening(for userID: String, onChange: @escaping ([BreathingSession]) -> Void) {
//        listenCallback = onChange
//        onChange(sessionsToReturn)
//    }
//
//    override func stopListening() {
//        listenCallback = nil
//    }


final class ALP_Jevon_CarryTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
