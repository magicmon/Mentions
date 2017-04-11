//
//  ViewController.swift
//  Mentions
//
//  Created by magicmon on 03/27/2017.
//  Copyright (c) 2017 magicmon. All rights reserved.
//

import UIKit
import Mentions

class ViewController: UIViewController {

    @IBOutlet weak var textLabel: MentionLabel!
    
    @IBOutlet weak var mentionTextView: MentionTextView!
    
    @IBOutlet weak var textField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        mentionTextView.mentionText = ""
        
        mentionTextView.becomeFirstResponder()
        
        textLabel.tapHandler = { (mention) in
            let alert = UIAlertView(title: "", message: mention, delegate: nil, cancelButtonTitle: nil, otherButtonTitles: "OK")
            alert.show()
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

