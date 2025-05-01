protocol BookmarkUseCase {
    func addBookmark(news: News)
    func removeBookmark(news: News)
    func getAllBookmarks() -> [News]
    func isBookmarked(news: News) -> Bool
}

class ManageBookmarksUseCase: BookmarkUseCase {
    private let bookmarkStorage: BookmarkStorage
    
    init(bookmarkStorage: BookmarkStorage) {
        self.bookmarkStorage = bookmarkStorage
    }
    
    func addBookmark(news: News) {
        bookmarkStorage.addBookmark(news: news)
    }
    
    func removeBookmark(news: News) {
        bookmarkStorage.removeBookmark(news: news)
    }
    
    func getAllBookmarks() -> [News] {
        return bookmarkStorage.getAllBookmarks()
    }
    
    func isBookmarked(news: News) -> Bool {
        return bookmarkStorage.isBookmarked(news: news)
    }
}
