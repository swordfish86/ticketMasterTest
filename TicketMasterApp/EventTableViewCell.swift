//
//  EventTableViewCell.swift
//  TicketMasterApp
//
//  Created by Jorge Angel Sanchez Martinez on 15/11/23.
//

import UIKit
import AlamofireImage
import Combine

class EventTableViewCell: UITableViewCell {
    static let identifier = String(describing: EventTableViewCell.self)
    static let cellHeight: CGFloat = 120
    static let imageWidth: CGFloat = 150
    private let container: UIView = {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = .clear
        return container
    }()
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setContentHuggingPriority(.defaultHigh,
                                        for: .vertical)
        return label
    }()
    private let eventImageView: UIImageView = {
        let image = UIImageView()
        let placeholderImage = UIImage(named: "event")
        image.translatesAutoresizingMaskIntoConstraints = false
        image.image = placeholderImage
        image.contentMode = .scaleToFill
        return image
    }()
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private var cancellable = Set<AnyCancellable>()

    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubview(container)
        container.addSubview(nameLabel)
        container.addSubview(eventImageView)
        container.addSubview(descriptionLabel)
        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: topAnchor),
            container.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            container.leadingAnchor.constraint(equalTo: leadingAnchor),
            container.trailingAnchor.constraint(equalTo: trailingAnchor),
            eventImageView.topAnchor.constraint(equalTo: container.topAnchor),
            eventImageView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            eventImageView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            eventImageView.widthAnchor.constraint(equalToConstant: EventTableViewCell.imageWidth),
            nameLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 10),
            nameLabel.leadingAnchor.constraint(equalTo: eventImageView.trailingAnchor, constant: 10),
            nameLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -10),
            nameLabel.bottomAnchor.constraint(equalTo: descriptionLabel.topAnchor, constant: 10),
            descriptionLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -10),
            descriptionLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: 10)
        ])

        container.layer.borderWidth = 1.0
        container.layer.borderColor = UIColor.gray.cgColor
        container.layer.cornerRadius = 10
        container.layer.shadowColor = UIColor.lightGray.cgColor
        container.clipsToBounds = true
    }

    required init?(coder aDecoder: NSCoder) {
        return nil
    }

    func configure(with viewModel: EventViewModel) {
        nameLabel.text = viewModel.name
        descriptionLabel.text = viewModel.description
        viewModel.loadImage()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                guard let self = self else { return }
                if case .failure(let error) = completion {
                    let errorImage = UIImage(named: "errorImage")
                    if error == .urlError {
                        self.eventImageView.image = errorImage
                    } else if error == .networkError {
                        self.eventImageView.image = errorImage
                    }
                }
            }, receiveValue: { [weak self] image in
                guard let self = self else { return }
                self.eventImageView.image = image
            }).store(in: &cancellable)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        cancellable.removeAll()
        eventImageView.image = nil
        nameLabel.text = nil
        descriptionLabel.text = nil
    }
}

class EventErrorTableViewCell: UITableViewCell {
    static let identifier = String(describing: EventErrorTableViewCell.self)
    private var cancellables = Set<AnyCancellable>()
    private let descriptionErrorLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var reloadButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(LanguageString.retry.localized, for: .normal)
        button.addTarget(self, action: #selector(reloadAction(_:)), for: .touchUpInside)
        button.layer.cornerRadius = 10
        button.backgroundColor = .blue
        button.titleLabel?.textColor = .white
        return button
    }()
    
    var reloadPublisher = PassthroughSubject<Void,Never>()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(descriptionErrorLabel)
        contentView.addSubview(reloadButton)
        NSLayoutConstraint.activate([
            descriptionErrorLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            descriptionErrorLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            descriptionErrorLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 10),
            reloadButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            reloadButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            reloadButton.topAnchor.constraint(equalTo: descriptionErrorLabel.bottomAnchor, constant: 10)
        ])
        
        contentView.layer.borderWidth = 1.0
        contentView.layer.borderColor = UIColor.gray.cgColor
        contentView.layer.cornerRadius = 10
        contentView.layer.shadowColor = UIColor.lightGray.cgColor
        contentView.clipsToBounds = true
    }

    required init?(coder aDecoder: NSCoder) {
        return nil
    }

    @objc
    func reloadAction(_ sender: Any) {
        reloadPublisher.send(())
    }
    
    func configure(with error: String) {
        descriptionErrorLabel.text = error
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        descriptionErrorLabel.text = nil
    }
}

#if DEBUG
extension EventTableViewCell {
    var testHook: TestHook {
        .init(target: self)
    }
    
    struct TestHook {
        private let target: EventTableViewCell

        var descriptionLabel: UILabel {
            target.descriptionLabel
        }

        var nameLabel: UILabel {
            target.nameLabel
        }

        var eventImageView: UIImageView {
            target.eventImageView
        }

        fileprivate init(target: EventTableViewCell) {
            self.target = target
        }
    }
}

extension EventErrorTableViewCell {
    var testHook: TestHook {
        .init(target: self)
    }
    
    struct TestHook {
        private let target: EventErrorTableViewCell

        var reloadButton: UIButton {
            target.reloadButton
        }

        var descriptionErrorLabel: UILabel {
            target.descriptionErrorLabel
        }

        fileprivate init(target: EventErrorTableViewCell) {
            self.target = target
        }
    }
}
#endif
