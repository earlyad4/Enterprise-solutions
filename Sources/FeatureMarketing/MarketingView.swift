import SwiftUI
import CoreData
import NexusCore
import NexusUI

public struct MarketingView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Campaign.startDate, ascending: true)],
        animation: .default)
    private var campaigns: FetchedResults<Campaign>
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Segment.estimatedSize, ascending: false)],
        animation: .default)
    private var segments: FetchedResults<Segment>
    
    @State private var selectedTab = "Campaigns"
    
    public init() {}
    
    public var body: some View {
        VStack {
            Picker("View", selection: $selectedTab) {
                Text("Campaigns").tag("Campaigns")
                Text("Segments").tag("Segments")
            }
            .pickerStyle(.segmented)
            .padding()
            
            if selectedTab == "Campaigns" {
                campaignList
            } else {
                segmentList
            }
        }
        .navigationTitle("Marketing")
        .toolbar {
            ToolbarItem {
                Button(action: {
                    if selectedTab == "Campaigns" { addCampaign() } else { addSegment() }
                }) {
                    Label("Add", systemImage: "plus")
                }
            }
        }
    }
    
    var campaignList: some View {
        List(campaigns) { campaign in
            HStack {
                VStack(alignment: .leading) {
                    Text(campaign.name)
                        .font(.headline)
                    Text(campaign.type)
                        .font(.caption)
                        .padding(4)
                        .background(Color.purple.opacity(0.1))
                        .cornerRadius(4)
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text(campaign.budget.formatted(.currency(code: "USD")))
                        .fontWeight(.bold)
                    Text(campaign.status)
                        .font(.caption)
                        .foregroundStyle(campaign.status == "Active" ? .green : .secondary)
                }
            }
        }
    }
    
    var segmentList: some View {
        List(segments) { segment in
            HStack {
                VStack(alignment: .leading) {
                    Text(segment.name)
                        .font(.headline)
                    Text(segment.criteria)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Text("\(segment.estimatedSize) users")
                    .fontWeight(.bold)
            }
        }
    }
    
    private func addCampaign() {
        withAnimation {
            let c = Campaign(context: viewContext)
            c.id = UUID()
            c.name = "New Campaign Q3"
            c.type = "Email"
            c.status = "Planning"
            c.budget = 5000.0
            c.startDate = Date()
            
            try? viewContext.save()
        }
    }
    
    private func addSegment() {
        withAnimation {
            let s = Segment(context: viewContext)
            s.id = UUID()
            s.name = "High Value Customers"
            s.criteria = "LTV > $10,000"
            s.estimatedSize = 150
            
            try? viewContext.save()
        }
    }
}
