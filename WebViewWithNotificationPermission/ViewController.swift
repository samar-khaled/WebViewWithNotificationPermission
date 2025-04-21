//
//  ViewController.swift
//  WebViewWithNotificationPermission
//
//  Created by Samar Khaled on 21/04/2025.
//

import UIKit
import WebKit

final class ViewController: UIViewController {
    
    // MARK: - Properties

    private lazy var webView: WKWebView = {
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.applicationNameForUserAgent = "user agent"
        let webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        webView.navigationDelegate = self
        webView.translatesAutoresizingMaskIntoConstraints = false
        return webView
    }()

    private lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.hidesWhenStopped = true
        return activityIndicator
    }()

    // MARK: - LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureWebView(urlString: "https://www.google.com")
        activityIndicator.center = view.center
        view.addSubview(activityIndicator)
    }

    // MARK: - Helpers

    private func setupUI() {
        navigationController?.setNavigationBarHidden(true, animated: false)
        view.addSubview(webView)
        webView.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor).isActive = true
        webView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor).isActive = true
        webView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
    }

    /// webView configuration
    private func configureWebView(urlString: String) {
        guard let url = URL(string: urlString) else { return }
        webView.load(URLRequest(url: url))
        let contentController = webView.configuration.userContentController
        contentController.add(self, name: "toggleMessageHandler")
    }
}

extension ViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {}
}

// MARK: - WKNavigationDelegate, WKUIDelegate

extension ViewController: WKNavigationDelegate, WKUIDelegate {}
