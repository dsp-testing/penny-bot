import Foundation
import DiscordBM

enum Constants {
    static func env(_ key: String) -> String {
        if let value = ProcessInfo.processInfo.environment[key] {
            return value
        } else {
            fatalError("""
            Set an environment value for key '\(key)'.
            In tests you usually can set dummy values.
            """)
        }
    }
    static let vaporGuildId: GuildSnowflake = "431917998102675485"
    static let botDevUserId: UserSnowflake = "290483761559240704"
    static let botId: UserSnowflake = "950695294906007573"
    static let botToken = env("BOT_TOKEN")
    static let loggingWebhookUrl = env("LOGGING_WEBHOOK_URL")
    static let apiBaseUrl = env("API_BASE_URL")
    static let ghOAuthClientId = env("GH_OAUTH_CLIENT_ID")
    static let accountLinkOAuthPrivKey = env("ACCOUNT_LINKING_OAUTH_FLOW_PRIV_KEY")

    enum ServerEmojis {
        case coin
        case vapor
        case love

        var id: EmojiSnowflake {
            switch self {
            case .coin: return "473588485962596352"
            case .vapor: return "431934596121362453"
            case .love: return "656303356280832062"
            }
        }

        var name: String {
            switch self {
            case .coin: return "coin"
            case .vapor: return "vapor"
            case .love: return "vaporlove"
            }
        }

        var emoji: String {
            DiscordUtils.customEmoji(name: self.name, id: self.id)
        }
    }

    enum Channels: ChannelSnowflake {
        case welcome = "437050958061764608"
        case news = "431917998102675487"
        case publications = "435934451046809600"
        case release = "431926479752921098"
        case jobs = "442420282292961282"
        case status = "459521920241500220"
        case logs = "1067060193982156880"
        case proposals = "1104650517549953094"
        case thanks = "443074453719744522"

        var id: ChannelSnowflake {
            self.rawValue
        }

        /// Must not send thanks-responses to these channels.
        /// Instead send to the #thanks channel.
        static let thanksResponseDenyList: Set<ChannelSnowflake> = Set([
            Channels.welcome,
            Channels.news,
            Channels.publications,
            Channels.release,
            Channels.jobs,
            Channels.status,
        ].map(\.id))
    }

    enum Roles: RoleSnowflake {
        case nitroBooster = "621412660973535233"
        case backer = "431921695524126722"
        case sponsor = "444167329748746262"
        case contributor = "431920712505098240"
        case maintainer = "530113860129259521"
        case moderator = "431920836631592980"
        case core = "431919254372089857"
        
        static let elevatedPublicCommandsAccess: [Roles] = [
            .nitroBooster,
            .backer,
            .sponsor,
            .contributor,
            .maintainer,
            .moderator,
            .core,
        ]

        static let elevatedRestrictedCommandsAccess: [Roles] = [
            .contributor,
            .maintainer,
            .moderator,
            .core,
        ]

        static let elevatedRestrictedCommandsAccessSet: Set<RoleSnowflake> = Set([
            Roles.contributor,
            Roles.maintainer,
            Roles.moderator,
            Roles.core,
        ].map(\.rawValue))
    }
}
