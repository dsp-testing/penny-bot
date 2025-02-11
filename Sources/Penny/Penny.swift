import NIOPosix
import AsyncHTTPClient
import SotoS3
import Backtrace

@main
struct Penny {
    static func main() async throws {
        try await start(mainService: PennyService())
    }

    static func start(mainService: any MainService) async throws {
        Backtrace.install()

        /// Use `1` instead of `System.coreCount`.
        /// This is preferred for apps that primarily use structured concurrency.
        let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        let httpClient = HTTPClient(eventLoopGroupProvider: .shared(eventLoopGroup))
        let awsClient = AWSClient(httpClientProvider: .shared(httpClient))

        /// These shutdown calls are only useful for tests where we call `Penny.main()` repeatedly
        defer {
            /// Shutdown in reverse order of dependance.
            try! awsClient.syncShutdown()
            try! httpClient.syncShutdown()
            try! eventLoopGroup.syncShutdownGracefully()
        }

        try await mainService.bootstrapLoggingSystem(httpClient: httpClient)

        let bot = try await mainService.makeBot(
            eventLoopGroup: eventLoopGroup,
            httpClient: httpClient
        )
        let cache = try await mainService.makeCache(bot: bot)

        let context = try await mainService.beforeConnectCall(
            bot: bot,
            cache: cache,
            httpClient: httpClient,
            awsClient: awsClient
        )

        await bot.connect()
        let stream = await bot.makeEventsStream()

        try await mainService.afterConnectCall(context: context)

        for await event in stream {
            EventHandler(event: event, context: context).handle()
        }
    }
}
