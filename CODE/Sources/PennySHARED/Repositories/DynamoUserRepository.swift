import Foundation
import SotoDynamoDB
import PennyModels
import PennyExtensions

public enum DBError: Error {
    case invalidItem
    case tableNameNotFound
    case invalidRequest
    case invalidHandler
    case itemNotFound
}

public struct DynamoUserRepository: UserRepository {
    
    // MARK: - Properties
    let db: DynamoDB
    let tableName: String
    let eventLoop: EventLoop
    let logger: Logger
    
    let discordIndex = "GSI-1"
    let githubIndex = "GSI-2"
    
    public init(db: DynamoDB, tableName: String, eventLoop: EventLoop, logger: Logger) {
        self.db = db
        self.tableName = tableName
        self.eventLoop = eventLoop
        self.logger = logger
    }
    
    // MARK: - Insert & Update
    public func insertUser(_ user: DynamoDBUser) async throws -> Void {
        let input = DynamoDB.PutItemCodableInput(item: user, tableName: self.tableName)
        
        _ = try await db.putItem(input, logger: self.logger, on: self.eventLoop)
    }
    
    public func updateUser(_ user: DynamoDBUser) async throws -> Void {
        let input = DynamoDB.UpdateItemCodableInput(key: ["pk", "sk"], tableName: self.tableName, updateItem: user)
        
        _ = try await db.updateItem(input, logger: self.logger, on: self.eventLoop)
    }
    
    // MARK: - Retrieve
    public func getUser(discord id: String) async throws -> User {
        let query = DynamoDB.QueryInput(
            expressionAttributeValues: [":v1": .s("DISCORD-\(id)")],
            indexName: discordIndex,
            keyConditionExpression: "data1 = :v1",
            limit: 1,
            tableName: self.tableName
        )
        
        return try await queryUser(with: query)
    }
    
    public func getUser(github id: String) async throws -> User {
        let query = DynamoDB.QueryInput(
            expressionAttributeValues: [":v1": .s("GITHUB-\(id)")],
            indexName: githubIndex,
            keyConditionExpression: "data2 = :v1",
            limit: 1,
            tableName: self.tableName
        )
        
        return try await queryUser(with: query)
    }
    
    private func queryUser(with query: DynamoDB.QueryInput) async throws -> User {
        let results = try await db.query(query, type: DynamoDBUser.self, logger: self.logger, on: self.eventLoop)
        guard let user = results.items?.first else {
            throw DBError.itemNotFound
        }
                        
        let localUser = User(
            id: UUID(uuidString: user.pk.deletePrefix("USER-"))!,
            discordID: user.data1?.deletePrefix("DISCORD-"),
            githubID: user.data2?.deletePrefix("GITHUB-"),
            numberOfCoins: user.amountOfCoins ?? 0,
            coinEntries: user.coinEntries ?? [],
            createdAt: user.createdAt
        )
        
        return localUser
    }
    
    // MARK: - Link users
    public func linkGithub(with discordId: String, _ githubId: String) async throws -> String {
        // TODO: Implement
        // Check if the users github already exists
        
        // If it exists, merge the 2 accounts
        
        // If the the given discordId already has a github account linked, overwrite the githubId
        
        // Delete the account that's not up-to-date
        abort()
    }
    
    public func linkDiscord(with githubId: String, _ discordId: String) async throws -> String {
        // TODO: Implement
        // Check if the users discord already exists
        
        // If it exists, merge the 2 accounts
        
        // If the the given discordId already has a github account linked, overwrite the githubId
        
        // Delete the account that's not up-to-date
        abort()
    }
    
    private func mergeAccounts() async throws -> Bool {
        // TODO: Implement
        // Return true if the merge was successful
        abort()
    }
    
    private func deleteAccount() async throws -> Bool {
        // TODO: Implement
        // Return true if the deletion was successful
        abort()
    }
}