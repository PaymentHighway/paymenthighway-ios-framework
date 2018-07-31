//
//  Decoder.swift
//  PaymentHighway
//
//  Created by Stefano Pironato on 05/07/2018.
//  Copyright © 2018 Payment Highway Oy. All rights reserved.
//

public class Decoder {
    static func decode<DataType: Decodable>(fromJson json: String) -> DataType? {
        guard let data = json.data(using: .utf8) else { return nil }
        guard let response = try? JSONDecoder().decode(DataType.self, from: data) else { return nil }
        return response
    }
}
