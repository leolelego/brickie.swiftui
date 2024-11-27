//
//  DebouncedString.swift
//  Brickie
//
//  Created by Léo on 27/11/2024.
//  Copyright © 2024 Homework. All rights reserved.
//
import Foundation
import Combine


class DebouncedString : ObservableObject {
    @Published var value = ""
    @Published var debouncedValue = ""
    private var cancellable: AnyCancellable?

    init(){
        
        cancellable = $value
        
        
            .debounce(for: .milliseconds(850), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink{  query in
                print("debounced: \(query)")
                self.objectWillChange.send()
                self.debouncedValue = query
                
            }
//        searchCancellable = value
//            .delay(for: .milliseconds(300), scheduler: DispatchQueue.main)
//            .sink { deboucedString in
//                print("debounced: \(deboucedString)")
//                self.debouncedValue = self.value
//            }
//        
            //.debounce(for: .milliseconds(300), scheduler: .)
    }
    
}
