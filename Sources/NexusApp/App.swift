import SwiftUI
import CoreData
import NexusCore
import NexusUI
import FeatureCRM
import FeatureFinance
import FeatureCommunication
import FeatureAI
import FeatureMarketing
import FeatureRND
import FeatureManufacturing
import FeatureJournal

@main
struct NexusApp: App {
    let persistenceController = PersistenceController.shared
    @StateObject private var themeManager = ThemeManager.shared
    
    var body: some Scene {
        WindowGroup {
            MainWindow()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(themeManager)
                .tint(themeManager.currentTheme.primaryColor)
        }
    }
}

struct MainWindow: View {
    enum NavigationItem: String, CaseIterable, Identifiable {
        case dashboard = "Dashboard"
        case crm = "CRM"
        case finance = "Finance"
        case communication = "Comm Hub"
        case ai = "AI Workspace"
        case marketing = "Marketing"
        case rnd = "R&D"
        case manufacturing = "Manufacturing"
        case journal = "Journal"
        
        var id: String { self.rawValue }
        var icon: String {
            switch self {
            case .dashboard: return "square.grid.2x2"
            case .crm: return "person.2"
            case .finance: return "banknote"
            case .communication: return "envelope"
            case .ai: return "brain"
            case .marketing: return "megaphone"
            case .rnd: return "hammer"
            case .manufacturing: return "gearshape.2"
            case .journal: return "book"
            }
        }
    }
    
    // Selection can be a standard item OR a custom UUID string
    @State private var selection: String? = NavigationItem.dashboard.id
    @AppStorage("activeModules") private var activeModuleRawValue: String = ""
    @State private var showingAddModule = false
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var themeManager: ThemeManager
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \CustomDepartment.createdAt, ascending: true)],
        animation: .default)
    private var customDepartments: FetchedResults<CustomDepartment>
    
    var activeStandardModules: [NavigationItem] {
        let saved = activeModuleRawValue.split(separator: ",").map { String($0) }
        return NavigationItem.allCases.filter { item in
             saved.contains(item.rawValue)
        }
    }
    
    var availableStandardToAdd: [NavigationItem] {
         let saved = activeModuleRawValue.split(separator: ",").map { String($0) }
         return NavigationItem.allCases.filter { item in
             item != .dashboard && !saved.contains(item.rawValue)
         }
    }
    
    var body: some View {
        NavigationSplitView {
            List(selection: $selection) {
                // Section 1: Dashboard
                NavigationLink(value: NavigationItem.dashboard.id) {
                    Label(NavigationItem.dashboard.rawValue, systemImage: NavigationItem.dashboard.icon)
                }
                
                // Section 2: Active Standard
                Section("Departments") {
                    ForEach(activeStandardModules) { item in
                        NavigationLink(value: item.id) {
                            Label(item.rawValue, systemImage: item.icon)
                        }
                    }
                }
                
                // Section 3: Custom
                if !customDepartments.isEmpty {
                    Section("Custom") {
                        ForEach(customDepartments) { dept in
                            NavigationLink(value: dept.id.uuidString) {
                                Label(dept.name, systemImage: dept.iconName)
                            }
                        }
                    }
                }
                
                // Footer: Add Button
                Button(action: { showingAddModule = true }) {
                    Label("Add Department", systemImage: "plus")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                .padding(.top, 10)
            }
            .navigationTitle("Nexus")
            .listStyle(.sidebar)
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    HStack {
                         // User Profile Icon
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundStyle(themeManager.currentTheme.primaryColor)
                            .contextMenu {
                                Text("User Settings")
                                Divider()
                                Menu("Themes") {
                                    ForEach(AppTheme.allCases) { theme in
                                        Button(action: { themeManager.currentTheme = theme }) {
                                            if themeManager.currentTheme == theme {
                                                Label(theme.rawValue, systemImage: "checkmark")
                                            } else {
                                                Text(theme.rawValue)
                                            }
                                        }
                                    }
                                }
                            }
                        Spacer()
                    }
                }
            }
        } detail: {
            if let sel = selection {
                if let item = NavigationItem(rawValue: sel) {
                    // Standard Module
                    switch item {
                    case .dashboard:
                        // Dashboard accepts Binding<NavigationItem?>, we need to adapt it or fix DashboardView
                        // For now, let's just pass a dummy binding or fix DashboardView separate.
                        // Let's assume we fix DashboardView to take String? binding or just ignore navigation for now.
                        DashboardViewWrapper() // Wrapper to handle type mismatch if needed
                    case .crm: CRMView()
                    case .finance: FinanceDashboardView()
                    case .communication: CommunicationView()
                    case .ai: AIWorkspaceView()
                    case .marketing: MarketingView()
                    case .rnd: RNDView()
                    case .manufacturing: ManufacturingView()
                    case .journal: JournalView()
                    }
                } else if let uuid = UUID(uuidString: sel), let dept = customDepartments.first(where: { $0.id == uuid }) {
                    // Custom Module
                    GenericDepartmentView(name: dept.name)
                } else {
                     ContentUnavailableView("Not Found", systemImage: "exclamationmark.triangle")
                }
            } else {
                Text("Select a department")
            }
        }
        .sheet(isPresented: $showingAddModule) {
            AddDepartmentSheet(availableStandard: availableStandardToAdd) { item in
                addStandardModule(item)
            }
        }
        #if os(macOS)
        .frame(minWidth: 900, minHeight: 600)
        #endif
    }
    
    private func addStandardModule(_ module: NavigationItem) {
        var current = activeModuleRawValue.split(separator: ",").map { String($0) }
        if !current.contains(module.rawValue) {
            current.append(module.rawValue)
            activeModuleRawValue = current.joined(separator: ",")
        }
    }
}

