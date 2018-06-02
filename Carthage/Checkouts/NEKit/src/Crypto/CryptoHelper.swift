import Foundation

public struct CryptoHelper {
    public static let infoDictionary: [CryptoAlgorithm:(Int, Int)] = [
        .AES128CFB: (16, 16),
        .AES192CFB: (24, 16),
        .AES256CFB: (32, 16),
        .CHACHA20: (32, 8),
        .SALSA20: (32, 8),
        .RC4MD5: (16, 16)
        ]

    public static func getKeyLength(_ methodType: CryptoAlgorithm) -> Int {
        return infoDictionary[methodType]!.0
    }

    public static func getIVLength(_ methodType: CryptoAlgorithm) -> Int {
        return infoDictionary[methodType]!.1
    }

    public static func getIV(_ methodType: CryptoAlgorithm) -> Data {
        var IV = Data(count: getIVLength(methodType))
        _ = IV.withUnsafeMutableBytes {
            SecRandomCopyBytes(kSecRandomDefault, IV.count, $0)
        }
        return IV
    }

    public static func getKey(_ password: String, methodType: CryptoAlgorithm) -> Data {
        var result = Data(count: getIVLength(methodType) + getKeyLength(methodType))
        let passwordData = password.data(using: String.Encoding.utf8)!
        var md5result = MD5Hash.final(password)
        var extendPasswordData = Data(count: passwordData.count + md5result.count)

        extendPasswordData.replaceSubrange(md5result.count..<extendPasswordData.count, with: passwordData)

        var length = 0
        repeat {
            let copyLength = min(result.count - length, md5result.count)
            result.withUnsafeMutableBytes {
                md5result.copyBytes(to: $0.advanced(by: length), count: copyLength)
            }
            extendPasswordData.replaceSubrange(0..<md5result.count, with: md5result)
            md5result = MD5Hash.final(extendPasswordData)
            length += copyLength
        } while length < result.count
        return result.subdata(in: 0..<getKeyLength(methodType))
    }
}
