@testable import Penny
import Models

public struct FakeCoinService: CoinService {
    
    public init() { }
    
    public func postCoin(with coinRequest: CoinRequest.AddCoin) async throws -> CoinResponse {
        CoinResponse(
            sender: coinRequest.from,
            receiver: coinRequest.receiver,
            coins: coinRequest.amount + .random(in: 0..<10_000)
        )
    }
    
    public func getCoinCount(of user: String) async throws -> Int {
        2591
    }

    public func getGitHubID(of user: String) async throws -> GitHubUserResponse {
        .userName("fake-username")
    }
}
