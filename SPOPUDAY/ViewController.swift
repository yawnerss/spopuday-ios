import UIKit
import WebKit
import MediaPlayer

class ViewController: UIViewController, WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler {

    private var webView: WKWebView!
    private var loadingIndicator: UIActivityIndicatorView!
    private var serverUrl: String = "http://localhost:5000"

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.05, green: 0.05, blue: 0.05, alpha: 1.0)

        // Load saved server URL if customized
        if let saved = UserDefaults.standard.string(forKey: "spopuday_server_url"), !saved.isEmpty {
            serverUrl = saved
        }

        setupWebView()
        setupLoadingIndicator()
        setupRemoteCommandCenter()
        loadApp()
    }

    private func setupWebView() {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []

        // Register script message handler
        let contentController = WKUserContentController()
        contentController.add(self, name: "iosBridge")

        // Lock viewport zoom
        let viewportScript = """
        var meta = document.querySelector('meta[name=viewport]');
        if (meta) {
            meta.setAttribute('content', 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no, viewport-fit=cover');
        }
        """
        let userScript = WKUserScript(source: viewportScript, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        contentController.addUserScript(userScript)
        config.userContentController = contentController

        webView = WKWebView(frame: view.bounds, configuration: config)
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.isOpaque = false
        webView.backgroundColor = UIColor(red: 0.05, green: 0.05, blue: 0.05, alpha: 1.0)
        webView.scrollView.backgroundColor = UIColor(red: 0.05, green: 0.05, blue: 0.05, alpha: 1.0)
        webView.scrollView.contentInsetAdjustmentBehavior = .never

        // Pull to refresh
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor(red: 0.11, green: 0.73, blue: 0.33, alpha: 1.0)
        refreshControl.addTarget(self, action: #selector(refreshPage), for: .valueChanged)
        webView.scrollView.refreshControl = refreshControl

        view.addSubview(webView)
    }

    private func setupLoadingIndicator() {
        loadingIndicator = UIActivityIndicatorView(style: .large)
        loadingIndicator.color = UIColor(red: 0.11, green: 0.73, blue: 0.33, alpha: 1.0) // SPOPUDAY green
        loadingIndicator.center = view.center
        loadingIndicator.hidesWhenStopped = true
        view.addSubview(loadingIndicator)
    }

    @objc private func refreshPage() {
        webView.reload()
    }

    private func loadApp() {
        guard let url = URL(string: serverUrl) else { return }
        loadingIndicator.startAnimating()
        let request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 15.0)
        webView.load(request)
    }

    // MARK: - WKNavigationDelegate
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        loadingIndicator.stopAnimating()
        webView.scrollView.refreshControl?.endRefreshing()
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        loadingIndicator.stopAnimating()
        webView.scrollView.refreshControl?.endRefreshing()
        showConnectionErrorAlert(error: error.localizedDescription)
    }

    private func showConnectionErrorAlert(error: String) {
        let alert = UIAlertController(
            title: "Cannot Connect to SPOPUDAY",
            message: "Unable to reach server at \(serverUrl).\n\nEnsure your SPOPUDAY server is running or enter your server IP address.",
            preferredStyle: .alert
        )

        alert.addTextField { textField in
            textField.placeholder = "http://192.168.1.xxx:5000"
            textField.text = self.serverUrl
            textField.keyboardType = .URL
        }

        alert.addAction(UIAlertAction(title: "Retry", style: .default) { [weak self] _ in
            if let text = alert.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines), !text.isEmpty {
                self?.serverUrl = text
                UserDefaults.standard.set(text, forKey: "spopuday_server_url")
            }
            self?.loadApp()
        })

        present(alert, animated: true)
    }

    // MARK: - WKScriptMessageHandler (Bridge with SPOPUDAY)
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let body = message.body as? [String: Any] else { return }

        let isPlaying = body["playing"] as? Bool ?? false
        let title = body["title"] as? String ?? "SPOPUDAY"
        let artist = body["artist"] as? String ?? ""

        updateNowPlayingInfo(title: title, artist: artist, isPlaying: isPlaying)
    }

    // MARK: - Lock Screen & Control Center Media Controls
    private func setupRemoteCommandCenter() {
        let commandCenter = MPRemoteCommandCenter.shared()

        commandCenter.playCommand.addTarget { [weak self] _ in
            self?.webView.evaluateJavascript("togglePlay()", completionHandler: nil)
            return .success
        }

        commandCenter.pauseCommand.addTarget { [weak self] _ in
            self?.webView.evaluateJavascript("togglePlay()", completionHandler: nil)
            return .success
        }

        commandCenter.togglePlayPauseCommand.addTarget { [weak self] _ in
            self?.webView.evaluateJavascript("togglePlay()", completionHandler: nil)
            return .success
        }

        commandCenter.nextTrackCommand.addTarget { [weak self] _ in
            self?.webView.evaluateJavascript("next(false)", completionHandler: nil)
            return .success
        }

        commandCenter.previousTrackCommand.addTarget { [weak self] _ in
            self?.webView.evaluateJavascript("prev()", completionHandler: nil)
            return .success
        }
    }

    private func updateNowPlayingInfo(title: String, artist: String, isPlaying: Bool) {
        var info = [String: Any]()
        info[MPMediaItemPropertyTitle] = title
        info[MPMediaItemPropertyArtist] = artist
        info[MPMediaItemPropertyAlbumTitle] = "SPOPUDAY"
        info[MPNowPlayingInfoPropertyPlaybackRate] = isPlaying ? 1.0 : 0.0

        if let image = UIImage(named: "icon-1024") {
            info[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: image.size) { _ in image }
        }

        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }
}

