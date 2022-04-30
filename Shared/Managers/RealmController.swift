//
//  RealmController.swift
//  tunnel
//
//  Created by Arjun Singh on 18/2/22.
//

import Foundation
import RealmSwift

class RealmController {
    
    static let shared = RealmController()
    
    /**
     The default configuration for the TulaByte Realm database file. Only get-able.
    */
    var config: Realm.Configuration {
        get {
            let dbFileURL = FileManager.default
                .groupFolder!
                .appendingPathComponent("tulabyte.realm")
            return Realm.Configuration(fileURL: dbFileURL)
        }
    }
    
    /**
     The default reference to the TulaByte Realm database. Only get-able.
     */
    var db: Realm {
        get {
            let realm = try! Realm(configuration: self.config)
            return realm
        }
    }
    
    //MARK: - Lists

    /// UserDefaults key for lists engine migration
    let listsV2Key = "usesListsV2"

    ///Adds a single item to a given list
    ///- Parameter url: The URL to add
    ///- Parameter userAdded: Condition to see if the element is user added or by TulaByte
    ///- Parameter list: Which TulaList this element on: .block or .allow
    func addItemToList(url: String, userAdded: Bool = true, list: TulaList){
        try! self.db.write({
            self.db.add(ListItem(url: url, userAdded: userAdded, list: list), update: .modified)
        })
    }

    ///Adds multiple items to a given list
    ///- Parameter urls: An array of URLs to add
    ///- Parameter userAdded: Condition to see if the element is user added or by TulaByte
    ///- Parameter list: Which TulaList this element on: .block or .allow
    func addItemsToList(urls: [String], userAdded: Bool = true, list: TulaList) {
        try! self.db.write({
            urls.forEach({ url in
                let item = ListItem(url: url, userAdded: userAdded, list: list)
                self.db.add(item, update: .modified)
            })
        })
    }

    ///Deletes a URL from a given list
    ///- Parameter url: The URL to delete
    func deleteItemFromList(url: String){
        try! self.db.write({
            let item = self.db.object(ofType: ListItem.self, forPrimaryKey: url)
            self.db.delete(item!)
        })
    }

    ///Clears a given list
    ///- Parameter list: Which TulaList is to be cleared - .block or .allow
    func clearList(list: TulaList){
        try! self.db.write({
            let list = self.db.objects(ListItem.self).where {$0.list == list}
            self.db.delete(list)
        })
    }

    /// Gets a TulaList as an array of URL strings
    /// - Parameter list: Which TulaList to retrive: .block or .allow
    /// - Returns: An array of URL strings
    func getListArray(list: TulaList) -> [String]{
        var urlList: [String] = [String]()
        
        let fetchedUrls: [String] = self.db.objects(ListItem.self)
            .where{$0.list == list}
            .map{$0.url}
        
        if fetchedUrls.count > 0 {
            urlList = fetchedUrls
        }
        
        return urlList
    }

    /// Reads URL strings from a file in the app bundle
    /// - Parameter bundlePath: The name of the txt file in the bundle that will be read
    /// - Returns: An array of URL strings parsed from the file
    func readItemsFromFile(bundlePath: String) -> [String] {
        var domains = [String]()
        
        guard let path = Bundle.main.path(forResource: bundlePath, ofType: "txt") else {
            return domains
        }
        
        do {
            let contents = try String(contentsOfFile: path)
            let lines = contents.components(separatedBy: "\n")
            for line in lines {
                if (line.trimmingCharacters(in: CharacterSet.whitespaces) != "" && !line.starts(with: "#")) && !line.starts(with: "\n") {
                    domains.append(line)
                    //NSLog("TBT DB: \(line) enabled on blocklog")
                }
            }
        }
        catch {
            NSLog("TBT Lists ERROR: \(error)")
        }
        
        return domains
    }

