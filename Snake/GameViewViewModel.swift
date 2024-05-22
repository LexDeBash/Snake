//
//  GameViewViewModel.swift
//  Snake
//
//  Created by Alexey Efimov on 21.05.2024.
//

import Foundation

// Перечисление возможных состояний игры
enum GameState {
    case notStarted, playing, paused, gameOver
    
    var buttonTitle: String {
        switch self {
        case .notStarted:
            "Start Game"
        case .playing:
            "Pause"
        case .paused:
            "Resume"
        case .gameOver:
            "Restart"
        }
    }
}

// Перечисление возможных направлений движения змейки
enum Direction {
    case up, down, left, right
}

// Конфигурация игрового поля
struct GridConfig {
    static let columnCount = 10
    static let rowCount = 18
}

// Структура для предоставления координат на игровом поле
struct Point: Equatable {
    var x: Int
    var y: Int
    
    static var zero: Point {
        Point(x: 0, y: 0)
    }
}

// Модель представления для игры
@Observable
final class GameViewViewModel {
    var snakeBody = [Point(x: 2, y: 2), Point(x: 2, y: 1), Point(x: 2, y: 0)]
    var apple = Point.zero
    
    var score = 0
    var alertIsPresented = false
    
    var highScore: Int {
        storageManager.getHighScore
    }
    
    var buttonTitle: String {
        currentState.buttonTitle
    }
    
    private var currentState: GameState = .notStarted
    private var currentDirection: Direction = .down
    private var timer: Timer?
    private let storageManager = StorageManager.shared
    
    func buttonDidTapped() {
        switch currentState {
        case .notStarted:
            startGame()
        case .playing:
            pauseGame()
        case .paused:
            resumeGame()
        case .gameOver:
            startGame()
        }
    }
    
    func changeDirection(to newDirection: Direction) {
        // Запрещаем разворачиваться на 180 градусов, проверяя противоположные направления
        switch (currentDirection, newDirection) {
            case (.up, .down), (.down, .up), (.left, .right), (.right, .left):
                // Ничего не делаем, если новое направление противоположно текущему
                break
            default:
                // Изменяем направление, если оно не противоположно текущему
                currentDirection = newDirection
        }
    }
    
    // Начать игру с начальным состоянием
    private func startGame() {
        snakeBody = [Point(x: 2, y: 2), Point(x: 2, y: 1), Point(x: 2, y: 0)]
        placeApple()
        score = 0
        currentState = .playing
        setTimer()
    }
    
    // Логика движения змейки
    private func moveSnake() {
        guard currentState != .gameOver else { return }
        let newHead = calculateNewHead()
        handleCollision(newHead: newHead)
    }
    
    private func calculateNewHead() -> Point {
        var newHead = snakeBody.first ?? Point.zero
        switch currentDirection {
        case .up:
            newHead.y -= 1
        case .down:
            newHead.y += 1
        case .left:
            newHead.x -= 1
        case .right:
            newHead.x += 1
        }
        return newHead
    }
    
    private func handleCollision(newHead: Point) {
        if newHead == apple {
            eatApple(newHead: newHead)
        } else if isCollision(newHead: newHead) {
            endGame()
        } else {
            moveSnakeBody(newHead: newHead)
        }
    }
    
    private func eatApple(newHead: Point) {
        snakeBody.insert(newHead, at: 0)
        placeApple()
        score += 1
    }

    private func isCollision(newHead: Point) -> Bool {
        newHead.x < 0 || newHead.y < 0 || newHead.x >= GridConfig.columnCount || newHead.y >= GridConfig.rowCount || snakeBody.dropFirst().contains(newHead)
    }

    private func moveSnakeBody(newHead: Point) {
        snakeBody.insert(newHead, at: 0)
        snakeBody.removeLast()
    }
    
    private func pauseGame() {
        timer?.invalidate()
        currentState = .paused
    }
    
    private func resumeGame() {
        setTimer()
        currentState = .playing
    }
    
    private func endGame() {
        alertIsPresented.toggle()
        timer?.invalidate()
        currentState = .gameOver
        currentDirection = .down
        storageManager.setHighScore(max(score, highScore))
    }
    
    // Размещаем новое яблоко на поле
    private func placeApple() {
        repeat {
            apple = Point(
                x: Int.random(in: 0..<GridConfig.columnCount),
                y: Int.random(in: 0..<GridConfig.rowCount)
            )
        } while snakeBody.contains(apple)
    }
    
    private func setTimer() {
        timer = .scheduledTimer(withTimeInterval: 0.5, repeats: true) { [unowned self] _ in
            moveSnake()
        }
    }
}
