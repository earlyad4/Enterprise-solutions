import SwiftUI
import CoreData
import NexusCore
import NexusUI

public struct CRMView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Customer.name, ascending: true)],
        animation: .default)
    private var customers: FetchedResults<Customer>
    
    @State private var selection: UUID?
    @State private var showingAddCustomer = false
    @State private var showingAddContract = false
    
    public init() {}
    
    public var body: some View {
        NavigationSplitView {
            List(customers, selection: $selection) { customer in
                NavigationLink(value: customer.id) {
                    Text(customer.name)
                }
            }
            .navigationTitle("Customers")
            .toolbar {
                ToolbarItem {
                    Button(action: { showingAddCustomer = true }) {
                        Label("Add Customer", systemImage: "plus")
                    }
                }
            }
        } detail: {
            if let selection = selection, let customer = customers.first(where: { $0.id == selection }) {
                 CustomerDetailView(customer: customer, showingAddContract: $showingAddContract)
            } else {
                Text("Select a customer")
                    .font(.title)
                    .foregroundStyle(.secondary)
            }
        }
        .sheet(isPresented: $showingAddCustomer) {
            AddCustomerSheet()
        }
        .sheet(isPresented: $showingAddContract) {
            if let selection = selection, let customer = customers.first(where: { $0.id == selection }) {
                AddContractSheet(customer: customer)
            }
        }
    }
}

struct CustomerDetailView: View {
    let customer: Customer
    @Binding var showingAddContract: Bool
    @Environment(\.managedObjectContext) private var viewContext

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                HStack {
                    VStack(alignment: .leading) {
                        Text(customer.name)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        if let email = customer.email {
                            Text(email)
                                .font(.title3)
                                .foregroundStyle(.secondary)
                        }
                    }
                    Spacer()
                    NexusCard {
                        VStack {
                            Text("LTV")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(customer.lifetimeValue.formatted(.currency(code: "USD")))
                                .font(.title2)
                                .fontWeight(.bold)
                        }
                    }
                }
                
                Divider()
                
                // key Info
                NexusCard {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Lifecycle Stage")
                            .font(.headline)
                        Picker("Stage", selection: Binding(get: { customer.lifecycleStage }, set: { newValue in
                            customer.lifecycleStage = newValue
                            try? viewContext.save()
                        })) {
                            Text("Lead").tag("Lead")
                            Text("Prospect").tag("Prospect")
                            Text("Customer").tag("Customer")
                            Text("Churned").tag("Churned")
                        }
                        .pickerStyle(.segmented)
                    }
                    .padding()
                }
                
                // Contracts Section
                VStack(alignment: .leading) {
                    HStack {
                        Text("Contracts")
                            .font(.headline)
                        Spacer()
                        Button(action: { showingAddContract = true }) {
                            Label("Add Contract", systemImage: "plus")
                        }
                    }
                    
                    if let contracts = customer.contracts as? Set<Contract>, !contracts.isEmpty {
                        ForEach(Array(contracts).sorted(by: { $0.startDate > $1.startDate })) { contract in
                            NexusCard {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(contract.title)
                                            .font(.headline)
                                        Text(contract.status)
                                            .font(.caption)
                                            .padding(4)
                                            .background(contract.status == "Active" ? Color.green.opacity(0.2) : Color.gray.opacity(0.2))
                                            .cornerRadius(4)
                                    }
                                    Spacer()
                                    VStack(alignment: .trailing) {
                                        Text(contract.value.formatted(.currency(code: "USD")))
                                            .fontWeight(.bold)
                                        Text(contract.startDate.formatted(date: .abbreviated, time: .omitted))
                                            .font(.caption)
                                    }
                                }
                                .padding()
                            }
                        }
                    } else {
                        Text("No contracts found.")
                            .foregroundStyle(.secondary)
                            .padding()
                    }
                }
            }
            .padding()
        }
    }
}

struct AddCustomerSheet: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var stage: String = "Lead"
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Name", text: $name)
                TextField("Email", text: $email)
                Picker("Stage", selection: $stage) {
                    Text("Lead").tag("Lead")
                    Text("Prospect").tag("Prospect")
                    Text("Customer").tag("Customer")
                }
            }
            .navigationTitle("New Customer")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        addCustomer()
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
            .frame(minWidth: 300, minHeight: 200)
        }
    }
    
    private func addCustomer() {
        let newCustomer = Customer(context: viewContext)
        newCustomer.id = UUID()
        newCustomer.name = name
        newCustomer.email = email
        newCustomer.lifecycleStage = stage
        newCustomer.lifetimeValue = 0
        
        try? viewContext.save()
    }
}

struct AddContractSheet: View {
    let customer: Customer
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var title: String = "New Contract"
    @State private var value: Double = 0.0
    @State private var status: String = "Draft"
    @State private var startDate = Date()
    @State private var endDate = Date().addingTimeInterval(365*24*60*60)
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Title", text: $title)
                TextField("Value", value: $value, format: .currency(code: "USD"))
                Picker("Status", selection: $status) {
                    Text("Draft").tag("Draft")
                    Text("Active").tag("Active")
                    Text("Expired").tag("Expired")
                }
                DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                DatePicker("End Date", selection: $endDate, displayedComponents: .date)
            }
            .navigationTitle("New Contract")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        addContract()
                        dismiss()
                    }
                }
            }
            .frame(minWidth: 300, minHeight: 300)
        }
    }
    
    private func addContract() {
        let newContract = Contract(context: viewContext)
        newContract.id = UUID()
        newContract.title = title
        newContract.value = value
        newContract.startDate = startDate
        newContract.endDate = endDate
        newContract.status = status
        newContract.customer = customer
        
        // Update Customer LTV if active
        if status == "Active" {
            customer.lifetimeValue += value
        }
        
        try? viewContext.save()
    }
}
