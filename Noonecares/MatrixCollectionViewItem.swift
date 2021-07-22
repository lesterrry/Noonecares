//
//  MatrixCollectionViewItem.swift
//  Noonecares
//
//  Created by Lesterrry on 17.07.2021.
//

import Cocoa

class MatrixCollectionViewItem: NSCollectionViewItem {

    @IBOutlet weak var colorWell: NSColorWell!
    @IBAction func colorSelected(_ sender: Any) {
        let index = MatrixViewController.colorWellKeys.firstIndex(of: (sender as! NSColorWell).hash)
    }
    
    var index: Int! {
        didSet {
            MatrixViewController.colorWellKeys.append(colorWell.hash)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.wantsLayer = true
    }
    
}
