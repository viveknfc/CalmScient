//
//  ApplicationSharedInfo.swift
//  CalmscientIOS
//
//  Created by NFC on 03/05/24.
//

import Foundation

class ApplicationSharedInfo {
    static let shared = ApplicationSharedInfo()
    
    private init() {
       
    }
    
    public var loginResponse:LoginDetails?
    
    public var tokenResponse:TokenResponse?
    
    
    
}
