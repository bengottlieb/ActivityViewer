//
//  ContentView.swift
//  ActivityViewer
//
//  Created by Ben Gottlieb on 12/29/24.
//

import SwiftUI
import Suite
import CoreMotion

struct ContentView: View {
	@State private var timeline: ActivityTimeline?
	@State private var date = Date.now.previousDay
	
	func buildTimeline() {
		let samples: [CMMotionActivity.Saved] = try! .loadJSON(file: Bundle.main.url(forResource: "motion_samples", withExtension: "txt"))
		
		timeline = ActivityTimeline(samples: samples)
	}
	
	var body: some View {
		VStack {
			if let timeline {
				ScrollView {
					VStack {
						TimelineTotalsView(timeline: timeline)
						ActivityTimelineView(timeline: timeline)
					}
				}
			}
			
			HStack {
				AsyncButton("Query") {
					let results = try await ActivityManager.instance.fetch()
					let encoded = results.map { CMMotionActivity.Saved($0) }
					timeline = ActivityTimeline(samples: encoded)
				}
				DatePicker("", selection: $date, displayedComponents: [.date])
					.fixedSize()
			}
		}
		.padding()
		.onAppear { buildTimeline() }
		.onChange(of: date) {
			updateQuery()
		}
		
	}
	
	func updateQuery() {
		let start = date.midnight
		let end = date.lastSecond
		
		Task {
			let results = try await ActivityManager.instance.fetch(startDate: start, endDate: end)
			let encoded = results.map { CMMotionActivity.Saved($0) }
			timeline = ActivityTimeline(samples: encoded)
		}
	}
}

#Preview {
	ContentView()
}
