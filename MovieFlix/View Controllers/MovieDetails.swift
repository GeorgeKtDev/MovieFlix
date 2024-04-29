//
//  MovieDetails.swift
//  MovieFlix
//
//  Created by George on 28/4/24.
//

import SwiftUI
import Kingfisher

struct MovieDetails: View {
    @EnvironmentObject var coordinator: Coordinator
    
    let pathPrefix = "https://image.tmdb.org/t/p/original/"
    var dismissAction: () -> Void
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                HStack {
                    Button(action: {
                        dismissAction()
                    }) {
                        Image(systemName: "arrow.left")
                            .resizable()
                            .font(.title)
                            .foregroundColor(.black)
                            .scaledToFit()
                            .frame(width: 32, height: 32)
                    }
                    .padding(.leading)
                    
                    Spacer()
                }
                
                if let posterPath = coordinator.selectedItem?.posterPath,
                   let imageURL = URL(string: pathPrefix + posterPath) {
                    KFImage(imageURL)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(maxWidth: .infinity)
                        .frame(height: 200)
                        .cornerRadius(10)
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                } else {
                    Image(.movieIcon)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(maxWidth: .infinity)
                        .frame(height: 200)
                        .cornerRadius(10)
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                }
                
                HStack {
                    if let title = coordinator.selectedItem?.title {
                        Text(title)
                            .font(.title)
                            .fontWeight(.bold)
                    } else {
                        Text("Movie Title")
                            .font(.title)
                            .fontWeight(.bold)
                    }
                    
                    Spacer()
                    Button(action: {
                        
                    }) {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.red)
                            .frame(width: 40, height: 40)
                    }
                }.padding(.horizontal, 16)
                
                // I suppose the genres are meant to be fetched with these IDs
                if let genreIDs = coordinator.selectedItem?.genreIds {
                    let genresText = genreIDs.map { String($0) }.joined(separator: ", ")
                    
                    Text(genresText)
                        .padding(.horizontal, 16)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.gray)
                } else {
                    Text("")
                        .padding(.horizontal, 16)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.gray)
                }
                
                if let date = coordinator.selectedItem?.releaseDate {
                    Text(dateFormatted(dateUnformatted: date))
                        .padding(.horizontal, 16)
                        .padding(.top, 20)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.yellow)
                }
                
                // Haven't implemented it yet.
                HStack {
                    Image(systemName: "star.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.yellow)
                    
                    Image(systemName: "star.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.yellow)
                    
                    Image(systemName: "star.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.yellow)
                    
                    Image(systemName: "star.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.yellow)
                    
                    Image(systemName: "star.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.yellow)
                }.padding(.horizontal, 16)
                    .padding(.top, 2)
                
                
                Text("Description")
                    .padding(.horizontal, 16)
                    .padding(.top, 20)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.blue)
                
                if let overview = coordinator.selectedItem?.overview {
                    Text(overview)
                        .padding(.horizontal, 16)
                        .padding(.top, 2)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.gray)
                } else {
                    Text("Add an overview for this movie...")
                        .padding(.horizontal, 16)
                        .padding(.top, 2)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.gray)
                }
                
                Text("Cast")
                    .padding(.horizontal, 16)
                    .padding(.top, 20)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.blue)
                
                Text("Actor 1, Actor 2 etc")
                    .padding(.horizontal, 16)
                    .padding(.top, 2)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.black)
            }
        }.padding(.top, 16)
    }
    
    
    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            let coordinator = Coordinator()
            let dummyDismiss = {}
            
            return MovieDetails(dismissAction: dummyDismiss)
                .environmentObject(coordinator)
        }
    }
}
