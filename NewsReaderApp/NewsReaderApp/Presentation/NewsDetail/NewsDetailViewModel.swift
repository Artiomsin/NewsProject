import Foundation

class NewsDetailViewModel {
    let news: News
    private let bookmarkUseCase: BookmarkUseCase
    
    var isBookmarked: Bool {
        bookmarkUseCase.isBookmarked(news: news)
    }
    
    var onBookmarkStatusChanged: (() -> Void)?
    
    init(news: News, bookmarkUseCase: BookmarkUseCase) {
        self.news = news
        self.bookmarkUseCase = bookmarkUseCase
    }
    
    func toggleBookmark() {
        if isBookmarked {
            bookmarkUseCase.removeBookmark(news: news)
        } else {
            bookmarkUseCase.addBookmark(news: news)
        }
        onBookmarkStatusChanged?()
    }
}

