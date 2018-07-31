//
//  Reachability.swift
//  n2k Map
//
//  Created by localuser on 31.07.18.
//  Copyright © 2018 cqd.ch. All rights reserved.
//

import Foundation
import SystemConfiguration

func reachable() -> Bool {
    
    var address = sockaddr_in()
    address.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
    address.sin_family = sa_family_t(AF_INET)
    
    // Passes the reference of the struct
    let reachability = withUnsafePointer(to: &address, { pointer in
        // Converts to a generic socket address
        return pointer.withMemoryRebound(to: sockaddr.self, capacity: MemoryLayout<sockaddr>.size) {
            // $0 is the pointer to `sockaddr`
            return SCNetworkReachabilityCreateWithAddress(nil, $0)
        }
    })
    
    var flags = SCNetworkReachabilityFlags()
    SCNetworkReachabilityGetFlags(reachability!, &flags)
    let isReachable: Bool = flags.contains(.reachable)
    return isReachable
}
