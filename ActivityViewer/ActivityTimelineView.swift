//
//  ActivityTimelineView.swift
//  ActivityViewer
//
//  Created by Ben Gottlieb on 12/29/24.
//

import Suite

struct ActivityTimelineView: View {
	let timeline: ActivityTimeline
	var secondHeight: Double = 0.05
	
	var body: some View {
		VStack(spacing: 0) {
			ForEach(timeline.segments.indices, id: \.self) { index in
				let segment = timeline.segments[index]
				
				if let duration = segment.duration {
					let height = secondHeight * duration
					Rectangle()
						.fill(segment.primaryActivity.color)
						.frame(height: height)
						.overlay {
							if height > 12 {
								Text(//"\(index). " +
									segment.visibleDescription + ", " + segment.timeDescription)
									.foregroundStyle(segment.primaryActivity.color.textColor)
									.font(.callout)
							}
						}
				}
			}
		}
	}
}
