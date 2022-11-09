//
//  ViewController.swift
//  SJWaterFallLayout
//
//  Created by MartinChristopher on 11/08/2022.
//  Copyright (c) 2022 MartinChristopher. All rights reserved.
//

import UIKit
import SJWaterFallLayout

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension ViewController: SJWaterFallLayoutDelegate {
    
    func setItemHeight(layouyt: SJWaterFallLayout, indexPath: IndexPath, itemWidth: CGFloat) -> CGFloat {
        return 0
    }
    
}
