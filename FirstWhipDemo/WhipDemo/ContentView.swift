//
//  ContentView.swift
//  WhipDemo
//
//  Created by Antonio Tridente on 11/03/24.
//

import SwiftUI
import SpriteKit

var mostraBarra = false

struct ContentView: View {
    
    // !!!!!!!!! Questo una volta era State object !!!!!!!!!!
    @ObservedObject private var viewModel: ViewModel = ViewModel()
    
    var body: some View {
        Sview(viewModel: viewModel)
    }
    
}


struct Sview: View {
    
   var viewModel: ViewModel
    
    var scene: SKScene{
        let scene = SKScene (fileNamed: "GameSceneIphone") as! SKScriptIphone
        scene.size = CGSize(width: 1634, height: 750)
        scene.scaleMode = .aspectFill
        scene.setViewModel(viewModel: viewModel)
        return scene
    }

    var body: some View {
      
        SpriteView(scene: scene)
        
    }
    

}

// Struttura che mostra la barra di progressione
struct BarraPiena: View {
   var valore: Double
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .opacity(0.2)
                    .foregroundColor(Color.blue)
                
                Rectangle()
                    .frame(width: self.barraWidth(geometry: geometry), height: geometry.size.height)
                    .foregroundColor(self.barraColor())
                    .animation(.smooth)
                
            }
        }
    }
    
    private func barraWidth(geometry: GeometryProxy) -> CGFloat {
        let width = CGFloat(600 - self.valore) / 600 * geometry.size.width
        return width
    }
    
    private func barraColor() -> Color {
        let percentuale = self.valore / 600
        let red = percentuale
        let green = max(0.3, 0.77 - percentuale)
        let blue = max(0.2, 0.7 - percentuale)
        return Color(red: red, green: green, blue: blue)
        
    }
}





#Preview {
    ContentView()
}
