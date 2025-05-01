import Foundation

struct News: Codable, Equatable {
    let title: String
    let description: String?
    let source: Source
    let urlToImage: String?
    let publishedAt: Date
    let url: String?
    let content: String?
    
    static func == (lhs: News, rhs: News) -> Bool {
        return lhs.title == rhs.title && lhs.source.name == rhs.source.name
    }
}

struct Source: Codable {
    let name: String
}
