//
//  ScrumTimer.swift
//  Scrumdinger
//
//  Created by Auwfar on 20/03/25.
//

import Foundation

@MainActor
@Observable public final class ScrumTimer {
    public struct Speaker: Identifiable {
        public let id: UUID = UUID()
        public var name: String
        public var isCompleted: Bool
        
        init(name: String, isCompleted: Bool) {
            self.name = name
            self.isCompleted = isCompleted
        }
    }
    
    public var activeSpeaker = ""
    public var secondsElapsed: Int = 0
    public var secondsRemaining: Int = 0
    private var _speakers: [Speaker] = []
    public var speakers: [Speaker] {
        _speakers
    }
    public var speakerChangedAction: (() -> Void)?
    
    private var lengthInMinutes: Int
    private weak var timer: Timer?
    private var timerStopped = false
    private var frequency: TimeInterval { 1.0 / 60.0 }
    private var lengthInSeconds: Int { lengthInMinutes * 60 }
    private var secondsPerSpeaker: Int { (lengthInMinutes * 60) / _speakers.count }
    private var secondsElapsedForSpeaker: Int = 0
    private var speakerIndex: Int = 0
    private var speakerText: String {
        return "Speaker \(speakerIndex + 1):" + speakers[speakerIndex].name
    }
    private var startDate: Date?
    
    public init(lengthInMinutes: Int = 0, attendeeNames: [String] = []) {
        self.lengthInMinutes = lengthInMinutes
        self._speakers = Self.generateSpeakersList(with: attendeeNames)
        secondsRemaining = lengthInSeconds
        activeSpeaker = speakerText
    }
    
    public func startScrum() {
        timer = Timer.scheduledTimer(withTimeInterval: frequency, repeats: true) { [weak self] timer in
            self?.update()
        }
        timer?.tolerance = 0.1
        changeToSpeaker(at: 0)
    }
    
    public func stopScrum() {
        timer?.invalidate()
        timerStopped = true
    }
    
    nonisolated func skipSpeaker() {
        Task { @MainActor in
            changeToSpeaker(at: speakerIndex + 1)
        }
    }
    
    public func reset(lengthInMinutes: Int, attendeeNames: [String]) {
        self.lengthInMinutes = lengthInMinutes
        self._speakers = Self.generateSpeakersList(with: attendeeNames)
        secondsRemaining = lengthInSeconds
        activeSpeaker = speakerText
    }
    
    private func changeToSpeaker(at index: Int) {
        if index > 0 {
            let previousSpeakerIndex = index - 1
            _speakers[previousSpeakerIndex].isCompleted = true
        }
        secondsElapsedForSpeaker = 0
        guard index < speakers.count else { return }
        speakerIndex = index
        activeSpeaker = speakerText
        
        secondsElapsed = index * secondsPerSpeaker
        secondsRemaining = lengthInSeconds - secondsElapsed
        startDate = Date()
    }
    
    nonisolated private func update() {
        Task { @MainActor in
            guard let startDate,
                  !timerStopped else { return }
            let secondsElapsed = Int(Date().timeIntervalSince1970 - startDate.timeIntervalSince1970)
            secondsElapsedForSpeaker = secondsElapsed
            self.secondsElapsed = secondsPerSpeaker * speakerIndex + secondsElapsedForSpeaker
            guard secondsElapsed <= secondsPerSpeaker else {
                return
            }
            secondsRemaining = max(lengthInSeconds - self.secondsElapsed, 0)
            
            if secondsElapsedForSpeaker >= secondsPerSpeaker {
                changeToSpeaker(at: speakerIndex + 1)
                speakerChangedAction?()
            }
        }
    }
    
    private static func generateSpeakersList(with names: [String]) -> [Speaker] {
        guard !names.isEmpty else { return [Speaker(name: "Speaker 1", isCompleted: false)] }
        return names.map { Speaker(name: $0, isCompleted: false) }
    }
}
