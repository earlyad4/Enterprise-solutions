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
    
    @State private var selectedTab = "Dashboard"
    @State private var showingAddCampaign = false
    
    public init() {}
    
    public var body: some View {
        VStack {
            Picker("View", selection: $selectedTab) {
                Text("Dashboard").tag("Dashboard")
                Text("Campaigns (Promotion)").tag("Campaigns")
                Text("Products").tag("Products")
                Text("Analysis").tag("Analysis")
            }
            .pickerStyle(.segmented)
            .padding()
            
            if selectedTab == "Dashboard" {
                dashboardView
            } else if selectedTab == "Campaigns" {
                campaignList
            } else if selectedTab == "Products" {
                ProductView()
            } else {
                MarketingAnalysisView()
            }
        }
        .navigationTitle("Marketing")
        .toolbar {
            ToolbarItem {
                if selectedTab == "Campaigns" {
                     Button(action: { showingAddCampaign = true }) {
                        Label("Add Campaign", systemImage: "plus")
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddCampaign) {
            AddCampaignSheet()
        }
    }
    
    var dashboardView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    NexusCard {
                        VStack {
                            Text("Active Campaigns")
                                .font(.caption)
                            Text("\(campaigns.filter { $0.status == "Active" }.count)")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                        }
                    }
                    NexusCard {
                        VStack {
                            Text("Total Budget")
                                .font(.caption)
                            let total = campaigns.reduce(0) { $0 + $1.budget }
                            Text(total.formatted(.currency(code: "USD")))
                                .font(.title2)
                                .fontWeight(.bold)
                        }
                    }
                }
                .padding(.horizontal)
                
                Text("Quick Analysis Preview")
                    .font(.headline)
                    .padding(.horizontal)
                
                MarketingAnalysisView()
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
}

struct AddCampaignSheet: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String = ""
    @State private var type: String = "Email"
    @State private var budget: Double = 1000.0
    @State private var status: String = "Planning"
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Campaign Name", text: $name)
                Picker("Type", selection: $type) {
                    Text("Email").tag("Email")
                    Text("Social Media").tag("Social Media")
                    Text("Print").tag("Print")
                    Text("TV/Video").tag("TV/Video")
                }
                TextField("Budget", value: $budget, format: .currency(code: "USD"))
                Picker("Status", selection: $status) {
                    Text("Planning").tag("Planning")
                    Text("Active").tag("Active")
                    Text("Completed").tag("Completed")
                }
            }
            .navigationTitle("New Campaign")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        addCampaign()
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
            .frame(minWidth: 300, minHeight: 250)
        }
    }
    
    private func addCampaign() {
        let c = Campaign(context: viewContext)
        c.id = UUID()
        c.name = name
        c.type = type
        c.status = status
        c.budget = budget
        c.startDate = Date()
        
        try? viewContext.save()
    }
}
