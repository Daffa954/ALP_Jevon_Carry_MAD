import Foundation
import AVFoundation
import Combine

class MusicPlayerViewModel: NSObject, ObservableObject, AVAudioPlayerDelegate {
    @Published var isPlaying = false
    @Published var currentTime: TimeInterval = 0
    @Published var duration: TimeInterval = 0
    @Published var currentSongFileName: String?

    let didSongFinishPlaying = PassthroughSubject<Void, Never>()

    var audioPlayer: AVAudioPlayer?
    var timer: Timer?

    override init() {
        super.init()
    }

    func loadSong(fileName: String, autoPlay: Bool = false) {
        if audioPlayer?.isPlaying == true {
            audioPlayer?.stop()
        }
        stopTimerAndUpdateState(isPlaying: false, resetCurrentTime: true)

        guard let url = Bundle.main.url(forResource: fileName, withExtension: "mp3") else {
            print("Audio file \(fileName).mp3 not found in bundle.")
            resetPlayerState()
            return
        }

        do {
            // Only configure audio session on iOS
            #if os(iOS)
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            #endif

            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.delegate = self
            self.duration = audioPlayer?.duration ?? 0
            self.currentSongFileName = fileName
            print("Loaded song: \(fileName), Duration: \(self.duration)")

            if autoPlay {
                self.play()
            }
        } catch {
            print("Failed to initialize audio player for \(fileName): \(error.localizedDescription)")
            resetPlayerState()
        }
    }

    func play() {
        guard let player = audioPlayer else {
            if let songName = currentSongFileName {
                loadSong(fileName: songName, autoPlay: true)
            } else {
                print("MusicPlayerViewModel: No song loaded to play.")
            }
            return
        }
        if !player.isPlaying {
            player.play()
            self.isPlaying = true
            startTimer()
        }
    }

    func pause() {
        guard let player = audioPlayer, player.isPlaying else { return }
        player.pause()
        self.isPlaying = false
        stopTimer()
    }

    func playPause() {
        guard audioPlayer != nil else {
            if let songName = currentSongFileName {
                loadSong(fileName: songName, autoPlay: true)
            } else {
                print("MusicPlayerViewModel: No song loaded to play/pause.")
            }
            return
        }
        if self.isPlaying {
            pause()
        } else {
            play()
        }
    }

    func stop() {
        audioPlayer?.stop()
        stopTimerAndUpdateState(isPlaying: false, resetCurrentTime: true)
    }

    func seek(to time: TimeInterval) {
        guard let player = audioPlayer else {
            print("MusicPlayerViewModel: Cannot seek, audioPlayer is nil.")
            return
        }
        player.currentTime = time
        self.currentTime = time
    }

    func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

 func startTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            guard let self = self, let player = self.audioPlayer, player.isPlaying else {
                self?.stopTimer()
                if self?.audioPlayer?.isPlaying == false && self?.isPlaying == true {
                    DispatchQueue.main.async { self?.isPlaying = false }
                }
                return
            }
            self.currentTime = player.currentTime
        }
    }

func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    func stopTimerAndUpdateState(isPlaying: Bool, resetCurrentTime: Bool = false) {
        self.isPlaying = isPlaying
        if !isPlaying {
            stopTimer()
        }
        if resetCurrentTime {
            self.currentTime = 0
            if !isPlaying {
                audioPlayer?.currentTime = 0
            }
        }
    }

    func resetPlayerState() {
        self.audioPlayer?.stop()
        self.audioPlayer = nil
        self.duration = 0
        self.currentTime = 0
        self.isPlaying = false
        self.currentSongFileName = nil
        stopTimer()
    }

    // MARK: - AVAudioPlayerDelegate

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        DispatchQueue.main.async {
            self.stopTimerAndUpdateState(isPlaying: false, resetCurrentTime: true)
            self.didSongFinishPlaying.send()
            print("MusicPlayerViewModel: Song finished playing. Successfully: \(flag)")
        }
    }

    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        DispatchQueue.main.async {
            print("MusicPlayerViewModel: Audio player decode error: \(error?.localizedDescription ?? "Unknown error")")
            self.stopTimerAndUpdateState(isPlaying: false, resetCurrentTime: true)
        }
    }
}

