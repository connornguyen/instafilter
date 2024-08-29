//
//  ContentView.swift
//  Instafilter
//
//  Created by Apple on 29/08/2024.
//

import SwiftUI
import SwiftData
import PhotosUI

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    
    @Query private var items: [Item]
    
    @State private var pickerItems  = [PhotosPickerItem]()
    @State private var selectedImage  = [Image]()
    var body: some View {
        VStack {
            
                PhotosPicker(selection: $pickerItems,maxSelectionCount: 2, matching: .images) {
                    Label("Select pictures", systemImage: "photo")
                }
            ScrollView {
                ForEach(0..<selectedImage.count, id: \.self) { i in
                    selectedImage[i]
                        .resizable()
                        .scaledToFit()
                }
            }
        }
        .onChange(of: pickerItems) {
            Task {
                selectedImage.removeAll()
                for item in pickerItems {
                    if let loadingImage = try await item.loadTransferable(type: Image.self) {
                        selectedImage.append(loadingImage)
                    }
                    
                }
                
            }
        }
        
        ShareLink(item: URL(string: "http://www.hackingwithswift.com")!, subject: Text("Learn swift here"), message: Text("There is 100 days with SwiftUI course.")) {
            Label("Share", systemImage: "swift")
        }
    }

    
    
    
    
    
    
    
    
    private func addItem() {
        withAnimation {
            let newItem = Item(timestamp: Date())
            modelContext.insert(newItem)
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
