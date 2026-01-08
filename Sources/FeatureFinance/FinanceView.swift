import SwiftUI
import CoreData
import NexusCore
import NexusUI
import UniformTypeIdentifiers

public struct FinanceDashboardView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Invoice.issueDate, ascending: false)],
        animation: .default)
    private var invoices: FetchedResults<Invoice>
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \LedgerEntry.entryDate, ascending: false)],
        animation: .default)
    private var ledgerEntries: FetchedResults<LedgerEntry>
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Document.ingestedAt, ascending: false)],
        predicate: NSPredicate(format: "department == %@", "Finance"),
        animation: .default)
    private var statements: FetchedResults<Document>

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Customer.name, ascending: true)],
        animation: .default)
    private var customers: FetchedResults<Customer>

    @State private var selectedTab: String = "Invoices"
    @State private var showingFileImporter = false
    @State private var showingAddInvoice = false
    @State private var showingAddLedger = false

    public init() {}
    
    public var body: some View {
        VStack {
            Picker("View", selection: $selectedTab) {
                Text("Invoices").tag("Invoices")
                Text("Ledger").tag("Ledger")
                Text("Statements").tag("Statements")
            }
            .pickerStyle(.segmented)
            .padding()
            
            if selectedTab == "Invoices" {
                invoiceList
            } else if selectedTab == "Ledger" {
                ledgerList
            } else {
                statementList
            }
        }
        .navigationTitle("Finance")
        .toolbar {
            ToolbarItem {
                if selectedTab == "Invoices" {
                    Button(action: { showingAddInvoice = true }) {
                        Label("New Invoice", systemImage: "plus")
                    }
                } else if selectedTab == "Ledger" {
                     Button(action: { showingAddLedger = true }) {
                        Label("Add Entry", systemImage: "plus")
                    }
                } else {
                     Button(action: { showingFileImporter = true }) {
                        Label("Import", systemImage: "square.and.arrow.down")
                    }
                }
            }
        }
        .fileImporter(
            isPresented: $showingFileImporter,
            allowedContentTypes: [.pdf, .plainText],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                if let url = urls.first {
                    importStatement(from: url)
                }
            case .failure(let error):
                print("Import failed: \(error.localizedDescription)")
            }
        }
        .sheet(isPresented: $showingAddInvoice) {
            AddInvoiceSheet()
        }
        .sheet(isPresented: $showingAddLedger) {
            AddLedgerEntrySheet()
        }
    }
    
    var dashboardView: some View {
        ScrollView {
            FinanceFlowView(invoices: invoices, ledgerEntries: ledgerEntries)
                .padding()
        }
    }
    
    var invoiceList: some View {
        List(invoices) { invoice in
            HStack {
                VStack(alignment: .leading) {
                    Text(invoice.invoiceNumber)
                        .font(.headline)
                    Text(invoice.customer?.name ?? "Unknown Customer")
                         .font(.caption)
                         .foregroundStyle(.secondary)
                    Text(invoice.status)
                        .font(.caption)
                        .padding(4)
                        .background(invoice.status == "Paid" ? Color.green.opacity(0.2) : Color.orange.opacity(0.2))
                        .cornerRadius(4)
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text(invoice.totalAmount.formatted(.currency(code: "USD")))
                        .fontWeight(.bold)
                    Text("Due: \(invoice.dueDate.formatted(date: .numeric, time: .omitted))")
                        .font(.caption)
                }
            }
        }
    }
    
    var ledgerList: some View {
        List(ledgerEntries) { entry in
            HStack {
                Text(entry.entryDate.formatted(date: .numeric, time: .omitted))
                    .font(.caption)
                    .frame(width: 80, alignment: .leading)
                
                VStack(alignment: .leading) {
                    Text(entry.userDescription)
                        .font(.headline)
                    Text(entry.accountCode)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                if entry.debitAmount > 0 {
                    Text("DR \(entry.debitAmount.formatted(.currency(code: "USD")))")
                        .foregroundStyle(.red)
                } else {
                    Text("CR \(entry.creditAmount.formatted(.currency(code: "USD")))")
                        .foregroundStyle(.green)
                }
            }
        }
    }
    
    var statementList: some View {
        List(statements) { doc in
            VStack(alignment: .leading) {
                Text(doc.filename)
                    .font(.headline)
                Text(doc.ingestedAt.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                if let content = doc.rawContent {
                    Text("Analysis Summary:")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .padding(.top, 2)
                    Text(content)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(4)
                }
            }
        }
    }
    
    private func importStatement(from url: URL) {
        // Security-scoped access for sandboxed apps
        guard url.startAccessingSecurityScopedResource() else { return }
        defer { url.stopAccessingSecurityScopedResource() }
        
        // Parse
        let analysis = FinancialParser.parse(url)
        
        // Save
        withAnimation {
            let doc = Document(context: viewContext)
            doc.id = UUID()
            doc.filename = url.lastPathComponent
            doc.contentType = url.pathExtension
            doc.ingestedAt = Date()
            doc.department = "Finance"
            doc.rawContent = analysis.narrative 
            
            try? viewContext.save()
        }
    }
}

// MARK: - Visual Dashboard
struct FinanceFlowView: View {
    let invoices: FetchedResults<Invoice>
    let ledgerEntries: FetchedResults<LedgerEntry>
    
    var totalRevenue: Double {
        invoices.filter { $0.status == "Paid" || $0.status == "Active" }.reduce(0) { $0 + $1.totalAmount }
    }
    
    var totalExpenses: Double {
        ledgerEntries.reduce(0) { $0 + $1.debitAmount }
    }
    
    var netIncome: Double {
        totalRevenue - totalExpenses
    }
    
    var body: some View {
        VStack(spacing: 40) {
            // Header
            Text("Financial Overview")
                .font(.title)
                .bold()
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 20) {
                // Revenue Box
                FinanceBox(title: "Revenue", amount: totalRevenue, color: .green, icon: "arrow.down.left.circle.fill")
                
                // Flow Arrow
                Image(systemName: "arrow.right")
                    .font(.system(size: 40))
                    .foregroundStyle(.secondary)
                
                // Net Income Box (Central)
                FinanceBox(title: "Net Income", amount: netIncome, color: netIncome >= 0 ? .blue : .red, icon: "banknote.fill", isLarge: true)
                
                // Flow Arrow (Incoming Expense subtracted)
                Image(systemName: "arrow.left")
                    .font(.system(size: 40))
                    .foregroundStyle(.secondary)
                
                // Expense Box
                FinanceBox(title: "Expenses", amount: totalExpenses, color: .red, icon: "arrow.up.right.circle.fill")
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 15).fill(Color.gray.opacity(0.05)))
            
            // Equation Visualization
            HStack {
                Text("Calculation:")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                
                Text(totalRevenue.formatted(.currency(code: "USD")))
                    .foregroundStyle(.green)
                    .bold()
                
                Text("—")
                
                Text(totalExpenses.formatted(.currency(code: "USD")))
                    .foregroundStyle(.red)
                    .bold()
                
                Text("=")
                
                Text(netIncome.formatted(.currency(code: "USD")))
                    .foregroundStyle(netIncome >= 0 ? .blue : .red)
                    .bold()
                    .padding(4)
                    .background(netIncome >= 0 ? Color.blue.opacity(0.1) : Color.red.opacity(0.1))
                    .cornerRadius(4)
            }
            .padding()
            .background(Material.thinMaterial)
            .cornerRadius(10)
        }
    }
}

