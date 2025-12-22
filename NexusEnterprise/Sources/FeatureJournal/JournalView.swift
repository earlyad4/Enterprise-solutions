import SwiftUI
import CoreData
import NexusCore
import NexusUI

public struct JournalView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \LogEntry.timestamp, ascending: false)],
        animation: .default)
    private var logs: FetchedResults<LogEntry>
    
    @State private var newLogContent: String = ""
    @State private var summary: String = ""
    
    public init() {}
    
    public var body: some View {
        HStack(spacing: 0) {
            // Main Input and List
            VStack(alignment: .leading, spacing: 20) {
                Text("Daily Operational Log")
                    .font(.largeTitle)
                    .bold()
                
                // Input Area
                VStack(alignment: .leading) {
                    Text("New Entry")
                        .font(.headline)
                    TextEditor(text: $newLogContent)
                        .font(.body)
                        .padding(8)
                        .background(Color(NSColor.textBackgroundColor))
                        .cornerRadius(8)
                        .frame(height: 100)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.3)))
                    
                    HStack {
                        Spacer()
                        Button("Post Entry") {
                            addLog()
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(newLogContent.isEmpty)
                    }
                }
                .padding()
                .background(Color(NSColor.controlBackgroundColor))
                .cornerRadius(12)
                
                Divider()
                
                // History
                List(logs) { log in
                    VStack(alignment: .leading) {
                        HStack {
                            Text(log.timestamp.formatted(date: .numeric, time: .shortened))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Spacer()
                            if let sentiment = log.sentiment {
                                Text(sentiment)
                                    .font(.caption2)
                                    .padding(2)
                                    .background(Color.blue.opacity(0.1))
                                    .cornerRadius(4)
                            }
                        }
                        Text(log.content)
                            .padding(.top, 2)
                    }
                }
            }
            .padding()
            
            Divider()
            
            // AI Sidebar
            VStack(alignment: .leading, spacing: 20) {
                Text("AI Consolidator")
                    .font(.headline)
                
                Text("The AI consolidator reads your daily logs and connected documents to generate executive summaries.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                NexusButton("Generate Daily Briefing") {
                    generateSummary()
                }
                
                ScrollView {
                    if !summary.isEmpty {
                        VStack(alignment: .leading) {
                            Text(Date().formatted(date: .abbreviated, time: .omitted))
                                .font(.headline)
                            Text(summary)
                                .padding(.top, 4)
                        }
                        .padding()
                        .background(Color(NSColor.controlBackgroundColor))
                        .cornerRadius(8)
                    }
                }
                Spacer()
            }
            .frame(width: 300)
            .padding()
            .background(Color(NSColor.windowBackgroundColor))
        }
        .navigationTitle("Journal")
    }
    
    private func addLog() {
        withAnimation {
            let log = LogEntry(context: viewContext)
            log.id = UUID()
            log.timestamp = Date()
            log.content = newLogContent
            
            // Simulated Sentiment Analysis (Stub for AI Pipeline)
            log.sentiment = ["Positive", "Neutral", "Critical"].randomElement()
            
            try? viewContext.save()
            newLogContent = ""
        }
    }
    
    private func generateSummary() {
        // Here we would call the AIPipeline service
        // For now, we simulate a response based on the logs
        let count = logs.count
        summary = "Analyzed \(count) log entries. Key themes: High activity in R&D module deployment. Financials show stable growth. Pending contract approvals identified in CRM."
    }
}
