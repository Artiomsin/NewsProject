import Foundation

class FetchNewsUseCase {
    private let newsRepository: NewsRepository

    init(newsRepository: NewsRepository) {
        self.newsRepository = newsRepository
    }

    func execute(query: String, fromDate: String, sortBy: String, completion: @escaping (Result<[News], Error>) -> Void) {
        newsRepository.fetchNews(query: query, fromDate: fromDate, sortBy: sortBy, completion: completion)
    }
   
}