struct FinanceBox: View {
    let title: String
    let amount: Double
    let color: Color
    let icon: String
    var isLarge: Bool = false
    
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Image(systemName: icon)
                    .font(isLarge ? .title : .headline)
                Text(title)
                    .font(isLarge ? .title2 : .headline)
                    .fontWeight(.semibold)
            }
            .foregroundStyle(color)
            
            Divider()
            
            Text(amount.formatted(.currency(code: "USD")))
                .font(isLarge ? .largeTitle : .title3)
                .fontWeight(.bold)
                .foregroundStyle(.primary)
        }
        .padding()
        .frame(minWidth: isLarge ? 200 : 150, minHeight: isLarge ? 150 : 120)
        .background(color.opacity(0.1))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(color.opacity(0.3), lineWidth: 1)
        )
        .shadow(color: color.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct AddInvoiceSheet: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Customer.name, ascending: true)],
        animation: .default)
    private var customers: FetchedResults<Customer>
    
    @State private var selectedCustomer: Customer?
    @State private var amount: Double = 0.0
    @State private var dueDate = Date()
    @State private var invoiceNumber: String = "INV-"
    
    var body: some View {
        NavigationStack {
             Form {
                 Picker("Customer", selection: $selectedCustomer) {
                     Text("Select Customer").tag(Optional<Customer>.none)
                     ForEach(customers) { customer in
                         Text(customer.name).tag(Optional(customer))
                     }
                 }
                 TextField("Invoice #", text: $invoiceNumber)
                 TextField("Amount", value: $amount, format: .currency(code: "USD"))
                 DatePicker("Due Date", selection: $dueDate, displayedComponents: .date)
             }
             .navigationTitle("New Invoice")
             .toolbar {
                 ToolbarItem(placement: .cancellationAction) {
                     Button("Cancel") { dismiss() }
                 }
                 ToolbarItem(placement: .confirmationAction) {
                     Button("Create") {
                         addInvoice()
                         dismiss()
                     }
                     .disabled(selectedCustomer == nil || amount <= 0)
                 }
             }
         }
         .onAppear {
             invoiceNumber = "INV-\(Int.random(in: 10000...99999))"
         }
    }
    
    private func addInvoice() {
        guard let customer = selectedCustomer else { return }
        
        let inv = Invoice(context: viewContext)
        inv.id = UUID()
        inv.invoiceNumber = invoiceNumber
        inv.issueDate = Date()
        inv.dueDate = dueDate
        inv.totalAmount = amount
        inv.status = "Draft"
        inv.customer = customer
        
        try? viewContext.save()
    }
}

struct AddLedgerEntrySheet: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var description: String = ""
    @State private var accountCode: String = "1000-GEN"
    @State private var type: String = "Debit"
    @State private var amount: Double = 0.0
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Description", text: $description)
                TextField("Account Code", text: $accountCode)
                Picker("Type", selection: $type) {
                    Text("Debit").tag("Debit")
                    Text("Credit").tag("Credit")
                }
                .pickerStyle(.segmented)
                TextField("Amount", value: $amount, format: .currency(code: "USD"))
            }
            .navigationTitle("New Ledger Entry")
             .toolbar {
                 ToolbarItem(placement: .cancellationAction) {
                     Button("Cancel") { dismiss() }
                 }
                 ToolbarItem(placement: .confirmationAction) {
                     Button("Add") {
                         addEntry()
                         dismiss()
                     }
                 }
             }
        }
    }
    
    private func addEntry() {
        let entry = LedgerEntry(context: viewContext)
        entry.id = UUID()
        entry.entryDate = Date()
        entry.userDescription = description
        entry.accountCode = accountCode
        if type == "Debit" {
            entry.debitAmount = amount
            entry.creditAmount = 0
        } else {
            entry.creditAmount = amount
            entry.debitAmount = 0
        }
        
        try? viewContext.save()
    }
}
