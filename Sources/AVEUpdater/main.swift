import Foundation


let runLoop = CFRunLoopGetCurrent();
let arguments = CommandLine.arguments;
let aveUpdater = AVEUpdaterRunLoop(rLoop: runLoop!);

let exec = aveUpdater.getArgument(arguments: arguments, forType: ArgumentType.EXE);
let mode = aveUpdater.getArgument(arguments: arguments, forType: ArgumentType.MODE);
let dPath = aveUpdater.getArgument(arguments: arguments, forType: ArgumentType.DPATH);
let iPath = aveUpdater.getArgument(arguments: arguments, forType: ArgumentType.IPATH);
let debug = aveUpdater.getArgument(arguments: arguments, forType: ArgumentType.DEBUG);
if(!debug.isEmpty) {print("Arguments: \(arguments)");}
if(!debug.isEmpty) {aveUpdater.isDebugMode();}
print("\(aveUpdater.readMode(arg: mode))\n");
if(!debug.isEmpty) {
print("Mode: \(aveUpdater.readMode(arg: mode)), Download path: \(aveUpdater.readDPath(arg: dPath)), Installation path: \(aveUpdater.readIPath(arg: iPath))\n");
}

aveUpdater.setMode(value: aveUpdater.readMode(arg: mode));

aveUpdater.writeFolders(path: aveUpdater.readDPath(arg: dPath));
aveUpdater.writeFolders(path: aveUpdater.readIPath(arg: iPath));
aveUpdater.writeFolders(path: aveUpdater.readIPath(arg: iPath + "/Manifest"));
aveUpdater.writeFolders(path: aveUpdater.readIPath(arg: iPath + "/Eventinterface"));
aveUpdater.writeFile(name: "MV_WatchDog.exe", path: aveUpdater.readIPath(arg: iPath));
aveUpdater.writeFile(name: "AVEUpdater-1.3.5.manifest", path: aveUpdater.readIPath(arg: iPath + "/Manifest"));

CFRunLoopRun();
exit(EXIT_SUCCESS)
