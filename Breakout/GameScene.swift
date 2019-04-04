import SpriteKit
import GameplayKit

class GameScene: SKScene,  SKPhysicsContactDelegate {
    var ball = SKShapeNode()
    var paddle = SKSpriteNode()
    var brick = SKSpriteNode()
    var loseZone = SKSpriteNode()
    
    var bricks = [SKSpriteNode()]
    
    var button = SKLabelNode()
    var gameStart = false
    
    
    let BallCategory   : UInt32 = 0x1 << 0
    let CollisionCategory : UInt32 = 0x1 << 1
    let BlockCategory  : UInt32 = 0x1 << 2
    let PaddleCategory : UInt32 = 0x1 << 3
    let BoarderCategory : UInt32 = 0x1 << 4
    
    override func didMove(to view: SKView) {
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        
        physicsWorld.contactDelegate = self
        
        
        
        createBackground()
        makeBrick()
        makeLoseZone()
        makeeButton()
        makePaddle()
        
        self.physicsBody!.categoryBitMask = BoarderCategory
        loseZone.physicsBody!.categoryBitMask = CollisionCategory
        brick.physicsBody!.categoryBitMask = CollisionCategory
        
        
        let paddle = childNode(withName: "paddle") as! SKSpriteNode
        
        paddle.physicsBody!.categoryBitMask = PaddleCategory
        paddle.physicsBody!.categoryBitMask = CollisionCategory
        
    }
    
    func startUp(){
        makeBall()
        
        ball.physicsBody!.categoryBitMask = BallCategory
        ball.physicsBody!.categoryBitMask = BallCategory
        ball.physicsBody!.contactTestBitMask = CollisionCategory
        ball.physicsBody?.isDynamic = true
        ball.physicsBody?.applyImpulse(CGVector(dx: 3, dy: 5))
    }
    
    func createBackground() {
        let stars = SKTexture(imageNamed: "stars")
        for i in 0...1 {
            let starsBackground = SKSpriteNode(texture: stars)
            starsBackground.zPosition = -1
            starsBackground.position = CGPoint(x: 0, y: starsBackground.size.height * CGFloat(i))
            addChild(starsBackground)
            let moveDown = SKAction.moveBy(x: 0, y: -starsBackground.size.height, duration: 20)
            let moveReset = SKAction.moveBy(x: 0, y: starsBackground.size.height, duration: 0)
            let moveLoop = SKAction.sequence([moveDown, moveReset])
            let moveForever = SKAction.repeatForever(moveLoop)
            starsBackground.run(moveForever)
        }
    }
    
    
    func makeBall() {
        ball = SKShapeNode(circleOfRadius: 10)
        ball.position = CGPoint(x: frame.midX, y: frame.midY)
        ball.strokeColor = UIColor.black
        ball.fillColor = UIColor.yellow
        ball.name = "ball"
        // physics shape matches ball image
        ball.physicsBody = SKPhysicsBody(circleOfRadius: 10)
        // ignores all forces and impulses
        ball.physicsBody?.isDynamic = true
        // use precise collision detection
        ball.physicsBody?.usesPreciseCollisionDetection = true
        // no loss of energy from friction
        ball.physicsBody?.friction = 0
        // gravity is not a factor
        ball.physicsBody?.affectedByGravity = false
        // bounces fully off of other objects
        ball.physicsBody?.restitution = 1
        // does not slow down over time
        ball.physicsBody?.linearDamping = 0
        addChild(ball) // add ball object to the view
    }
    
    
    
    func makePaddle() {
        paddle = SKSpriteNode(color: UIColor.white, size: CGSize(width: frame.width/4, height: 20))
        paddle.position = CGPoint(x: frame.midX, y: frame.minY + 125)
        paddle.name = "paddle"
        paddle.physicsBody = SKPhysicsBody(rectangleOf: paddle.size)
        paddle.physicsBody?.isDynamic = false
        paddle.physicsBody?.restitution = 1
        addChild(paddle)
    }
    //frame.width = (numBricks*BrickSize) + (numBricks-1)*spacer)
    
    func makeBrick() {
        var tracker = 1;
        //make sure to change baselineX when changing brickSize
        let baselineX = CGFloat(frame.minX + frame.width/16)
        //spacer = frame.width-(numBricks*brickSize)/numBricks-1
        let spacer = CGFloat((frame.width-(7*(frame.width/8)))/6)
        for x in 0...6{
            let temp = CGFloat(x)
            //xMod = brickNum(brickSize + spacer)
            let xMod = (temp*(frame.width/8)) + CGFloat(temp*spacer)//make sure no bricks are cut off horizontally
            let baselineY = CGFloat(frame.maxY-80)
            for y in 0...2{
                let yMod = CGFloat((y*20)+(y*5))
                brick = SKSpriteNode(color: UIColor.blue, size: CGSize(width: frame.width/8, height: 20))
                brick.position = CGPoint(x: baselineX + xMod, y: baselineY - yMod)
                brick.name = "\(tracker)"
                brick.physicsBody = SKPhysicsBody(rectangleOf: brick.size)
                brick.physicsBody?.isDynamic = false
                addChild(brick)
                bricks.append(brick)
                tracker = tracker + 1
            }
        }
    }
    
    
    func makeLoseZone() {
        loseZone = SKSpriteNode(color: UIColor.red, size: CGSize(width: frame.width, height: 70))
        loseZone.position = CGPoint(x: frame.midX, y: frame.minY + 25)
        loseZone.name = "loseZone"
        loseZone.physicsBody = SKPhysicsBody(rectangleOf: loseZone.size)
        loseZone.physicsBody?.isDynamic = false
        loseZone.physicsBody?.restitution = 0.5
        addChild(loseZone)
    }
    
    
    func makeeButton(){
        button.text = "Tap to Start"
        addChild(button)
    }
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            if gameStart {
                let location = touch.location(in: self)
                paddle.position.x = location.x
                //paddle.position.y = location.y
            }else{
                startUp()
                button.alpha = 0
                gameStart = true
                
            }
            
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            paddle.position.x = location.x
            //paddle.position.y = location.y
        }
    }
    
    
    func brickHit(){
        if brick.color == .blue{
            brick.color = .orange
            
        }else if brick.color == .orange{
            brick.color = .red
            
        }else if brick.color == .red{
            brick.removeFromParent()
        }else{
            print("UHHHHHHHHHH")
        }
    }
    
    
    func didBegin(_ contact: SKPhysicsContact) {
        var obj: SKPhysicsBody
        // 2
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            obj = contact.bodyB
        } else {
            obj = contact.bodyA
        }
        
        
        //print(obj.node!.name!)
        
        if (obj.node!.name!.contains("loseZone")){
            ball.removeFromParent()
            
        }else if obj.node!.name!.contains("paddle"){
            
            
        }else{
            let index =  Int(obj.node!.name!)
            //print(index!)
            brick = bricks[index!]
            brickHit()
        }
        
    }
}






