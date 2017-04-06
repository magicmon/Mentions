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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        mentionTextView.mentionText = "123[test2]"
        
        mentionTextView.becomeFirstResponder()
        
        textLabel.tapHandler = { (user) in
            let alert = UIAlertView(title: "", message: user, delegate: nil, cancelButtonTitle: nil, otherButtonTitles: "OK")
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
        mentionTextView.mentionText = "123[test2]"
    }
    
    @IBAction func pressedConfirm(_ sender: UIButton) {
//        textLabel.text = mentionTextView.mentionText
        
        mentionTextView.insert(to: "test1", with: NSRange.init(location: 0, length: 2))
    }
}

