//
//  CharactersViewModel.swift
//  TestCombine+RestAPI
//
//  Created by pavel on 21.11.23.
//

import Foundation
import Combine

protocol CharactersListViewModelProtocol {
    func getCharactersData(name: String?, gender: String?, status: String?)
}

class CharactersViewModel: CharactersListViewModelProtocol {
    
    private let layer = NetworkLayer()
    @Published var names = [String]()
    private var cancellableSet: Set<AnyCancellable> = []
    
    func getCharactersData(name: String?, gender: String?, status: String?) {
        layer.getData(name: name, gender: gender, status: status)
            .sink { complete in
                print("Sink complete: \(complete)")
            } receiveValue: { data in
                self.getCharactersNames(data: data)
            }.store(in: &cancellableSet)
    }
    
    private func getCharactersNames(data: Data) {
        names.removeAll()
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data)
            if let jsonResult = jsonObject as? Dictionary<String, Any>,
               let results = jsonResult["results"] as? [Any] {
                if let charactersData = try? JSONSerialization.data(withJSONObject: results, options: []) {
                    let characters = try JSONDecoder().decode([Character].self, from: charactersData)
                    for character in characters {
                        if let name = character.name {
                            names.append(name)
                        }
                    }
                }
            }
        } catch let parsingError {
            print("Error", parsingError)
        }
    }
}
