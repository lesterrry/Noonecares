//
//  MatrixViewController.swift
//  Noonecares
//
//  Created by Lesterrry on 17.07.2021.
//

import Cocoa

class MatrixViewController: NSViewController {
    
    static var colorWellKeys: [Int] = []
    
    @IBOutlet weak var collectionView: NSCollectionView!

    @IBAction func drawButtonPressed(_ sender: Any) {
        print(MatrixViewController.colorWellKeys)
    }
    @IBAction func saveButtonPressed(_ sender: Any) {
        
    }
    @IBAction func copyButtonPressed(_ sender: Any) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.register(MatrixCollectionViewItem.self, forItemWithIdentifier: NSUserInterfaceItemIdentifier(rawValue: "Item"))
    }
    
}

extension MatrixViewController : NSCollectionViewDataSource {
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return 432
    }
  
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "Item"), for: indexPath)
        
        guard let collectionViewItem = item as? MatrixCollectionViewItem else { return item }
        collectionViewItem.index = 9
        return item
    }
}
