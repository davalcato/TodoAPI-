//
//  File.swift
//  
//
//  Created by Daval Cato on 10/16/21.
//

import Foundation

struct Todo: Codable {
    
    let id: String
    let name: String
    let isCompleted: Bool
    var dueDate: Date?
    var createdAt: Date?
    var updatedAt: Date?
    
    struct DynamoDBField {
        static let id = "id"
        static let name = "name"
        static let isCompleted = "isCompleted"
        static let dueDate = "dueDate"
        static let createdAt = "createdAt"
        static let updatedAt = "updatedAt"
    }
    
    
}



