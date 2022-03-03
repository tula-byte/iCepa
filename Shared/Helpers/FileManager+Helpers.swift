//
//  FileManager+Helpers.swift
//  iCepa
//
//  Created by Benjamin Erhart on 20.05.20.
//  Copyright © 2020 Guardian Project. All rights reserved.
//

import Foundation

extension FileManager {

	var groupFolder: URL? {
		return containerURL(forSecurityApplicationGroupIdentifier: Config.groupId)
	}

	var vpnLogFile: URL? {
		return groupFolder?.appendingPathComponent("log")
	}

    var torLogFile: URL? {
        return groupFolder?.appendingPathComponent("tor.log")
    }

    var leafLogFile: URL? {
        return groupFolder?.appendingPathComponent("leaf.log")
    }

    var leafConfFile: URL? {
        return groupFolder?.appendingPathComponent("leaf.conf")
    }

    var leafConfAppTemplateFile: URL? {
        return Bundle.main.url(forResource: "template-app", withExtension: "conf")
    }

    var leafConfNeTemplateFile: URL? {
        return Bundle.main.url(forResource: "template-ne", withExtension: "conf")
    }
    
    var siteDatFile: URL? {
        return Bundle.main.url(forResource: "site", withExtension: "dat")
    }
    
    var siteDatFileDest: URL? {
        return groupFolder?.appendingPathComponent("site.dat")
    }

	var vpnLog: String? {
		if let logfile = vpnLogFile {
			return try? String(contentsOf: logfile)
		}

		return nil
	}

    var torLog: String? {
        if let logfile = torLogFile {
            return try? String(contentsOf: logfile)
        }

        return nil
    }

    var leafLog: String? {
        if let logfile = leafLogFile {
            return try? String(contentsOf: logfile)
        }

        return nil
    }

    var leafConfAppTemplate: String? {
        if let templateFile = leafConfAppTemplateFile {
            return try? String(contentsOf: templateFile)
        }

        return nil
    }

    var leafConfNeTemplate: String? {
        if let templateFile = leafConfNeTemplateFile {
            return try? String(contentsOf: templateFile)
        }

        return nil
    }

    var leafConf: String? {
        if let confFile = leafConfFile {
            return try? String(contentsOf: confFile)
        }

        return nil
    }
    
    var inAppLog: URL? {
        //save the log file in the user directory to make it easily readable on Mac
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0].appendingPathComponent("leaf.log")
    }
    
    var siteDatFileData: Data? {
        if let siteDatFile = siteDatFile {
            return try? Data(contentsOf: siteDatFile)
        }
        return nil
    }
    
    var siteDatFileDestData: Data? {
        if let siteDatFileDest = siteDatFileDest {
            return try? Data(contentsOf: siteDatFileDest)
        }
        return nil
    }
}
