import SwiftUI
import CoreData
import NexusCore
import NexusUI

public struct CRMView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    // We need to verify if the Entity name matches what we put in Persistence.swift
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Customer.name, ascending: true)],
        animation: .default)
    private var customers: FetchedResults<Customer>
    
    @State private var selection: UUID?

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
                    Button(action: addCustomer) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
        } detail: {
            if let selection = selection, let customer = customers.first(where: { $0.id == selection }) {
                 CustomerDetailView(customer: customer)
            } else {
                Text("Select a customer")
                    .font(.title)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func addCustomer() {
        withAnimation {
            let newCustomer = Customer(context: viewContext)
            newCustomer.id = UUID()
            newCustomer.name = "New Customer \(Date().timeIntervalSince1970)"
            newCustomer.email = "test@example.com"

            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                print("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

struct CustomerDetailView: View {
    let customer: Customer
    
    // We would need the context to save changes to stage/contracts
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
                        Button(action: addContract) {
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
    
    private func addContract() {
        withAnimation {
            let newContract = Contract(context: viewContext)
            newContract.id = UUID()
            newContract.title = "New Agreement"
            newContract.value = 10000.0
            newContract.startDate = Date()
            newContract.endDate = Date().addingTimeInterval(365*24*60*60)
            newContract.status = "Draft"
            newContract.customer = customer
            
            // Auto update LTV
            customer.lifetimeValue += newContract.value
            
            try? viewContext.save()
        }
    }
}
