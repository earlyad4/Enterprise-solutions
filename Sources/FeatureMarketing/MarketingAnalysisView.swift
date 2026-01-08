import SwiftUI
import CoreData
import NexusCore
import NexusUI
import Charts

struct MarketingAnalysisView: View {
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Segment.estimatedSize, ascending: false)],
        animation: .default)
    private var segments: FetchedResults<Segment>
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Data Analysis Results")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.horizontal)
                
                if segments.isEmpty {
                     ContentUnavailableView("No Data", systemImage: "chart.pie", description: Text("Create segments to view analysis."))
                } else {
                    NexusCard {
                        VStack(alignment: .leading) {
                            Text("Market Segmentation (Place)")
                                .font(.headline)
                            
                            Chart(segments) { segment in
                                SectorMark(
                                    angle: .value("Size", segment.estimatedSize),
                                    innerRadius: .ratio(0.5),
                                    angularInset: 1.5
                                )
                                .cornerRadius(5)
                                .foregroundStyle(by: .value("Name", segment.name))
                            }
                            .frame(height: 250)
                        }
                    }
                    .padding(.horizontal)
                    
                    VStack(alignment: .leading) {
                        Text("Segment Details")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ForEach(segments) { segment in
                            NexusCard {
                                VStack(alignment: .leading) {
                                    HStack {
                                        Text(segment.name)
                                            .font(.headline)
                                        Spacer()
                                        Text("\(segment.estimatedSize) users")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                    Text("Criteria: \(segment.criteria)")
                                        .font(.caption)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
            }
            .padding(.vertical)
        }
        .background(Color(NSColor.textBackgroundColor)) // Slightly different background
    }
}
