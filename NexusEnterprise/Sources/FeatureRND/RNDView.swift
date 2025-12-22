import SwiftUI
import CoreData
import NexusCore
import NexusUI

public struct RNDView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Project.deadline, ascending: true)],
        animation: .default)
    private var projects: FetchedResults<Project>
    
    @State private var selectedProject: Project?
    
    public init() {}
    
    public var body: some View {
        NavigationSplitView {
            List(selection: $selectedProject) {
                Section("Active Projects") {
                    ForEach(projects) { project in
                        NavigationLink(value: project) {
                            Text(project.name)
                        }
                    }
                }
                
                Section("Intelligence Feeds") {
                    NavigationLink(value: "rss_techcrunch") { Label("TechCrunch", systemImage: "antenna.radiowaves.left.and.right") }
                    NavigationLink(value: "rss_hackernews") { Label("Hacker News", systemImage: "bolt.fill") }
                }
            }
            .navigationTitle("R&D")
            .toolbar {
                ToolbarItem {
                    Button(action: addProject) {
                        Label("Add Project", systemImage: "plus")
                    }
                }
            }
        } detail: {
            if let project = selectedProject {
                ProjectDetailView(project: project)
            } else {
                Text("Select a project or feed")
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func addProject() {
        withAnimation {
            let proj = Project(context: viewContext)
            proj.id = UUID()
            proj.name = "New Research Project"
            proj.status = "Active"
            proj.deadline = Date().addingTimeInterval(90*24*60*60)
            
            try? viewContext.save()
        }
    }
}

struct ProjectDetailView: View {
    let project: Project
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text(project.name)
                    .font(.largeTitle)
                    .bold()
                
                HStack {
                    NexusCard {
                        VStack {
                            Text("Status")
                                .font(.caption)
                            Text(project.status)
                                .font(.headline)
                        }
                    }
                    NexusCard {
                        VStack {
                            Text("Deadline")
                                .font(.caption)
                            Text(project.deadline?.formatted(date: .abbreviated, time: .omitted) ?? "None")
                                .font(.headline)
                        }
                    }
                }
                
                Divider()
                
                Text("Linked Research")
                    .font(.headline)
                
                NexusCard {
                    HStack {
                        Image(systemName: "doc.text.fill")
                        VStack(alignment: .leading) {
                            Text("Market_Analysis_2025.pdf")
                            Text("Auto-linked from Marketing")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                    }
                    .padding()
                }
            }
            .padding()
        }
    }
}
