//
//  GameView.swift
//  Snake
//
//  Created by Alexey Efimov on 21.05.2024.
//

import SwiftUI

struct GameView: View {
    @State private var viewModel = GameViewViewModel()
    
    var body: some View {
        
        // Текущая информация о количестве набранных очков
        VStack {
            HStack {
                Text("Current Score: \(viewModel.score)")
                    .font(.headline)
                
                Spacer()
                
                Text("High Score: \(viewModel.highScore)")
                    .font(.headline)
            }
            
            CellView(viewModel: viewModel)
                .gesture(
                    DragGesture(minimumDistance: 0).onEnded { value in
                         changeDirection(from: value)
                    }
                )
            
            Button(viewModel.buttonTitle, action: viewModel.buttonDidTapped)
                .padding()
        }
        .padding()
        .alert(
            "Game Over",
            isPresented: $viewModel.alertIsPresented,
            actions: {
                Button("Restart", action: viewModel.buttonDidTapped)
                Button("Cancel") {}
            }, message: {
                Text("Your Score: \(viewModel.score). High Score: \(viewModel.highScore)")
            }
        )
    }
    
    // Определение направления движения змейки по жестам
    private func changeDirection(from drag: DragGesture.Value) {
        let horizontal = drag.translation.width
        let vertical = drag.translation.height

        if abs(horizontal) > abs(vertical) {
            viewModel.changeDirection(to: horizontal > 0 ? .right : .left)
        } else {
            viewModel.changeDirection(to: vertical > 0 ? .down : .up)
        }
    }
}

#Preview {
    GameView()
}

struct CellView: View {
    let viewModel: GameViewViewModel
    
    var body: some View {
        Grid(horizontalSpacing: 2, verticalSpacing: 2) {
            ForEach(0..<GridConfig.rowCount, id: \.self) { row in
                GridRow {
                    ForEach(0..<GridConfig.columnCount, id: \.self) { column in
                        var point: Point {
                            Point(x: column, y: row)
                        }
                        
                        var cellColor: Color {
                            if viewModel.snakeBody.contains(point) {
                                .green
                            } else if viewModel.apple == point {
                                .red
                            } else {
                                .black
                            }
                        }
                        
                        Rectangle()
                            .fill(cellColor)
                            .aspectRatio(contentMode: .fit)
                    }
                }
            }
        }
        .border(.gray, width: 2)
    }
}
