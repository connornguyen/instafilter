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
    
    
    @State private var selectedImage: PhotosPickerItem?
    @State private var filterIntensity = 0.0
    @State private var processedImage: Image?
    
    var body: some View {
        NavigationStack {
            VStack {
                PhotosPicker(selection: $selectedImage) {
                    if let processedImage {
                        processedImage
                            .resizable()
                            .scaledToFit()
                    } else {
                        ContentUnavailableView("No photo", systemImage: "photo.badge.plus", description: Text("Tap to import photo"))
                    }
                }
                .buttonStyle(.plain)  //This help button ignore the color changing when wrapped inside PhotoPicker
                .onChange(of: selectedImage, loadImage) //Look for change of selectedIamge, then perform loadImage
                
                 
                Spacer()
                
            }
            /*.onChange(of: $selectedImage) {
                Task {
                    if let loadingImage = try await selectedImage?.loadTransferable(type: Image.self) {
                    }
                }
                }
            } */
            
            Spacer()
            
            HStack {
                Label("Intensity", systemImage: "slider.horizontal.3")
                Slider(value: $filterIntensity)
            }
            
            Spacer()
            
            HStack{
                Button("Change filter", action: changeFilter)
                    
                Spacer()
                
                ShareLink(item: URL(string: "http://www.hackingwithswift.com")!, subject: Text("Learn swift here"), message: Text("There is 100 days with SwiftUI course.")) {
                    Label("Share", systemImage: "square.and.arrow.up")
                }
            }
            .padding(.horizontal)
            .navigationTitle("Instafilter")
            .toolbar {
                PhotosPicker(selection: $selectedImage, matching: .images) {
                    Label("Select pictures", systemImage: "photo.badge.plus")
                }
            }
        }
        .padding()
        
    }
    
    private func changeFilter() {
        
    }
    
    private func loadImage() {
        Task {
            // Get the raw data from selectedImage
            guard let imageData = try await selectedImage?.loadTransferable(type: Data.self) else { return }
            //Get inputImage by converting imageData to UI Image using UIImage
            guard let inputImage = UIImage(data: imageData) else { return }
            
            
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
