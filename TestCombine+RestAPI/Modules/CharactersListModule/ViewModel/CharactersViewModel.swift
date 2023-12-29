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
    var namesPubliser: Published<[String]>.Publisher { get }
}

class CharactersViewModel: CharactersListViewModelProtocol {
    
    private let networkLayer: NetworkLayerInterface
    @Published var names: [String]
    var namesPubliser: Published<[String]>.Publisher { $names }
    private var cancellableSet: Set<AnyCancellable>
    
    init(networkLayer: NetworkLayerInterface = NetworkLayer(),
         names: [String] = [],
         cancellableSet: Set<AnyCancellable> = []) {
        self.networkLayer = networkLayer
        self.names = names
        self.cancellableSet = cancellableSet
    }
    
    func getCharactersData(name: String?, gender: String?, status: String?) {
        networkLayer.getData(name: name, gender: gender, status: status)
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
