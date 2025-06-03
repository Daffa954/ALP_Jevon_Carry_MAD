//
//  ALP_Jevon_CarryTests.swift
//  ALP_Jevon_CarryTests
//
//  Created by Daffa Khoirul on 16/05/25.
//

import XCTest
@testable import ALP_Jevon_Carry

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
    
        
    class MockHistoryRepository: HistoryRepository {
        var isAddCalled = false
        var addedHistory: HistoryModel?
        var fetchCompletion: (([HistoryModel]) -> Void)?
        
        override func addHistory(_ history: HistoryModel, completion: @escaping (Bool) -> Void) {
            isAddCalled = true
            addedHistory = history
            completion(true)
        }
        
        override func fetchAllHistory(for userID: String, completion: @escaping ([HistoryModel]) -> Void) {
            fetchCompletion = completion
            completion([
                HistoryModel(type: "PHQ-9", totalScore: 10, date: Date(), summary: "Moderate depression", userID: userID)
            ])
        }
    }
        
        
    @MainActor func testPHQ9_Questions_is_9() {
        let vm = QuizViewModel(type: "PHQ-9")
        XCTAssertEqual(vm.questions.count, 9)
    }
        
    @MainActor func testGAD7_Questions_is_7() {
        let vm = QuizViewModel(type: "GAD-7")
        XCTAssertEqual(vm.questions.count, 7)
    }
        
    @MainActor func testTotalScoreCalculation_PHQ9() {
        let vm = QuizViewModel(type: "PHQ-9")
        vm.selectedAnswers = [0: 1, 1: 1, 2: 1, 3: 1, 4: 1, 5: 1, 6: 1, 7: 1, 8: 1]
        XCTAssertEqual(vm.totalScore(), 9)
    }
    
    @MainActor func testTotalScoreCalculation_GAD7() {
        let vm = QuizViewModel(type: "GAD-7")
        vm.selectedAnswers = [0: 1, 1: 1, 2: 1, 3: 1, 4: 1, 5: 1, 6: 1]
        XCTAssertEqual(vm.totalScore(), 7)
    }
        
    @MainActor func testSummary_PHQ9() {
        let vm = QuizViewModel(type: "PHQ-9")
        XCTAssertEqual(vm.getSummary(score: 3), "Minimal or no depression")
        XCTAssertEqual(vm.getSummary(score: 7), "Mild depression")
        XCTAssertEqual(vm.getSummary(score: 11), "Moderate depression")
        XCTAssertEqual(vm.getSummary(score: 17), "Moderately severe depression")
        XCTAssertEqual(vm.getSummary(score: 21), "Severe depression")
    }
        
    @MainActor func testSummary_GAD7() {
        let vm = QuizViewModel(type: "GAD-7")
        XCTAssertEqual(vm.getSummary(score: 2), "Minimal anxiety")
        XCTAssertEqual(vm.getSummary(score: 6), "Mild anxiety")
        XCTAssertEqual(vm.getSummary(score: 12), "Moderate anxiety")
        XCTAssertEqual(vm.getSummary(score: 16), "Severe anxiety")
    }

    @MainActor func testSaveHistory_PHQ9() {
        let vm = QuizViewModel(type: "PHQ-9")
        vm.selectedAnswers = [0: 1, 1: 1, 2: 1, 3: 1, 4: 1, 5: 1, 6: 1, 7: 1, 8: 1]
        let history = vm.saveHistory(userID: "user123")
        
        XCTAssertEqual(history.type, "PHQ-9")
        XCTAssertEqual(history.totalScore, 9)
        XCTAssertEqual(history.userID, "user123")
        XCTAssertEqual(history.summary, "Mild depression")
    }
    
    @MainActor func testSaveHistory_GAD7() {
        let vm = QuizViewModel(type: "GAD-7")
        vm.selectedAnswers = [0: 1, 1: 1, 2: 1, 3: 1, 4: 1, 5: 1, 6: 1]
        let history = vm.saveHistory(userID: "user123")
        
        XCTAssertEqual(history.type, "GAD-7")
        XCTAssertEqual(history.totalScore, 7)
        XCTAssertEqual(history.userID, "user123")
        XCTAssertEqual(history.summary, "Mild anxiety")
    }
        
        
    func testAddHistory_ShouldCallRepository() {
        let mockRepo = MockHistoryRepository()
        let viewModel = HistoryViewModel(historyRepository: mockRepo)
        
        let history = HistoryModel(type: "PHQ-9", totalScore: 5, date: Date(), summary: "Mild depression", userID: "testUser")
        viewModel.addHistory(history)
        
        XCTAssertTrue(mockRepo.isAddCalled)
        XCTAssertEqual(mockRepo.addedHistory?.userID, "testUser")
    }
        
    func testFetchHistory_ShouldUpdatePublishedList() {
        let mockRepo = MockHistoryRepository()
        let viewModel = HistoryViewModel(historyRepository: mockRepo)
        let expectation = XCTestExpectation(description: "Fetch history updates list")
        
        viewModel.fetchHistory(userID: "testUser")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            XCTAssertEqual(viewModel.historyList.count, 1)
            XCTAssertEqual(viewModel.historyList[0].summary, "Moderate depression")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2.0)
    }

}
