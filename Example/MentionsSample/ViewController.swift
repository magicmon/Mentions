//
//  ViewController.swift
//  Mentions
//
//  Created by magicmon on 03/27/2017.
//  Copyright (c) 2017 magicmon. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var textLabel: MentionLabel!
    @IBOutlet weak var mentionTextView: MentionTextView!
    @IBOutlet weak var textField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mentionTextView.mentionText = ""
        mentionTextView.deleteType = .cancel // or .delete
        
        textLabel.pattern = .mention // or .html
        textLabel.tapHandler = { (mention) in
            let alert = UIAlertController(title: "", message: mention, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ViewController {
    @IBAction func pressedClear(_ sender: Any) {
        mentionTextView.mentionText = ""
        textLabel.text = ""
    }
    
    @IBAction func pressedAdd(_ sender: UIButton) {
        mentionTextView.insert(to: textField.text)
        
        textField.text = nil
        
        textField.resignFirstResponder()
    }
    
    @IBAction func pressedConfirm(_ sender: UIButton) {
        textLabel.text = mentionTextView.mentionText
    }
}

