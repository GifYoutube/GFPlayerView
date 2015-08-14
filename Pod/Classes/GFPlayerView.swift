//
//  GFPlayerView.swift
//
//  Created by Jaehyun Jeon on 7/28/15.
//  Copyright (c) 2015 GIFS. All rights reserved.
//

import UIKit
import AVFoundation

//let GFTwitter = "twitter"
//let GFReddit = "reddit"
//let GFInstagram = "instagram"
//let GFDribbble = "dribbble"
//let GFCustomSite = "website"
//let GFAnonymous = "anonymous"

public class GFPlayerView: UIView, UIWebViewDelegate, NSURLConnectionDelegate {
    
    private var moviePlayer:AVPlayer!
    private var gifId:String!
    private var youtubeId:String!
    private var gifSet = false
    private var gifVideoId:String!
    public var autoPlayEnabled:Bool = false {
        didSet {
            if autoPlayEnabled {
                if playBtn != nil {
                    playBtn.removeFromSuperview()
                }
                if moviePlayer != nil {
                    moviePlayer.play()
                }
                started = true
            }
        }
    }
    
    private var sns:String!
    private var username:String!
    private var apiKey:String!
    public func setGifURL(apiKey: String, url: String, sns: String, username: String) {
        if !gifSet {
            gifSet = true
            self.apiKey = apiKey
            self.sns = sns
            self.username = username
            post(["sourceId":url], url: "http://test.gifs.com/convertLink", callback: { (newId) -> Void in
                self.gifId = newId
                self.gifVideoId = newId
                self.disableFullVideo()
                self.setupPlayer()
            })
        }
    }
    
