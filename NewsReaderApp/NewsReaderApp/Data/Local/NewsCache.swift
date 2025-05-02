import Foundation

protocol NewsCacheProtocol {
    func save(_ news: [News], for key: String)
    func load(for key: String) -> [News]?
}

final class NewsCache: NewsCacheProtocol {
    private let cache = NSCache<NSString, NSArray>()
    private let expirationTime: TimeInterval = 3600
    
    func save(_ news: [News], for key: String) {
        print(" Кэшируем \(news.count) новостей по ключу: \(key)")
        cache.setObject(news as NSArray, forKey: key as NSString)
        UserDefaults.standard.set(Date(), forKey: "\(key)_timestamp")
    }

    func load(for key: String) -> [News]? {
        if let cachedDate = UserDefaults.standard.object(forKey: "\(key)_timestamp") as? Date {
            print("⏱ Время кэша для '\(key)': \(cachedDate)")
        }
        
        if let news = cache.object(forKey: key as NSString) as? [News] {
            print(" Загружено из кэша: \(news.count) новостей")
            return news
        }
        print(" Кэш пуст для ключа: \(key)")
        return nil
    }
}

