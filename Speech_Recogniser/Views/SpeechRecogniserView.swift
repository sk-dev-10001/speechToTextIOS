import SwiftUI
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

// MARK: - Speech Recogniser View
struct SpeechRecogniserView: View {
    @StateObject var speechRecognizer = SpeechRecognizer()
    @State private var isRecording = false
    @State private var speechText = ""

    private var player: AVPlayer { AVPlayer.sharedDingPlayer }

    var body: some View {
        VStack(spacing: 20) {
            // Title
            Text("Speech Recogniser")
                .font(.title)
                .fontWeight(.bold)
                .padding(.top, 20)

            // Speech Output Box
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(radius: 5)
                .frame(maxHeight:.infinity)
                .padding()
                .overlay(
                    Text(isRecording ? speechText : "Please speak...")
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
                isRecording ? endSpeechRecogniser() : startSpeechRecogniser()
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
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .onAppear {
            print("Speech Recogniser View Loaded")
        }
        .onDisappear {
            endSpeechRecogniser()
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Speech Recognition Functions
    private func startSpeechRecogniser() {
        print("Starting Speech Recognition")
        speechText = ""
        isRecording = true
        speechRecognizer.startRecording { text in
            DispatchQueue.main.async {
                self.speechText += text ?? ""
            }
        }
    }

    private func endSpeechRecogniser() {
        print("Ending Speech Recognition")
        speechRecognizer.stopRecording()
        isRecording = false
    }
}

// MARK: - Preview
struct SpeechRecogniserView_Preview: PreviewProvider {
    static var previews: some View {
        SpeechRecogniserView()
    }
}