    func post(params : [String:String], url : String, callback: (String) -> Void) {
        var request = NSMutableURLRequest(URL: NSURL(string: url)!)
        var session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        
        var err: NSError?
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(params, options: nil, error: &err)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        var task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in

            var err: NSError?
            var json = NSJSONSerialization.JSONObjectWithData(data, options: .MutableLeaves, error: &err) as? NSDictionary
            
            // Did the JSONObjectWithData constructor return an error? If so, log the error to the console
            if(err != nil) {
                println(err!.localizedDescription)
                let jsonStr = NSString(data: data, encoding: NSUTF8StringEncoding)
                println("Error could not parse JSON: '\(jsonStr)'")
            }
            else {
                // The JSONObjectWithData constructor didn't return an error. But, we should still
                // check and make sure that json has a value using optional binding.
                if let parseJSON = json {
                    if let newId = parseJSON["returned_val"] as? String {
                        callback(newId)
                    }
                }
                else {
                    // Woa, okay the json object was nil, something went worng. Maybe the server isn't running?
                    let jsonStr = NSString(data: data, encoding: NSUTF8StringEncoding)
                    println("Error could not parse JSON: \(jsonStr)")
                }
            }
        })
        
        task.resume()
    }
    
    public func setGifId(id: String) {
        if !gifSet {
            gifSet = true
            setupGifyt(id)
        }
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
    }
    
    func setupGifyt(id: String) {
        self.gifId = id
        getJSON(id)
    }
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @IBOutlet var shareCloseBtnW: NSLayoutConstraint!
    @IBOutlet var shareLabel: UILabel!
    @IBOutlet var shareLabelTopSpace: NSLayoutConstraint!
    @IBOutlet var playBtn: UIButton!
    @IBOutlet var panelContentHeight: NSLayoutConstraint!
    @IBOutlet var snsProfileHeight: NSLayoutConstraint!
    @IBOutlet var shareBtn: UIButton!
    @IBOutlet var fullVideoBtn: UIButton!
    @IBOutlet var panelHeight: NSLayoutConstraint!
    @IBOutlet var startBtnHeight: NSLayoutConstraint!
    func setupPlayer() {
        if self.frame.height <= 200 {
            startBtnHeight.constant = 100
            returnToGIF.titleLabel?.font = UIFont.systemFontOfSize(18)
            shareLabelTopSpace.constant = 5
            shareLabel.hidden = true
            shareCloseBtnW.constant = 15
        }
        
        if self.frame.width <= 375 {
            panelContentHeight.constant = 30
            snsProfileHeight.constant = 30
            panelHeight.constant = 40
            shareBtn.titleLabel?.font = UIFont.systemFontOfSize(18)
            fullVideoBtn.titleLabel?.font = UIFont.systemFontOfSize(18)
        }
        
        println("http://j.gifs.com/\(self.gifVideoId).mp4")
        moviePlayer = AVPlayer(URL: NSURL(string: "http://j.gifs.com/\(self.gifVideoId).mp4"))
        moviePlayer.actionAtItemEnd = AVPlayerActionAtItemEnd.None
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "playerItemDidReachEnd:",
            name: AVPlayerItemDidPlayToEndTimeNotification,
            object: moviePlayer.currentItem)
        let layer = AVPlayerLayer(player: moviePlayer)
        let lview = UIView(frame: self.view.bounds)
        layer.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        lview.layer.addSublayer(layer)
        layer.videoGravity = "fillMode"
        self.view.addSubview(lview)
        self.view.sendSubviewToBack(lview)
        
        if autoPlayEnabled {
            if playBtn != nil {
                playBtn.removeFromSuperview()
            }
            if moviePlayer != nil {
                moviePlayer.play()
            }
            started = true
        }
        
        println(moviePlayer.status.rawValue)
    }
    
    func playerItemDidReachEnd(notification: NSNotification) {
        let p: AVPlayerItem = notification.object as! AVPlayerItem
        p.seekToTime(kCMTimeZero)
    }
    
    @IBAction func onTap(sender: AnyObject) {
        if panelOn {
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.panel.frame.origin = CGPoint(x: 0, y: self.frame.height)
                self.openPanel.alpha = 1.0
            
            })
            self.panelOn = false
        } else {
            if moviePlayer != nil && started{
                if (moviePlayer.rate == 1.0) {
                    moviePlayer.pause()
                } else {
                    moviePlayer.play()
                }
            }
        }
    }
    
    @IBAction func goToGIFYT(sender: UIButton) {
        let url = NSURL(string: "http://gifs.com/gif/\(self.gifId)")
        UIApplication.sharedApplication().openURL(url!)
    }
    
    var start = 0
    @IBOutlet var tapView: UIView!
    @IBOutlet var returnToGIF: UIButton!
    var webview:UIWebView!
    @IBAction func displayFullVideo(sender: UIButton) {
        self.tapView.userInteractionEnabled = false
        moviePlayer.pause()
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.panel.frame.origin = CGPoint(x: 0, y: self.frame.height)
            self.openPanel.alpha = 1.0
        })
        panelOn = false
        
        loadView = UIView(frame: self.tapView.frame)
        loadView.backgroundColor = UIColor.blackColor()
        actInd = UIActivityIndicatorView(frame: CGRectMake(0,0, 20, 20)) as UIActivityIndicatorView
        actInd.center = loadView.center
        actInd.hidesWhenStopped = true
        actInd.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.White
        actInd.startAnimating()
        loadView.addSubview(actInd)
        tapView.addSubview(loadView)
        
        returnToGIF.hidden = false
        
        if self.youtubeId != nil {
            webview = UIWebView(frame: self.view.frame)
            webview.allowsInlineMediaPlayback = true
            webview.loadHTMLString("<html><head><title>.</title><style>body,html,iframe{margin:0;padding:0;}</style></head><body><iframe width=\"100%\"  height=\"\(self.view.frame.height)\" src=\"http://www.youtube.com/embed/\(self.youtubeId)?start=\(start)&feature=player_detailpage&playsinline=1&autoplay=1\" frameborder=\"0\" webkit-playsinline></iframe></body></html>", baseURL: nil)
            webview.scrollView.scrollEnabled = false
            webview.scrollView.showsHorizontalScrollIndicator = false
            webview.scrollView.showsVerticalScrollIndicator = false
            webview.delegate = self
            tapView.insertSubview(webview, belowSubview: loadView)
        } else {
            delay(0.5, closure: { () -> () in
                if self.loadView != nil {
                    self.loadView.removeFromSuperview()
                    self.loadView = nil
                    self.displayFullVideo(UIButton())
                }
            })
        }
    }
    
    var loadView:UIView!
    var actInd:UIActivityIndicatorView!
    public func webViewDidFinishLoad(webView: UIWebView) {
        actInd.stopAnimating()
        if self.loadView != nil {
            loadView.removeFromSuperview()
            self.loadView = nil
        }
        self.tapView.userInteractionEnabled = true
    }
    
    @IBAction func returnToGif(sender: UIButton) {
        if webview != nil {
            webview.stopLoading()
            webview.loadRequest(NSURLRequest(URL: NSURL(string: "about:blank")!))
            webview.removeFromSuperview()
        } else if loadView != nil {
            loadView.removeFromSuperview()
            self.loadView = nil
            self.tapView.userInteractionEnabled = true
        }
        returnToGIF.hidden = true
    }
    
    @IBOutlet var shareView: UIView!
    @IBAction func share(sender: UIButton) {
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.shareView.alpha = 1.0
        })
    }
    
    @IBAction func closeShare(sender: UIButton) {
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.shareView.alpha = 0.0
        })
    }
    
    var started = false
    @IBAction func startGIF(sender: UIButton) {
        if moviePlayer != nil {
            started = true
            moviePlayer.play()
            sender.removeFromSuperview()
            
            if self.panelOn {
                UIView.animateWithDuration(0.3, animations: { () -> Void in
                    self.panel.frame.origin = CGPoint(x: 0, y: self.frame.height)
                    self.openPanel.alpha = 1.0
                })
                self.panelOn = false
            }
        }
    }
    
    @IBOutlet var panel: UIView!
    @IBOutlet var openPanel: UIButton!
    var panelOn = false
    @IBAction func openPanel(sender: UIButton) {
        if moviePlayer != nil {
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.panel.frame.origin = CGPoint(x: 0, y: self.frame.height - self.panelHeight.constant)
                sender.alpha = 0.0
            })
            panelOn = true
        }
    }
    
    @IBAction func holdToCopy(sender: UIButton) {
        UIPasteboard.generalPasteboard().string = "http://gifs.com/gif/\(self.gifId)"
        
        var label = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
        label.backgroundColor = UIColor(white: 1, alpha: 0.75)
        label.layer.cornerRadius = 5
        label.clipsToBounds = true
        label.textAlignment = NSTextAlignment.Center
        label.center = self.shareView.center
        label.textColor = UIColor.whiteColor()
        label.text = "Copied!"
        label.alpha = 0
        self.shareView.addSubview(label)
        
        UIView.animateWithDuration(0.3, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
            label.alpha = 1
        }, completion: nil)
        
        delay(0.5) {
            UIView.animateWithDuration(0.3, delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
                label.alpha = 0
                }, completion: nil)
        }
    }
    
    @IBAction func copyEmbed(sender: UIButton) {
        UIPasteboard.generalPasteboard().string = "<iframe src='http://gifs.com/embed/\(self.gifId)' frameborder='0' scrolling='no' width='360px' height='270px' style='-webkit-backface-visibility: hidden;-webkit-transform: scale(1);'' ></iframe>"
        
        var label = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
        label.backgroundColor = UIColor(white: 1, alpha: 0.75)
        label.layer.cornerRadius = 5
        label.clipsToBounds = true
        label.textAlignment = NSTextAlignment.Center
        label.center = self.shareView.center
        label.textColor = UIColor.whiteColor()
        label.text = "Copied!"
        label.alpha = 0
        self.shareView.addSubview(label)
        
        UIView.animateWithDuration(0.3, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
            label.alpha = 1
            }, completion: nil)
        
        delay(0.5) {
            UIView.animateWithDuration(0.3, delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
                label.alpha = 0
                }, completion: nil)
        }
    }
    
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
    @IBAction func shareOnSNS(sender: UIButton) {
        let gifytURL = "http://gifs.com/gif/\(self.gifId)"
        
        if sender.titleLabel?.text == "facebook" {
            UIApplication.sharedApplication().openURL(NSURL(string: "http://www.facebook.com/share.php?u=\(gifytURL)")!)
        } else if sender.titleLabel?.text == "twitter" {
            UIApplication.sharedApplication().openURL(NSURL(string: "http://twitter.com/intent/tweet?status=\(gifytURL)")!)
        } else if sender.titleLabel?.text == "tumblr" {
            UIApplication.sharedApplication().openURL(NSURL(string: "http://www.tumblr.com/share?v=3&u=\(gifytURL)")!)
        } else if sender.titleLabel?.text == "pinterest" {
            UIApplication.sharedApplication().openURL(NSURL(string: "https://www.pinterest.com/pin/create/button/?url=\(gifytURL)")!)
        } else if sender.titleLabel?.text == "reddit" {
            UIApplication.sharedApplication().openURL(NSURL(string: "http://www.reddit.com/submit?url=\(gifytURL)")!)
        } else if sender.titleLabel?.text == "email" {
            UIApplication.sharedApplication().openURL(NSURL(string: "mailto:?body=\(gifytURL)")!)
        }
    }
    
    lazy var data = NSMutableData()
    func getJSON(id: String){
        let urlPath: String = "http://wasted.gifyoutube.com/info/\(id)"
        var url: NSURL = NSURL(string: urlPath)!
        var request: NSURLRequest = NSURLRequest(URL: url)
        var connection1 = NSURLConnection(request: request, delegate: self, startImmediately: false)!
        connection1.start()
    }
    
    func connection(connection: NSURLConnection!, didReceiveData data: NSData!){
        self.data.appendData(data)
    }
    @IBOutlet var separator1: UIImageView!
    @IBOutlet var separator2: UIImageView!
    
    @IBOutlet var shareRight: NSLayoutConstraint!
    private var snsLink:String!
    func connectionDidFinishLoading(connection: NSURLConnection!) {
        var err: NSError
        
        var jsonResult: NSDictionary = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil) as! NSDictionary
        
        if let yid = jsonResult["yid"] as? String {
            if yid != "" {
                self.youtubeId = yid
            } else {
                disableFullVideo()
            }
        } else {
            disableFullVideo()
        }
        
        if let id = jsonResult["actualId"] as? String {
            self.gifVideoId = id
            setupPlayer()
        } else {
            self.gifVideoId = self.gifId
            setupPlayer()
        }
            
        if let time = jsonResult["start"] as? String {
            self.start = time.toInt()!
        }
        
        if let link = jsonResult["url"] as? String {
            if link != "" {
                self.snsLink = link
            }
        }

        if let str = jsonResult["image"] as? String {
            if str != "" {
                if let checkedUrl = NSURL(string: str) {
                    downloadImage(checkedUrl)
                }
            }
        }
        
    }
    
    func disableFullVideo() {
        separator1.removeFromSuperview()
        fullVideoBtn.removeFromSuperview()
        shareRight.active = false
        var l = NSLayoutConstraint(item: separator2, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: shareBtn, attribute: NSLayoutAttribute.Trailing, multiplier: 1, constant: 8)
        l.active = true
    }
    
    @IBOutlet var profile: UIButton!
    func downloadImage(url:NSURL){
        getDataFromUrl(url) { data in
            dispatch_async(dispatch_get_main_queue()) {
                self.profile.setBackgroundImage(UIImage(data: data!), forState: UIControlState.Normal)
                self.profile.imageView?.contentMode = UIViewContentMode.ScaleAspectFill
                self.profile.layer.cornerRadius = self.profile.frame.height / 2.0
            }
        }
    }
    
    func getDataFromUrl(urL:NSURL, completion: ((data: NSData?) -> Void)) {
        NSURLSession.sharedSession().dataTaskWithURL(urL) { (data, response, error) in
            completion(data: data)
            }.resume()
    }
    

    @IBAction func goToProfile(sender: AnyObject) {
        if snsLink != nil {
            if snsLink != "" {
                UIApplication.sharedApplication().openURL(NSURL(string: snsLink)!)
            }
        }
    }
    
    var view: UIView!
    func xibSetup() {
        view = loadViewFromNib()
        view.frame = bounds
        view.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleHeight
        addSubview(view)
    }
    
    func loadViewFromNib() -> UIView {
        let bundle = NSBundle(forClass: self.dynamicType)
        let nib = UINib(nibName: "GFPlayerView", bundle: bundle)
        let view = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
        return view
    }
}
