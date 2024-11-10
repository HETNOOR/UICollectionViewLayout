//
//  ViewController.swift
//  UICollectionViewLayout
//
//  Created by Максим Герасимов on 11.11.2024.
//

import UIKit

enum Size: Float {
    case small = 0.2
    case normal = 0.4
}

enum Alignment {
    case center
    case left
    case right
}

struct Data {
    let alignment: Alignment
    let elements: [[Size]]
}

class CustomCollectionViewLayout: UICollectionViewLayout {
    private var attributesCache: [UICollectionViewLayoutAttributes] = []
    private var contentSize: CGSize = .zero
    
    var data: Data?
    private let itemSpacing: CGFloat = 20      // Отступ между элементами
    private let rowSpacing: CGFloat = 20       // Отступ между рядами
    private let itemHeight: CGFloat = 30       // Фиксированная высота элементов

    override func prepare() {
        super.prepare()
        
        guard let collectionView = collectionView, let data = data else { return }
        
        attributesCache.removeAll()
        
        let collectionViewWidth = collectionView.bounds.width
        print(collectionViewWidth)
        var yOffset: CGFloat = 0
        
        for row in data.elements {
            // Расчет отступов для текущего ряда
            let totalItemSpacing = CGFloat(row.count - 1) * itemSpacing
            // Доступная ширина с учетом отступов
            let availableWidth = collectionViewWidth - totalItemSpacing
            var xOffset: CGFloat = 0
            
            // Суммарная ширина всех элементов в ряду с учетом доступной ширины экрана
            let rowWidth = row.reduce(0) { $0 + CGFloat($1.rawValue) * availableWidth }
            
            // Выравнивание ряда
            switch data.alignment {
            case .center:
                xOffset = (collectionViewWidth - rowWidth - totalItemSpacing) / 2
            case .left:
                xOffset = 0
            case .right:
                xOffset = collectionViewWidth - rowWidth - totalItemSpacing
            }
            
            for size in row {
                let itemWidth = CGFloat(size.rawValue) * availableWidth
                let frame = CGRect(x: xOffset, y: yOffset, width: itemWidth, height: itemHeight)
                
                let attributes = UICollectionViewLayoutAttributes(forCellWith: IndexPath(item: attributesCache.count, section: 0))
                attributes.frame = frame
                attributesCache.append(attributes)
                
                xOffset += itemWidth + itemSpacing // Учитываем отступ при смещении xOffset
            }
            
            yOffset += itemHeight + rowSpacing
        }
        
        contentSize = CGSize(width: collectionViewWidth, height: yOffset)
    }


    override var collectionViewContentSize: CGSize {
        return contentSize
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return attributesCache.filter { $0.frame.intersects(rect) }
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return attributesCache[indexPath.item]
    }
}


class CollectionViewCell: UICollectionViewCell {
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .boldSystemFont(ofSize: 12)
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        contentView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = 15
        layer.borderWidth = 3
        layer.borderColor = UIColor.blue.cgColor
    }
}

class ViewController: UIViewController {
    lazy var collectionView: UICollectionView = {
        let layout = CustomCollectionViewLayout()
        layout.data = data
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(CollectionViewCell.self, forCellWithReuseIdentifier: "CollectionViewCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .white
        return collectionView
    }()
    
    let data = Data(
        alignment: .right,
        elements: [
            [.small, .normal, .normal],
            [.small, .small, .small, .small],
            [.small, .normal, .small],
            [.normal]
        ]
    )
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Проверка данных перед передачей в макет
        showData(data: data)
        
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func showData(data: Data) {
        data.elements.forEach { row in
            if row.isEmpty {
                print("В ряду не может быть 0 элементов")
                fatalError("В ряду не может быть 0 элементов")
            }
            if row.reduce(0.0, { $0 + $1.rawValue }) > 1 {
                print("В ряду не может быть количество элементов сумма которых больше одного.")
                fatalError("В ряду не может быть количество элементов сумма которых больше одного.")
            }
        }
        
      
    }
    
    func showUI(data: Data) {
       
    }
}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.elements.flatMap { $0 }.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as! CollectionViewCell
        cell.titleLabel.text = "\(indexPath.row)"
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("indexPath = \(indexPath)")
    }
}
