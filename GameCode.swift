import Foundation

let ball = OvalShape(width: 40, height: 40)

var barriers: [Shape] = []
var targets: [Shape] = []
var score = 0
var currentLevel = 1

let colorPalette: [Color] = [.red, .orange, .yellow, .green, .blue, .purple]

let funnelPoints = [
    Point(x: 0, y: 50),
    Point(x: 80, y: 50),
    Point(x: 60, y: 0),
    Point(x: 20, y: 0)
]

let funnel = PolygonShape(points: funnelPoints)

fileprivate func setupBall() {
    ball.position = Point(x: 250, y: 400)
    scene.add(ball)
    ball.hasPhysics = true
    ball.fillColor = .blue
    ball.isDraggable = false
    
    ball.onCollision = ballCollided(with:)
    
    scene.trackShape(ball)
    ball.onExitedScene = ballExitedScene
    
    ball.onTapped = resetGame
    
    ball.bounciness = 0.8
}

fileprivate func addBarrier(at position: Point, width: Double, height: Double, angle: Double) {
    let barrierPoints = [
        Point(x: 0, y: 0),
        Point(x: 0, y: height),
        Point(x: width, y: height),
        Point(x: width, y: 0)
    ]
    
    let barrier = PolygonShape(points: barrierPoints)
    
    barriers.append(barrier)
    
    barrier.position = position
    barrier.hasPhysics = true
    scene.add(barrier)
    barrier.isImmobile = true
    barrier.isImpermeable = true
    barrier.fillColor = colorPalette.randomElement()!
    barrier.angle = angle
}

fileprivate func setupFunnel() {
    funnel.position = Point(x: 200, y: scene.height - 25)
    scene.add(funnel)
    funnel.onTapped = dropBall
    funnel.fillColor = .purple
    funnel.isDraggable = true  // Change this to true

}

func restrictFunnelPosition(_ shape: Shape) {
    let topMargin: Double = 25 // Distance from the top of the screen
    let minX: Double = 40 // Half the funnel's width
    let maxX = scene.width - 40 // Adjust based on funnel width
    
    let restrictedX = min(max(shape.position.x, minX), maxX)
    let restrictedY = scene.height - topMargin
    
    shape.position = Point(x: restrictedX, y: restrictedY)
}




func addTarget(at position: Point) {
    let targetPoints = [
        Point(x: 10, y: 0),
        Point(x: 0, y: 10),
        Point(x: 10, y: 20),
        Point(x: 20, y: 10)
    ]

    let target = PolygonShape(points: targetPoints)

    targets.append(target)
    
    target.position = position
    target.hasPhysics = true
    target.isImmobile = true
    target.isImpermeable = false
    target.fillColor = colorPalette.randomElement()!
    target.name = "target"
    target.isDraggable = false
    
    scene.add(target)
}

func setup() {
    setupBall()
    setupFunnel()
    setupLevel()
    
    resetGame()
        
    scene.onShapeMoved = printPosition(of:)
}

func setupLevel() {
    // Clear existing barriers and targets
    for barrier in barriers { scene.remove(barrier) }
    for target in targets { scene.remove(target) }
    barriers.removeAll()
    targets.removeAll()

    // Add barriers and targets based on the current level
    let barrierCount = 2 + currentLevel
    let targetCount = 3 + currentLevel

    for _ in 0..<barrierCount {
        let x = Double.random(in: 50...scene.width-50)
        let y = Double.random(in: 100...scene.height-200)
        let width = Double.random(in: 30...100)
        let height = Double.random(in: 15...30)
        let angle = Double.random(in: -0.5...0.5)
        addBarrier(at: Point(x: x, y: y), width: width, height: height, angle: angle)
    }

    for _ in 0..<targetCount {
        let x = Double.random(in: 50...scene.width-50)
        let y = Double.random(in: 100...scene.height-100)
        addTarget(at: Point(x: x, y: y))
    }
}

func dropBall() {
    ball.position = funnel.position
    ball.stopAllMotion()
    
    for barrier in barriers {
        barrier.isDraggable = false
    }
    
    for target in targets {
        target.fillColor = colorPalette.randomElement()!
    }
}


func resetFunnel() {
    funnel.isDraggable = true
}


func ballCollided(with otherShape: Shape) {
    if otherShape.name == "target" {
        if otherShape.fillColor != .green {
            otherShape.fillColor = .green
            score += 10
            animateTarget(otherShape)
        }
    }
}

func ballExitedScene() {
    for barrier in barriers {
        barrier.isDraggable = true
    }
    
    var hitTargets = 0
    for target in targets {
        if target.fillColor == .green {
            hitTargets += 1
        }
    }
    
    if hitTargets == targets.count {
        currentLevel += 1
        scene.presentAlert(text: "Level \(currentLevel-1) completed! Next level: \(currentLevel)", completion: nextLevel)
    } else {
        resetBall()
    }
}

func resetBall() {
    ball.position = Point(x: 0, y: -80)
}


func nextLevel() {
    setupLevel()
    resetGame()
    resetFunnel()
}

func resetGame() {
    resetBall()
    score = 0
}


func animateTarget(_ target: Shape) {
    let originalPosition = target.position
    target.position = Point(x: originalPosition.x, y: originalPosition.y + 10)
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
        target.position = originalPosition
    }
}

func printPosition(of shape: Shape) {
    print(shape.position)
}
