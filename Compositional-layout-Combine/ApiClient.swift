//
//  ApiClient.swift
//  Compositional-layout-Combine
//
//  Created by Tsering Lama on 10/29/20.
//

import Foundation
import Combine

struct PhotoResultsWrapper: Decodable {
    let hits: [Photo]
}

struct Photo: Decodable, Hashable {
    let id: Int
    let webformatURL: String
}


class APIClient {
    
    public func searchPhotos(query: String) -> AnyPublisher<[Photo], Error> {
        
        let perPage = 200
        let query = query.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? "paris"
        let endpoint = "https://pixabay.com/api/?key=\(Config.apikey)&q=\(query)&per_page=\(perPage)&safesearch=true"
        let url = URL(string: endpoint)!
        
        // use combine
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data) // data
            .decode(type: PhotoResultsWrapper.self, decoder: JSONDecoder())
            .map {$0.hits}
            .receive(on: DispatchQueue.main)  // receive on main thread
            .eraseToAnyPublisher() // doesnt expose of inner publisher
        
    }
}
