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
//
//  BreathingSessionView.swift
//  ALP_Jevon_Carry
//
//  Created by student on 27/05/25.
//
//
//  BreathingSessionView.swift
//  ALP_Jevon_Carry
//
//  Created by student on 27/05/25.
//

import SwiftUI

struct BreathingSessionView: View {
    @StateObject var breathingViewModel: BreathingViewModel
    @EnvironmentObject var authViewModel: AuthViewModel

    @State private var isDraggingSlider = false
    @State private var showingSongSelectionSheet = false
    @State private var backgroundGradientOffset: CGFloat = 0

    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ZStack {
                    // Static elegant background
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.white,
                            AppColors.neutralColor.opacity(0.1),
                            Color.white
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .ignoresSafeArea()
                    
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 0) {
                            // Header Section
                            headerSection
                                .padding(.top, 20)
                            
                            // Main Breathing Circle
                            breathingCircleSection(geometry: geometry)
                                .padding(.vertical, 40)
                            
                            // Session Info
                            sessionInfoSection
                                .padding(.horizontal, 20)
                            
                            // Music Controls (if applicable)
                            if breathingViewModel.selectedSong != "No Music",
                               breathingViewModel.musicPlayerViewModel.currentSongFileName != nil {
                                musicControlsSection
                                    .padding(.horizontal, 20)
                                    .padding(.top, 20)
                            }
                            
                            // Control Button
                            controlButtonSection
                                .padding(.horizontal, 20)
                                .padding(.top, 30)
                                .padding(.bottom, 40)
                        }
                    }
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)
            .onAppear {
                if authViewModel.user == nil && authViewModel.myUser.uid.isEmpty {
                    breathingViewModel.instructionText = "Please sign in to begin your mindful journey"
                }
            }
            .sheet(isPresented: $showingSongSelectionSheet) {
                SongSelectionSheet(
                    availableSongs: breathingViewModel.availableSongs,
                    selectedSong: $breathingViewModel.selectedSong,
                    onDismiss: { songName in
                        breathingViewModel.songSelectionChanged(newSong: songName)
                    }
                )
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 16) {
            Text("Mindful Breathing")
                .font(.system(size: 32, weight: .thin, design: .rounded))
                .foregroundColor(AppColors.lightPrimaryText)
                .multilineTextAlignment(.center)
            
            // Music Selection Card
            Button(action: {
                showingSongSelectionSheet = true
            }) {
                HStack(spacing: 12) {
                    Image(systemName: breathingViewModel.selectedSong == "No Music" ? "music.note.list" : "music.note")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(AppColors.neutralColor)
                        .frame(width: 24, height: 24)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Background Music")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(AppColors.lightSecondaryText)
                        
                        Text(breathingViewModel.selectedSong == "No Music" ? "Silent Session" : breathingViewModel.selectedSong.capitalized)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(AppColors.lightPrimaryText)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(AppColors.lightSecondaryText)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white)
                        .shadow(color: AppColors.neutralColor.opacity(0.1), radius: 8, x: 0, y: 2)
                )
            }
            .padding(.horizontal, 20)
        }
    }
    
    // MARK: - Breathing Circle Section
    private func breathingCircleSection(geometry: GeometryProxy) -> some View {
        let circleSize = min(geometry.size.width, geometry.size.height) * 0.65
        
        return VStack(spacing: 30) {
            ZStack {
                // Outer glow effect
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [
                                breathingViewModel.circleColor.opacity(0.3),
                                breathingViewModel.circleColor.opacity(0.1),
                                Color.clear
                            ]),
                            center: .center,
                            startRadius: circleSize * 0.3,
                            endRadius: circleSize * 0.6
                        )
                    )
                    .frame(width: circleSize * 1.2, height: circleSize * 1.2)
                    .scaleEffect(breathingViewModel.circleScale * 0.8)
                    .opacity(breathingViewModel.isSessionActive ? 0.6 : 0.3)
                
                // Main breathing circle
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [
                                breathingViewModel.circleColor.opacity(0.8),
                                breathingViewModel.circleColor.opacity(0.6),
                                breathingViewModel.circleColor.opacity(0.4)
                            ]),
                            center: .center,
                            startRadius: 0,
                            endRadius: circleSize * 0.5
                        )
                    )
                    .frame(width: circleSize, height: circleSize)
                    .scaleEffect(breathingViewModel.circleScale)
                    .opacity(breathingViewModel.circleOpacity)
                
                // Inner circle with breathing phase indicator
                Circle()
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.white.opacity(0.8),
                                Color.white.opacity(0.4)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 3
                    )
                    .frame(width: circleSize * 0.7, height: circleSize * 0.7)
                    .scaleEffect(breathingViewModel.circleScale * 0.9)
                
                // Breathing instruction text
                VStack(spacing: 8) {
                    if breathingViewModel.isSessionActive {
                        Image(systemName: breathingViewModel.breathingPhase == .inhale ? "arrow.up.circle.fill" :
                                          breathingViewModel.breathingPhase == .exhale ? "arrow.down.circle.fill" : "pause.circle.fill")
                            .font(.system(size: 24, weight: .light))
                            .foregroundColor(AppColors.lightPrimaryText)
                    }
                    
                    Text(breathingViewModel.instructionText)
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(AppColors.lightPrimaryText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                        .shadow(color: .white, radius: 2, x: 0, y: 0)
                }
            }
        }
    }
    
    // MARK: - Session Info Section
    private var sessionInfoSection: some View {
        VStack(spacing: 16) {
            // Session timer
            HStack {
                Image(systemName: "clock")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(AppColors.neutralColor)
                
                Text("Session Time")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(AppColors.lightSecondaryText)
                
                Spacer()
                
                Text(formatTime(breathingViewModel.sessionTimeElapsed))
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(AppColors.lightPrimaryText)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
                    .shadow(color: AppColors.neutralColor.opacity(0.08), radius: 6, x: 0, y: 2)
            )
        }
    }
    
    // MARK: - Music Controls Section
    private var musicControlsSection: some View {
        VStack(spacing: 16) {
            Text("Now Playing")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(AppColors.lightSecondaryText)
            
            MusicControlsView(
                musicPlayerViewModel: breathingViewModel.musicPlayerViewModel,
                isDraggingSlider: $isDraggingSlider
            )
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: AppColors.neutralColor.opacity(0.08), radius: 8, x: 0, y: 3)
        )
    }
    
    // MARK: - Control Button Section
    private var controlButtonSection: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.2)) {
                breathingViewModel.toggleSession()
            }
        }) {
            HStack(spacing: 12) {
                Image(systemName: breathingViewModel.isSessionActive ? "stop.fill" : "play.fill")
                    .font(.system(size: 20, weight: .semibold))
                
                Text(breathingViewModel.isSessionActive ? "End Session" : "Begin Session")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
            }
            .foregroundColor(.white)
            .padding(.vertical, 18)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                breathingViewModel.isSessionActive ? AppColors.exhaleColor : AppColors.inhaleColor,
                                breathingViewModel.isSessionActive ? AppColors.exhaleColor.opacity(0.8) : AppColors.inhaleColor.opacity(0.8)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: (breathingViewModel.isSessionActive ? AppColors.exhaleColor : AppColors.inhaleColor).opacity(0.3),
                           radius: 12, x: 0, y: 6)
            )
        }
        .scaleEffect(breathingViewModel.isSessionActive ? 1.0 : 1.02)
        .animation(.easeInOut(duration: 0.15), value: breathingViewModel.isSessionActive)
    }

    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

