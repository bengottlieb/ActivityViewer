//
//  ActivityTimeline.swift
//  ActivityViewer
//
//  Created by Ben Gottlieb on 12/29/24.
//

import Suite
import CoreMotion


struct ActivityTimeline: Equatable, Hashable, Sendable {
	var segments: [Segment] = []
	var collapsed: [Segment] = []
	var tolerance = 10.0 { didSet { updateCollapsed() }}
	
	var duration: TimeInterval {
		guard let first = segments.first, let last = segments.last else { return 0 }
		
		return last.startDate.timeIntervalSince(first.startDate)
	}

	func duration(for activity: Segment.Activity) -> TimeInterval {
		segments.filter { $0.contains(activity) }.compactMap { $0.duration }.sum()
	}
	
	mutating func updateCollapsed(for activities: [Segment.Activity] = [.driving, .walking, .running, .cycling]) {
		var indexesToRemove: [Int] = []
		for index in segments.indices.dropFirst(2).dropLast(2) {
			if !activities.contains(segments[index].primaryActivity) { continue }
			
			if (segments[index - 1].primaryActivity == .unknown || segments[index - 1].primaryActivity == .stationary), segments[index - 2].primaryActivity == segments[index].primaryActivity {
				segments[index].startDate = segments[index - 2].startDate
				indexesToRemove.append(index - 2)
				indexesToRemove.append(index - 1)
			} else if segments[index - 1].primaryActivity == segments[index].primaryActivity {
				segments[index].startDate = segments[index - 1].startDate
				indexesToRemove.append(index - 1)
			}
		}
		
		for index in indexesToRemove.reversed() {
			segments.remove(at: index)
		}
	}
	
	init(samples: [CMMotionActivity.Saved]) {
		load(samples: samples)
	}
	
	mutating func load(samples: [CMMotionActivity.Saved]) {
		segments = []
		for index in samples.indices {
			let endDate = index < samples.count - 1 ? samples[index + 1].startDate : nil
			
			segments.append(Segment(source: samples[index], end: endDate))
		}
		updateCollapsed()
	}
	
	struct Segment: Codable, Hashable, Sendable, Identifiable {
		var id: Date { startDate }
		var startDate: Date
		var endDate: Date?
		let activities: [Activity]
		
		var timeDescription: String {
			guard let endDate else { return startDate.formatted(date: .omitted, time: .shortened) + "-" }
			
			return startDate.formatted(date: .omitted, time: .shortened) + "-" + endDate.formatted(date: .omitted, time: .shortened)
		}
		
		var duration: TimeInterval? {
			endDate?.timeIntervalSince(startDate)
		}
		
		enum Activity: String, Codable, Hashable, Sendable, IdentifiableEnum { case unknown, stationary, walking, running, cycling, driving
			@MainActor var color: Color {
				switch self {
				case .stationary: return Color.stationary
				case .walking: return Color.walking
				case .running: return Color.running
				case .cycling: return Color.cycling
				case .driving: return Color.driving
				case .unknown: return Color.unknown
				}
			}
		}
		
		func contains(_ activity: Activity) -> Bool { activities.contains(activity) }
		
		var primaryActivity: Activity { activities.first ?? .unknown }
		
		init(source: CMMotionActivity.Saved, end: Date?) {
			startDate = source.startDate
			endDate = end
			
			var activities: [Activity] = []
			
			if source.automotive { activities.append(.driving) }
			if source.running { activities.append(.running) }
			if source.walking { activities.append(.walking) }
			if source.cycling { activities.append(.cycling) }
			if source.stationary { activities.append(.stationary) }
			if source.unknown { activities.append(.unknown) }
			
			self.activities = activities
		}
		
		var visibleDescription: String {
			activities.map { $0.rawValue }.joined(separator: ", ")
		}
		
	}
}
