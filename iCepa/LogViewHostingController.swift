//
//  LogViewHostingController.swift
//  iCepa
//
//  Created by Arjun Singh on 27/4/2022.
//  Copyright © 2022 Guardian Project. All rights reserved.
//

import UIKit
import SwiftUI

struct LogView: View {
    @State var log: [LogItem] = LogParser.shared.parseLog()
    
    var body: some View {
        VStack{
            Button {
                log = LogParser.shared.parseLog()
            } label: {
                Text("Refresh Log")
            }
            .buttonStyle(.borderedProminent)
            
            List(log){ item in
                LogListView(item: item)
            }
        }
        .padding()
    }
}

struct LogListView : View {
    var item: LogItem
    var img: String {
        switch item.dest {
        case .block:
            return "xmark.shield"
        case .direct, .tor:
            return "checkmark.shield"
        default:
            return "0.circle"
        }
    }
        
    var body: some View {
        Label(item.url, systemImage: img)
    }
}

class LogViewHostingController: UIHostingController<LogView> {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder, rootView: LogView())
    }

}
