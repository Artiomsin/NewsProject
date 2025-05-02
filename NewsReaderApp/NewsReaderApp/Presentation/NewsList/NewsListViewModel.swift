import Foundation

class NewsListViewModel {
    private let fetchNewsUseCase: FetchNewsUseCase
    let bookmarkUseCase: BookmarkUseCase
    
    var news: [News] = []
    var isLoading = false
    var onNewsUpdated: (() -> Void)?
    var onError: ((NetworkError) -> Void)?
    
    init(fetchNewsUseCase: FetchNewsUseCase, bookmarkUseCase: BookmarkUseCase) {
        self.fetchNewsUseCase = fetchNewsUseCase
        self.bookmarkUseCase = bookmarkUseCase
    }
    
    func loadNews(for category: String) {
        isLoading = true
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let fromDate = formatter.string(from: Date().addingTimeInterval(-7*24*60*60))
        
        fetchNewsUseCase.execute(query: category, fromDate: fromDate, sortBy: "publishedAt") { [weak self] result in
            self?.isLoading = false
            switch result {
            case .success(let newsItems):
                self?.news = newsItems
                self?.onNewsUpdated?()
            case .failure(let error):
                self?.onError?(error)
            }
        }
    }
}