// Helper for Dashboard type mismatch fix (DashboardView expects Binding<NavigationItem?>)
// We will create a simple wrapper or just Instantiate DashboardView with constant for now to avoid breaking changes there.
struct DashboardViewWrapper: View {
    @State private var ignoredSelection: MainWindow.NavigationItem? = .dashboard
    var body: some View {
        DashboardView(navigationSelection: $ignoredSelection)
    }
}

struct AddDepartmentSheet: View {
    let availableStandard: [MainWindow.NavigationItem]
    let onAddStandard: (MainWindow.NavigationItem) -> Void
    
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab = 0
    
    // Custom Dept Form
    @State private var customName = ""
    @State private var customIcon = "folder"
    let icons = ["folder", "briefcase", "tray", "archivebox", "doc.text", "calendar", "chart.bar", "building.2"]
    
    var body: some View {
        NavigationStack {
            VStack {
                Picker("Type", selection: $selectedTab) {
                    Text("Standard Modules").tag(0)
                    Text("Create Custom").tag(1)
                }
                .pickerStyle(.segmented)
                .padding()
                
                if selectedTab == 0 {
                    List(availableStandard) { module in
                        Button(action: {
                            onAddStandard(module)
                            dismiss()
                        }) {
                            HStack {
                                Label(module.rawValue, systemImage: module.icon)
                                Spacer()
                                Image(systemName: "plus.circle")
                            }
                        }
                        .buttonStyle(.plain)
                    }
                } else {
                    Form {
                        TextField("Department Name", text: $customName)
                        Picker("Icon", selection: $customIcon) {
                            ForEach(icons, id: \.self) { icon in
                                Label(icon, systemImage: icon).tag(icon)
                            }
                        }
                    }
                    .padding()
                    
                    Button("Create Department") {
                        addCustomDepartment()
                        dismiss()
                    }
                    .disabled(customName.isEmpty)
                    .buttonStyle(.borderedProminent)
                    .padding()
                }
                
                Spacer()
            }
            .navigationTitle("Add Department")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
            .frame(minWidth: 350, minHeight: 400)
        }
    }
    
    private func addCustomDepartment() {
        let newDept = CustomDepartment(context: viewContext)
        newDept.id = UUID()
        newDept.name = customName
        newDept.iconName = customIcon
        newDept.createdAt = Date()
        
        try? viewContext.save()
    }
}
