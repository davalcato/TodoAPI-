//
//  File.swift
//  
//
//  Created by Daval Cato on 10/23/21.
//

import Foundation
import AWSDynamoDB

class TodoService {
    
    let db: DynamoDB
    let tableName: String
    
    init(db: DynamoDB, tabeleName: String) {
    self.db = db
    self.tableName = tableName
    }
    // Create new method
    func getAllTodos() -> EventLoopFuture<[Todo]> {
        // Passing the table name
        let input = DynamoDB.ScanInput(tableName: tableName)
        
        // Passing the input
        return db.scan(input).flatMapThrowing { (output) -> [Todo] in
            try output.items?compactMap { try Todo(dictionary: $0 )} ?? []
        }
    }
    
    func getTodo(id: String) -> EventLoopFuture<Todo> {
        let input = DynamoDB.GetItemInput(key: [Todo.DynamoDB.AttributeValue(s:id)], tableName: tableName)
        
        return db.getItem(input).flatMapThrowing { (output) -> Todo in
            if output.item == nil { throw APIError.todoNotFound }
            return try Todo(dictionary: output.item ?? [:])
        }
    }
    
    func createTodo(todo: Todo) -> EventLoopFuture<Todo> {
        var todo = todo
        let currentDate = Date()
        
        todo.createdAt = currentDate
        todo.updatedAt = currentDate
        
        let input = DynamoDB.PutItem(item: todo.dynamoDBDictionary, tableName; tableName)
        
        // invoke item method on the db passing the input
        return db.putItem(input).map { ( ) -> Todo in
            todo
        }
    }
    
    func updateTodo(todo: Todo) -> EventLoopFuture<Todo> {
        var todo = todo
        todo.updatedAt = Date()
        
        let input = DynamoDB.UpdateItemInput(
            expressionAttributeNames: [
                "#name": Todo.DynamoDBField.name,
                "#isCompleted": Todo.DynamoDBField.isCompleted,
                "#dueDate": Todo.DynamoDBField.dueDate,
                "#updatedAt": Todo.DynamoDBField.updatedAt
            ],
            expressionAttributeValues: [
                ":name": DynamoDB.AttributeValue(s: todo.name),
                ":isCompleted": DynamoDB.AttributeValue(bool: todo.isCompleted),
                ":dueDate": DynamoDB.AttributeValue(s: todo.dueDate?.iso8601 ?? ""),
                ":updateAt": DynamoDB.AttributeValue(s: todo.updatedAt?.iso8601 ?? "")
            ],
            key: [Todo.DynamoDBField.id: DynamoDB.AttributeValue(s: todo.id)],
            returnValues: DynamoDB.ReturnValue.allNew,
            tableName: tableName,
            updateExpression: "SET #name = :name, #isCompleted = :isCompleted, #dueDate = :dueDate, #updatedAt = :updatedAt"
        )
        // use update item passing the input
        return db.updateItem(input)
        
        // using flatmap to invoke the todo item
        return db.updateItem(input).flatMap { (output) in
            self.getTodo(id: todo.id)
        }
    }
    
    func deleteTodo(id: String) -> EventLoopFuture<void> {
        // passing the key and table name
        let input = DynamoDB.DeleteItemInput(key: [Todo.DynamoDBField.id: DynamoDB.AttributeValue(s: id)], tableName: tableName)
        
        // invoke the db deleteItem
        return db.deleteItem(input).map { _ in }
        
    }
    
}