// MARK: - Song Selection Sheet
struct SongSelectionSheet: View {
    let availableSongs: [String]
    @Binding var selectedSong: String
    var onDismiss: (String) -> Void
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 8) {
                    Text("Choose Your Sound")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.lightPrimaryText)
                    
                    Text("Select background music for your session")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(AppColors.lightSecondaryText)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 16)
                
                Divider()
                    .padding(.horizontal, 20)
                
                // Song List
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(availableSongs, id: \.self) { song in
                            Button(action: {
                                selectedSong = song
                                onDismiss(song)
                                dismiss()
                            }) {
                                HStack(spacing: 16) {
                                    Image(systemName: song == "No Music" ? "speaker.slash.fill" : "music.note")
                                        .font(.system(size: 18, weight: .medium))
                                        .foregroundColor(song == selectedSong ? AppColors.neutralColor : AppColors.lightSecondaryText)
                                        .frame(width: 24, height: 24)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(song == "No Music" ? "Silent Session" : song.capitalized)
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(AppColors.lightPrimaryText)
                                        
                                        Text(song == "No Music" ? "Practice in peaceful silence" : "Relaxing background music")
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(AppColors.lightSecondaryText)
                                    }
                                    
                                    Spacer()
                                    
                                    if song == selectedSong {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.system(size: 20, weight: .semibold))
                                            .foregroundColor(AppColors.neutralColor)
                                    }
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 16)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(song == selectedSong ? AppColors.neutralColor.opacity(0.1) : Color.clear)
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
                
                Spacer()
            }
            .background(Color.white.ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppColors.neutralColor)
                }
            }
        }
    }
}

// MARK: - Enhanced Music Controls
struct MusicControlsView: View {
    @ObservedObject var musicPlayerViewModel: MusicPlayerViewModel
    @Binding var isDraggingSlider: Bool

    var body: some View {
        VStack(spacing: 16) {
            Text(musicPlayerViewModel.currentSongFileName?.capitalized ?? "No song loaded")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(AppColors.lightPrimaryText)

            // Progress Slider
            VStack(spacing: 8) {
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
                .accentColor(AppColors.neutralColor)
                .background(
                    RoundedRectangle(cornerRadius: 2)
                        .fill(AppColors.neutralColor.opacity(0.2))
                        .frame(height: 4)
                )

                HStack {
                    Text(musicPlayerViewModel.formatTime(musicPlayerViewModel.currentTime))
                    Spacer()
                    Text(musicPlayerViewModel.formatTime(musicPlayerViewModel.duration))
                }
                .font(.system(size: 12, weight: .medium, design: .monospaced))
                .foregroundColor(AppColors.lightSecondaryText)
            }

            // Play/Pause Button
            Button(action: {
                musicPlayerViewModel.playPause()
            }) {
                Image(systemName: musicPlayerViewModel.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .font(.system(size: 44, weight: .light))
                    .foregroundColor(AppColors.neutralColor)
            }
            .scaleEffect(musicPlayerViewModel.isPlaying ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: musicPlayerViewModel.isPlaying)
        }
    }
}

// MARK: - Preview
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

        return BreathingSessionView(breathingViewModel: breathingVM)
            .environmentObject(previewAuthVM)
    }
}
