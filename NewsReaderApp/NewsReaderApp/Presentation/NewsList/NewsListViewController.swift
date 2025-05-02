import UIKit

class NewsListViewController: UIViewController {
    private let viewModel: NewsListViewModel
    private let tableView = UITableView()
    private let segmentedControl = UISegmentedControl(items: [ "Business", "Technology", "Sports"])
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    
    init(viewModel: NewsListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        setupThemeButton()
        loadNews(for: "technology")
        NotificationCenter.default.addObserver(
                    self,
                    selector: #selector(themeChanged),
                    name: .themeDidChange,
                    object: nil
                )
    }
    
    
    @objc private func toggleTheme() {
            let currentTheme = ThemeManager.shared.currentTheme
            let newTheme: AppTheme
            
            switch currentTheme {
            case .system:
                newTheme = .dark
            case .light:
                newTheme = .dark
            case .dark:
                newTheme = .light
            }
            
            ThemeManager.shared.setTheme(newTheme)
        }
    
    @objc private func themeChanged() {
            updateThemeButtonIcon()
            view.backgroundColor = .systemBackground
            tableView.backgroundColor = .systemBackground
            tableView.reloadData()
        }
    
    private func setupThemeButton() {
           let themeButton = UIBarButtonItem(
               image: UIImage(systemName: "moon.circle.fill"),
               style: .plain,
               target: self,
               action: #selector(toggleTheme)
           )
           navigationItem.rightBarButtonItem = themeButton
           updateThemeButtonIcon()
       }
    
    private func updateThemeButtonIcon() {
            let imageName: String
            switch ThemeManager.shared.currentTheme {
            case .system:
                imageName = "moon.circle.fill"
            case .light:
                imageName = "sun.max.fill"
            case .dark:
                imageName = "moon.fill"
            }
            navigationItem.rightBarButtonItem?.image = UIImage(systemName: imageName)
        }
    
    private func setupUI() {
        title = "News"
        view.backgroundColor = .systemBackground
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(categoryChanged), for: .valueChanged)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 50))
        headerView.addSubview(segmentedControl)
        NSLayoutConstraint.activate([
            segmentedControl.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            segmentedControl.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            segmentedControl.centerYAnchor.constraint(equalTo: headerView.centerYAnchor)
        ])
        tableView.tableHeaderView = headerView

        // Table View
        tableView.register(NewsCell.self, forCellReuseIdentifier: NewsCell.reuseIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 120
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        // Activity Indicator
        activityIndicator.hidesWhenStopped = true
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicator)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    
    private func setupBindings() {
        viewModel.onNewsUpdated = { [weak self] in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
                self?.activityIndicator.stopAnimating()
            }
        }
        
        viewModel.onError = { [weak self] error in
               DispatchQueue.main.async {
                   self?.activityIndicator.stopAnimating()
                   
                   let message: String
                   switch error {
                   case .noInternet:
                       message = "Нет подключения к интернету."
                   case .timeout:
                       message = "Время ожидания истекло."
                   case .serverError(let statusCode):
                       message = "Ошибка сервера. Код: \(statusCode)."
                   case .invalidResponse:
                       message = "Некорректный ответ от сервера."
                   case .emptyData:
                       message = "Нет данных."
                   case .decodingFailed:
                       message = "Не удалось обработать данные."
                   case .other(let err):
                       message = err.localizedDescription
                   }
                   
                   self?.showErrorAlert(message: message)
               }
           }
       }
    
    @objc private func categoryChanged(_ sender: UISegmentedControl) {
        let categories = ["technology", "business", "sports", "entertainment"]
        let selectedCategory = categories[sender.selectedSegmentIndex]
        loadNews(for: selectedCategory)
    }
    
    private func loadNews(for category: String) {
        activityIndicator.startAnimating()
        viewModel.loadNews(for: category)
    }
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension NewsListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.news.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NewsCell.reuseIdentifier, for: indexPath) as! NewsCell
        cell.configure(with: viewModel.news[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let newsItem = viewModel.news[indexPath.row]
        let detailVM = NewsDetailViewModel(news: newsItem, bookmarkUseCase: viewModel.bookmarkUseCase)
        let detailVC = NewsDetailViewController(viewModel: detailVM)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

