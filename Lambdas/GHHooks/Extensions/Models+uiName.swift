import GitHubAPI

extension Repository {
    /// If it's a Vapor repository, use the raw repo name like `postgres-nio`.
    /// Otherwise use the full repo name, like `vapor-community/stripe`.
    var uiName: String {
        self.owner.login == "vapor" ? self.name : self.full_name
    }
}

extension User {
    var uiName: String {
        self.name ?? self.login
    }
}

extension NullableUser {
    var uiName: String {
        self.name ?? self.login
    }
}
