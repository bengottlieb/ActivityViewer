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
	var duration: TimeInterval
	
	func duration(for activity: Segment.Activity) -> TimeInterval {
		segments.filter { $0.contains(activity) }.compactMap { $0.duration }.sum()
	}
	
	init(samples: [CMMotionActivity.Saved]) {
		for index in samples.indices {
			let endDate = index < samples.count - 1 ? samples[index + 1].startDate : nil
			
			segments.append(Segment(source: samples[index], end: endDate))
		}
		
		if segments.count > 1 {
			duration = segments.last!.startDate.timeIntervalSince(segments.first!.startDate)
		} else {
			duration = 0
		}
	}
	
	struct Segment: Codable, Hashable, Sendable, Identifiable {
		var id: Date { startDate }
		let startDate: Date
		let endDate: Date?
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
			
			if source.stationary { activities.append(.stationary) }
			if source.walking { activities.append(.walking) }
			if source.running { activities.append(.running) }
			if source.cycling { activities.append(.cycling) }
			if source.automotive { activities.append(.driving) }
			if source.unknown { activities.append(.unknown) }
			
			self.activities = activities
		}
		
		var visibleDescription: String {
			activities.map { $0.rawValue }.joined(separator: ", ")
		}
		
	}
}
