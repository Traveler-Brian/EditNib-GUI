//
//  ViewController.swift
//  EditNib GUI
//
//  Created by 黃浩源 on 2020/02/24.
//  Copyright © 2020 黃浩源. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    
    var editNibDirectory = ""

    @IBOutlet weak var Convt: NSButton!
    @IBOutlet weak var selectFd: NSButton!
    @IBOutlet var logs: NSTextView!
    @IBOutlet weak var InputFolderPath: NSTextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        InputFolderPath.isEditable = false
        logs.isEditable = false
        log(Message: "Getting Current Directory...")
        var appURL = URL(fileURLWithPath: Bundle.main.bundleURL.absoluteString)
        appURL.deleteLastPathComponent()
        self.editNibDirectory = "'\(appURL.path)/EditNib GUI.app/Contents/Resources/editnib'";
            
        do{
            try shellOut(to: "cd '\(appURL.path)/EditNib GUI.app/'")
            log(Message: "Executable File Exist...")
        }catch{
            dialogOKCancel(Title: "Error! Failed To Access!", Content: "Cannot access the executable file in the application content!\nMaybe the application name has been changed or the directory is not allowed to access!")
            exit(0);
        }
        
    }
    
    func editNib(Path:String) -> String
    {
        let Command = "\(self.editNibDirectory) \(Path)"
        var Status = "Normal"
        do{
            try shellOut(to: Command)
        }catch{
            let error = error as? ShellOutError
            Status = error!.message
        }
        return Status
    }
    
    func dialogOKCancel(Title: String, Content: String) -> Bool {
        let alert = NSAlert()
        alert.messageText = Title
        alert.informativeText = Content
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK")
        return alert.runModal() == .alertFirstButtonReturn
    }
    
    func log(Message:String){
        let hour = Calendar.current.component(.hour, from: Date())
        let minute = Calendar.current.component(.minute, from: Date())
        let second = Calendar.current.component(.second, from: Date())
        self.logs.string += "[\(hour):\(minute):\(second)] \(Message)\n"
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    @IBAction func SelectFolder(_ sender: Any) {
        
        let dialog = NSOpenPanel();
        
        dialog.title                   = "Select a folder...";
        dialog.showsResizeIndicator    = false;
        dialog.showsHiddenFiles        = false;
        dialog.canChooseDirectories    = true;
        dialog.canCreateDirectories    = false;
        dialog.allowsMultipleSelection = false;
        dialog.allowedFileTypes        = [String(Int.random(in: 100000...999999))];

        if (dialog.runModal() == NSApplication.ModalResponse.OK) {
            let result = dialog.url // Pathname of the file
            
            if (result != nil) {
                let path = result!.path
                self.InputFolderPath.stringValue = path + "/"
                log(Message: "User selected: " + self.InputFolderPath.stringValue)
            }
        } else {
            // User clicked on "Cancel"
            return
        }
        
        
    }
    @IBAction func ConvertButtonPressed(_ sender: Any) {
        
        log(Message: "Convert! button clicked...")
        
        if(self.InputFolderPath.stringValue == ""){
            log(Message: "Nothing Selected Message Poped Up...")
            dialogOKCancel(Title: "Nothing Selected!", Content: "Please Select a Folder which Contains nib Files!")
        }else{
            
            var FilesExist = true
            
            do{
                try shellOut(to: "cd \(InputFolderPath.stringValue)")
                do{
                    try shellOut(to: "cd \(InputFolderPath.stringValue);ls *.nib")
                }catch{
                    FilesExist = false
                    dialogOKCancel(Title: "Error!", Content: "No Nib Files Found!")
                }
            }catch{
                FilesExist = false
                dialogOKCancel(Title: "Error!", Content: "Directory May Not Exist!")
            }
            
            
            if(FilesExist){
             log(Message: "File Exist...")
                let InputFilesName = try? shellOut(to: "cd \(InputFolderPath.stringValue);ls *.nib")
                let lines = InputFilesName!.split(separator:"\n")
                var filesCount = 0
                var failedFiles = 0
                var processedFiles = 0;
                var ErrorMessage = "";
                
                for InputFilesName in lines{
                    filesCount += 1;
                }
                log(Message: "\(filesCount) files found...")
                log(Message: "Starting to convert...")
                self.selectFd.isEnabled = false
                self.Convt.isEnabled = false
                
                    for InputFilesName in lines{
                        let ReturnedVal = self.editNib(Path: "\(self.InputFolderPath.stringValue)\(InputFilesName)")
                        
                        if(ReturnedVal == "Normal"){
                            processedFiles += 1
                            self.log(Message: "\(processedFiles)/\(filesCount) file(s) processed!")
                        }else{
                            processedFiles += 1;
                            self.log(Message: "\(processedFiles)/\(filesCount) file(s) processed!")
                            failedFiles += 1
                            self.log(Message: "File: \(self.InputFolderPath.stringValue)\(InputFilesName) failed with message: \(ReturnedVal)")
                            ErrorMessage += "\(ReturnedVal)\n"
                        }
                    }
                
                if(failedFiles > 0)
                {
                    dialogOKCancel(Title: "Convertion Finished! \(failedFiles) Files Failed!", Content: "Details:\n\(ErrorMessage)")
                }else{
                    dialogOKCancel(Title: "Convertion Finished! All Files Are Converted!", Content: "You have already converted all files. But they may not be able to opened because of some unknown reasons.")
                }
                
                self.selectFd.isEnabled = true
                self.Convt.isEnabled = true
            }
            
            
        }
        
    }
    

}

