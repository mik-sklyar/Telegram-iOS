import Foundation
import SwiftSignalKit

public let apiFetcher = ApiFetcher.shared

final public class ApiFetcher {
    public static let shared = ApiFetcher()

    public typealias TimestampSignal = Signal<Int32, Error>

    public func fetchCurrentTimestamp() -> TimestampSignal {
        return TimestampSignal { subscriber in
            let url = URL(string: "http://worldtimeapi.org/api/timezone/Europe/Moscow")!

            let task = URLSession.shared.dataTask(with: url) { (data, _, error) in
                if let error = error {
                    subscriber.putError(error)
                } else if let data = data {
                    do {
                        let date = try JSONDecoder().decode(DateResponse.self, from: data)
                        subscriber.putNext(date.unixtime)
                    }
                    catch { subscriber.putError(error) }
                }
                subscriber.putCompletion()
            }
            task.resume()

            return ActionDisposable { task.cancel() }
        }
    }
}

fileprivate struct DateResponse: Codable {
    let unixtime: Int32
}
