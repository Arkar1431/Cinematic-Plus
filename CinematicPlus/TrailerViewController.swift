//
//  TrailerViewController.swift
//  CinematicPlus
//
//  Created by Mac on 9/11/24.
//

import UIKit
import WebKit

class TrailerViewController: UIViewController {

    var trailerURL: String?
    private var webView: WKWebView!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        // Set up the web view
        webView = WKWebView(frame: view.bounds)
        view.addSubview(webView)

        // Load the trailer URL
        guard let trailerURLString = trailerURL else { return }
        if let trailerURL = URL(string: trailerURLString) {
            let request = URLRequest(url: trailerURL)
            webView.load(request)
        } else {
            print("Invalid trailer URL")
        }
    }
}
