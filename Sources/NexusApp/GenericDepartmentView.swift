import SwiftUI
import NexusUI

public struct GenericDepartmentView: View {
    let name: String
    
    public init(name: String) {
        self.name = name
    }
    
    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text(name)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                NexusCard {
                    VStack(alignment: .leading) {
                        Text("Custom Content Area")
                            .font(.headline)
                        Text("This is a custom department. You can add widgets or notes here in future updates.")
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                }
                
                Spacer()
            }
            .padding()
        }
    }
}
