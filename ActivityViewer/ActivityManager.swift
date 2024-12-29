//
//  ActivityManager.swift
//  ActivityViewer
//
//  Created by Ben Gottlieb on 12/29/24.
//

import CoreMotion
import Suite

actor ActivityManager {
	private let activityManager = CMMotionActivityManager()
	
	public static let instance = ActivityManager()
	
	func preflight() -> Bool {
		// Check if activity tracking is available
		guard CMMotionActivityManager.isActivityAvailable() else {
			print("Activity tracking is not available on this device")
			return false
		}
		
		// Request authorization
		CMMotionActivityManager.authorizationStatus()
		return true
	}
	
	func startTracking() {
		if !preflight() { return }
		
		// Start live tracking
		activityManager.startActivityUpdates(to: .main) { activity in
			guard let activity = activity else { return }
			
			// Handle different activity types
			if activity.walking {
				print("User is walking")
			} else if activity.running {
				print("User is running")
			} else if activity.automotive {
				print("User is in a vehicle")
			} else if activity.stationary {
				print("User is stationary")
			}
			
			// Get confidence level
			switch activity.confidence {
			case .low:
				print("Low confidence")
			case .medium:
				print("Medium confidence")
			case .high:
				print("High confidence")
				
			@unknown default:
				print("Unnown confidence: \(activity.confidence)")
			}
		}
	}
	
	
	func fetch(startDate: Date = Date.now.addingTimeInterval(-24 * .hour), endDate: Date = .now) async throws -> [CMMotionActivity] {
		if !preflight() { return [] }

		return try await withCheckedThrowingContinuation { continuation in
			// Query historical data
			activityManager.queryActivityStarting(from: startDate, to: endDate, to: .main) { activities, error in
				if let error = error {
					continuation.resume(throwing: error)
				} else if let activities {
					continuation.resume(returning: activities)
				} else {
					continuation.resume(returning: [])
				}
			}
		}
	}
	
	func stopTracking() {
		activityManager.stopActivityUpdates()
	}
}
