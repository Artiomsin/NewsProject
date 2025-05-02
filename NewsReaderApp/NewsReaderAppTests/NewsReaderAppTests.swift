import XCTest
@testable import NewsReaderApp

class MockNewsRepository: NewsRepository {
    var fetchCalled = false
    var resultToReturn: Result<[News], NetworkError> = .success([])

    func fetchNews(query: String, fromDate: String, sortBy: String, completion: @escaping (Result<[News], NetworkError>) -> Void) {
        fetchCalled = true
        completion(resultToReturn)
    }
}

class MockNewsCache: NewsCacheProtocol {
    var savedNews: [News]?
    var savedKey: String?

    func save(_ news: [News], for key: String) {
        savedNews = news
        savedKey = key
    }

    func load(for key: String) -> [News]? {
        return savedNews
    }
}

class MockAPIService: APIService {
    var resultToReturn: Result<[News], NetworkError> = .success([])

    override func fetchNews(query: String, fromDate: String, sortBy: String, completion: @escaping (Result<[News], NetworkError>) -> Void) {
        completion(resultToReturn)
    }
}

class MockBookmarkStorage: BookmarkStorage {
    var bookmarks: [News] = []

    func addBookmark(news: News) {
        bookmarks.append(news)
    }

    func removeBookmark(news: News) {
        bookmarks.removeAll { $0 == news }
    }

    func getAllBookmarks() -> [News] {
        return bookmarks
    }

    func isBookmarked(news: News) -> Bool {
        return bookmarks.contains(news)
    }
}

final class NewsReaderAppTests: XCTestCase {

    let sampleNews = News(
        title: "Test Title",
        description: "Description",
        source: Source(name: "Source"),
        urlToImage: nil,
        publishedAt: Date(),
        url: "https://example.com",
        content: "Test content",
        author: "The Daily Blast with Greg Sargent"
    )

    var mockCache: MockNewsCache!
    var mockAPI: MockAPIService!
    var mockRepository: MockNewsRepository!
    var mockStorage: MockBookmarkStorage!

    override func setUp() {
        super.setUp()
        
        mockCache = MockNewsCache()
        mockAPI = MockAPIService()
        mockRepository = MockNewsRepository()
        mockStorage = MockBookmarkStorage()
    }

    override func tearDown() {
        mockCache.savedNews = nil
        mockCache.savedKey = nil
        mockRepository.resultToReturn = .success([])
        mockStorage.bookmarks.removeAll()

        super.tearDown()
    }

    func testFetchNews_SavesToCacheAfterNetworkCall() {
        mockAPI.resultToReturn = .success([sampleNews])
        let repo = NewsRepositoryImpl(apiService: mockAPI, cache: mockCache)
        let exp = expectation(description: "news fetched and cached")

        repo.fetchNews(query: "test", fromDate: "2024-05-01", sortBy: "publishedAt") { result in
            XCTAssertEqual(self.mockCache.savedNews?.first?.title, self.sampleNews.title, "Новость должна быть сохранена в кэш")
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1)
    }

    func testFetchNewsUseCase_CallsRepository() {
        let useCase = FetchNewsUseCase(newsRepository: mockRepository)
        let exp = expectation(description: "usecase called repo")

        useCase.execute(query: "abc", fromDate: "2024-05-01", sortBy: "publishedAt") { _ in
            XCTAssertTrue(self.mockRepository.fetchCalled, "Репозиторий должен быть вызван")
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1)
    }

    func testAddBookmark_AddsNewsToStorage() {
        let useCase = ManageBookmarksUseCase(bookmarkStorage: mockStorage)

        useCase.addBookmark(news: sampleNews)

        XCTAssertTrue(mockStorage.bookmarks.contains(sampleNews), "Новость должна быть в закладках")
    }

    func testIsBookmarked_ReturnsTrueIfExists() {
        mockStorage.bookmarks = [sampleNews]
        let useCase = ManageBookmarksUseCase(bookmarkStorage: mockStorage)

        XCTAssertTrue(useCase.isBookmarked(news: sampleNews), "Метод должен вернуть true, если новость в закладках")
    }
    
    func testFetchNews_ReturnsFromCacheIfAvailable() {
        let mockNews = [News(title: "Test Title", description: "Test Description", source: Source(name: "Test Source"), urlToImage: nil, publishedAt: Date(), url: nil, content: "Test Content",
                             author: "Reuters")]
        
        mockCache.save(mockNews, for: "technology_2025-04-24_publishedAt")
        
        mockRepository.resultToReturn = .success(mockNews)
        
        let expectation = self.expectation(description: "cache returned")
        
        mockRepository.fetchNews(query: "technology", fromDate: "2025-04-24", sortBy: "publishedAt") { result in
            switch result {
            case .success(let news):
                XCTAssertEqual(news.count, 1, "Должна быть 1 новость в кэше")
                XCTAssertEqual(news.first?.title, "Test Title", "Заголовок новости должен совпадать")
                expectation.fulfill()
            case .failure:
                XCTFail("Ожидался успешный результат, но получена ошибка")
            }
        }
        
        waitForExpectations(timeout: 4.0, handler: nil)
    }
}


