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
/// :param:   DER-formatted certificate
/// :returns: SecKeyRef or Nil.
private func loadDER(publicKeyFileContent: NSData) -> SecKeyRef? {
    let certificate = SecCertificateCreateWithData(kCFAllocatorDefault, publicKeyFileContent as CFData).takeUnretainedValue()
    let policy = SecPolicyCreateBasicX509().takeUnretainedValue();
    var unmanagedTrust : Unmanaged<SecTrust>? = nil
    let status = SecTrustCreateWithCertificates(certificate, policy, &unmanagedTrust)
    if (status != 0) {
        println("SecTrustCreateWithCertificates fail. Error Code: \(status)");
        return nil
    }
    let trust = unmanagedTrust!.takeUnretainedValue()
    let evaluateStatus = SecTrustEvaluate(trust, nil)
    if (evaluateStatus != 0) {
        println("SecTrustEvaluate fail. Error Code: \(evaluateStatus)");
        return nil
    }
    return SecTrustCopyPublicKey(trust).takeUnretainedValue();
}

private func encryptWithData(content :NSData, publicKey :SecKeyRef) -> NSData? {
    
    let blockSize = Int(SecKeyGetBlockSize(publicKey) - 11)
    var encryptedData = NSMutableData()
    let blockCount = Int(ceil(Double(content.length) / Double(blockSize)))

    for i in 0..<blockCount {
        var cipherLen = SecKeyGetBlockSize(publicKey)
        var cipher = [UInt8](count: Int(cipherLen), repeatedValue: 0)
        let bufferSize = min(blockSize,(content.length - i * blockSize))
        var buffer = content.subdataWithRange(NSMakeRange(i*blockSize, bufferSize))
        let status = SecKeyEncrypt(publicKey, SecPadding(kSecPaddingOAEP), UnsafePointer<UInt8>(buffer.bytes), buffer.length, &cipher, &cipherLen)
        if (status == noErr){
            encryptedData.appendBytes(cipher, length: Int(cipherLen))
        }else{
            println("SecKeyEncrypt fail. Error Code: \(status)")
            return nil
        }
    }
    return encryptedData
}

public func encryptWithRsaAes(data: String, certificateBase64Der: String) -> (encryptedBase64Message: String, encryptedBase64Key: String, iv: String)?
{
    let keyAes = Cipher.randomIV(AES.blockSize)
    let iv = Cipher.randomIV(AES.blockSize)
    
    if let encryptedData = CryptoSwift.AES(key: keyAes, iv: iv, blockMode: CryptoSwift.CipherBlockMode.CBC)?.encrypt([UInt8](data.utf8), padding: PKCS7())
    {
        if let publicKey = loadDER(NSData(base64EncodedString: certificateBase64Der, options: .allZeros)!)
        {
            if let encryptedKey = encryptWithData(NSData(bytes: keyAes, length: keyAes.count), publicKey)
            {
                let encryptedBase64Message =  NSData(bytes: encryptedData, length: encryptedData.count).base64EncodedStringWithOptions(.allZeros)
                
                let encryptedBase64Key = encryptedKey.base64EncodedStringWithOptions(.allZeros)
                
                let base64Iv = NSData(bytes: iv, length: iv.count).base64EncodedStringWithOptions(.allZeros)
                
                return (encryptedBase64Message, encryptedBase64Key, base64Iv)
            }
        }
    }
    return nil
}

