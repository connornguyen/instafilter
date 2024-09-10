//
//  ContentView.swift
//  Instafilter
//
//  Created by Apple on 29/08/2024.
//

import CoreImage
import CoreImage.CIFilterBuiltins
import SwiftUI
import SwiftData
import PhotosUI

struct ContentView: View {
    @AppStorage("filterCount") var filterCount = 0
    //@Environment(\.requestReview) var requestReview
    
    @State private var selectedImage: PhotosPickerItem?
    @State private var filterIntensity = 0.0
    @State private var processedImage: Image?
    @State private var showingChangeFilter = false
    
    @State private var currentFilter: CIFilter = CIFilter.sepiaTone()
    let context = CIContext()
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                
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
            
            Spacer()
            
            HStack {
                Label("Intensity", systemImage: "slider.horizontal.3")
                Slider(value: $filterIntensity)
            }
            .onChange(of: filterIntensity, processingFilter)
            
            Spacer()
            
            HStack{
                Button("Change filter", action: changeFilter)
                
                
                Spacer()
                
                // this if let means if there is no processedImage, there is no button, or code excecute behind inside the {}
                if let processedImage {
                    ShareLink(item: processedImage, preview: SharePreview("Instafilter image", image: processedImage)) {
                        Label("Share", systemImage: "square.and.arrow.up")
                    }
                }
            }
            .padding(.horizontal)
            .navigationTitle("Instafilter")
            .toolbar {
                PhotosPicker(selection: $selectedImage, matching: .images) {
                    Label("Select pictures", systemImage: "photo.on.rectangle.angled")
                }
            }
            .confirmationDialog("Changing filter menu", isPresented: $showingChangeFilter) {
                Button("Sepia tone") {  setFilter(CIFilter.sepiaTone()) }
                Button("Pixellate") { setFilter(CIFilter.pixellate()) }
                Button("Gloom") { setFilter(CIFilter.gloom()) }
                Button("Vigneete") { setFilter(CIFilter.vignette()) }
                Button("Cancel" , role: .cancel) {}
            } message: {
                Text("Select your filter")
            }
        }
        .padding()
    }
    
    private func changeFilter() {
        showingChangeFilter.toggle()
    }
    
    // use " _ " when we don't need external label and call the function directly without spectify label
    func setFilter(_ filter: CIFilter) {
        currentFilter = filter
        loadImage()
    }
    
    private func loadImage() {
        Task {
            // Get the raw data from selectedImage
            guard let imageData = try await selectedImage?.loadTransferable(type: Data.self) else { return }
            //Get inputImage by converting imageData to UI Image using UIImage
            guard let inputImage = UIImage(data: imageData) else { return }
            //Convert UI-> CI
            let beginImage = CIImage(image: inputImage)
            currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
            processingFilter()
        }
    }
    
    private func processingFilter() {
        //currentFilter.setValue(filterIntensity, forKey: kCIInputIntensityKey)
        //This to make sure all the filter works, which is including Intensity, Scale, and Radius
        let inputKeys = currentFilter.inputKeys

            if inputKeys.contains(kCIInputIntensityKey) {
                currentFilter.setValue(filterIntensity, forKey: kCIInputIntensityKey) }
            if inputKeys.contains(kCIInputRadiusKey) { currentFilter.setValue(filterIntensity * 200, forKey: kCIInputRadiusKey) }
            if inputKeys.contains(kCIInputScaleKey) { currentFilter.setValue(filterIntensity * 10, forKey: kCIInputScaleKey) }
        
        //Get raw CI data from the filter
        guard let outputImage = currentFilter.outputImage else { return }
        
        //Convert CI -> CG
        guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else { return }
        
        //convert CG -> UI
        let uiImage = UIImage(cgImage: cgImage)
        
        //convert UI -> Swift Image
        processedImage = Image(uiImage: uiImage)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
