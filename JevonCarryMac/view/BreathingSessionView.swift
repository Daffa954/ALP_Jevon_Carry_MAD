//
//  BreathingSessionView.swift
//  ALP_Jevon_Carry
//
//  Created by Daffa Khoirul on 01/06/25.
//

import SwiftUI

struct BreathingSessionView: View {
    @StateObject var breathingViewModel: BreathingViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @Binding var showingSessionHistory: Bool

    @State private var isDraggingSlider = false
    @State private var showingSongSelectionSheet = false

    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ZStack {
                    // Static elegant background
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.white,
                            Color("skyBlue").opacity(0.1),
                            Color.white
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .ignoresSafeArea()

                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 0) {
                            // Header Section
                            VStack(spacing: 16) {
                                Text("Mindful Breathing")
                                    .font(.system(size: 32, weight: .thin, design: .rounded))
                                    .foregroundColor(Color.black)
                                    .multilineTextAlignment(.center)

                                // Music Selection Card
                                Button(action: {
                                    showingSongSelectionSheet = true
                                }) {
                                    HStack(spacing: 12) {
                                        Image(systemName: breathingViewModel.selectedSong == "No Music" ? "music.note.list" : "music.note")
                                            .font(.system(size: 18, weight: .medium))
                                            .foregroundColor(Color("skyBlue"))
                                            .frame(width: 24, height: 24)

                                        VStack(alignment: .leading, spacing: 2) {
                                            Text("Background Music")
                                                .font(.system(size: 12, weight: .medium))
                                                .foregroundColor(Color.gray)

                                            Text(breathingViewModel.selectedSong == "No Music" ? "Silent Session" : breathingViewModel.selectedSong.capitalized)
                                                .font(.system(size: 16, weight: .semibold))
                                                .foregroundColor(Color.black)
                                        }
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(Color.gray)
                                    }
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(Color.white)
                                            .shadow(color: Color("skyBlue").opacity(0.1), radius: 8, x: 0, y: 2)
                                    )
                                }
                                .padding(.horizontal, 20)
                            }
                            .padding(.top, 20)

