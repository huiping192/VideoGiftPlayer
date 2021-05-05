//
//  Util.swift
//  VideoGiftPlayer_Example
//
//  Created by Huiping Guo on 2021/05/05.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation


func filePath(fileName: String) -> URL {
    var docDir = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)

    docDir.appendPathComponent(fileName + ".mp4", isDirectory: false)
    
    return docDir
}

func copyFileIfNeeded(fileName: String) {
    let path = filePath(fileName: fileName)
    checkFileisExistOrNot(strPath: path.path, fileName: fileName)
}

func checkFileisExistOrNot(strPath: String, fileName: String) {
    let filemgr = FileManager.default
    if !filemgr.fileExists(atPath: strPath) {
        let resorcePath = Bundle.main.path(forResource: fileName, ofType: "mp4")
        do {
            try filemgr.copyItem(atPath: resorcePath!, toPath: strPath)
        }catch{
            print("Error for file write")
        }
    }
}

