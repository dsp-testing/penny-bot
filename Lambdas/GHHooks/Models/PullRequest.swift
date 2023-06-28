import Foundation

// MARK: - PullRequest
struct PullRequest: Codable {
    let url: String
    let id: Int
    let nodeID: String?
    let htmlURL: String?
    let diffURL: String?
    let patchURL: String?
    let issueURL: String?
    let number: Int
    let state: String
    let locked: Bool
    let title: String
    let user: User
    let body: String?
    let createdAt, updatedAt: Date?
    let closedAt, mergedAt: Date?
    let mergeCommitSHA: String?
    /// Might not be a `String`
    let assignee: String?
    /// Might not be a `String`
    let assignees, requestedReviewers, requestedTeams, labels: [String]?
    let milestone: Date?
    let draft: Bool
    let commitsURL: String?
    let reviewCommentsURL: String?
    let reviewCommentURL: String?
    let commentsURL: String?
    let statusesURL: String?
    let head, base: Base
    let links: Links?
    let authorAssociation: String?
    let autoMerge: Bool?
    let activeLockReason: String?
    let merged: Bool
    let mergeable, rebaseable: Bool?
    let mergeableState: String?
    /// Might not be a `String`
    let mergedBy: String?
    let comments: Int
    let reviewComments: Int?
    let maintainerCanModify: Bool?
    let commits, additions, deletions: Int
    let changedFiles: Int?

    enum CodingKeys: String, CodingKey {
        case url, id
        case nodeID
        case htmlURL
        case diffURL
        case patchURL
        case issueURL
        case number, state, locked, title, user, body
        case createdAt
        case updatedAt
        case closedAt
        case mergedAt
        case mergeCommitSHA
        case assignee, assignees
        case requestedReviewers
        case requestedTeams
        case labels, milestone, draft
        case commitsURL
        case reviewCommentsURL
        case reviewCommentURL
        case commentsURL
        case statusesURL
        case head, base
        case links
        case authorAssociation
        case autoMerge
        case activeLockReason
        case merged, mergeable, rebaseable
        case mergeableState
        case mergedBy
        case comments
        case reviewComments
        case maintainerCanModify
        case commits, additions, deletions
        case changedFiles
    }
}

// MARK: - Action
extension PullRequest {
    enum Action: String, Codable {
        case assigned
        case auto_merge_disabled
        case auto_merge_enabled
        case closed
        case converted_to_draft
        case demilestoned
        case dequeued
        case edited
        case enqueued
        case labeled
        case locked
        case milestoned
        case opened
        case ready_for_review
        case reopened
        case review_request_removed
        case review_requested
        case synchronize
        case unassigned
        case unlabeled
        case unlocked
    }
}

// MARK: - Base
struct Base: Codable {
    let label, ref, sha: String
    let user: User
    let repo: Repository
}

// MARK: - Links
struct Links: Codable {
    let linksSelf, html, issue, comments: Comments
    let reviewComments, reviewComment, commits, statuses: Comments

    enum CodingKeys: String, CodingKey {
        case linksSelf
        case html, issue, comments
        case reviewComments
        case reviewComment
        case commits, statuses
    }
}

// MARK: - Comments
struct Comments: Codable {
    let href: String
}