                            // Breathing Circle Section
                            VStack(spacing: 30) {
                                let circleSize = min(geometry.size.width, geometry.size.height) * 0.65
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

                                    // Breathing instruction text and phase icon
                                    VStack(spacing: 8) {
                                        if breathingViewModel.isSessionActive {
                                            Image(systemName:
                                                breathingViewModel.breathingPhase == "inhale" ? "arrow.up.circle.fill" :
                                                breathingViewModel.breathingPhase == "exhale" ? "arrow.down.circle.fill" :
                                                breathingViewModel.breathingPhase == "hold" ? "pause.circle.fill" :
                                                "pause.circle"
                                            )
                                            .font(.system(size: 24, weight: .light))
                                            .foregroundColor(Color.black)
                                        }
                                        Text(breathingViewModel.instructionText)
                                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                                            .foregroundColor(Color.black)
                                            .multilineTextAlignment(.center)
                                            .padding(.horizontal, 20)
                                            .shadow(color: .white, radius: 2, x: 0, y: 0)
                                    }
                                }
                            }
                            .padding(.vertical, 40)

                            // Session Info Section
                            VStack(spacing: 16) {
                                HStack {
                                    Image(systemName: "clock")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(Color("skyBlue"))

                                    Text("Session Time")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(Color.gray)

                                    Spacer()

                                    Text(String(format: "%02d:%02d", Int(breathingViewModel.sessionTimeElapsed) / 60, Int(breathingViewModel.sessionTimeElapsed) % 60))
                                        .font(.system(size: 18, weight: .bold, design: .rounded))
                                        .foregroundColor(Color.black)
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 16)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.white)
                                        .shadow(color: Color("skyBlue").opacity(0.08), radius: 6, x: 0, y: 2)
                                )
                            }
                            .padding(.horizontal, 20)

                            // Music Controls Section (if applicable)
                            if breathingViewModel.selectedSong != "No Music",
                               breathingViewModel.musicPlayerViewModel.currentSongFileName != nil {
                                VStack(spacing: 16) {
                                    Text("Now Playing")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(Color.gray)

                                    VStack(spacing: 16) {
                                        Text(breathingViewModel.musicPlayerViewModel.currentSongFileName?.capitalized ?? "No song loaded")
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(Color.black)

                                        VStack(spacing: 8) {
                                            Slider(
                                                value: Binding(
                                                    get: { breathingViewModel.musicPlayerViewModel.currentTime },
                                                    set: { newValue in if isDraggingSlider { breathingViewModel.musicPlayerViewModel.currentTime = newValue }}
                                                ),
                                                in: 0...(breathingViewModel.musicPlayerViewModel.duration > 0 ? breathingViewModel.musicPlayerViewModel.duration : 1),
                                                onEditingChanged: { editing in
                                                    isDraggingSlider = editing
                                                    if !editing {
                                                        breathingViewModel.musicPlayerViewModel.seek(to: breathingViewModel.musicPlayerViewModel.currentTime)
                                                    }
                                                }
                                            )
                                            .accentColor(Color("skyBlue"))
                                            .background(
                                                RoundedRectangle(cornerRadius: 2)
                                                    .fill(Color("skyBlue").opacity(0.2))
                                                    .frame(height: 4)
                                            )

                                            HStack {
                                                Text(breathingViewModel.musicPlayerViewModel.formatTime(breathingViewModel.musicPlayerViewModel.currentTime))
                                                Spacer()
                                                Text(breathingViewModel.musicPlayerViewModel.formatTime(breathingViewModel.musicPlayerViewModel.duration))
                                            }
                                            .font(.system(size: 12, weight: .medium, design: .monospaced))
                                            .foregroundColor(Color.gray)
                                        }

                                        Button(action: {
                                            breathingViewModel.musicPlayerViewModel.playPause()
                                        }) {
                                            Image(systemName: breathingViewModel.musicPlayerViewModel.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                                                .font(.system(size: 44, weight: .light))
                                                .foregroundColor(Color("skyBlue"))
                                        }
                                        .scaleEffect(breathingViewModel.musicPlayerViewModel.isPlaying ? 0.95 : 1.0)
                                        .animation(.easeInOut(duration: 0.1), value: breathingViewModel.musicPlayerViewModel.isPlaying)
                                    }
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 20)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color.white)
                                        .shadow(color: Color("skyBlue").opacity(0.08), radius: 8, x: 0, y: 3)
                                )
                                .padding(.horizontal, 20)
                                .padding(.top, 20)
                            }

                            // Control Button Section
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
                                                    breathingViewModel.isSessionActive ? Color("coralOrange") : Color("color1"),
                                                    breathingViewModel.isSessionActive ? Color("coralOrange").opacity(0.8) : Color("color1").opacity(0.8)
                                                ]),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .shadow(color: (breathingViewModel.isSessionActive ? Color("coralOrange") : Color("color1")).opacity(0.3),
                                                radius: 12, x: 0, y: 6)
                                )
                            }
                            .scaleEffect(breathingViewModel.isSessionActive ? 1.0 : 1.02)
                            .animation(.easeInOut(duration: 0.15), value: breathingViewModel.isSessionActive)
                            .padding(.horizontal, 20)
                            .padding(.top, 30)

                            // History Button Section
                            Button(action: {
                                showingSessionHistory = true
                            }) {
                                HStack(spacing: 12) {
                                    Image(systemName: "clock.badge.checkmark")
                                        .font(.system(size: 18, weight: .medium))
                                        .foregroundColor(Color("skyBlue"))

                                    Text("View Session History")
                                        .font(.system(size: 16, weight: .medium, design: .rounded))
                                        .foregroundColor(Color.black)

                                    Spacer()

                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(Color.gray)
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 16)
                                .background(
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(Color.white)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 14)
                                                .stroke(
                                                    LinearGradient(
                                                        gradient: Gradient(colors: [
                                                            Color("skyBlue").opacity(0.3),
                                                            Color("skyBlue").opacity(0.1)
                                                        ]),
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    ),
                                                    lineWidth: 1
                                                )
                                        )
                                        .shadow(color: Color("skyBlue").opacity(0.05), radius: 4, x: 0, y: 2)
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                            .animation(.easeInOut(duration: 0.1), value: showingSessionHistory)
                            .padding(.horizontal, 20)
                            .padding(.top, 16)
                            .padding(.bottom, 40)
                        }
                    }
                }
            }
            .navigationTitle("")
            .onAppear {
                if authViewModel.user == nil && authViewModel.myUser.uid.isEmpty {
                    breathingViewModel.instructionText = "Please sign in to begin your mindful journey"
                }
            }
            .sheet(isPresented: $showingSongSelectionSheet) {
                NavigationView {
                    VStack(spacing: 0) {
                        VStack(spacing: 8) {
                            Text("Choose Your Sound")
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .foregroundColor(Color.black)
                            Text("Select background music for your session")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Color.gray)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        .padding(.bottom, 16)
                        Divider().padding(.horizontal, 20)
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(breathingViewModel.availableSongs, id: \.self) { song in
                                    Button(action: {
                                        breathingViewModel.selectedSong = song
                                        breathingViewModel.songSelectionChanged(newSong: song)
                                        showingSongSelectionSheet = false
                                    }) {
                                        HStack(spacing: 16) {
                                            Image(systemName: song == "No Music" ? "speaker.slash.fill" : "music.note")
                                                .font(.system(size: 18, weight: .medium))
                                                .foregroundColor(song == breathingViewModel.selectedSong ? Color("skyBlue") : Color.gray)
                                                .frame(width: 24, height: 24)
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(song == "No Music" ? "Silent Session" : song.capitalized)
                                                    .font(.system(size: 16, weight: .semibold))
                                                    .foregroundColor(Color.black)
                                                Text(song == "No Music" ? "Practice in peaceful silence" : "Relaxing background music")
                                                    .font(.system(size: 12, weight: .medium))
                                                    .foregroundColor(Color.gray)
                                            }
                                            Spacer()
                                            if song == breathingViewModel.selectedSong {
                                                Image(systemName: "checkmark.circle.fill")
                                                    .font(.system(size: 20, weight: .semibold))
                                                    .foregroundColor(Color("skyBlue"))
                                            }
                                        }
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 16)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(song == breathingViewModel.selectedSong ? Color("skyBlue").opacity(0.1) : Color.clear)
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
                        ToolbarItem() {
                            Button("Done") {
                                showingSongSelectionSheet = false
                            }
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color("skyBlue"))
                        }
                    }
                }
            }
        }
      
    }
}
