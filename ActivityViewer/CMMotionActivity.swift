//
//  CMMotionActivity.swift
//  ActivityViewer
//
//  Created by Ben Gottlieb on 12/29/24.
//

import CoreMotion

extension CMMotionActivity {
	struct Saved: Codable {
		let confidence: CMMotionActivityConfidence
		let startDate: Date
		
		let unknown: Bool
		let stationary: Bool
		let walking: Bool
		let running: Bool
		let automotive: Bool
		let cycling: Bool
		
		init(_ activity: CMMotionActivity) {
			confidence = activity.confidence
			startDate = activity.startDate
			
			unknown = activity.unknown
			stationary = activity.stationary
			walking = activity.walking
			running = activity.running
			automotive = activity.automotive
			cycling = activity.cycling
		}
	}
}

extension CMMotionActivityConfidence: Codable { }
