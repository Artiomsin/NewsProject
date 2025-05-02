import Foundation

class NewsRepositoryImpl: NewsRepository {
    private let apiService: APIService
    private let cache: NewsCacheProtocol
    
    init(apiService: APIService, cache: NewsCacheProtocol = NewsCache()) {
        self.apiService = apiService
        self.cache = cache
    }
    
    func fetchNews(query: String, fromDate: String, sortBy: String, completion: @escaping (Result<[News], NetworkError>) -> Void) {
        let cacheKey = "\(query)_\(fromDate)_\(sortBy)"
        
        //Пытаемся загрузить из кэша
        if let cachedNews = cache.load(for: cacheKey) {
            completion(.success(cachedNews))
        }
        
        //Все равно загружаем из сети (для актуальности)
        apiService.fetchNews(query: query, fromDate: fromDate, sortBy: sortBy) { [weak self] result in
            switch result {
            case .success(let news):
                //При успехе сохраняем в кэш
                self?.cache.save(news, for: cacheKey)
                completion(.success(news))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
