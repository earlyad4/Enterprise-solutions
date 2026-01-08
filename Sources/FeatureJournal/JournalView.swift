import SwiftUI
import CoreData
import NexusCore
import NexusUI

public struct JournalView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \JournalEntry.createdAt, ascending: false)],
        animation: .default)
    private var entries: FetchedResults<JournalEntry>
    
    @State private var selection: UUID?
    
    public init() {}
    
    public var body: some View {
        NavigationSplitView {
            List(entries, selection: $selection) { entry in
                NavigationLink(value: entry.id) {
                    VStack(alignment: .leading) {
                        Text(entry.title)
                            .font(.headline)
                        Text(entry.createdAt.formatted(date: .abbreviated, time: .shortened))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Journal")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: addEntry) {
                        Label("New Note", systemImage: "square.and.pencil")
                    }
                }
            }
        } detail: {
            if let selection = selection, let entry = entries.first(where: { $0.id == selection }) {
                JournalEditorView(entry: entry)
            } else {
                ContentUnavailableView("Select a Note", systemImage: "note.text", description: Text("Select an entry to view or edit."))
            }
        }
    }
    
    private func addEntry() {
        withAnimation {
            let entry = JournalEntry(context: viewContext)
            entry.id = UUID()
            entry.title = "New Note"
            entry.content = ""
            entry.createdAt = Date()
            
            try? viewContext.save()
            selection = entry.id
        }
    }
}

struct JournalEditorView: View {
    @ObservedObject var entry: JournalEntry
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(spacing: 0) {
            TextField("Title", text: Binding(get: { entry.title }, set: { entry.title = $0 }))
                .font(.title)
                .padding()
                .background(Color(NSColor.controlBackgroundColor))
            
            Divider()
            
            TextEditor(text: Binding(get: { entry.content ?? "" }, set: {
                entry.content = $0
            }))
            .font(.body)
            .padding()
            .scrollContentBackground(.hidden) // Use custom background
            .background(Color(NSColor.textBackgroundColor))
        }
        .toolbar {
            ToolbarItem {
                Button("Save") {
                    try? viewContext.save()
                }
            }
        }
        .onDisappear {
            // Auto-save on exit
            try? viewContext.save()
        }
    }
}
