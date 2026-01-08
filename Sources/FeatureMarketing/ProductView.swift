import SwiftUI
import CoreData
import NexusCore
import NexusUI

struct ProductView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Product.name, ascending: true)],
        animation: .default)
    private var products: FetchedResults<Product>
    
    @State private var showingAddProduct = false
    
    var body: some View {
        VStack {
            if products.isEmpty {
                ContentUnavailableView("No Products", systemImage: "cube.box", description: Text("Add your products to define the 'Product' and 'Price' mix."))
            } else {
                List(products) { product in
                    VStack(alignment: .leading, spacing: 5) {
                        HStack {
                            Text(product.name)
                                .font(.headline)
                            Spacer()
                            Text(product.price.formatted(.currency(code: "USD")))
                                .font(.headline)
                                .foregroundStyle(.secondary)
                        }
                        
                        if let desc = product.productDescription, !desc.isEmpty {
                            Text(desc)
                                .font(.body)
                                .foregroundStyle(.secondary)
                        }
                        
                        if let pos = product.positioning, !pos.isEmpty {
                            HStack {
                                Image(systemName: "target")
                                Text(pos)
                            }
                            .font(.caption)
                            .padding(4)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(4)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: { showingAddProduct = true }) {
                    Label("Add Product", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddProduct) {
            AddProductSheet()
        }
    }
}

struct AddProductSheet: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String = ""
    @State private var price: Double = 99.99
    @State private var description: String = ""
    @State private var positioning: String = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Product Details") {
                    TextField("Name", text: $name)
                    TextField("Price", value: $price, format: .currency(code: "USD"))
                    TextField("Description", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section("Positioning (Analysis)") {
                    TextField("Positioning Statement", text: $positioning, axis: .vertical)
                        .lineLimit(2...4)
                }
            }
            .navigationTitle("New Product")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        addProduct()
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
    
    private func addProduct() {
        withAnimation {
            let newProduct = Product(context: viewContext)
            newProduct.id = UUID()
            newProduct.name = name
            newProduct.price = price
            newProduct.productDescription = description
            newProduct.positioning = positioning
            
            try? viewContext.save()
        }
    }
}
