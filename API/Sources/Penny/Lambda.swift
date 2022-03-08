import AWSLambdaRuntime

struct Request: Codable {
    let name: String
}

struct Response: Codable {
    let body: String
}

// in this example we are receiving and responding with codables. Request and Response above are examples of how to use
// codables to model your request and response objects
@main
struct MyLambda: LambdaHandler {
    typealias Event = Request
    typealias Output = Response

    init(context: Lambda.InitializationContext) async throws {
        // setup your resources that you want to reuse for every invocation here.
    }

    func handle(_ event: Request, context: LambdaContext) async throws -> Response {
        // as an example, respond with the input event's reversed body
        Response(body: "Hello \(event.name)")
    }
}
