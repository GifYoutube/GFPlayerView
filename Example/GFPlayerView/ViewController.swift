//
//  ViewController.swift
//  GFPlayerView
//
//  Created by jeon97 on 08/12/2015.
//  Copyright (c) 2015 jeon97. All rights reserved.
//

import UIKit
import GFPlayerView

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        var view = GFPlayerView(frame: CGRect(x: 0, y: 50, width: self.view.frame.width, height: 200))
        view.setGifId("mlLr7a")
        view.autoPlayEnabled = true
        self.view.addSubview(view)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

