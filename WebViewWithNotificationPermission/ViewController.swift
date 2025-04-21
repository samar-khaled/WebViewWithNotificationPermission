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
        configureWebView()
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

    private func configureWebView() {
        guard let url = Bundle.main.url(forResource: "NotificationPage", withExtension: "html") else { return }
        webView.load(URLRequest(url: url))
        let contentController = webView.configuration.userContentController
        contentController.add(self, name: "observer")
    }
}

extension ViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, _ in
            print("Permission granted: \(granted)")
            self?.showAlert(granted: granted)
        }
    }
    
    private func showAlert(granted: Bool) {
        DispatchQueue.main.async { [weak self] in
            let alertController = UIAlertController(
                title: "Permission Status",
                message: "Permission granted: \(granted)",
                preferredStyle: .alert
            )
            alertController.addAction(UIAlertAction(title: "OK", style: .default))
            if !granted {
                alertController.addAction(UIAlertAction(title: "Settings", style: .default) { _ in
                    if let appSettings = URL(string: UIApplication.openSettingsURLString) {
                        if UIApplication.shared.canOpenURL(appSettings) {
                            UIApplication.shared.open(appSettings, options: [:], completionHandler: nil)
                        }
                    }

                })
            }
            self?.present(alertController, animated: true)
        }
    }
}

// MARK: - WKNavigationDelegate, WKUIDelegate

extension ViewController: WKNavigationDelegate, WKUIDelegate {}
