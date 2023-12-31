//
//  HomeDetailVM.swift
//  Travio
//
//  Created by Ferdi DEMİRCİ on 4.09.2023.
//

import Foundation

class HomeDetailVM {
    
    var placeArray: [Place] = []
        
    func fetchPlaces(request: Router, completion: @escaping (Bool) -> Void) {
         NetworkManager.shared.routerRequest(request: request) { (result: Result<MapPlaceResponse, Error>) in
             switch result {
             case .success(let data):
                 self.placeArray = data.data.places
                 completion(true)
             case .failure:
                 completion(false)
             }
         }
     }
    
    func sortingFromAtoZ() {
        placeArray = placeArray.sorted { $0.title.lowercased() < $1.title.lowercased() }
    }
    
    func sortingFromZtoA() {
        placeArray = placeArray.sorted { $0.title.lowercased() > $1.title.lowercased() }
    }
}
