//
//  ALP_Jevon_CarryTests.swift
//  ALP_Jevon_CarryTests
//
//  Created by Daffa Khoirul on 16/05/25.
//


import XCTest
import Combine
import SwiftUI
@testable import ALP_Jevon_Carry

struct User {
    var uid: String
}


//Bikin mock/dummy data
class MockSessionHistoryRepository: FirebaseSessionHistoryRepository {
    var sessionsToReturn: [BreathingSession] = []
    var fetchCalled = false
    var listenCallback: (([BreathingSession]) -> Void)?
    
    override func fetchAllSessions(for userID: String, completion: @escaping ([BreathingSession]) -> Void) {
        fetchCalled = true
        completion(sessionsToReturn)
    }
    
    override func startListening(for userID: String, onChange: @escaping ([BreathingSession]) -> Void) {
        listenCallback = onChange
        onChange(sessionsToReturn)
    }
    
    override func stopListening() {
        listenCallback = nil
    }
}

class journalRepository : FirebaseJournalRepository {
    var listUserJournals: [JournalModel] = []
    var fetchCalled = false
    
    
}
class MockAuthRepository: FirebaseAuthRepository {
    var mockUser: User?
    var mockMyUser: MyUser = MyUser()
    var signOutCalled = false
    
    func getCurrentUser() -> User? { mockUser }
    override func signOut() throws { signOutCalled = true }
}

class MockBreathingRepo: FirebaseBreathingRepository {
    var addSessionSuccess = true
    var addSessionCalled = false
    var lastSession: BreathingSession?
    override func addSession(_ session: BreathingSession, completion: @escaping (Bool) -> Void) {
        addSessionCalled = true
        lastSession = session
        completion(addSessionSuccess)
    }
}

class DummyMusicPlayerViewModel: MusicPlayerViewModel {
    override func loadSong(fileName: String, autoPlay: Bool = false) {}
    override func play() {}
    override func pause() {}
    override func stop() {}
}
class MockOpenRouterService: OpenRouterService {
    var didCallGetActivityRecommendations = false
    var stubbedResult: Result<[String], Error> = .success([])
    var lastPrompt: String?
    
    override func getActivityRecommendations(prompt: String) async throws -> [String] {
        didCallGetActivityRecommendations = true
        lastPrompt = prompt
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 second delay
        
        return try stubbedResult.get()
    }
}
//class MockOpenRouterService: OpenRouterService {
//    var didCallGetActivityRecommendations = false
//    var stubbedResult: Result<[String], Error>?
//    var lastPrompt: String?
//
//    override func getActivityRecommendations(prompt: String, completion: @escaping (Result<[String], Error>) -> Void) {
//        didCallGetActivityRecommendations = true
//        lastPrompt = prompt
//        if let result = stubbedResult {
//            completion(result)
//        }
//    }
//}

class MockFirebaseJournalRepository: FirebaseJournalRepository {
    var didAddJournal = false
    var addJournalSuccess = true
    var fetchedJournals: [JournalModel] = []
    var fetchedJournalsThisWeek: [JournalModel] = []
    var journalsInMockStorage: [JournalModel] = [] // Ini adalah "database" internal mock
    
    override func addJournal(_ journal: JournalModel, completion: @escaping (Bool) -> Void) {
        didAddJournal = true
        completion(addJournalSuccess)
    }
    
    override func fetchAllJournals(for userID: String, completion: @escaping ([JournalModel]) -> Void) {
        completion(fetchedJournals.filter { $0.userID == userID })
    }
    
    //    override func fetchJournalsThisWeek(for userID: String, completion: @escaping ([JournalModel]) -> Void) {
    //        completion(fetchedJournalsThisWeek.filter { $0.userID == userID })
    //    }
    override func fetchJournalsThisWeek(for userID: String, completion: @escaping ([JournalModel]) -> Void) {
        let calendar = Calendar.current
        let sevenDaysAgo = calendar.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        
        let journalsFiltered = journalsInMockStorage.filter { journal in // Filter dari storage internal
            return journal.userID == userID && journal.date >= sevenDaysAgo
        }
        completion(journalsFiltered.sorted { $0.date > $1.date }) // Urutkan dan kembalikan
    }
}

