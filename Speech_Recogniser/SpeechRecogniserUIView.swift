//
//  SpeechRecogniserUIView.swift
//  Speech_Recogniser
//
//  Created by Somveer Kumar on 28/02/25.
//

import SwiftUI
import Speech
import AVFoundation

// MARK: - AVPlayer Extension for Sound
extension AVPlayer {
    static let sharedDingPlayer: AVPlayer = {
        guard let url = Bundle.main.url(forResource: "ding", withExtension: "wav") else {
            fatalError("Failed to find sound file.")
        }
        return AVPlayer(url: url)
    }()
}

// MARK: - SpeechRecogniserUIView
struct SpeechRecogniserUIView: View {
    @StateObject private var speechRecognizer = SpeechRecognizer()
    @State private var speechText = "Please Speak..."
    private var player: AVPlayer { AVPlayer.sharedDingPlayer }
    
    @State private var isRecording = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Title
            Text("Speech Recogniser")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.top, 20)
            
            // Displaying Transcription
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(radius: 5)
                .frame(height: 120)
                .padding()
                .overlay(
                    Text(isRecording ? "speaking" : speechText)
                        .font(.headline)
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                        .padding()
                )
            
            // Recording Indicator
            if isRecording {
                ProgressView("Listening...")
                    .progressViewStyle(CircularProgressViewStyle(tint: .red))
                    .padding(.bottom, 10)
            }
            
            // Start/Stop Button
            Button(action: {
                isRecording ? endSpeechRecognition() : startSpeechRecognition()
            }) {
                Text(isRecording ? "Stop" : "Start")
                    .font(.headline)
                    .frame(width: 150, height: 50)
                    .background(isRecording ? Color.red : Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .shadow(radius: 5)
            }
            .padding(.bottom, 20)
        }
        .padding()
        .background(Color(.systemGroupedBackground))
        .cornerRadius(20)
        .padding()
        .onAppear { print("Speech Recognition View Appeared") }
        .onDisappear { endSpeechRecognition() }
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Speech Recognition Functions
    private func startSpeechRecognition() {
        speechRecognizer.resetTranscript()
        speechRecognizer.startTranscribing()
        speechText += "\n" + speechRecognizer.transcript
        isRecording = true
    }
    
    private func endSpeechRecognition() {
        speechRecognizer.stopTranscribing()
        isRecording = false
        speechText += "\n" + speechRecognizer.transcript
    }
}

// MARK: - Preview
struct SpeechRecogniserUIView_Previews: PreviewProvider {
    static var previews: some View {
        SpeechRecogniserUIView()
    }
}
