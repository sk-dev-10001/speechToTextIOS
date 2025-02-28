//
//  SpeechRecognizer.swift
//  Speech_Recogniser
//
//  Created by somveer kumar on 28/02/25.
//


/*
 See LICENSE folder for this sample’s licensing information.
 */
import Foundation
import Speech

class SpeechRecognizer: NSObject, SFSpeechRecognizerDelegate, ObservableObject {
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()

    override init() {
        super.init()
        speechRecognizer?.delegate = self
        requestSpeechPermission()
    }

    func requestSpeechPermission() {
        SFSpeechRecognizer.requestAuthorization { status in
            if status != .authorized {
                print("Speech recognition not authorized")
            }
        }
    }

    func startRecording(completion: @escaping (String?) -> Void) {
        guard SFSpeechRecognizer.authorizationStatus() == .authorized else { return }

        if audioEngine.isRunning {
            stopRecording()
            return
        }

        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        let inputNode = audioEngine.inputNode
        let request = recognitionRequest!
        request.shouldReportPartialResults = true

        recognitionTask = speechRecognizer?.recognitionTask(with: request) { result, error in
            if let result = result {
                let recognizedText = result.bestTranscription.formattedString
                completion(recognizedText)
            } else if let error = error {
                print("Recognition error: \(error.localizedDescription)")
                completion(nil)
            }
        }

        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, _) in
            request.append(buffer)
        }

        audioEngine.prepare()
        try? audioEngine.start()
    }

    func stopRecording() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        audioEngine.outputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        recognitionTask = nil
    }
}
