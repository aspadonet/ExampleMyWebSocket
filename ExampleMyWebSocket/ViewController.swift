//
//  ViewController.swift
//  ExampleMyWebSocket
//
//  Created by Alexander Avdacev on 10.04.22.
//

import UIKit

class ViewController: UIViewController, URLSessionWebSocketDelegate {

    var webSocket: URLSessionWebSocketTask?
    
    private let closeButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .white
        button.setTitle("Close", for: .normal)
        button.setTitleColor(.blue, for: .normal)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBlue
        
        let session = URLSession(configuration: .default,
                                 delegate: self,
                                 delegateQueue: OperationQueue()
        )
        
        let url = URL(string: "wss://demo.piesocket.com/v3/channel_1?api_key=oCdCMcMPQpbvNjUIzqtvF1d2X2okWpDQj4AwARJuAgtjhzKxVEjQU6IdCjwm&notify_self")
        
        let webSocket = session.webSocketTask(with: url!)
        webSocket.resume()
        
        closeButton.frame = CGRect(x: 0, y: 0, width: 200, height: 50)
        view.addSubview(closeButton)
        closeButton.addTarget(self, action: #selector(close), for: .touchUpInside)
        closeButton.center = view.center
    }
      
    func ping() {
        webSocket?.sendPing(pongReceiveHandler: { error in
            if let error = error {
                print("Ping error: \(error)")
            }
        })
    }
    @objc func close() {
        webSocket?.cancel(with: .goingAway, reason: "Demo ended".data(using: .utf8))
    }
    func send() {
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
            self.send()
            self.webSocket?.send(.string("Send new maessage: \(Int.random(in: 0...1000))"), completionHandler: { error in
                if let error = error {
                    print("Send error: \(error)")
                }
            })
        }
        
    }
    func receive() {
        webSocket?.receive(completionHandler: { [weak self] result in
            
            //guard let self = self else { return }
            
            switch result {
                
            case .success(let message):
                switch message {
                    
                case .data(let data):
                    print("Got Data: \(data)")
                case .string(let message):
                    print("Got Data: \(message)")
                @unknown default:
                    break
                }
            case .failure(let error):
                print("Receive error: \(error)")
            }
            
            self?.receive()
        })
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
                print("Did connect to socket")
                ping()
                receive()
                send()
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        print("Did close with session")
    }

}

