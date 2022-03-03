//
//  LeafPTProvider.swift
//  TorVPN
//
//  Created by Benjamin Erhart on 16.09.21.
//  Copyright © 2021 Guardian Project. All rights reserved.
//

import NetworkExtension

/**
 https://github.com/eycorsican/leaf.git
 */
class LeafPTProvider: BasePTProvider {

    private static let leafId: UInt16 = 666

    override func startTun2Socks() {
        var conf: String?

        if Config.torInApp {
            conf = FileManager.default.leafConfAppTemplate?
                .replacingOccurrences(of: "{{leafProxyPort}}", with: String(TorManager.leafProxyPort))
        }
        else {
            conf = FileManager.default.leafConfNeTemplate
        }
        
        /*
        do {
            NSLog("iCFM: site.dat contents - \(FileManager.default.siteDatFileData)")
            try FileManager.default.siteDatFileData?.write(to: FileManager.default.siteDatFileDest!)
            NSLog("iCFM: site.dat destination path - \(FileManager.default.siteDatFileDest?.path) contents - \(FileManager.default.siteDatFileDestData)")
        } catch  {
            NSLog("iCFM: File could not be copied")
        }
        */
        
        conf = conf?.replacingOccurrences(of: "{{leafLogFile}}", with: FileManager.default.leafLogFile!.path)
            .replacingOccurrences(of: "{{tunFd}}", with: String(tunnelFd!))
            .replacingOccurrences(of: "{{torProxyPort}}", with: String(TorManager.torProxyPort))
            .replacingOccurrences(of: "{{dnsPort}}", with: String(TorManager.dnsPort))
            //.replacingOccurrences(of: "{{datFilePath}}", with: FileManager.default.siteDatFile!.path)

        let file = FileManager.default.leafConfFile

        try! conf!.write(to: file!, atomically: true, encoding: .utf8)

        setenv("LOG_NO_COLOR", "true", 1)
        
        // add site.dat blocklist file path to env, so that leaf can access it
        setenv("ASSET_LOCATION", "\(FileManager.default.siteDatFile!.deletingLastPathComponent().path)", 1)
        
        NSLog("iCFM: ASSET_LOCATION - \(FileManager.default.siteDatFile!.path)")

        DispatchQueue.global(qos: .userInteractive).async {
            leaf_run(LeafPTProvider.leafId, file?.path)
            
        }
    }

    override func stopTun2Socks() {
        leaf_shutdown(LeafPTProvider.leafId)
    }
}
