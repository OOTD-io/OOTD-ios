//
//  ClosetView.swift
//  OOTD-swift
//
//  Created by Rahqi Sarsour on 6/15/25.
//

import SwiftUI

struct ClosetView: View {
    var body: some View {
        ScrollView() {
            VStack {
//                HStack {
//                    Text("Generate Outfit")
//                        .font(.largeTitle)
//                        .frame(width: 200, height: 200)
//                        .background(.red)
//
//                    Text("Weather")
//                        .font(.largeTitle)
//                        .frame(width: 200, height: 200)
//                        .background(.red)
//                }
                Spacer()
                HStack {
                    Spacer()
                    VStack(alignment: .leading) {
                        HStack {
                            Spacer()
                            Text("Suggested Outfits")
                                .font(.title)
                                .fontWeight(.bold)
                            Spacer()
                        }
                        
                        
                        ForEach(0..<2) { index in
                            HStack {
                                Spacer()
                                ForEach(index..<index+2) { i1 in
                                    Text("Generated Outfit \(index)")
                                    .font(.largeTitle)
                                    .frame(width: 150, height: 150)
                                    .background(.red)
                                    Spacer()
                                }
                                Spacer()
                            }
                        }
                        
                    }
//                    Spacer()
//                    Text("Generated Outfit")
//                        .font(.largeTitle)
//                        .frame(width: 150, height: 150)
//                        .background(.red)
//                    Spacer()
//                    Text("Saved Outfits")
//                        .font(.largeTitle)
//                        .frame(width: 150, height: 150)
//                        .background(.red)
//                    Spacer()
                }
                HStack {
                    Spacer()
                    VStack(alignment: .leading) {
                        HStack {
                            
                            Text("👕 Tops")
                                .font(.title)
                                .fontWeight(.bold)
                            Spacer()
                            Spacer()
                            Spacer()
                            Button(action: {
                                print("Tops action")
                            }) {
                                Text("See All →")
                                    .font(.subheadline)
                                    .padding(EdgeInsets(top: 15, leading: 0, bottom: 0, trailing: 10))
                                    .background(Color.clear)
                                    .foregroundColor(.black)
                                    .cornerRadius(10)
                            }

                        }
                        
                        ScrollView(.horizontal) {
                            HStack(spacing: 20) {
                                ForEach(0..<5) { index in
                                    Text("Item \(index)")
                                        .font(.largeTitle)
                                        .frame(width: 100, height: 100)
                                        .background(.red)
                                }
                            }
                            
                        }
                    }
                }
                .padding(EdgeInsets(top: 0, leading: 15, bottom: 0, trailing: 0))
                
                HStack {
                    Spacer()
                    VStack(alignment: .leading) {
                        HStack{
                            Text("👖 Bottoms")
                                .font(.title)
                                .fontWeight(.bold)
                            
                            Spacer()
                            Spacer()
                            Spacer()
                            Button(action: {
                                print("Bottoms action")
                            }) {
                                Text("See All →")
                                    .font(.subheadline)
                                    .padding(EdgeInsets(top: 15, leading: 0, bottom: 0, trailing: 10))
                                    .background(Color.clear)
                                    .foregroundColor(.black)
                                    .cornerRadius(10)
                            }
                        }
                        
                        ScrollView(.horizontal) {
                            HStack(spacing: 20) {
                                ForEach(0..<5) { index in
                                    Text("Item \(index)")
                                        .font(.largeTitle)
                                        .frame(width: 100, height: 100)
                                        .background(.red)
                                }
                            }
                            
                        }
                    }
                }
                .padding(EdgeInsets(top: 0, leading: 15, bottom: 0, trailing: 0))

                
                HStack {
                    Spacer()
                    VStack(alignment: .leading) {
                        HStack{
                            Text("👟 Shoes")
                                .font(.title)
                                .fontWeight(.bold)
                            
                            Spacer()
                            Spacer()
                            Spacer()
                            Button(action: {
                                print("Shoes action")
                            }) {
                                Text("See All →")
                                    .font(.subheadline)
                                    .padding(EdgeInsets(top: 15, leading: 0, bottom: 0, trailing: 10))
                                    .background(Color.clear)
                                    .foregroundColor(.black)
                                    .cornerRadius(10)
                            }
                        }
                        
                        ScrollView(.horizontal) {
                            HStack(spacing: 20) {
                                ForEach(0..<5) { index in
                                    Text("Item \(index)")
                                        .font(.largeTitle)
                                        .frame(width: 100, height: 100)
                                        .background(.red)
                                }
                            }
                            
                        }
                    }
                }
                .padding(EdgeInsets(top: 0, leading: 15, bottom: 0, trailing: 0))

                
                Spacer()

            }
        }
        .padding(EdgeInsets(top: 0, leading: 0, bottom: 50, trailing: 0))
    }
}

#Preview {
    ClosetView()
}
