//
//  ImageLoader.swift
//  TicketMasterApp
//
//  Created by Jorge Angel Sanchez Martinez on 16/11/23.
//

import AlamofireImage
import Combine

class ImageLoader {
    static let imageCache = AutoPurgingImageCache(memoryCapacity: 100 * 1024 * 1024)
    static let imageDownloader = ImageDownloader(
        configuration: ImageDownloader.defaultURLSessionConfiguration(),
        downloadPrioritization: .fifo,
        maximumActiveDownloads: 8,
        imageCache: imageCache
    )
    static func loadImagePublisher(with url: URL) -> AnyPublisher<UIImage?, EventError> {
        return Future<UIImage?, EventError> { promise in
            imageDownloader.download(URLRequest(url: url), filter: nil, progress: nil) { response in
                switch response.result {
                case .success(let image):
                    promise(.success(image))
                case .failure:
                    promise(.failure(EventError.networkError))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
