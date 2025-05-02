import Foundation

class NewsRepositoryImpl: NewsRepository {
    private let apiService: APIService
    
    init(apiService: APIService) {
        self.apiService = apiService
    }
    
    func fetchNews(query: String, fromDate: String, sortBy: String, completion: @escaping (Result<[News], NetworkError>) -> Void) {
        apiService.fetchNews(query: query, fromDate: fromDate, sortBy: sortBy, completion: completion)
    }
    
    
}
