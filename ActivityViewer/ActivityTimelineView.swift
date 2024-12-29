//
//  ActivityTimelineView.swift
//  ActivityViewer
//
//  Created by Ben Gottlieb on 12/29/24.
//

import Suite

struct ActivityTimelineView: View {
	let timeline: ActivityTimeline
	let secondHeight: Double = 0.1
	
	var body: some View {
		VStack(spacing: 0) {
			ForEach(timeline.segments) { segment in
				if let duration = segment.duration {
					let height = secondHeight * duration
					Rectangle()
						.fill(segment.primaryActivity.color)
						.frame(height: height)
						.overlay {
							if height > 12 {
								Text(segment.visibleDescription + ", " + segment.timeDescription)
									.foregroundStyle(segment.primaryActivity.color.textColor)
									.font(.caption)
							}
						}
				}
			}
		}
	}
}
