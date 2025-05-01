import UIKit

class NewsCell: UITableViewCell {
    static let reuseIdentifier = "NewsCell"
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.numberOfLines = 0
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.numberOfLines = 2
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let sourceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = .systemBlue
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
        setupColors()
        NotificationCenter.default.addObserver(
                    self,
                    selector: #selector(themeChanged),
                    name: .themeDidChange,
                    object: nil
                )
        
    }
    
    @objc private func themeChanged() {
            setupColors()
        }
    
    private func setupColors() {
            contentView.backgroundColor = .systemBackground
            titleLabel.textColor = .label
            descriptionLabel.textColor = .secondaryLabel
            sourceLabel.textColor = .systemBlue
            
            let bgColorView = UIView()
            bgColorView.backgroundColor = .systemGray5
            selectedBackgroundView = bgColorView
        }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, descriptionLabel, sourceLabel])
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }
    
    func configure(with news: News) {
        titleLabel.text = news.title
        descriptionLabel.text = news.description
        sourceLabel.text = news.source.name
    }
}
