//
//  Crypto.swift
//
//  Created by ZERO on 14/10/25.
//  Copyright (c) 2014年 ZERO. All rights reserved.
//

import CryptoSwift

/// Returns Optional SecKeyRef from given certificate in DER-format.
///
/// - parameter   DER-formatted: certificate
/// - returns: SecKeyRef or Nil.
private func loadDER(_ publicKeyFileContent: Data) -> SecKey? {
    let certificate = SecCertificateCreateWithData(kCFAllocatorDefault, publicKeyFileContent as CFData)
    let policy = SecPolicyCreateBasicX509()
    var unmanagedTrust : SecTrust? 
    let status = SecTrustCreateWithCertificates(certificate!, policy, &unmanagedTrust)
    if status != 0 {
        print("SecTrustCreateWithCertificates fail. Error Code: \(status)")
        return nil
    }
    let trust = unmanagedTrust!
    let evaluateStatus = SecTrustEvaluate(trust, nil)
    if evaluateStatus != 0 {
        print("SecTrustEvaluate fail. Error Code: \(evaluateStatus)")
        return nil
    }
    return SecTrustCopyPublicKey(trust)
}

private func encryptWithData(_ content :Data, publicKey :SecKey) -> Data? {
    
    let blockSize = Int(SecKeyGetBlockSize(publicKey) - 11)
    let encryptedData = NSMutableData()
    let blockCount = Int(ceil(Double(content.count) / Double(blockSize)))

    for index in 0..<blockCount {
        var cipherLen = SecKeyGetBlockSize(publicKey)
        var cipher = [UInt8](repeating: 0, count: Int(cipherLen))
        let bufferSize = min(blockSize, (content.count - index * blockSize))
        let buffer = content.subdata(in: Range.init(uncheckedBounds: (lower: index * blockSize, upper: bufferSize)))
        let status = SecKeyEncrypt(publicKey,
                                   SecPadding.OAEP,
                                   (buffer as NSData).bytes.bindMemory(to: UInt8.self, capacity: buffer.count),
                                   buffer.count,
                                   &cipher,
                                   &cipherLen)
        if status == noErr {
            encryptedData.append(cipher, length: Int(cipherLen))
        } else {
            print("SecKeyEncrypt fail. Error Code: \(status)")
            return nil
        }
    }
    return encryptedData as Data
}

public func encryptWithRsaAes(_ data: String, certificateBase64Der: String) -> (encryptedBase64Message: String, encryptedBase64Key: String, iv: String)? {
    
    let keyAes = AES.randomIV(AES.blockSize)
    let iv = AES.randomIV(AES.blockSize)
    
    do {
        // Create AES encryptor
        let aes = try AES(key: keyAes, blockMode: CBC(iv: iv), padding: .pkcs7)

        // Encrypt given data
        let encryptedData = try aes.encrypt(Array(data.utf8))

        // Create encryption key
        guard let certificateData = Data(base64Encoded: certificateBase64Der),
              let publicKey = loadDER(certificateData) else {
            return nil
        }
        
        guard let encryptedKey = encryptWithData(Data(bytes: keyAes, count: keyAes.count), publicKey: publicKey) else {
            return nil
        }
        
        // Encrypt data
        let encryptedBase64Data = Data(bytes: UnsafePointer<UInt8>(encryptedData), count: encryptedData.count).base64EncodedString(options: [])
        let encryptedBase64Key = encryptedKey.base64EncodedString(options: [])
        let base64IV = Data(bytes: iv, count: iv.count).base64EncodedString(options: [])
        
        return (encryptedBase64Data, encryptedBase64Key, base64IV)
    } catch {
        // Handle errors
    }

    return nil
}
