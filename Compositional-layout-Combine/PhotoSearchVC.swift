//
//  ViewController.swift
//  Compositional-layout-Combine
//
//  Created by Tsering Lama on 10/29/20.
//

import UIKit
import Combine // asynchronous programming framework iOS 13

class PhotoSearchVC: UIViewController {
    
    enum SectionKind: Int, CaseIterable {
        case main
    }
    
    // declare collectionView
    private var collectionView: UICollectionView!
    
    // declare DataSource
    typealias DataSource = UICollectionViewDiffableDataSource<SectionKind, Int>
    private var dataSource: DataSource!
    
    // declare search controller
    private var searchController: UISearchController!
    
    // declare searchtext property that will be a 'publisher' - that listens for changes from the searchBar on the search controller
    // in order to make any property a publisher you need to append the @Publisher property wrapper
    // to subscribe to the searchtext's 'Publisher' a $ needs to be prefixed to searchText ==> $earchText
    
    @Published private var searchText = ""
    
    // store subscriptions
    private var subscriptions: Set<AnyCancellable> = []

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Photo Search"
        configureCollectionView()
        configureDataSource()
        configureSearchController()
        
        // subscribe to the searchText 'Publisher'
        $searchText.sink { (text) in
            print(text)
        }
        .store(in: &subscriptions)
    }
    
    private func configureCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.register(ImageCell.self, forCellWithReuseIdentifier: ImageCell.reuseIdentifier)
        collectionView.backgroundColor = .systemBackground
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(collectionView)
    }
    
    private func configureSearchController() {
        searchController = UISearchController(searchResultsController: nil)
        navigationItem.searchController = searchController
        searchController.searchResultsUpdater = self // delegate
        searchController.searchBar.autocapitalizationType = .none
        searchController.obscuresBackgroundDuringPresentation = false
    }

    private func createLayout() -> UICollectionViewLayout {
        
        let layout = UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
            
            // item
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            let itemSpacing: CGFloat = 5
            item.contentInsets = NSDirectionalEdgeInsets(top: itemSpacing, leading: itemSpacing, bottom: itemSpacing, trailing: itemSpacing)
            
            // group (leading, trailing, nested)
            let innerGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(1.0))
            let leadingGroup = NSCollectionLayoutGroup.vertical(layoutSize: innerGroupSize, subitem: item, count: 2)
            let trailingGroup = NSCollectionLayoutGroup.vertical(layoutSize: innerGroupSize, subitem: item, count: 3)
            
            let nestedGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(1000))
            let nestedGroup = NSCollectionLayoutGroup.horizontal(layoutSize: nestedGroupSize, subitems: [leadingGroup, trailingGroup])
            
            // section
            let section = NSCollectionLayoutSection(group: nestedGroup)
            
            return section
        }
        return layout
    }
    
    private func configureDataSource() {
        
        // initializing datasource
        dataSource = DataSource(collectionView: collectionView, cellProvider: { (collectionView, indexPath, int) -> UICollectionViewCell? in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCell.reuseIdentifier, for: indexPath) as? ImageCell else {
                fatalError()
            }
            cell.backgroundColor = .systemGray
            return cell
        })
        
        // setup initial snapshot
        var snapshot = dataSource.snapshot() // current snapshot
        snapshot.appendSections([.main])
        snapshot.appendItems(Array(1...100))
        dataSource.apply(snapshot, animatingDifferences: false)
    }
}

extension PhotoSearchVC: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text, !text.isEmpty else {
            return
        }
        searchText = text
        // upon assigning a new value to the searchText
        // the subscriber in the viewDidLoad will receive that value 
    }
}
