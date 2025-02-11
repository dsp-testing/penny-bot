import DiscordBM
@testable import Penny
import Atomics
import struct NIOCore.ByteBuffer
import XCTest

public actor FakeManager: GatewayManager {
    public nonisolated let client: any DiscordClient = FakeDiscordClient()
    public nonisolated let id: UInt = 0
    public nonisolated let identifyPayload: Gateway.Identify = .init(token: "", intents: [])
    var eventContinuations = [AsyncStream<Gateway.Event>.Continuation]()
    
    public init() { }
    
    public func connect() async { }

    public func requestGuildMembersChunk(payload: Gateway.RequestGuildMembers) async { }
    public func updatePresence(payload: Gateway.Identify.Presence) async { }
    public func updateVoiceState(payload: VoiceStateUpdate) async { }
    public func makeEventsStream() async -> AsyncStream<Gateway.Event> {
        AsyncStream { continuation in
            eventContinuations.append(continuation)
        }
    }
    public func makeEventsParseFailureStream() async -> AsyncStream<(any Error, ByteBuffer)> {
        AsyncStream { _ in }
    }
    public func disconnect() { }

    public func send(event: Gateway.Event) {
        for continuation in eventContinuations {
            continuation.yield(event)
        }
    }

    public func send(key: EventKey) {
        let data = TestData.for(gatewayEventKey: key.rawValue)!
        let decoder = JSONDecoder()
        let event: Gateway.Event
        do {
            event = try decoder.decode(Gateway.Event.self, from: data)
        } catch {
            fatalError("Failed to get event: '\(key)'. Error: \(error)")
        }
        for continuation in eventContinuations {
            continuation.yield(event)
        }
    }
    
    @_disfavoredOverload
    public func sendAndAwaitResponse<T>(
        key: EventKey,
        endpoint: APIEndpoint? = nil,
        as type: T.Type = T.self,
        file: StaticString = #filePath,
        line: UInt = #line
    ) async throws -> T {
        try await self.sendAndAwaitResponse(
            key: key,
            endpoint: endpoint.map { .api($0) },
            as: T.self,
            file: file,
            line: line
        )
    }
    
    public func sendAndAwaitResponse<T>(
        key: EventKey,
        endpoint: AnyEndpoint? = nil,
        as type: T.Type = T.self,
        file: StaticString = #filePath,
        line: UInt = #line
    ) async throws -> T {
        let box = await withCheckedContinuation {
            (continuation: CheckedContinuation<AnyBox, Never>) in
            FakeResponseStorage.shared.expect(
                at: endpoint ?? .api(key.responseEndpoints[0]),
                continuation: continuation,
                file: file,
                line: line
            )
            self.send(key: key)
        }
        let unwrapped = try XCTUnwrap(
            box.value as? T,
            "Value '\(box.value)' can't be cast to '\(_typeName(T.self))'",
            file: file,
            line: line
        )
        return unwrapped
    }
}
