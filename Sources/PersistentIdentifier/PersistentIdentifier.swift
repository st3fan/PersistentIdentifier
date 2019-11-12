/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/. */


import Foundation
import Security


// Based on https://github.com/objcio/keychain-item

final public class PersistentIdentifier {
    static let `default` = PersistentIdentifier()

    public enum KeychainError: Error {
        case keychainError(status: OSStatus)
    }
    
    private let name: String;
    
    init(name: String = "persistentIdentifier") {
        self.name = name
    }
    
    func initialize() throws {
        if try get() == nil {
            try add(name: self.name, value: generateIdentifier())
        }
    }
    
    func reset() throws {
        try set(identifier: generateIdentifier())
    }
    
    func delete() throws {
        let item: [String:AnyObject] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: name as AnyObject
        ]
        
        let status = SecItemDelete(item as CFDictionary)
        if status != noErr && status != errSecItemNotFound {
            throw KeychainError.keychainError(status: status)
        }
    }
    
    func get() throws -> String? {
        let query: [String:AnyObject] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: name as AnyObject,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecReturnData as String: true as AnyObject
        ]
        
        var result: AnyObject? = nil
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        if status == errSecItemNotFound {
            return nil
        }
        
        if status != noErr {
            throw KeychainError.keychainError(status: status)
        }
        
        guard let data = result as? Data, let identifier = String(data: data, encoding: .utf8) else {
            return nil
        }
        
        return identifier
    }
    
    private func add(name: String, value: String) throws {
        let attributes: [String:AnyObject] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: name as AnyObject,
            kSecValueData as String: value.data(using: .utf8)! as AnyObject,
        ]
        
        let status = SecItemAdd(attributes as CFDictionary, nil)
        if status != noErr {
            throw KeychainError.keychainError(status: status)
        }
    }
    
    private func update(name: String, value: String) throws {
    }
    
    private func set(identifier: String) throws {
        if try get() == nil {
            try add(name: self.name, value: identifier)
        } else {
            try update(name: self.name, value: identifier)
        }
    }
    
    private func generateIdentifier() -> String {
        return UUID().uuidString
    }
}

