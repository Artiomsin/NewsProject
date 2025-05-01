import Foundation

class BookmarksViewModel {
    let bookmarkUseCase: BookmarkUseCase
    
    var bookmarks: [News] = []
    var onBookmarksUpdated: (() -> Void)?
    
    init(bookmarkUseCase: BookmarkUseCase) {
        self.bookmarkUseCase = bookmarkUseCase
    }
    
    func loadBookmarks() {
        bookmarks = bookmarkUseCase.getAllBookmarks()
        onBookmarksUpdated?()
    }
    
    func removeBookmark(at index: Int) {
        let news = bookmarks[index]
        bookmarkUseCase.removeBookmark(news: news)
        bookmarks.remove(at: index)
        onBookmarksUpdated?()
    }
}

