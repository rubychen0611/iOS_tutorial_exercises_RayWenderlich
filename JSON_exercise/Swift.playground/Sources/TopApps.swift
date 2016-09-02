import Foundation

public struct TopApps: Decodable {
    //模型的属性
    public let feed: Feed?
    //初始化
    public init?(json: JSON) {
        feed = "feed" <~~ json
    }
}