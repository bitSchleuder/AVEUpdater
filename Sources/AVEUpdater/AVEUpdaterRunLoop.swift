//
//  File.swift
//  
//
//  Created by Florian Schebelle on 23.11.19.
//
import Foundation

enum ArgumentType {
    case EXE
    case MODE
    case DPATH
    case IPATH
    case DEBUG
}

enum AVEUpdateMode {
    case download
    case install
}

class AVEUpdaterRunLoop {
    
    var status = 0;
    var timer: Timer?;
    var runLoop: CFRunLoop?;
    var mode = AVEUpdateMode.install;
    var DEBUG = false;
    
    init(rLoop: CFRunLoop) {
        setbuf(__stdoutp, nil);
        runLoop = rLoop
        if #available(OSX 10.12, *) {
            timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) {timer in
                self.writeToStdout()
            }
        } else {
            print("Unsupported version \(ProcessInfo.processInfo.operatingSystemVersion)");
        }
    }
    
    @objc public func isDebugMode() {
        self.DEBUG = true;
    }
    
    @objc private func writeToStdout(){
        if(self.status <= 100){
            if(self.mode == AVEUpdateMode.download){
                fputs("\(self.status)\n", stdout);
                self.status += 1;
            } else {
                fputs("\(self.status)\n", stdout);
                self.status += 2;
                
            }
        }else{
            if(self.status == 100){
                fputs(" ", stdout);
            }
            self.status += 1;
        }
        
        if(self.status > 150){
            self.timer?.invalidate();
            CFRunLoopStop(self.runLoop);
        }
        
    }
    
    @objc public func setMode(value: String){
        if(value == "download"){
            self.mode = AVEUpdateMode.download;
        }
    }
    
    @objc public func readMode(arg: String) -> String {
        return self.readValue(regex: "=(download|install)", mode: arg);
    }
    
    @objc public func readDPath(arg: String) -> String {
        return self.readValue(regex: "=[ a-zA-Z0-9/]+", mode: arg);
    }
    
    @objc public func readIPath(arg: String) -> String {
        return self.readValue(regex: "=[ a-zA-Z0-9/]+", mode: arg);
    }
    
    @objc private func readValue(regex: String, mode: String) -> String {
        if(mode.count < 1) {return ""}
        do {
            let regex = try NSRegularExpression(pattern: regex);
            let results = regex.matches(in: mode,
                                        range: NSRange(mode.startIndex..., in: mode))
            
            return String(String(mode[Range(results[0].range, in: mode)!]).dropFirst())
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return ""
        }
    }
    
    public func getArgument(arguments: [String]?, forType: ArgumentType) -> String {
        switch forType {
            case .EXE:
                return arguments?[0] ?? "NO_EXEC";
            case .MODE:
                return arguments!.filter {$0.contains("-MODE=")}.count > 0 ? arguments!.filter {$0.contains("-MODE=")}[0] : "=install";
            case .DPATH:
                return arguments!.filter {$0.contains("-DOWNLOAD_DIR=")}.count > 0 ? arguments!.filter {$0.contains("-DOWNLOAD_DIR=")}[0] : "=/tmp/AVP/Download";
            case .IPATH:
                return arguments!.filter {$0.contains("-INSTALL_DIR=")}.count > 0 ? arguments!.filter {$0.contains("-INSTALL_DIR=")}[0] : "=/tmp/AVP/AVE";
            case .DEBUG:
                return arguments!.filter {$0.contains("--debug")}.count > 0 ? arguments!.filter {$0.contains("--debug")}[0] : "";
        }
    }
    
    public func getVersion(fileName: String) {
        let range = NSRange(location: 0, length: fileName.utf16.count)
        let regex = try! NSRegularExpression(pattern: "/([0-9]+[.]){2}([0-9]+)/g");
        regex.matches(in: fileName, range: range);
    }
    
    @objc public func writeFolders(path: String) {
        let pathes = path.split(separator: "/");
        var documentsPath = NSURL(string:"/");
        
        for p in pathes {
            documentsPath = documentsPath!.appendingPathComponent(String(p)) as NSURL?;
        };
        
        
        let fullPath = documentsPath!.absoluteURL;
        
        do
        {
            try FileManager.default.createDirectory(atPath: fullPath!.path, withIntermediateDirectories: true, attributes: nil)
        }
        catch let error as NSError
        {
            NSLog("Unable to create directory \(error.debugDescription)")
            exit(EXIT_FAILURE);
        }
    }
    
    @objc public func writeFile(name: String, path: String) {
        
        let pathes = path.split(separator: "/");
        var documentsPath = NSURL(string:"/");
        
        for p in pathes {
            documentsPath = documentsPath!.appendingPathComponent(String(p)) as NSURL?;
        };
        
        
        let fullPath = documentsPath!.absoluteURL;
        
        do
        {
            try FileManager.default.createDirectory(atPath: fullPath!.path, withIntermediateDirectories: true, attributes: nil)
            NSLog(fullPath!.path);
            try FileManager.default.changeCurrentDirectoryPath(fullPath!.path);
            try DummyFileContent.FILE_CONTENT.write(to: URL.init(fileURLWithPath: FileManager.default.currentDirectoryPath + "/" + name) , atomically: true, encoding: .ascii);
        }
        catch let error as NSError
        {
            NSLog("Failed writing to URL: \(FileManager.default.currentDirectoryPath), Error: " + error.localizedDescription);
            exit(EXIT_FAILURE);
        }
    }
}
