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
        
        var view2 = GFPlayerView(frame: CGRect(x: 0, y: 350, width: self.view.frame.width, height: 200))
        view2.setGifURL("HUFF2504", url: "http://media.giphy.com/media/q5D43XCcHr8v6/giphy.gif", sns: "twitter", username: "barackobama")
        view2.autoPlayEnabled = false
        self.view.addSubview(view2)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

