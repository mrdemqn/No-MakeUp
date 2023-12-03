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
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureLayout()
        prepareLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupCell(model: ClientTableViewCellModel) {
        timeLabel.text = "Time: \(model.time)| Date: \(model.date)"
        nameLabel.text = model.name
    }
}

private extension ClientTableViewCell {
    
    func configureLayout() {
        configureSuperView()
        configureBackgroundCellView()
        configureTimeLabel()
        configureNameLabel()
    }
    
    func prepareLayout() {
        prepareBackgroundCellView()
        prepareTimeLabel()
        prepareNameLabel()
    }
    
    func configureSuperView() {
        backgroundColor = .clear
        selectionStyle = .none
    }
    
    func configureBackgroundCellView() {
        backgroundCellView.translatesAutoresizingMaskIntoConstraints = false
        backgroundCellView.backgroundColor = .darkGray
        backgroundCellView.layer.cornerRadius = 20
    }
    
    func configureTimeLabel() {
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.font = .systemFont(ofSize: 12)
    }
    
    func configureNameLabel() {
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = .systemFont(ofSize: 10)
        nameLabel.numberOfLines = 0
    }
    
    func prepareBackgroundCellView() {
        addSubview(backgroundCellView)
        
        NSLayoutConstraint.activate([
            backgroundCellView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            backgroundCellView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            backgroundCellView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15),
            backgroundCellView.bottomAnchor.constraint(equalTo: bottomAnchor),
            backgroundCellView.heightAnchor.constraint(equalToConstant: 100),
        ])
    }
    
    func prepareTimeLabel() {
        backgroundCellView.addSubview(timeLabel)
        
        NSLayoutConstraint.activate([
            timeLabel.topAnchor.constraint(equalTo: backgroundCellView.topAnchor, constant: 10),
            timeLabel.leadingAnchor.constraint(equalTo: backgroundCellView.leadingAnchor, constant: 15),
            timeLabel.bottomAnchor.constraint(equalTo: backgroundCellView.bottomAnchor, constant: -10),
        ])
    }
    
    func prepareNameLabel() {
        backgroundCellView.addSubview(nameLabel)
        
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: backgroundCellView.topAnchor, constant: 10),
            nameLabel.leadingAnchor.constraint(equalTo: timeLabel.trailingAnchor, constant: 20),
            nameLabel.trailingAnchor.constraint(equalTo: backgroundCellView.trailingAnchor, constant: -15),
            nameLabel.bottomAnchor.constraint(equalTo: backgroundCellView.bottomAnchor, constant: -10),
        ])
    }
}

struct ClientTableViewCellModel {
    let time: String
    let date: String
    let name: String
}
