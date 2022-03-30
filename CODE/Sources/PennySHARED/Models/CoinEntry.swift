import Foundation

public struct CoinEntry: Codable {
    public let id: UUID
    public let createdAt: Date
    public let amount: Int
    public let from: UUID?
    public let source: CoinEntrySource
    public let reason: CoinEntryReason
    
    public init(id: UUID, createdAt: Date, amount: Int, from: UUID?, source: CoinEntrySource, reason: CoinEntryReason) {
        self.id = id
        self.createdAt = createdAt
        self.amount = amount
        self.from = from
        self.source = source
        self.reason = reason
    }
}