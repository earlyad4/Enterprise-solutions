import Foundation
import Security

public enum NexusSecurityError: Error {
    case duplicateEntry
    case unknown(OSStatus)
    case itemNotFound
}

public class SecurityManager {
    public static let shared = SecurityManager()
    
    public init() {}
    
    /// Storing a generic secret (e.g., API Key, Password)
    public func save(key: String, data: Data) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        guard status != errSecDuplicateItem else {
            throw NexusSecurityError.duplicateEntry
        }
        
        guard status == errSecSuccess else {
            throw NexusSecurityError.unknown(status)
        }
    }
    
    public func read(key: String) throws -> Data {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        
        guard status == errSecSuccess, let data = dataTypeRef as? Data else {
            if status == errSecItemNotFound {
                throw NexusSecurityError.itemNotFound
            }
            throw NexusSecurityError.unknown(status)
        }
        
        return data
    }
    
    public func delete(key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        
        guard status == errSecSuccess || status == errSecItemNotFound else {
             throw NexusSecurityError.unknown(status)
        }
    }
}
