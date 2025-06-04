//
//  BreathingSessionView.swift
//  ALP_Jevon_Carry_macOS
//
//  Created by Daffa Khoirul on 01/06/25.
//  Adapted for macOS
//


import SwiftUI

struct BreathingSessionView: View {
    @StateObject var breathingViewModel: BreathingViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @Binding var showingSessionHistory: Bool

    @State private var isDraggingSlider = false
    @State private var showingSongSelectionSheet = false

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Light mode background
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

                HStack(spacing: 0) {
                    // Left Panel - Controls and Information
                    VStack(spacing: 24) {
                        // Header Section
                        VStack(spacing: 16) {
                            Text("Mindful Breathing")
                                .font(.system(size: 28, weight: .thin, design: .rounded))
                                .foregroundColor(.black)
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
                                            .foregroundColor(.gray)

                                        Text(breathingViewModel.selectedSong == "No Music" ? "Silent Session" : breathingViewModel.selectedSong.capitalized)
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(.black)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(.gray)
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.white)
                                        .shadow(color: Color("skyBlue").opacity(0.1), radius: 4, x: 0, y: 1)
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }

                        // Session Info Section
                        VStack(spacing: 16) {
                            HStack {
                                Image(systemName: "clock")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(Color("skyBlue"))

                                Text("Session Time")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.gray)

                                Spacer()

                                Text(String(format: "%02d:%02d", Int(breathingViewModel.sessionTimeElapsed) / 60, Int(breathingViewModel.sessionTimeElapsed) % 60))
                                    .font(.system(size: 16, weight: .bold, design: .monospaced))
                                    .foregroundColor(.black)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.white)
                                    .shadow(color: Color("skyBlue").opacity(0.08), radius: 3, x: 0, y: 1)
                            )
                        }

                        // Music Controls Section (if applicable)
                        if breathingViewModel.selectedSong != "No Music",
                           breathingViewModel.musicPlayerViewModel.currentSongFileName != nil {
                            VStack(spacing: 16) {
                                Text("Now Playing")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.gray)

                                VStack(spacing: 12) {
                                    Text(breathingViewModel.musicPlayerViewModel.currentSongFileName?.capitalized ?? "No song loaded")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.black)
                                        .multilineTextAlignment(.center)

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
                                        .controlSize(.small)
                                        .accentColor(Color("skyBlue"))

                                        HStack {
                                            Text(breathingViewModel.musicPlayerViewModel.formatTime(breathingViewModel.musicPlayerViewModel.currentTime))
                                            Spacer()
                                            Text(breathingViewModel.musicPlayerViewModel.formatTime(breathingViewModel.musicPlayerViewModel.duration))
                                        }
                                        .font(.system(size: 10, weight: .medium, design: .monospaced))
                                        .foregroundColor(.gray)
                                    }

                                    Button(action: {
                                        breathingViewModel.musicPlayerViewModel.playPause()
                                    }) {
                                        Image(systemName: breathingViewModel.musicPlayerViewModel.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                                            .font(.system(size: 32, weight: .light))
                                            .foregroundColor(Color("skyBlue"))
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    .scaleEffect(breathingViewModel.musicPlayerViewModel.isPlaying ? 0.95 : 1.0)
                                    .animation(.easeInOut(duration: 0.1), value: breathingViewModel.musicPlayerViewModel.isPlaying)
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white)
                                    .shadow(color: Color("skyBlue").opacity(0.08), radius: 4, x: 0, y: 2)
                            )
                        }

                        Spacer()

                        // Control Buttons Section
                        VStack(spacing: 12) {
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    breathingViewModel.toggleSession()
                                }
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: breathingViewModel.isSessionActive ? "stop.fill" : "play.fill")
                                        .font(.system(size: 16, weight: .semibold))

                                    Text(breathingViewModel.isSessionActive ? "End Session" : "Begin Session")
                                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                                }
                                .foregroundColor(.white)
                                .padding(.vertical, 12)
                                .frame(maxWidth: .infinity)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
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
                                                radius: 6, x: 0, y: 3)
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                            .scaleEffect(breathingViewModel.isSessionActive ? 1.0 : 1.02)
                            .animation(.easeInOut(duration: 0.15), value: breathingViewModel.isSessionActive)

                            // History Button
                            Button(action: {
                                showingSessionHistory = true
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "clock.badge.checkmark")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(Color("skyBlue"))

                                    Text("Session History")
                                        .font(.system(size: 14, weight: .medium, design: .rounded))
                                        .foregroundColor(.black)

                                    Spacer()

                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(.gray)
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.white)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
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
                                        .shadow(color: Color("skyBlue").opacity(0.05), radius: 2, x: 0, y: 1)
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .frame(width: 280)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 32)

                    // Vertical Divider
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 1)

                    // Right Panel - Breathing Circle
                    VStack {
                        Spacer()

                        // Breathing Circle Section
                        let availableSize = min(geometry.size.width - 320, geometry.size.height - 100)
                        let circleSize = min(availableSize * 0.7, 400)

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
                                    lineWidth: 2
                                )
                                .frame(width: circleSize * 0.7, height: circleSize * 0.7)
                                .scaleEffect(breathingViewModel.circleScale * 0.9)

                            // Breathing instruction text and phase icon
                            VStack(spacing: 12) {
                                if breathingViewModel.isSessionActive {
                                    Image(systemName:
                                        breathingViewModel.breathingPhase == "inhale" ? "arrow.up.circle.fill" :
                                        breathingViewModel.breathingPhase == "exhale" ? "arrow.down.circle.fill" :
                                        breathingViewModel.breathingPhase == "hold" ? "pause.circle.fill" :
                                        "pause.circle"
                                    )
                                    .font(.system(size: 32, weight: .light))
                                    .foregroundColor(.black)
                                }
                                Text(breathingViewModel.instructionText)
                                    .font(.system(size: 20, weight: .medium, design: .rounded))
                                    .foregroundColor(.black)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 40)
                                    .shadow(color: .white, radius: 2, x: 0, y: 0)
                            }
                        }

                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .frame(minWidth: 800, minHeight: 600)
        .onAppear {
            if authViewModel.user == nil && authViewModel.myUser.uid.isEmpty {
                breathingViewModel.instructionText = "Please sign in to begin your mindful journey"
            }
        }
        .sheet(isPresented: $showingSongSelectionSheet) {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 8) {
                    Text("Choose Your Sound")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.black)
                    Text("Select background music for your session")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.gray)
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
                .padding(.bottom, 16)

                Divider()

                // Song List
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(breathingViewModel.availableSongs, id: \.self) { song in
                            Button(action: {
                                breathingViewModel.selectedSong = song
                                breathingViewModel.songSelectionChanged(newSong: song)
                                showingSongSelectionSheet = false
                            }) {
                                HStack(spacing: 12) {
                                    Image(systemName: song == "No Music" ? "speaker.slash.fill" : "music.note")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(song == breathingViewModel.selectedSong ? Color("skyBlue") : .gray)
                                        .frame(width: 20, height: 20)

                                    VStack(alignment: .leading, spacing: 3) {
                                        Text(song == "No Music" ? "Silent Session" : song.capitalized)
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(.black)
                                        Text(song == "No Music" ? "Practice in peaceful silence" : "Relaxing background music")
                                            .font(.system(size: 11, weight: .medium))
                                            .foregroundColor(.gray)
                                    }

                                    Spacer()

                                    if song == breathingViewModel.selectedSong {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(Color("skyBlue"))
                                    }
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(song == breathingViewModel.selectedSong ? Color("skyBlue").opacity(0.1) : Color.clear)
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                }

                Spacer()

                // Bottom buttons
                HStack {
                    Spacer()
                    Button("Done") {
                        showingSongSelectionSheet = false
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
            .frame(width: 400, height: 500)
            .background(Color.white)
        }
    }
}
