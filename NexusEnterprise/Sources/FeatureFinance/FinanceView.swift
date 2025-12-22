import SwiftUI
import CoreData
import NexusCore
import NexusUI

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

    @State private var selectedTab: String = "Invoices"

    public init() {}
    
    public var body: some View {
        VStack {
            Picker("View", selection: $selectedTab) {
                Text("Invoices").tag("Invoices")
                Text("Ledger").tag("Ledger")
            }
            .pickerStyle(.segmented)
            .padding()
            
            if selectedTab == "Invoices" {
                invoiceList
            } else {
                ledgerList
            }
        }
        .navigationTitle("Finance")
        .toolbar {
            ToolbarItem {
                if selectedTab == "Invoices" {
                    Button(action: addInvoice) {
                        Label("New Invoice", systemImage: "plus")
                    }
                } else {
                    Button(action: addLedgerEntry) {
                        Label("Add Entry", systemImage: "plus")
                    }
                }
            }
        }
    }
    
    var invoiceList: some View {
        List(invoices) { invoice in
            HStack {
                VStack(alignment: .leading) {
                    Text(invoice.invoiceNumber)
                        .font(.headline)
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
    
    private func addInvoice() {
        withAnimation {
            let inv = Invoice(context: viewContext)
            inv.id = UUID()
            inv.invoiceNumber = "INV-\(Int.random(in: 1000...9999))"
            inv.issueDate = Date()
            inv.dueDate = Date().addingTimeInterval(30*24*60*60)
            inv.totalAmount = Double.random(in: 100...5000)
            inv.status = "Draft"
            
            try? viewContext.save()
        }
    }
    
    private func addLedgerEntry() {
        withAnimation {
            let entry = LedgerEntry(context: viewContext)
            entry.id = UUID()
            entry.entryDate = Date()
            entry.userDescription = "Adjustment Entry"
            entry.accountCode = "1000-GEN"
            entry.debitAmount = 100.0
            entry.creditAmount = 0.0
            
            try? viewContext.save()
        }
    }
}