class MockCoreMLService: CoreMLService {
    var stubbedLabel: String = "Joy"
    override func classifyEmotion(from text: String) -> String {
        return stubbedLabel
    }
}

@MainActor
final class ALP_Jevon_CarryTests: XCTestCase {
    var authVM: AuthViewModel!
    var mockSessionRepo: MockSessionHistoryRepository!
    var sessionVM: SessionHistoryViewModel!
    var cancellables: Set<AnyCancellable> = []
    
    var breathingVM: BreathingViewModel!
    var mockBreathingRepo: MockBreathingRepo!
    var musicVM: DummyMusicPlayerViewModel!
    var journalViewModel: JournalViewModel!
    
    override func setUp() {
        super.setUp()
        let authRepo = MockAuthRepository()
        authVM = AuthViewModel(repository: authRepo)
        mockSessionRepo = MockSessionHistoryRepository()
        authVM.isSigneIn = true
        authVM.myUser = MyUser(uid: "testUser", name: "Test", email: "test@mail.com")
        sessionVM = SessionHistoryViewModel(authViewModel: authVM, sessionRepo: mockSessionRepo)
        musicVM = DummyMusicPlayerViewModel()
        mockBreathingRepo = MockBreathingRepo()
        breathingVM = BreathingViewModel(
            musicPlayerViewModel: musicVM,
            authViewModel: authVM,
            breathingRepo: mockBreathingRepo
        )
    }
    
    override func tearDown() {
        authVM = nil
        mockSessionRepo = nil
        sessionVM = nil
        cancellables.removeAll()
        breathingVM = nil
        mockBreathingRepo = nil
        musicVM = nil
        super.tearDown()
    }
    
    func testFetchAllJournalUpdatesAllJournalHistories() {
        let mockRepo = MockFirebaseJournalRepository()
        let userID = "user999"
        let journals = [
            JournalModel(title: "A", date: Date(), description: "descA", emotion: "Joy", score: 1, userID: userID),
            JournalModel(title: "B", date: Date(), description: "descB", emotion: "Sad", score: 7, userID: userID)
        ]
        mockRepo.fetchedJournals = journals
        let vm = ListJournalViewModel(journalRepository: mockRepo)
        let expectation = self.expectation(description: "FetchAllJournal")
        vm.fetchAllJournal(userID: userID)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            XCTAssertEqual(vm.allJournalHistories.count, 2)
            XCTAssertEqual(vm.allJournalHistories[0].title, "A")
            XCTAssertEqual(vm.allJournalHistories[1].title, "B")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }
    
    func testFetchJournalThisWeekUpdatesAllJournalThisWeek() {
        let mockRepo = MockFirebaseJournalRepository()
        let userID = "user88"
        
        let journalToday = JournalModel(title: "A", date: Date(), description: "descA", emotion: "Joy", score: 1, userID: userID)
        // Change journalFuture to be older than 7 days ago, so it's excluded
        let journalOld = JournalModel(title: "B", date: Date().addingTimeInterval(-8 * 24 * 60 * 60), description: "descA", emotion: "Joy", score: 1, userID: userID)
        
        // Provide both journals to the internal mock "storage."
        mockRepo.journalsInMockStorage = [journalToday, journalOld]
        
        let vm = ListJournalViewModel(journalRepository: mockRepo)
        let expectation = self.expectation(description: "FetchJournalThisWeek")
        
        vm.fetchJournalThisWeek(userID: userID)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            XCTAssertEqual(vm.allJournalThisWeek.count, 1)
            XCTAssertEqual(vm.allJournalThisWeek[0].title, "A")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }
    func testScoreForEmotion() {
        let vm = JournalViewModel()
        XCTAssertEqual(vm.scoreForEmotion("anger"), 10)
        XCTAssertEqual(vm.scoreForEmotion("fear"), 9)
        XCTAssertEqual(vm.scoreForEmotion("disgust"), 8)
        XCTAssertEqual(vm.scoreForEmotion("sadness"), 7)
        XCTAssertEqual(vm.scoreForEmotion("surprise"), 6)
        XCTAssertEqual(vm.scoreForEmotion("anticipation"), 5)
        XCTAssertEqual(vm.scoreForEmotion("trust"), 3)
        XCTAssertEqual(vm.scoreForEmotion("joy"), 1)
        XCTAssertEqual(vm.scoreForEmotion("unknown"), 5)
    }
    
