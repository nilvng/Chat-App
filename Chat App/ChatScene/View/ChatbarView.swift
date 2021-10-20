//
//  ChatboxView.swift
//  Chat App
//
//  Created by Nil Nguyen on 9/29/21.
//

import UIKit

protocol ChatBarDelegate {
    func keyboardMoved(keyboardFrame: NSValue, moveUp: Bool, animateDuration: Double)
    func messageSubmitted(message: String)
}
class ChatbarView: UIView {

    var delegate : ChatBarDelegate?
    
    var textView : UITextView = {
        let tview = UITextView()
        tview.isScrollEnabled = false
        tview.font = UIFont(name: "Arial", size: 16)
        return tview
    }()
    
    private var submitButton : UIButton = {
        let button = UIButton()
        button.setImage(.btn_send_forboy, for: .normal)
        button.setImage(.btn_send_forboy_disabled, for: .disabled)

        return button
    }()
    var separatorLine : UIView = {
        let line = UIView()
        line.backgroundColor = UIColor(white: 0.5, alpha: 0.5)
        return line
    }()

    init() {
        super.init(frame: .zero)
        
        backgroundColor = .white
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardMoving), name: UIResponder.keyboardDidShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardMoving), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        
        setupSubmitButton()
        setupTextView()
        setupSeparatorLine()
        
        submitButton.addTarget(self, action: #selector(submitButtonPressed), for: .touchUpInside)
        textView.delegate = self
    }
    
    func setupTextView(){
        addSubview(textView)
        textView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            textView.bottomAnchor.constraint(equalTo: bottomAnchor, constant:  -5),
            textView.topAnchor.constraint(equalTo: topAnchor, constant:  5),
            textView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            textView.trailingAnchor.constraint(equalTo: submitButton.leadingAnchor, constant:  -5),

        ])
        textView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    }
    
    func setupSubmitButton(){
        addSubview(submitButton)
        submitButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            submitButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            submitButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            submitButton.widthAnchor.constraint(equalToConstant: 50),
            submitButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        submitButton.setContentHuggingPriority(.defaultLow, for: .horizontal)

    }
    
    func setupSeparatorLine(){
        addSubview(separatorLine)
        separatorLine.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            separatorLine.topAnchor.constraint(equalTo: topAnchor, constant: -5),
                separatorLine.leadingAnchor.constraint(equalTo: leadingAnchor),
                separatorLine.trailingAnchor.constraint(equalTo: trailingAnchor),
            separatorLine.heightAnchor.constraint(equalToConstant: 0.7)
        ])
    }

    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    @objc func handleKeyboardMoving(notification: NSNotification){
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue? else {
            return
        }
        print("Keyboard is moving...")
        let moveUp = notification.name == UIResponder.keyboardDidShowNotification
        let animateDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        delegate?.keyboardMoved(keyboardFrame: keyboardFrame, moveUp: moveUp, animateDuration: animateDuration)
        
    }

    @objc func submitButtonPressed(){
        print("submit button pressed")
        
        sendMessage(textView.text)
        
    }
}

extension ChatbarView : UITextViewDelegate{
    fileprivate func sendMessage(_ text: String) {
        if  text != ""{
            ///  remove leading and trailing whitespace
            let cleanValue = text.trimmingCharacters(in: .whitespacesAndNewlines)
            print("about to submit \(cleanValue)")
            
            delegate?.messageSubmitted(message: cleanValue)
            // clear chat bar
            textView.text = ""

            }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if let originalText = textView.text {
            
            // Send message
            if text == "\n" {
                // Usual edit message
                let title = (originalText as NSString).replacingCharacters(in: range, with: text)
                sendMessage(title)
                return false
            }
        }
        return true

    }

}
