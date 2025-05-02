import Foundation

protocol NewsRepository {
    func fetchNews(query: String, fromDate: String, sortBy: String, completion: @escaping (Result<[News], NetworkError>) -> Void)
    
}
