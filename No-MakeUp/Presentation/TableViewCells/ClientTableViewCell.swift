//
//  ClientTableViewCell.swift
//  Instaura
//
//  Created by Димон on 24.11.23.
//

import UIKit

final class ClientTableViewCell: UITableViewCell {
    
    static let identifier = "ClientCell"
    
    private let backgroundCellView = UIView()
    
    private let timeLabel = UILabel()
    private let nameLabel = UILabel()
    
    var numberOfRowsInSection: Int = 0
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureLayout()
        prepareLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureLayout()
        prepareLayout()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected {
            UIView.animate(withDuration: 0.1, animations: {
                self.transform = CGAffineTransform(scaleX: 0.97, y: 0.97)
            }, completion: { finished in
                UIView.animate(withDuration: 0.1) {
                    self.transform = .identity
                }
            })
        }
    }
    
    func setupCell(model: ClientTableViewCellModel) {
        timeLabel.text = "\(model.date) | \(model.time)"
        nameLabel.text = model.name
    }
    
    func configureCellCorners(indexPath: IndexPath) {
        if numberOfRowsInSection == 1 {
            backgroundCellView.layer.cornerRadius = 10
            backgroundCellView.layer.maskedCorners = [.layerMinXMinYCorner,
                                                      .layerMaxXMinYCorner,
                                                      .layerMinXMaxYCorner,
                                                      .layerMaxXMaxYCorner]
        } else if indexPath.isFirstRow {
            backgroundCellView.layer.cornerRadius = 10
            backgroundCellView.layer.maskedCorners = [.layerMinXMinYCorner,
                                                      .layerMaxXMinYCorner]
        } else if indexPath.row == numberOfRowsInSection - 1 {
            backgroundCellView.layer.cornerRadius = 10
            backgroundCellView.layer.maskedCorners = [.layerMinXMaxYCorner,
                                                      .layerMaxXMaxYCorner]
        } else {
            backgroundCellView.layer.cornerRadius = 0
        }
    }
}

private extension ClientTableViewCell {
    
    func configureLayout() {
        configureSuperView()
        configureTimeLabel()
        configureNameLabel()
    }
    
    func prepareLayout() {
        prepareLabels()
    }
    
    func configureSuperView() {
        backgroundColor = .clear
        separatorInset = .zero
        
        contentView.backgroundColor = .sectionBackground
    }
    
    func configureNameLabel() {
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = .systemFont(ofSize: 14, weight: .bold)
        nameLabel.textColor = .white
        nameLabel.numberOfLines = 1
        nameLabel.lineBreakMode = .byTruncatingTail
    }
    
    func configureTimeLabel() {
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.font = .systemFont(ofSize: 14, weight: .regular)
        timeLabel.textColor = .lightGray
        timeLabel.numberOfLines = 1
        nameLabel.lineBreakMode = .byTruncatingTail
    }
    
    func prepareLabels() {
        contentView.addSubview(nameLabel)
        contentView.addSubview(timeLabel)
        
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            nameLabel.bottomAnchor.constraint(equalTo: timeLabel.topAnchor),
            nameLabel.heightAnchor.constraint(equalToConstant: 20),
            
            timeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            timeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            timeLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            timeLabel.heightAnchor.constraint(equalToConstant: 20),
        ])
    }
}

struct ClientTableViewCellModel {
    let time: String
    let date: String
    let name: String
}