    /// Reads URL strings from a file, given a filepath
    /// - Parameter fileURL: The filepath structured as a Swift URL
    /// - Returns: An array of URL strings parsed from the file
    func readItemsFromFile(fileURL: URL) -> [String] {
        var domains = [String]()
        
        do {
            if fileURL.startAccessingSecurityScopedResource() == true {
                let contents = try String(contentsOfFile: fileURL.path)
                //NSLog("TBT Lists: Selected file - \(contents)")
                let lines = contents.components(separatedBy: "\n")
                for line in lines {
                    if (line.trimmingCharacters(in: CharacterSet.whitespaces) != "" && !line.starts(with: "#")) && !line.starts(with: "\n") {
                        domains.append(line)
                        //NSLog("TBT DB: \(line) enabled on blocklog")
                    }
                }
            } else {
                NSLog("TBT Lists ERROR: Permission not received to read file")
            }
            fileURL.stopAccessingSecurityScopedResource()
        }
        catch {
            NSLog("TBT Lists ERROR: \(error)")
        }
        return domains
    }

    /// Adds items from a file within the bundle to a TulaList
    /// - Parameter bundlePath: The name of the txt file in the bundle that will be read
    /// - Parameter list: Which TulaList to retrive: .block or .allow
    /// - Parameter userAdded: Condition to see if the element is user added or by TulaByte
    func addFileItemsToList(bundlePath: String, list: TulaList, userAdded: Bool = true) {
        let startTime = CFAbsoluteTimeGetCurrent()
        let fileItems = readItemsFromFile(bundlePath: bundlePath)
        
        addItemsToList(urls: fileItems, userAdded: userAdded, list: list)
        let time = CFAbsoluteTimeGetCurrent() - startTime
        NSLog("TBT DB: \(fileItems.count) list items added in \(time)s")
    }

    /// Adds items from a provided filepath to a TulaList
    /// - Parameter fileURL: The filepath structured as a Swift URL
    /// - Parameter list: Which TulaList to retrive: .block or .allow
    /// - Parameter userAdded: Condition to see if the element is user added or by TulaByte
    func addFileItemsToList(fileURL: URL, list: TulaList, userAdded: Bool = true) {
        let startTime = CFAbsoluteTimeGetCurrent()
        let fileItems = readItemsFromFile(fileURL: fileURL)
        
        addItemsToList(urls: fileItems, userAdded: userAdded, list: list)
        let time = CFAbsoluteTimeGetCurrent() - startTime
        NSLog("TBT DB: \(fileItems.count) list items added in \(time)s")
    }

    /// Parses and adds the default TulaByte blocklist
    func setupTulaByteBlockList() {
        addFileItemsToList(bundlePath: "blocklist", list: .block, userAdded: false)
    }

    /// Parses and adds the default TulaByte allowlist
    func setupTulaByteAllowList() {
        addFileItemsToList(bundlePath: "allowlist", list: .allow, userAdded: false)
    }

    /// Checks if a given domain exists in a given TulaList
    /// - Parameter url: The url to check
    /// - Parameter list: The TulaList to check in: .block or .allow
    /// - Returns: A boolean value indicating whether it was found or not
    func isDomainInList(url: String, list: TulaList) -> Bool {
        var returnVal: Bool = false
        let start = CFAbsoluteTimeGetCurrent()
        
        let bothLists = self.db.objects(ListItem.self)
        
        let value = bothLists.where {
            ($0.list == list) && (($0.url.ends(with: ".\(url)")) || ($0.url == url))
        }
        
        if value.count >= 1 {
            NSLog("TBT DB: \(url) matched to \(value.first!.url) in \(CFAbsoluteTimeGetCurrent() - start)s")
            returnVal = true
        }
    
        return returnVal
    }

    /// Swaps the list of a given URL
    /// - Parameter url: The url to swap
    /// - Parameter toList: The destination list for the URL
    func swapList(url: String, toList: TulaList){
        deleteItemFromList(url: url)
        if toList == .allow {
            addItemToList(url: url, list: .allow)
        } else if toList == .block {
            addItemToList(url: url, list: .block)
        }
    }


    //MARK: - Logging
    func addItemToMonitorList(item: LogItem) {
        try! self.db.write {
            self.db.add(item)
            NSLog("TBT REALM: Added \(item.url) to monitor list")
        }
    }

}
