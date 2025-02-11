import DiscordBM
import AsyncHTTPClient
import NIOCore
import NIOFoundationCompat
import GitHubAPI
import SwiftSemver
import Markdown
import Foundation

struct PRHandler {

    enum Configuration {
        static let userIDDenyList: Set<Int> = [/*dependabot[bot]:*/ 49699333]
    }

    let context: HandlerContext
    let pr: PullRequest
    var event: GHEvent {
        context.event
    }
    var repo: Repository {
        get throws {
            try event.repository.requireValue()
        }
    }

    init(context: HandlerContext) throws {
        self.context = context
        self.pr = try context.event.pull_request.requireValue()
    }

    func handle() async throws {
        let action = try event.action
            .flatMap({ PullRequest.Action(rawValue: $0) })
            .requireValue()
        guard !Configuration.userIDDenyList.contains(pr.user.id) else {
            return
        }
        switch action {
        case .opened:
            try await onOpened()
        case .closed:
            try await onClosed()
        case .edited, .converted_to_draft, .dequeued, .enqueued, .locked, .ready_for_review, .reopened, .unlocked:
            try await onEdited()
        case .assigned, .auto_merge_disabled, .auto_merge_enabled, .demilestoned, .labeled, .milestoned, .review_request_removed, .review_requested, .synchronize, .unassigned, .unlabeled, .submitted:
            break
        }
    }

    func onEdited() async throws {
        try await editPRReport()
    }

    func onOpened() async throws {
        try await makeReporter().reportCreation()
    }

    func onClosed() async throws {
        try await ReleaseMaker(
            context: context,
            pr: pr,
            number: event.number.requireValue()
        ).handle()
        try await editPRReport()
    }

    func editPRReport() async throws {
        try await makeReporter().reportEdition()
    }

    func makeReporter() throws -> Reporter {
        Reporter(
            context: context,
            embed: try createReportEmbed(),
            repoID: try repo.id,
            number: try event.number.requireValue(),
            ticketCreatedAt: pr.created_at
        )
    }

    func createReportEmbed() throws -> Embed {
        let authorName = pr.user.login
        let authorAvatarLink = pr.user.avatar_url

        let prLink = pr.html_url

        let body = pr.body.map { body -> String in
            let formatted = body.formatMarkdown(
                maxLength: 256,
                trailingParagraphMinLength: 128
            )
            return formatted.isEmpty ? "" : ">>> \(formatted)"
        } ?? ""

        let description = """
        ### \(pr.title)

        \(body)
        """

        let status = Status(pr: pr)
        let statusString = status.titleDescription.map { " - \($0)" } ?? ""
        let maxCount = 256 - statusString.unicodeScalars.count
        let number = try event.number.requireValue()
        let title = try "[\(repo.uiName)] PR #\(number)".unicodesPrefix(maxCount) + statusString

        let embed = Embed(
            title: title,
            description: description,
            url: prLink,
            color: status.color,
            footer: .init(
                text: "By \(authorName)",
                icon_url: .exact(authorAvatarLink)
            )
        )

        return embed
    }
}

private enum Status: String {
    case merged = "Merged"
    case closed = "Closed"
    case draft = "Draft"
    case opened = "Opened"

    var color: DiscordColor {
        switch self {
        case .merged:
            return .purple
        case .closed:
            return .red
        case .draft:
            return .gray
        case .opened:
            return .green
        }
    }

    var titleDescription: String? {
        switch self {
        case .opened:
            return nil
        case .merged, .closed, .draft:
            return self.rawValue
        }
    }

    init(pr: PullRequest) {
        if pr.merged_by != nil {
            self = .merged
        } else if pr.closed_at != nil {
            self = .closed
        } else if pr.draft == true {
            self = .draft
        } else {
            self = .opened
        }
    }
}
