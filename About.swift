//
//  About.swift
//  EditNib GUI
//
//  Created by 黃浩源 on 2020/02/24.
//  Copyright © 2020 黃浩源. All rights reserved.
//

import Cocoa

class About: NSViewController {

    override func viewDidAppear() {
        self.view.window?.styleMask.remove(NSWindow.StyleMask.resizable)
        //Make the window not resizable
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    @IBAction func JohnSundell(_ sender: Any) {
        
        try? shellOut(to: "open https://github.com/JohnSundell")
        
    }
    @IBAction func SeanZhu(_ sender: Any) {
        
        try? shellOut(to: "https://github.com/szhu")
        
    }
    
}
