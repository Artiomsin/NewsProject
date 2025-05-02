import UIKit

class NewsDetailViewController: UIViewController {
    private let viewModel: NewsDetailViewModel
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let newsImageView = UIImageView()
    private let imageLoadingIndicator = UIActivityIndicatorView(style: .medium)
    private let titleLabel = UILabel()
    private let authorLabel = UILabel()
    private let sourceLabel = UILabel()
    private let dateLabel = UILabel()
    private let contentLabel = UILabel()
    private let urlButton = UIButton()
    private let bookmarkButton = UIButton()
    private let imagePlaceholder = UIImage(systemName: "photo")?
        .withTintColor(.systemGray3, renderingMode: .alwaysOriginal)

    init(viewModel: NewsDetailViewModel) {
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
        updateBookmarkButton()
        loadImage()
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // Configure image view
        newsImageView.contentMode = .scaleAspectFill
        newsImageView.clipsToBounds = true
        newsImageView.layer.cornerRadius = 8
        newsImageView.backgroundColor = .systemGray6
        
        // Configure loading indicator
        imageLoadingIndicator.hidesWhenStopped = true
        imageLoadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        // Configure labels
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        titleLabel.numberOfLines = 0
        
        authorLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        authorLabel.textColor = .secondaryLabel
        authorLabel.numberOfLines = 1
        
        sourceLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        sourceLabel.textColor = .systemBlue
        sourceLabel.numberOfLines = 1
        
        dateLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        dateLabel.textColor = .secondaryLabel
        dateLabel.numberOfLines = 1
        
        contentLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        contentLabel.numberOfLines = 0
        
        // Configure URL button
        urlButton.setTitle("Read Full Article", for: .normal)
        urlButton.setTitleColor(.systemBlue, for: .normal)
        urlButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        urlButton.addTarget(self, action: #selector(openArticleURL), for: .touchUpInside)
        
        // Configure bookmark button
        bookmarkButton.setImage(UIImage(systemName: "bookmark"), for: .normal)
        bookmarkButton.tintColor = .gray
        bookmarkButton.addTarget(self, action: #selector(bookmarkButtonTapped), for: .touchUpInside)
        
        // Setup layout
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        newsImageView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        newsImageView.addSubview(imageLoadingIndicator)
        
        let metadataStack = UIStackView(arrangedSubviews: [
            authorLabel,
            sourceLabel,
            dateLabel
        ])
        metadataStack.axis = .vertical
        metadataStack.spacing = 4
        
        // Bottom buttons stack
        let buttonsStack = UIStackView(arrangedSubviews: [
            urlButton,
            bookmarkButton
        ])
        buttonsStack.axis = .horizontal
        buttonsStack.distribution = .equalSpacing
        
        // Main content stack
        let contentStack = UIStackView(arrangedSubviews: [
            titleLabel,
            metadataStack,
            contentLabel,
            buttonsStack
        ])
        contentStack.axis = .vertical
        contentStack.spacing = 16
        
        // Main stack (image + content)
        let mainStackView = UIStackView(arrangedSubviews: [
            newsImageView,
            contentStack
        ])
        mainStackView.axis = .vertical
        mainStackView.spacing = 20
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(mainStackView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            mainStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            mainStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            mainStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            mainStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            
            newsImageView.heightAnchor.constraint(equalTo: newsImageView.widthAnchor, multiplier: 0.6),
            bookmarkButton.widthAnchor.constraint(equalToConstant: 30),
            bookmarkButton.heightAnchor.constraint(equalToConstant: 30),
            
            imageLoadingIndicator.centerXAnchor.constraint(equalTo: newsImageView.centerXAnchor),
            imageLoadingIndicator.centerYAnchor.constraint(equalTo: newsImageView.centerYAnchor)
        ])
        
        titleLabel.text = viewModel.news.title
        authorLabel.text = viewModel.news.author ?? "Unknown author"
        sourceLabel.text = viewModel.news.source.name
        contentLabel.text = viewModel.news.content ?? viewModel.news.description ?? "No content available"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        dateLabel.text = dateFormatter.string(from: viewModel.news.publishedAt)
    }

    private func loadImage() {
        guard let urlString = viewModel.news.urlToImage,
              let url = URL(string: urlString) else {
            newsImageView.image = imagePlaceholder
            return
        }
        
        imageLoadingIndicator.startAnimating()
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.imageLoadingIndicator.stopAnimating()
                
                if let data = data, let image = UIImage(data: data) {
                    UIView.transition(with: self?.newsImageView ?? UIView(),
                                    duration: 0.3,
                                    options: .transitionCrossDissolve,
                                    animations: {
                        self?.newsImageView.image = image
                    }, completion: nil)
                } else {
                    self?.newsImageView.image = self?.imagePlaceholder
                }
            }
        }.resume()
    }

    @objc private func openArticleURL() {
        guard let urlString = viewModel.news.url,
              let url = URL(string: urlString) else {
            return
        }
        UIApplication.shared.open(url)
    }

    private func setupBindings() {
        viewModel.onBookmarkStatusChanged = { [weak self] in
            self?.updateBookmarkButton()
        }
    }

    private func updateBookmarkButton() {
        let image = viewModel.isBookmarked ?
            UIImage(systemName: "bookmark.fill") :
            UIImage(systemName: "bookmark")
        bookmarkButton.setImage(image, for: .normal)
        bookmarkButton.tintColor = viewModel.isBookmarked ? .systemBlue : .gray
    }

    @objc private func bookmarkButtonTapped() {
        viewModel.toggleBookmark()
    }
}

