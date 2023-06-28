import AWSLambdaEvents

enum Errors: Error, CustomStringConvertible {
    case envVarNotFound(name: String)
    case secretNotFound(arn: String)
    case signaturesDoNotMatch(found: String, expected: String)
    case headerNotFound(name: String, headers: AWSLambdaEvents.HTTPHeaders)

    var description: String {
        switch self {
        case let .envVarNotFound(name):
            return "envVarNotFound(name: \(name))"
        case let .secretNotFound(arn):
            return "secretNotFound(arn: \(arn))"
        case let .signaturesDoNotMatch(found, expected):
            return "signaturesDoNotMatch(found: \(found), expected: \(expected)"
        case let .headerNotFound(name, headers):
            return "headerNotFound(name: \(name), headers: \(headers))"
        }
    }
}