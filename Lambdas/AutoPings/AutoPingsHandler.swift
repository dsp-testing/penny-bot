import AWSLambdaRuntime
import AWSLambdaEvents
import Foundation
import SotoCore
import Models
import Extensions

@main
struct AutoPingsHandler: LambdaHandler {
    typealias Event = APIGatewayV2Request
    typealias Output = APIGatewayV2Response
    
    let awsClient: AWSClient
    let pingsRepo: S3AutoPingsRepository

    init(context: LambdaInitializationContext) async {
        let awsClient = AWSClient(
            httpClientProvider: .createNewWithEventLoopGroup(context.eventLoop)
        )
        self.awsClient = awsClient
        self.pingsRepo = S3AutoPingsRepository(awsClient: awsClient, logger: context.logger)
    }
    
    func handle(
        _ event: APIGatewayV2Request,
        context: LambdaContext
    ) async -> APIGatewayV2Response {
        let newItems: S3AutoPingItems
        if event.rawPath.hasSuffix("all") {
            do {
                newItems = try await pingsRepo.getAll()
            } catch {
                return APIGatewayV2Response(
                    status: .expectationFailed,
                    content: GatewayFailure(
                        reason: "Error when getting the full list: \(error)"
                    )
                )
            }
        } else if event.rawPath.hasSuffix("users") {
            switch event.context.http.method {
            case .PUT:
                do {
                    let request = try event.decode(as: AutoPingsRequest.self)
                    newItems = try await pingsRepo.insert(
                        expressions: request.expressions,
                        forDiscordID: request.discordID
                    )
                } catch {
                    return APIGatewayV2Response(
                        status: .expectationFailed,
                        content: GatewayFailure(
                            reason: "Error when adding texts for user: \(error)"
                        )
                    )
                }
            case .DELETE:
                do {
                    let request = try event.decode(as: AutoPingsRequest.self)
                    newItems = try await pingsRepo.remove(
                        expressions: request.expressions,
                        forDiscordID: request.discordID
                    )
                } catch {
                    return APIGatewayV2Response(
                        status: .expectationFailed,
                        content: GatewayFailure(
                            reason: "Error when removing texts for user: \(error)"
                        )
                    )
                }
            default:
                return APIGatewayV2Response(
                    status: .badRequest,
                    content: GatewayFailure(
                        reason: "Unexpected method: \(event.context.http.method)"
                    )
                )
            }
        } else {
            return APIGatewayV2Response(
                status: .badRequest,
                content: GatewayFailure(
                    reason: "Unexpected path parameter: \(event.context.http.path)"
                )
            )
        }
        
        return APIGatewayV2Response(status: .ok, content: newItems)
    }
}