    //        func testGetRecommendationsSuccess() {
    //            let mockOpenRouter = MockOpenRouterService()
    //            mockOpenRouter.stubbedResult = .success(["A", "B", "C", "D", "E"])
    //            let vm = JournalViewModel(
    //                journalRepository: MockFirebaseJournalRepository(),
    //                openRouterService: mockOpenRouter,
    //                coreMLService: MockCoreMLService()
    //            )
    //            vm.result = JournalModel(title: "test", date: Date(), description: "desc", emotion: "Joy", score: 1, userID: "userX")
    //            let expectation = self.expectation(description: "GetRecommendationsSuccess")
    //            vm.getRecommendations()
    //            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
    //                XCTAssertEqual(vm.recommendations, ["A", "B", "C", "D", "E"])
    //                XCTAssertNil(vm.errorMessage)
    //                XCTAssertTrue(mockOpenRouter.didCallGetActivityRecommendations)
    //                expectation.fulfill()
    //            }
    //            wait(for: [expectation], timeout: 1)
    //        }
    //
    //        func testGetRecommendationsFailure() {
    //            let mockOpenRouter = MockOpenRouterService()
    //            let expectedError = NSError(domain: "", code: 999, userInfo: [NSLocalizedDescriptionKey: "Failed"])
    //            mockOpenRouter.stubbedResult = .failure(expectedError)
    //            let vm = JournalViewModel(
    //                journalRepository: MockFirebaseJournalRepository(),
    //                openRouterService: mockOpenRouter,
    //                coreMLService: MockCoreMLService()
    //            )
    //            vm.result = JournalModel(title: "test", date: Date(), description: "desc", emotion: "Joy", score: 1, userID: "userX")
    //            let expectation = self.expectation(description: "GetRecommendationsFailure")
    //            vm.getRecommendations()
    //            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
    //                XCTAssertEqual(vm.errorMessage, "Failed")
    //                XCTAssertTrue(vm.recommendations.isEmpty)
    //                XCTAssertTrue(mockOpenRouter.didCallGetActivityRecommendations)
    //                expectation.fulfill()
    //            }
    //            wait(for: [expectation], timeout: 1)
    //        }
    //
    func testGetRecommendationsSuccess() async throws {
        // Arrange
        let mockOpenRouter = MockOpenRouterService()
        mockOpenRouter.stubbedResult = .success(["A", "B", "C", "D", "E"])
        
        let vm = JournalViewModel(
            journalRepository: MockFirebaseJournalRepository(),
            openRouterService: mockOpenRouter,
            coreMLService: MockCoreMLService()
        )
        
        vm.result = JournalModel(
            title: "test",
            date: Date(),
            description: "desc",
            emotion: "Joy",
            score: 1,
            userID: "userX"
        )
        
        let expectation = XCTestExpectation(description: "Recommendations should be set after async update")
        vm.$isLoading
            .dropFirst()
            .sink { isLoading in
                if !isLoading {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        vm.getRecommendations()
        await fulfillment(of: [expectation], timeout: 2.0)
        
        // Assert
        XCTAssertEqual(vm.recommendations, ["A", "B", "C", "D", "E"])
        XCTAssertNil(vm.errorMessage)
        XCTAssertTrue(mockOpenRouter.didCallGetActivityRecommendations)
        XCTAssertEqual(mockOpenRouter.lastPrompt, "Joy")
        XCTAssertFalse(vm.isLoading) // Should be false after completion
    }
    
    func testGetRecommendationsFailure() async throws {
        // Arrange
        let mockOpenRouter = MockOpenRouterService()
        let expectedError = NSError(domain: "Test", code: 999, userInfo: [NSLocalizedDescriptionKey: "Failed"])
        mockOpenRouter.stubbedResult = .failure(expectedError)
        
        let vm = JournalViewModel(
            journalRepository: MockFirebaseJournalRepository(),
            openRouterService: mockOpenRouter,
            coreMLService: MockCoreMLService()
        )
        
        vm.result = JournalModel(
            title: "test",
            date: Date(),
            description: "desc",
            emotion: "Joy",
            score: 1,
            userID: "userX"
        )
        
        let expectation = XCTestExpectation(description: "Error message should be set after async update")
        
        vm.$isLoading
            .dropFirst()
            .sink { isLoading in
                if !isLoading {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // Act
        vm.getRecommendations()
        
        // Wait for the expectation to be fulfilled
        await fulfillment(of: [expectation], timeout: 2.0) // Provide a reasonable timeout
        
        // Assert
        XCTAssertEqual(vm.errorMessage, "Failed")
        XCTAssertTrue(vm.recommendations.isEmpty)
        XCTAssertTrue(mockOpenRouter.didCallGetActivityRecommendations)
        XCTAssertEqual(mockOpenRouter.lastPrompt, "Joy")
        XCTAssertFalse(vm.isLoading) // Should be false after completion
    }
    
    func testAnalyzeEmotionSetsResultAndEmoticonAndAddsJournal() {
        let mockRepo = MockFirebaseJournalRepository()
        let mockOpenRouter = MockOpenRouterService()
        let mockCoreML = MockCoreMLService()
        mockCoreML.stubbedLabel = "joy"
        let vm = JournalViewModel(
            journalRepository: mockRepo,
            openRouterService: mockOpenRouter,
            coreMLService: mockCoreML
        )
        vm.userInput = "I am happy"
        let expectation = self.expectation(description: "AnalyzeEmotion")
        vm.analyzeEmotion(userID: "user42")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            XCTAssertEqual(vm.result.emotion.lowercased(), "joy")
            XCTAssertEqual(vm.emoticonSymbol, "😊")
            XCTAssertTrue(mockRepo.didAddJournal)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 3)
    }
    func testFetchSessionHistory_EmptyState() {
        mockSessionRepo.sessionsToReturn = []
        sessionVM.fetchSessionHistory()
        XCTAssertTrue(sessionVM.isEmpty)
        XCTAssertTrue(sessionVM.groupedSessions.isEmpty)
    }
    
    func testFetchSessionHistory_WithSessions() {
        let now = Date()
        let session = BreathingSession(userID: "testUser", sessionDate: now, duration: 60)
        mockSessionRepo.sessionsToReturn = [session]
        sessionVM.fetchSessionHistory()
        XCTAssertFalse(sessionVM.isEmpty)
        XCTAssertEqual(sessionVM.groupedSessions.count, 1)
        XCTAssertEqual(sessionVM.groupedSessions.first?.sessions.count, 1)
        XCTAssertEqual(sessionVM.groupedSessions.first?.sessions.first?.userID, "testUser")
    }
    
    func testGroupSessionsByDate_SortsAndGroups() {
        let today = Date()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
        let session1 = BreathingSession(userID: "testUser", sessionDate: today, duration: 30)
        let session2 = BreathingSession(userID: "testUser", sessionDate: yesterday, duration: 40)
        let session3 = BreathingSession(userID: "testUser", sessionDate: today.addingTimeInterval(-120), duration: 50)
        let grouped = sessionVM.groupSessionsByDate(sessions: [session1, session2, session3])
        XCTAssertEqual(grouped.count, 2)
        XCTAssertTrue(grouped.first!.sessions.contains(where: { Calendar.current.isDate($0.sessionDate, inSameDayAs: today) }))
        XCTAssertTrue(grouped.last!.sessions.contains(where: { Calendar.current.isDate($0.sessionDate, inSameDayAs: yesterday) }))
    }
    
    func testFormatSectionDateTitle() {
        let today = Date()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
        let lastWeek = Calendar.current.date(byAdding: .day, value: -4, to: today)!
        let resultToday = sessionVM.formatSectionDateTitle(today)
        let resultYesterday = sessionVM.formatSectionDateTitle(yesterday)
        XCTAssertTrue(resultToday == "Today")
        XCTAssertTrue(resultYesterday == "Yesterday")
        let resultDayOfWeek = sessionVM.formatSectionDateTitle(lastWeek)
        XCTAssertFalse(resultDayOfWeek.isEmpty)
    }
    
    func testFormatSessionDuration() {
        XCTAssertEqual(sessionVM.formatSessionDuration(65), "1m 5s")
        XCTAssertEqual(sessionVM.formatSessionDuration(120), "2m")
        XCTAssertEqual(sessionVM.formatSessionDuration(40), "40s")
    }
    
    // MARK: - BreathingViewModel Tests
    
    func testStartSession_UpdatesStateAndInstruction() {
        breathingVM.selectedSong = "No Music"
        breathingVM.toggleSession()
        XCTAssertTrue(breathingVM.isSessionActive)
        XCTAssertEqual(breathingVM.instructionText, "Find your center and breathe deeply...")
        XCTAssertTrue(breathingVM.pulseEffect)
    }
    
    func testStartSession_WhenNotSignedIn() {
        authVM.isSigneIn = false
        authVM.myUser.uid = ""
        breathingVM.toggleSession()
        XCTAssertFalse(breathingVM.isSessionActive)
        XCTAssertEqual(breathingVM.instructionText, "Please sign in to start your mindful journey")
    }
    
    func testSongSelectionChanged_WithMusic() {
        breathingVM.songSelectionChanged(newSong: "song1")
        XCTAssertEqual(breathingVM.selectedSong, "song1")
        XCTAssertEqual(breathingVM.instructionText, "Ready to breathe with Song1")
    }
    
    func testSongSelectionChanged_NoMusic() {
        breathingVM.songSelectionChanged(newSong: "No Music")
        XCTAssertEqual(breathingVM.selectedSong, "No Music")
        XCTAssertEqual(breathingVM.instructionText, "Ready for a peaceful silent session")
    }
    
    func testStopSession_ShortSession_WontSave() {
        breathingVM.selectedSong = "No Music"
        breathingVM.toggleSession()
        breathingVM.sessionTimeElapsed = 2
        breathingVM.toggleSession() // Stop
        XCTAssertFalse(breathingVM.isSessionActive)
        XCTAssertFalse(mockBreathingRepo.addSessionCalled)
        XCTAssertNil(breathingVM.saveError)
    }
    
    func testStopSession_SavesIfLongEnough() {
        breathingVM.selectedSong = "No Music"
        breathingVM.toggleSession()
        breathingVM.sessionTimeElapsed = 10
        breathingVM.toggleSession() // Stop
        XCTAssertTrue(mockBreathingRepo.addSessionCalled)
        XCTAssertNil(breathingVM.saveError)
    }
    
    func testStopSession_SavesIfLongEnough_Fail() {
        mockBreathingRepo.addSessionSuccess = false
        breathingVM.selectedSong = "No Music"
        breathingVM.toggleSession()
        breathingVM.sessionTimeElapsed = 10
        breathingVM.toggleSession()
        XCTAssertTrue(mockBreathingRepo.addSessionCalled)
        XCTAssertEqual(breathingVM.saveError, "Failed to save session.")
    }
    
    func testStopSession_NoUser_SetsError() {
        authVM.isSigneIn = false
        authVM.myUser.uid = ""
        authVM.user = nil
        // Simulate an active session
        breathingVM.isSessionActive = true
        breathingVM.sessionStartTime = Date()
        breathingVM.sessionTimeElapsed = 10
        breathingVM.stopSession()
        XCTAssertEqual(breathingVM.saveError, "Unable to save session: User not identified. Please sign in again.")
        XCTAssertFalse(mockBreathingRepo.addSessionCalled)
    }
    
    func testRetrySaveSession_Success() {
        breathingVM.selectedSong = "No Music"
        breathingVM.toggleSession()
        breathingVM.sessionTimeElapsed = 10
        breathingVM.toggleSession() // saves once
        mockBreathingRepo.addSessionSuccess = true
        breathingVM.retrySaveSession()
        XCTAssertTrue(mockBreathingRepo.addSessionCalled)
        XCTAssertNil(breathingVM.saveError)
    }
    
    func testRetrySaveSession_MissingData_SetsError() {
        breathingVM.sessionTimeElapsed = 10
        breathingVM.retrySaveSession()
        XCTAssertEqual(breathingVM.saveError, "Cannot retry: Missing data.")
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
    
    //Buat test Quiz
    func testPHQ9_Questions_is_9() {
        let vm = QuizViewModel(type: "PHQ-9")
        XCTAssertEqual(vm.questions.count, 9)
    }
    
    func testGAD7_Questions_is_7() {
        let vm = QuizViewModel(type: "GAD-7")
        XCTAssertEqual(vm.questions.count, 7)
    }
    
    func testTotalScoreCalculation_PHQ9() {
        let vm = QuizViewModel(type: "PHQ-9")
        vm.selectedAnswers = [0: 1, 1: 1, 2: 1, 3: 1, 4: 1, 5: 1, 6: 1, 7: 1, 8: 1]
        XCTAssertEqual(vm.totalScore(), 9)
    }
    
    func testTotalScoreCalculation_GAD7() {
        let vm = QuizViewModel(type: "GAD-7")
        vm.selectedAnswers = [0: 1, 1: 1, 2: 1, 3: 1, 4: 1, 5: 1, 6: 1]
        XCTAssertEqual(vm.totalScore(), 7)
    }
    
    func testSummary_PHQ9() {
        let vm = QuizViewModel(type: "PHQ-9")
        XCTAssertEqual(vm.getSummary(score: 3), "Minimal or no depression")
        XCTAssertEqual(vm.getSummary(score: 7), "Mild depression")
        XCTAssertEqual(vm.getSummary(score: 11), "Moderate depression")
        XCTAssertEqual(vm.getSummary(score: 17), "Moderately severe depression")
        XCTAssertEqual(vm.getSummary(score: 21), "Severe depression")
    }
    
    func testSummary_GAD7() {
        let vm = QuizViewModel(type: "GAD-7")
        XCTAssertEqual(vm.getSummary(score: 2), "Minimal anxiety")
        XCTAssertEqual(vm.getSummary(score: 6), "Mild anxiety")
        XCTAssertEqual(vm.getSummary(score: 12), "Moderate anxiety")
        XCTAssertEqual(vm.getSummary(score: 16), "Severe anxiety")
    }
    
    
    //Buat test History
    func testSaveHistory_PHQ9() {
        let vm = QuizViewModel(type: "PHQ-9")
        vm.selectedAnswers = [0: 1, 1: 1, 2: 1, 3: 1, 4: 1, 5: 1, 6: 1, 7: 1, 8: 1]
        let history = vm.saveHistory(userID: "user123")
        
        XCTAssertEqual(history.type, "PHQ-9")
        XCTAssertEqual(history.totalScore, 9)
        XCTAssertEqual(history.userID, "user123")
        XCTAssertEqual(history.summary, "Mild depression")
    }
    
    func testSaveHistory_GAD7() {
        let vm = QuizViewModel(type: "GAD-7")
        vm.selectedAnswers = [0: 1, 1: 1, 2: 1, 3: 1, 4: 1, 5: 1, 6: 1]
        let history = vm.saveHistory(userID: "user123")
        
        XCTAssertEqual(history.type, "GAD-7")
        XCTAssertEqual(history.totalScore, 7)
        XCTAssertEqual(history.userID, "user123")
        XCTAssertEqual(history.summary, "Mild anxiety")
    }
    
    
    //Test save History + fetch History
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

