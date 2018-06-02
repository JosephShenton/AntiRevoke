import Foundation
import Sodium

open class SodiumStreamCrypto: StreamCryptoProtocol {
    public enum Alogrithm {
        case chacha20, salsa20
    }

    open let key: Data
    open let iv: Data
    open let algorithm: Alogrithm

    var counter = 0

    let blockSize = 64

    public init(key: Data, iv: Data, algorithm: Alogrithm) {
        _ = Libsodium.initialized
        self.key = key
        self.iv = iv
        self.algorithm = algorithm
    }

    open func update(_ data: inout Data) {
        guard data.count > 0 else {
            return
        }

        let padding = counter % blockSize

        var outputData: Data
        if padding == 0 {
            outputData = data
        } else {
            outputData = Data(count: data.count + padding)
            outputData.replaceSubrange(padding..<padding + data.count, with: data)
        }

        switch algorithm {
        case .chacha20:
            _ = outputData.withUnsafeMutableBytes { outputPtr in
                iv.withUnsafeBytes { ivPtr in
                    key.withUnsafeBytes { keyPtr in
                        crypto_stream_chacha20_xor_ic(outputPtr, outputPtr, UInt64(outputData.count), ivPtr, UInt64(counter/blockSize), keyPtr)
                    }
                }
            }

        case .salsa20:
            _ = outputData.withUnsafeMutableBytes { outputPtr in
                iv.withUnsafeBytes { ivPtr in
                    key.withUnsafeBytes { keyPtr in
                        crypto_stream_salsa20_xor_ic(outputPtr, outputPtr, UInt64(outputData.count), ivPtr, UInt64(counter/blockSize), keyPtr)
                    }
                }
            }
        }

        counter += data.count

        if padding == 0 {
            data = outputData
        } else {
            data.withUnsafeMutableBytes {
                outputData.copyBytes(to: $0, from: padding..<outputData.count)
            }
        }
    }
}
