import UIKit

class NewsDetailViewController: UIViewController {
    private let viewModel: NewsDetailViewModel
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let titleLabel = UILabel()
    private let contentLabel = UILabel()
    private let sourceLabel = UILabel()
    private let dateLabel = UILabel()
    private let bookmarkButton = UIButton()
    
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
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        titleLabel.numberOfLines = 0
        
        contentLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        contentLabel.numberOfLines = 0
        
        sourceLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        sourceLabel.textColor = .systemBlue
        
        dateLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        dateLabel.textColor = .secondaryLabel
        
        bookmarkButton.addTarget(self, action: #selector(bookmarkButtonTapped), for: .touchUpInside)
        
        bookmarkButton.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        let titleAndSourceStackView = UIStackView(arrangedSubviews: [titleLabel, sourceLabel])
        titleAndSourceStackView.axis = .vertical
        titleAndSourceStackView.spacing = 16
        titleAndSourceStackView.translatesAutoresizingMaskIntoConstraints = false
        
        let dateAndBookmarkStackView = UIStackView(arrangedSubviews: [dateLabel, bookmarkButton])
        dateAndBookmarkStackView.axis = .horizontal
        dateAndBookmarkStackView.spacing = 8
        dateAndBookmarkStackView.alignment = .center
        dateAndBookmarkStackView.translatesAutoresizingMaskIntoConstraints = false
        
        let stackView = UIStackView(arrangedSubviews: [titleAndSourceStackView, dateAndBookmarkStackView, contentLabel])
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(stackView)
        
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
            
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            
            dateAndBookmarkStackView.heightAnchor.constraint(equalToConstant: 30),
            bookmarkButton.widthAnchor.constraint(equalToConstant: 30),
            bookmarkButton.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        titleLabel.text = viewModel.news.title
        contentLabel.text = viewModel.news.content ?? viewModel.news.description ?? "No content available"
        sourceLabel.text = viewModel.news.source.name
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        dateLabel.text = dateFormatter.string(from: viewModel.news.publishedAt)
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

