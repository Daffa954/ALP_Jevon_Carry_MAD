//
//  BreathingSessionView.swift
//  ALP_Jevon_Carry
//
//  Created by student on 27/05/25.
//

// BreathingSessionView.swift (Create this new file)
// Make sure to import SwiftUI
// BreathingSessionView.swift
// Make sure to import SwiftUI
// BreathingSessionView.swift
import SwiftUI

struct BreathingSessionView: View {
    @StateObject var breathingViewModel: BreathingViewModel
    @EnvironmentObject var authViewModel: AuthViewModel

    @State private var isDraggingSlider = false
    @State private var showingSongSelectionSheet = false

    private let viewBackgroundColor = Color.white
    private let primaryTextColor = AppColors.lightPrimaryText
    private let secondaryTextColor = AppColors.lightSecondaryText
    private let buttonTextColor = AppColors.primaryText // For text on colored buttons

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                HStack {
                    Text("Music:")
                        .font(.headline)
                        .foregroundColor(primaryTextColor)
                    
                    Button(action: {
                        showingSongSelectionSheet = true
                    }) {
                        Text(breathingViewModel.selectedSong == "No Music" ? "Choose Song" : breathingViewModel.selectedSong)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(AppColors.neutralColor.opacity(0.15))
                            .foregroundColor(AppColors.accent)
                            .cornerRadius(8)
                    }
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top)

                Spacer()

                ZStack {
                    Circle()
                        .fill(breathingViewModel.circleColor)
                        .frame(width: min(UIScreen.main.bounds.width, UIScreen.main.bounds.height) * 0.6,
                               height: min(UIScreen.main.bounds.width, UIScreen.main.bounds.height) * 0.6)
                        .scaleEffect(breathingViewModel.circleScale)
                    
                    Text(breathingViewModel.instructionText)
                        .font(.title2)
                        .fontWeight(.medium)
                        .foregroundColor(primaryTextColor.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding()
                }
                .frame(height: min(UIScreen.main.bounds.width, UIScreen.main.bounds.height) * 0.7)

                Spacer()

                Text("Session Time: \(formatTime(breathingViewModel.sessionTimeElapsed))")
                    .font(.headline)
                    .foregroundColor(secondaryTextColor)

                if breathingViewModel.selectedSong != "No Music", breathingViewModel.musicPlayerViewModel.currentSongFileName != nil {
                    MusicControlsView(
                        musicPlayerViewModel: breathingViewModel.musicPlayerViewModel,
                        isDraggingSlider: $isDraggingSlider,
                        textColor: secondaryTextColor,
                        accentColor: AppColors.neutralColor
                    )
                    .padding(.horizontal)
                }

                Button(action: {
                    breathingViewModel.toggleSession()
                }) {
                    Text(breathingViewModel.isSessionActive ? "Stop Session" : "Start Session")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(buttonTextColor)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(breathingViewModel.isSessionActive ? AppColors.exhaleColor : AppColors.inhaleColor)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
            .padding(.top, 1)
            .background(viewBackgroundColor.edgesIgnoringSafeArea(.all))
            .navigationTitle("Breathing Session")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                if authViewModel.user == nil && authViewModel.myUser.uid.isEmpty { // Check if really not logged in
                    breathingViewModel.instructionText = "Please sign in to use this feature."
                }
            }
            .sheet(isPresented: $showingSongSelectionSheet) {
                SongSelectionSheet(
                    availableSongs: breathingViewModel.availableSongs,
                    selectedSong: $breathingViewModel.selectedSong,
                    onDismiss: { songName in
                        breathingViewModel.songSelectionChanged(newSong: songName)
                    },
                    primaryTextColor: primaryTextColor,
                    accentColor: AppColors.accent
                )
            }
        }
        .accentColor(AppColors.accent)
        .navigationViewStyle(StackNavigationViewStyle()) // Good for iPad and iPhone
    }

    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

struct SongSelectionSheet: View {
    let availableSongs: [String]
    @Binding var selectedSong: String
    var onDismiss: (String) -> Void
    @Environment(\.dismiss) var dismiss

    let primaryTextColor: Color
    let accentColor: Color

    var body: some View {
        NavigationView {
            List {
                ForEach(availableSongs, id: \.self) { song in
                    Button(action: {
                        selectedSong = song
                        onDismiss(song)
                        dismiss()
                    }) {
                        HStack {
                            Text(song)
                                .foregroundColor(primaryTextColor)
                            Spacer()
                            if song == selectedSong {
                                Image(systemName: "checkmark")
                                    .foregroundColor(accentColor)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Choose a Song")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) { // Or .confirmationAction for iOS 16+
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(accentColor)
                }
            }
        }
        .accentColor(accentColor)
    }
}

struct MusicControlsView: View {
    @ObservedObject var musicPlayerViewModel: MusicPlayerViewModel
    @Binding var isDraggingSlider: Bool
    var textColor: Color
    var accentColor: Color

    var body: some View {
        VStack(spacing: 10) {
            Text(musicPlayerViewModel.currentSongFileName ?? "No song loaded")
                .font(.caption)
                .foregroundColor(textColor)

            Slider(
                value: Binding(
                    get: { musicPlayerViewModel.currentTime },
                    set: { newValue in
                        if isDraggingSlider {
                             musicPlayerViewModel.currentTime = newValue
                        }
                    }
                ),
                in: 0...(musicPlayerViewModel.duration > 0 ? musicPlayerViewModel.duration : 1),
                onEditingChanged: { editing in
                    isDraggingSlider = editing
                    if !editing {
                        musicPlayerViewModel.seek(to: musicPlayerViewModel.currentTime)
                    }
                }
            )
            .accentColor(accentColor)

            HStack {
                Text(musicPlayerViewModel.formatTime(musicPlayerViewModel.currentTime))
                Spacer()
                Text(musicPlayerViewModel.formatTime(musicPlayerViewModel.duration))
            }
            .font(.caption2)
            .foregroundColor(textColor)

            Button(action: {
                musicPlayerViewModel.playPause()
            }) {
                Image(systemName: musicPlayerViewModel.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50, height: 50)
                    .foregroundColor(accentColor)
            }
        }
    }
}

struct BreathingSessionView_Previews: PreviewProvider {
    static var previews: some View {
        let previewAuthVM = AuthViewModel()
        previewAuthVM.isSigneIn = true
        previewAuthVM.myUser = MyUser(
            uid: "previewUser123",
            name: "Preview User",
            email: "preview@example.com"
        )
            
        let musicPlayerVM = MusicPlayerViewModel()
        let breathingVM = BreathingViewModel(musicPlayerViewModel: musicPlayerVM, authViewModel: previewAuthVM)
        
        // To see music controls in preview:
        // breathingVM.selectedSong = "song1" // Assuming "song1.mp3" exists
        // musicPlayerVM.loadSong(fileName: "song1")


        return BreathingSessionView(breathingViewModel: breathingVM)
            .environmentObject(previewAuthVM)
    }
}
