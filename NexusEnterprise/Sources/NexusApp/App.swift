import SwiftUI
import NexusCore
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
    
    var body: some Scene {
        WindowGroup {
            MainWindow()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
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
    
    @State private var selection: NavigationItem? = .dashboard
    
    var body: some View {
        NavigationSplitView {
            List(NavigationItem.allCases, selection: $selection) { item in
                NavigationLink(value: item) {
                    Label(item.rawValue, systemImage: item.icon)
                }
            }
            .navigationTitle("Nexus")
            .listStyle(.sidebar)
        } detail: {
            switch selection {
            case .dashboard:
                Text("Dashboard Widget Area")
                    .font(.largeTitle)
            case .crm:
                CRMView()
            case .finance:
                FinanceDashboardView()
            case .communication:
                CommunicationView()
            case .ai:
                AIWorkspaceView()
            case .marketing:
                MarketingView()
            case .rnd:
                RNDView()
            case .manufacturing:
                ManufacturingView()
            case .journal:
                JournalView()
            case .none:
                Text("Select a module")
            }
        }
        #if os(macOS)
        .frame(minWidth: 900, minHeight: 600)
        #endif
    }
}
