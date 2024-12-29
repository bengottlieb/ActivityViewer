//
//  TimelineTotalsView.swift
//  ActivityViewer
//
//  Created by Ben Gottlieb on 12/29/24.
//

import Suite

struct TimelineTotalsView: View {
	let timeline: ActivityTimeline
	let activities: [ActivityTimeline.Segment.Activity] = [.stationary, .walking, .driving, .unknown]
	

	var body: some View {
		HStack {
			ForEach(activities) { activity in
				let duration = timeline.duration(for: activity)
				Text("\(duration.durationString())")
					.foregroundStyle(activity.color)
			}
		}
    }
}
