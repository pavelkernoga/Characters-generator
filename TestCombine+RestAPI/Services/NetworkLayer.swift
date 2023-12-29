//
//  NetworkLayer.swift
//  TestCombine+RestAPI
//
//  Created by pavel on 21.11.23.
//

import Foundation
import Combine

protocol NetworkLayerInterface {
    func getData(name: String?, gender: String?, status: String?) -> any Publisher<Data, CombineError>
}

class NetworkLayer: NetworkLayerInterface {
            
    func getData(name: String?, gender: String?, status: String?) -> any Publisher<Data, CombineError> {
        guard let inputName = name,
              let inputGender = gender,
              let inputStatus = status else {
            return Fail<Data, CombineError>(error: .failed).eraseToAnyPublisher()
        }
        
        guard let url = URL(string: "https://rickandmortyapi.com/api/character/?name=\(inputName)&status=\(inputStatus)&gender=\(inputGender)") else {
            return Fail<Data, CombineError>(error: .failed).eraseToAnyPublisher()
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        return Future<Data, CombineError> { promise in
            print("Start Future")
            
            URLSession.shared.dataTask(with: URLRequest(url: url)) { data, response, error in
                guard error == nil else {
                    promise(.failure(.failed))
                    return
                }
                
                guard let charactersData = data else {
                    promise(.failure(.failed))
                    return
                }
                
                promise(.success(charactersData))
            }.resume()
        }.eraseToAnyPublisher()
    }
}
