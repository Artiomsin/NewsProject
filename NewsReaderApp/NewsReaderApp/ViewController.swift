import UIKit

class ViewController: UITabBarController {
    private let apiService = APIService()
       private lazy var newsRepository: NewsRepository = NewsRepositoryImpl(apiService: apiService)
       private lazy var bookmarkStorage: BookmarkStorage = CoreDataBookmarkStorage()
       
       override func viewDidLoad() {
           super.viewDidLoad()
           setupViewControllers()
           setupTabBarAppearance()
           ThemeManager.shared.loadSavedTheme()
       }
       
       private func setupViewControllers() {
           // 1. News List
           let fetchUseCase = FetchNewsUseCase(newsRepository: newsRepository)
           let bookmarkUseCase = ManageBookmarksUseCase(bookmarkStorage: bookmarkStorage)
           let newsVM = NewsListViewModel(fetchNewsUseCase: fetchUseCase, bookmarkUseCase: bookmarkUseCase)
           let newsVC = NewsListViewController(viewModel: newsVM)
           let newsNav = UINavigationController(rootViewController: newsVC)
           newsNav.tabBarItem = UITabBarItem(title: "News", image: UIImage(systemName: "newspaper"), tag: 0)
           
           // 2. Bookmarks
           let bookmarksVM = BookmarksViewModel(bookmarkUseCase: bookmarkUseCase)
           let bookmarksVC = BookmarksViewController(viewModel: bookmarksVM)
           let bookmarksNav = UINavigationController(rootViewController: bookmarksVC)
           bookmarksNav.tabBarItem = UITabBarItem(title: "Bookmarks", image: UIImage(systemName: "bookmark"), tag: 1)
           
           viewControllers = [newsNav, bookmarksNav]
       }
       
       private func setupTabBarAppearance() {
                   let navBarAppearance = UINavigationBarAppearance()
                   navBarAppearance.configureWithOpaqueBackground()
                   navBarAppearance.backgroundColor = .systemBackground
                   navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.label]
                   
                   UINavigationBar.appearance().standardAppearance = navBarAppearance
                   UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
                   UINavigationBar.appearance().tintColor = .systemBlue
           
                   let tabBarAppearance = UITabBarAppearance()
                   tabBarAppearance.configureWithOpaqueBackground()
                   tabBarAppearance.backgroundColor = .systemBackground
                   
                   UITabBar.appearance().standardAppearance = tabBarAppearance
                   UITabBar.appearance().tintColor = .systemBlue
       }
}
