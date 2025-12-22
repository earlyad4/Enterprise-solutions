import SwiftUI
import WebKit

public struct AIWorkspaceView: View {
    @State private var urlString: String = "https://gemini.google.com" // Default to an AI provider
    
    public init() {}
    
    public var body: some View {
        VStack {
            HStack {
                TextField("URL", text: $urlString)
                    .textFieldStyle(.roundedBorder)
                Button("Go") {
                    // Trigger reload logic if needed
                }
            }
            .padding(8)
            .background(Color(NSColor.controlBackgroundColor))
            
            WebView(urlString: urlString)
        }
        .navigationTitle("AI Workspace")
    }
}

struct WebView: NSViewRepresentable {
    let urlString: String
    
    func makeNSView(context: Context) -> WKWebView {
        return WKWebView()
    }
    
    func updateNSView(_ nsView: WKWebView, context: Context) {
        if let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            nsView.load(request)
        }
    }
}
