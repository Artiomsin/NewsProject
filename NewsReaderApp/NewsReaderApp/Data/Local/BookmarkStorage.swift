import CoreData

protocol BookmarkStorage {
    func addBookmark(news: News)
    func removeBookmark(news: News)
    func getAllBookmarks() -> [News]
    func isBookmarked(news: News) -> Bool
}

class CoreDataBookmarkStorage: BookmarkStorage {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext = CoreDataStack.shared.persistentContainer.viewContext) {
        self.context = context
    }

    func addBookmark(news: News) {
        let bookmark = BookmarkEntity(context: context)
        bookmark.id = UUID().uuidString
        bookmark.title = news.title
        bookmark.newsDescription = news.description
        bookmark.sourceName = news.source.name
        bookmark.publishedAt = news.publishedAt
        bookmark.content = news.content
        bookmark.dateAdded = Date()
        bookmark.urlToImage = news.urlToImage
        bookmark.author = news.author
        CoreDataStack.shared.saveContext()
    }

    func removeBookmark(news: News) {
        let fetchRequest: NSFetchRequest<BookmarkEntity> = BookmarkEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title == %@ AND sourceName == %@", news.title, news.source.name)

        do {
            let results = try context.fetch(fetchRequest)
            results.forEach { context.delete($0) }
            CoreDataStack.shared.saveContext()
        } catch {
            print("Failed to remove bookmark: \(error)")
        }
    }

    func getAllBookmarks() -> [News] {
        let fetchRequest: NSFetchRequest<BookmarkEntity> = BookmarkEntity.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "dateAdded", ascending: false)]

        do {
            let bookmarks = try context.fetch(fetchRequest)
            return bookmarks.map {
                News(
                    title: $0.title ?? "",
                    description: $0.newsDescription,
                    source: Source(name: $0.sourceName ?? ""),
                    urlToImage: $0.urlToImage,
                    publishedAt: $0.publishedAt ?? Date(),
                    url: $0.url,
                    content: $0.content,
                    author: $0.author
                )
            }
        } catch {
            print("Failed to fetch bookmarks: \(error)")
            return []
        }
    }

    func isBookmarked(news: News) -> Bool {
        let fetchRequest: NSFetchRequest<BookmarkEntity> = BookmarkEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title == %@ AND sourceName == %@", news.title, news.source.name)

        do {
            let count = try context.count(for: fetchRequest)
            return count > 0
        } catch {
            print("Failed to check bookmark: \(error)")
            return false
        }
    }
}
