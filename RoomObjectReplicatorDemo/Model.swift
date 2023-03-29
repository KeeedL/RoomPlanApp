//
//  Model.swift
//  ModelPickerApp
//
//  Created by Gauthier Bocquet on 07/11/2022.
//

import Foundation

import RealityKit
import UIKit
import Combine

// MARK: - Model

class Model {
    var modelName: String
    var image: UIImage
    var modelEntity: ModelEntity?
    private var cancellable: AnyCancellable? = nil
    
    init(modelName: String) {
        self.modelName = modelName
        
        self.image = UIImage(named: modelName)!
        
        let filename = modelName + ".usdz"
        self.cancellable = ModelEntity.loadModelAsync(named: filename)
            .sink(receiveCompletion: { loadCompletion in
                // Handle error.
                print("DEBUG: unable to load modelEntity for \(filename).")
            }, receiveValue: { modelEntity in
                self.modelEntity = modelEntity
                print("DEBUG: modelEntity for \(modelName) has been loaded.")
            })
    }
}
