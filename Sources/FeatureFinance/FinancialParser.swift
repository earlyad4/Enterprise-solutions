import Foundation
import PDFKit
import NexusCore

public struct FinancialParser {
    
    public struct AnalysisResult {
        public let rawText: String
        public let revenue: Double?
        public let expenses: Double?
        public let netIncome: Double?
        
        public var narrative: String {
            var lines = ["Analysis Complete."]
            if let r = revenue { lines.append("Revenue found: \(r.formatted(.currency(code: "USD")))") }
            if let e = expenses { lines.append("Expenses found: \(e.formatted(.currency(code: "USD")))") }
            if let n = netIncome { lines.append("Net Income found: \(n.formatted(.currency(code: "USD")))") }
            if revenue == nil && expenses == nil && netIncome == nil {
                lines.append("No specific financial data patterns identified.")
            }
            return lines.joined(separator: "\n")
        }
    }
    
    public static func parse(_ url: URL) -> AnalysisResult {
        let text = extractText(from: url)
        return analyze(text: text)
    }
    
    private static func extractText(from url: URL) -> String {
        if url.pathExtension.lowercased() == "pdf" {
            if let pdf = PDFDocument(url: url) {
                return pdf.string ?? "Unable to extract text from PDF."
            }
            return "Invalid PDF."
        } else {
            // Assume text/plain for simplicity
            do {
                return try String(contentsOf: url)
            } catch {
                return "Failed to read file: \(error.localizedDescription)"
            }
        }
    }
    
    private static func analyze(text: String) -> AnalysisResult {
        // Very basic regex scanning for demonstration
        var revenue: Double?
        var expenses: Double?
        var netIncome: Double?
        
        let lines = text.components(separatedBy: .newlines)
        for line in lines {
            let lower = line.lowercased()
            if lower.contains("revenue") || lower.contains("sales") {
                if let val = extractValue(from: line) { revenue = val }
            }
            if lower.contains("expense") || lower.contains("cost") {
                if let val = extractValue(from: line) { expenses = val }
            }
            if lower.contains("net income") || lower.contains("profit") {
                if let val = extractValue(from: line) { netIncome = val }
            }
        }
        
        return AnalysisResult(rawText: text, revenue: revenue, expenses: expenses, netIncome: netIncome)
    }
    
    private static func extractValue(from string: String) -> Double? {
        // Remove everything but digits and dots
        let pattern = "[0-9,]+"
        do {
            let regex = try NSRegularExpression(pattern: pattern)
            let nsString = string as NSString
            let results = regex.matches(in: string, range: NSRange(location: 0, length: nsString.length))
            
            // Just grab the last number found in the line, assuming it's the value
            if let match = results.last {
                let numberString = nsString.substring(with: match.range).replacingOccurrences(of: ",", with: "")
                return Double(numberString)
            }
        } catch {
            return nil
        }
        return nil
    }
}
