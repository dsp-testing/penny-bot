import SotoDynamoDB
import Logging
import Models

struct DynamoCoinEntryRepository {
    let db: DynamoDB
    let eventLoop: any EventLoop
    let logger: Logger

    let tableName = "penny-coin-table"
    let toUserIDIndex = "TU-ID-GSI"
    let fromUserIDIndex = "FU-ID-GSI"

    init(db: DynamoDB, logger: Logger) {
        self.db = db
        self.eventLoop = db.eventLoopGroup.any()
        self.logger = logger
    }

    func createCoinEntry(_ entry: CoinEntry) async throws {
        let input = DynamoDB.PutItemCodableInput(item: entry, tableName: self.tableName)

        _ = try await db.putItem(input, logger: self.logger, on: self.eventLoop)
    }
}
