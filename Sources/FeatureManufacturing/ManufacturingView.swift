import SwiftUI
import NexusUI

public struct ManufacturingView: View {
    public init() {}
    
    public var body: some View {
        VStack {
            Text("Manufacturing")
                .font(.title)
            Text("Production Planning & Inventory Tracking")
                .foregroundStyle(.secondary)
            
            NexusButton("Start Production Cycle") {
                print("Production started")
            }
            .frame(width: 200)
        }
        .padding()
    }
}
