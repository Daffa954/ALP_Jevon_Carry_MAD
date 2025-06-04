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
    var stubbedResult: Result<[String], Error>?
    var lastPrompt: String?

    override func getActivityRecommendations(prompt: String, completion: @escaping (Result<[String], Error>) -> Void) {
        didCallGetActivityRecommendations = true
        lastPrompt = prompt
        if let result = stubbedResult {
            completion(result)
        }
    }
}

class MockFirebaseJournalRepository: FirebaseJournalRepository {
    var didAddJournal = false
    var addJournalSuccess = true
    var fetchedJournals: [JournalModel] = []
    var fetchedJournalsThisWeek: [JournalModel] = []

    override func addJournal(_ journal: JournalModel, completion: @escaping (Bool) -> Void) {
        didAddJournal = true
        completion(addJournalSuccess)
    }

    override func fetchAllJournals(for userID: String, completion: @escaping ([JournalModel]) -> Void) {
        completion(fetchedJournals.filter { $0.userID == userID })
    }

    override func fetchJournalsThisWeek(for userID: String, completion: @escaping ([JournalModel]) -> Void) {
        completion(fetchedJournalsThisWeek.filter { $0.userID == userID })
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
        // MARK: - SessionHistoryViewModel Tests
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
           let journals = [
               JournalModel(title: "A", date: Date(), description: "descA", emotion: "Joy", score: 1, userID: userID)
           ]
           mockRepo.fetchedJournalsThisWeek = journals
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

        func testGetRecommendationsSuccess() {
            let mockOpenRouter = MockOpenRouterService()
            mockOpenRouter.stubbedResult = .success(["A", "B", "C", "D", "E"])
            let vm = JournalViewModel(
                journalRepository: MockFirebaseJournalRepository(),
                openRouterService: mockOpenRouter,
                coreMLService: MockCoreMLService()
            )
            vm.result = JournalModel(title: "test", date: Date(), description: "desc", emotion: "Joy", score: 1, userID: "userX")
            let expectation = self.expectation(description: "GetRecommendationsSuccess")
            vm.getRecommendations()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                XCTAssertEqual(vm.recommendations, ["A", "B", "C", "D", "E"])
                XCTAssertNil(vm.errorMessage)
                XCTAssertTrue(mockOpenRouter.didCallGetActivityRecommendations)
                expectation.fulfill()
            }
            wait(for: [expectation], timeout: 1)
        }
        
        func testGetRecommendationsFailure() {
            let mockOpenRouter = MockOpenRouterService()
            let expectedError = NSError(domain: "", code: 999, userInfo: [NSLocalizedDescriptionKey: "Failed"])
            mockOpenRouter.stubbedResult = .failure(expectedError)
            let vm = JournalViewModel(
                journalRepository: MockFirebaseJournalRepository(),
                openRouterService: mockOpenRouter,
                coreMLService: MockCoreMLService()
            )
            vm.result = JournalModel(title: "test", date: Date(), description: "desc", emotion: "Joy", score: 1, userID: "userX")
            let expectation = self.expectation(description: "GetRecommendationsFailure")
            vm.getRecommendations()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                XCTAssertEqual(vm.errorMessage, "Failed")
                XCTAssertTrue(vm.recommendations.isEmpty)
                XCTAssertTrue(mockOpenRouter.didCallGetActivityRecommendations)
                expectation.fulfill()
            }
            wait(for: [expectation], timeout: 1)
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
}

