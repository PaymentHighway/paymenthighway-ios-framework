//
//  Crypto.swift
//
//  Created by ZERO on 14/10/25.
//  Copyright (c) 2014年 ZERO. All rights reserved.
//

import Foundation
import UIKit
import CryptoSwift

public func getRequestId() -> String {
    return NSUUID().UUIDString.lowercaseString
}

/// Returns Optional SecKeyRef from given certificate in DER-format.
///
/// - parameter   DER-formatted: certificate
/// - returns: SecKeyRef or Nil.
private func loadDER(publicKeyFileContent: NSData) -> SecKeyRef? {
    let certificate = SecCertificateCreateWithData(kCFAllocatorDefault, publicKeyFileContent as CFData)
    let policy = SecPolicyCreateBasicX509()
    var unmanagedTrust : SecTrust? = nil
    let status = SecTrustCreateWithCertificates(certificate!, policy, &unmanagedTrust)
    if (status != 0) {
        print("SecTrustCreateWithCertificates fail. Error Code: \(status)");
        return nil
    }
    let trust = unmanagedTrust!
    let evaluateStatus = SecTrustEvaluate(trust, nil)
    if (evaluateStatus != 0) {
        print("SecTrustEvaluate fail. Error Code: \(evaluateStatus)");
        return nil
    }
    return SecTrustCopyPublicKey(trust)
}

private func encryptWithData(content :NSData, publicKey :SecKeyRef) -> NSData? {
    
    let blockSize = Int(SecKeyGetBlockSize(publicKey) - 11)
    let encryptedData = NSMutableData()
    let blockCount = Int(ceil(Double(content.length) / Double(blockSize)))

    for i in 0..<blockCount {
        var cipherLen = SecKeyGetBlockSize(publicKey)
        var cipher = [UInt8](count: Int(cipherLen), repeatedValue: 0)
        let bufferSize = min(blockSize,(content.length - i * blockSize))
        let buffer = content.subdataWithRange(NSMakeRange(i*blockSize, bufferSize))
        let status = SecKeyEncrypt(publicKey, SecPadding.OAEP, UnsafePointer<UInt8>(buffer.bytes), buffer.length, &cipher, &cipherLen)
        if (status == noErr){
            encryptedData.appendBytes(cipher, length: Int(cipherLen))
        }else{
            print("SecKeyEncrypt fail. Error Code: \(status)")
            return nil
        }
    }
    return encryptedData
}

public func encryptWithRsaAes(data: String, certificateBase64Der: String) -> (encryptedBase64Message: String, encryptedBase64Key: String, iv: String)?
{
    //let keyAes = Cipher.randomIV(AES.blockSize)
    //let iv = Cipher.randomIV(AES.blockSize)
    
    /*if let encryptedData = CryptoSwift.AES(key: keyAes, iv: iv, blockMode: CryptoSwift.CipherBlockMode.CBC).encrypt([UInt8](data.utf8), padding: PKCS7())
    {
        if let publicKey = loadDER(NSData(base64EncodedString: certificateBase64Der, options: [])!)
        {
            if let encryptedKey = encryptWithData(NSData(bytes: keyAes, length: keyAes.count), publicKey: publicKey)
            {
                let encryptedBase64Message =  NSData(bytes: encryptedData, length: encryptedData.count).base64EncodedStringWithOptions(.allZeros)
                
                let encryptedBase64Key = encryptedKey.base64EncodedStringWithOptions([])
                
                let base64Iv = NSData(bytes: iv, length: iv.count).base64EncodedStringWithOptions([])
                
                return (encryptedBase64Message, encryptedBase64Key, base64Iv)
            }
        }
    }*/
    return nil
}

