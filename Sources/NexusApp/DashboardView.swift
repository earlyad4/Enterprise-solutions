import SwiftUI
import NexusUI

struct DashboardView: View {
    @Binding var navigationSelection: MainWindow.NavigationItem?
    
    // We'll use a simple local array for now. ideally this should be persisted.
    @State private var widgets: [DashboardWidget] = []
    @State private var showingAddWidget = false
    
    let columns = [
        GridItem(.adaptive(minimum: 150), spacing: 20)
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 20) {
                // Add Widget Button (Always first or accessible via toolbar, here we put it as a card for visibility too)
                Button(action: { showingAddWidget = true }) {
                    NexusCard {
                        VStack {
                            Image(systemName: "plus")
                                .font(.largeTitle)
                            Text("Add Widget")
                                .font(.headline)
                        }
                        .frame(minWidth: 120, minHeight: 120)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
                .buttonStyle(.plain)
                
                ForEach(widgets) { widget in
                    WidgetCard(widget: widget) {
                        handleWidgetAction(widget)
                    }
                }
            }
            .padding()
        }
        .sheet(isPresented: $showingAddWidget) {
            AddWidgetView(widgets: $widgets)
        }
        .navigationTitle("Dashboard")
    }
    
    private func handleWidgetAction(_ widget: DashboardWidget) {
        if case .shortcut(let item) = widget.type {
            navigationSelection = item
        }
    }
}

struct WidgetCard: View {
    let widget: DashboardWidget
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            NexusCard {
                VStack(alignment: .leading) {
                    HStack {
                        Image(systemName: widget.icon)
                        Spacer()
                    }
                    .font(.title2)
                    .padding(.bottom, 4)
                    
                    Text(widget.title)
                        .font(.headline)
                    
                    if let content = widget.content {
                        Text(content)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(3)
                    }
                }
                .frame(minWidth: 120, minHeight: 120)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .buttonStyle(.plain)
    }
}

struct AddWidgetView: View {
    @Binding var widgets: [DashboardWidget]
    @Environment(\.dismiss) private var dismiss
    
    @State private var title: String = ""
    @State private var type: WidgetType = .shortcut
    @State private var shortcutSelection: MainWindow.NavigationItem = .crm
    @State private var noteContent: String = ""
    
    enum WidgetType: String, CaseIterable, Identifiable {
        case shortcut = "Shortcut"
        case note = "Custom Note"
        var id: String { rawValue }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Picker("Type", selection: $type) {
                    ForEach(WidgetType.allCases) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                
                TextField("Title", text: $title)
                
                if type == .shortcut {
                    Picker("Destination", selection: $shortcutSelection) {
                        ForEach(MainWindow.NavigationItem.allCases) { item in
                            if item != .dashboard {
                                Text(item.rawValue).tag(item)
                            }
                        }
                    }
                } else {
                    TextField("Content", text: $noteContent) // TextEditor would be better but TextField is simpler for now
                }
            }
            .navigationTitle("New Widget")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        addWidget()
                        dismiss()
                    }
                    .disabled(title.isEmpty)
                }
            }
            .frame(minWidth: 300, minHeight: 200)
        }
    }
    
    private func addWidget() {
        let newWidget: DashboardWidget
        if type == .shortcut {
            newWidget = DashboardWidget(
                type: .shortcut(shortcutSelection),
                title: title,
                icon: shortcutSelection.icon,
                content: "Go to \(shortcutSelection.rawValue)"
            )
        } else {
            newWidget = DashboardWidget(
                type: .custom,
                title: title,
                icon: "note.text",
                content: noteContent
            )
        }
        widgets.append(newWidget)
    }
}

struct DashboardWidget: Identifiable {
    let id = UUID()
    let type: WidgetVariant
    let title: String
    let icon: String
    let content: String?
    
    enum WidgetVariant {
        case shortcut(MainWindow.NavigationItem)
        case custom
    }
}
