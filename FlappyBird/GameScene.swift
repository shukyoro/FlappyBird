//
//  GameScene.swift
//  FlappyBird
//
//  Created by 廣田秀人 on 2022/11/17.
//

import UIKit
import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var scrollNode:SKNode!
    var wallNode:SKNode!
    var itemNode:SKNode!
    var bird:SKSpriteNode!
    var gameOver:SKShapeNode!
    
    // 衝突判定カテゴリー
    let birdCategory: UInt32 = 1 << 0   // 0...00001
    let groundCategory: UInt32 = 1 << 1 // 0...00010
    let wallCategory: UInt32 = 1 << 2   // 0...00100
    let scoreCategory: UInt32 = 1 << 3  // 0...01000
    let itemCategory: UInt32 = 1 << 4  // 0...10000
    
    // スコア用
    var score = 0
    var scoreLabelNode:SKLabelNode!
    var bestScoreLabelNode:SKLabelNode!
    // アイテムスコア用
    var itemScore = 0
    var itemScoreLabelNode:SKLabelNode!
    let userDefaults:UserDefaults = UserDefaults.standard
    // リスタート用テキスト
    var restartLabelNode:SKLabelNode!
    
    var gameBGM : SKAction!
    var itemSE : SKAction!
    var gameOverSE : SKAction!
    
    var gameAudio = SKAudioNode.init(fileNamed: "comicalpizzicato.mp3")
    
    // SKView上にシーンが表示されたときに呼ばれるメソッド
    override func didMove(to view: SKView) {
        
        // 重力を設定
        physicsWorld.gravity = CGVector(dx: 0, dy: -4)
        physicsWorld.contactDelegate = self
        
        // 背景色を設定
        backgroundColor = UIColor(red: 0.15, green: 0.75, blue: 0.9, alpha: 1)
        
        // BGMを設定
//        gameBGM = SKAction.playSoundFileNamed("comicalpizzicato.mp3", waitForCompletion: true)
        //無限ループするアクションに変更する。
//        let gameBgmLoop = SKAction.repeatForever(gameBGM)
        //アクションを実行する。
//        self.run(gameBgmLoop)
        
        // BGM AudioNode　でのテスト
        addChild(gameAudio)
        
        // 効果音を設定
        itemSE = SKAction.playSoundFileNamed("itemGet.mp3", waitForCompletion: true)
        gameOverSE = SKAction.playSoundFileNamed("gameOver.mp3", waitForCompletion: true)

        // スクロールするスプライトの親ノード
        scrollNode = SKNode()
        addChild(scrollNode)
        
        // 壁用のノード
        wallNode = SKNode()
        scrollNode.addChild(wallNode)
        
        // アイテム用のノード
        itemNode = SKNode()
        scrollNode.addChild(itemNode)
        
        // 各種スプライトを生成する処理をメソッドに分割
        setupGround()
        setupCloud()
        setupWall()
        setupBird()
        setupItem()
        
        // スコア表示ラベルの設定
        setupScoreLabel()
    }
    
    func setupGround() {
        // 地面の画像を読み込む
        let groundTexture = SKTexture(imageNamed: "ground")
        groundTexture.filteringMode = .nearest
        
        // 必要な枚数を計算
        let needGroundNumber = Int(self.frame.size.width / groundTexture.size().width) + 2
        
        // スクロールするアクションを作成
        // 左方向に画像一枚分スクロールさせるアクション
        let moveGround = SKAction.moveBy(x: -groundTexture.size().width, y: 0, duration: 5)
        
        // 元の位置に戻すアクション
        let resetGround = SKAction.moveBy(x: groundTexture.size().width, y: 0, duration: 0)
        
        // 左にスクロール->元の位置->左にスクロールと無限に繰り返すアクション
        let repeatScrollGround = SKAction.repeatForever(SKAction.sequence([moveGround, resetGround]))
        
        // groundのスプライトを配置する
        for i in 0..<needGroundNumber {
            let sprite = SKSpriteNode(texture: groundTexture)
            
            // スプライトの表示する位置を指定する
            sprite.position = CGPoint(x: groundTexture.size().width / 2  + groundTexture.size().width * CGFloat(i),
                                      y: groundTexture.size().height / 2)
            
            // スプライトにアクションを設定する
            sprite.run(repeatScrollGround)
            
            // スプライトに物理体を設定する
            sprite.physicsBody = SKPhysicsBody(rectangleOf: groundTexture.size())
            
            // 衝突のカテゴリー設定
            sprite.physicsBody?.categoryBitMask = groundCategory
            
            // 衝突の時に動かないように設定する
            sprite.physicsBody?.isDynamic = false
            
            // シーンにスプライトを追加する
            scrollNode.addChild(sprite)
        }
    }
    
    func setupCloud() {
        // 雲の画像を読み込む
        let cloudTexture = SKTexture(imageNamed: "cloud")
        cloudTexture.filteringMode = .nearest
        
        // 必要な枚数を計算
        let needCloudNumber = Int(self.frame.size.width / cloudTexture.size().width) + 2
        
        // スクロールするアクションを作成
        // 左方向に画像一枚分スクロールさせるアクション
        let movecloud = SKAction.moveBy(x: -cloudTexture.size().width, y: 0, duration: 20)
        
        // 元の位置に戻すアクション
        let resetcloud = SKAction.moveBy(x: cloudTexture.size().width, y: 0, duration: 0)
        
        // 左にスクロール->元の位置->左にスクロールと無限に繰り返すアクション
        let repeatScrollcloud = SKAction.repeatForever(SKAction.sequence([movecloud, resetcloud]))
        
        // cloudのスプライトを配置する
        for i in 0..<needCloudNumber {
            let sprite = SKSpriteNode(texture: cloudTexture)
            sprite.zPosition = -100 // 一番後ろになるようにする
            
            // スプライトの表示する位置を指定する
            sprite.position = CGPoint(x: cloudTexture.size().width / 2  + cloudTexture.size().width * CGFloat(i),
                                      y: self.size.height - cloudTexture.size().height / 2)
            
            // スプライトにアクションを設定する
            sprite.run(repeatScrollcloud)
            
            // 衝突のカテゴリー設定
            sprite.physicsBody?.categoryBitMask = groundCategory
            
            // シーンにスプライトを追加する
            scrollNode.addChild(sprite)
        }
    }
    
    func setupWall() {
        // 壁の画像を読み込む
        let wallTexture = SKTexture(imageNamed: "wall")
        wallTexture.filteringMode = .linear
        
        // 移動する距離を計算
        let movingDistance = self.frame.size.width + wallTexture.size().width
        
        // 画面外まで移動するアクションを作成
        let moveWall = SKAction.moveBy(x: -movingDistance, y: 0, duration: 4)
        
        // 自信を取り除くアクションを作成
        let removeWall = SKAction.removeFromParent()
        
        // 二つのアニメーションを順に実行するアクションを作成
        let wallAnimation = SKAction.sequence([moveWall, removeWall])
        
        // 鳥の画像サイズを取得
        let birdSize = SKTexture(imageNamed: "bird_a").size()
        
        // 鳥が通り抜ける隙間の大きさを鳥のサイズの４倍とする
        let slit_length = birdSize.height * 4
        
        // 隙間位置の上下の振れ幅を60ptとする
        let random_y_range: CGFloat = 60
        
        // 空の中央位置（Y座標）を取得
        let groundSize = SKTexture(imageNamed: "ground").size()
        let sky_center_y = groundSize.height + (self.frame.size.height - groundSize.height) / 2
        
        // 空の中央位置を基準にして下側の壁の中央位置を取得
        let under_wall_center_y = sky_center_y - slit_length / 2 - wallTexture.size().height / 2
        
        // 壁を生成するアクションを作成
        let createWallAnimation = SKAction.run({
            // 壁をまとめるノードを作成
            let wall = SKNode()
            wall.position = CGPoint(x: self.frame.size.width + wallTexture.size().width / 2, y: 0)
            wall.zPosition = -50 // 雲より手前、地面より奥
            
            // 下側の壁の中央位置にランダム値を足して、下側の壁の表示位置を決定する
            let random_y = CGFloat.random(in: -random_y_range...random_y_range)
            let under_wall_y = under_wall_center_y + random_y
            
            // 下側の壁を作成
            let under = SKSpriteNode(texture: wallTexture)
            under.position = CGPoint(x: 0, y: under_wall_y)
            
            // 下側の壁に物理体を設定する
            under.physicsBody = SKPhysicsBody(rectangleOf: wallTexture.size())
            under.physicsBody?.categoryBitMask = self.wallCategory
            under.physicsBody?.isDynamic = false
            
            // 壁をまとめるノードに下側の壁を追加
            wall.addChild(under)
            
            // 上側の壁を作成
            let upper = SKSpriteNode(texture: wallTexture)
            upper.position = CGPoint(x: 0, y: under_wall_y + wallTexture.size().height + slit_length)
            
            // 上側の壁に物理体を設定する
            upper.physicsBody = SKPhysicsBody(rectangleOf: wallTexture.size())
            upper.physicsBody?.categoryBitMask = self.wallCategory
            upper.physicsBody?.isDynamic = false
            
            // 壁をまとめるノードに上側の壁を追加
            wall.addChild(upper)
            
            // スコアカウント用の透明な壁を作成
            let scoreNode = SKNode()
            scoreNode.position = CGPoint(x: upper.size.width + birdSize.width / 2, y: self.frame.height / 2)
            // 透明な壁に物理体を設定する
            scoreNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: upper.size.width, height: self.frame.size.height))
            scoreNode.physicsBody?.categoryBitMask = self.scoreCategory
            scoreNode.physicsBody?.isDynamic = false
            // 壁をまとめるノードに透明な壁を追加
            wall.addChild(scoreNode)
            
            // 壁をまとめるノードにアニメーションを設定
            wall.run(wallAnimation)
            
            // 壁を表示するノードに今回作成した壁を追加
            self.wallNode.addChild(wall)
        })
        // 次の壁作成までの時間まちのアクションを作成
        let waitAnimation = SKAction.wait(forDuration: 2)
        
        // 壁を作成->時間待ち->壁を作成を無限に繰り返すアクションを作成
        let repeatForeverAnimation = SKAction.repeatForever(SKAction.sequence([createWallAnimation, waitAnimation]))
        
        // 壁を表示するノードに壁の作成を無限に繰り返すアクションを設定
        wallNode.run(repeatForeverAnimation)
    }
    
    func setupBird() {
        // 鳥の画像を2種類読み込む
        let birdTextureA = SKTexture(imageNamed: "bird_a")
        birdTextureA.filteringMode = .linear
        let birdTextureB = SKTexture(imageNamed: "bird_b")
        birdTextureB.filteringMode = .linear
        
        // 2種類のテクスチャを交互に変更するアニメーションを作成
        let textureAnimation = SKAction.animate(with: [birdTextureA, birdTextureB], timePerFrame: 0.2)
        let flap = SKAction.repeatForever(textureAnimation)
        
        // スプライトを作成
        bird = SKSpriteNode(texture: birdTextureA)
        bird.position = CGPoint(x: self.frame.size.width * 0.2, y: self.frame.size.height * 0.7)
        
        // 物理体を設定
        bird.physicsBody = SKPhysicsBody(circleOfRadius: bird.size.height / 2)
        
        // カテゴリー設定
        bird.physicsBody?.categoryBitMask = birdCategory
        bird.physicsBody?.collisionBitMask = groundCategory | wallCategory
        bird.physicsBody?.contactTestBitMask = groundCategory | wallCategory | scoreCategory | itemCategory
        
        // 衝突した時に回転させない
        bird.physicsBody?.allowsRotation = false
        
        // アニメーションを設定
        bird.run(flap)
        
        // スプライトを追加する
        addChild(bird)
    }
    
    func setupItem() {
        // アイテムの画像を読み込む
        let itemTexture = SKTexture(imageNamed: "apple")
        itemTexture.filteringMode = .linear
        
        // 壁の画像サイズを取得
        let wallSize = SKTexture(imageNamed: "wall").size()
        // 移動する距離を計算
        let movingDistance = self.frame.size.width + wallSize.width
        // 画面外まで移動するアクションを作成
        let moveItem = SKAction.moveBy(x: -movingDistance, y: 0, duration: 4)
        
        // 自信を取り除くアクションを作成
        let removeItem = SKAction.removeFromParent()
        
        // 二つのアニメーションを順に実行するアクションを作成
        let itemMoveAnimation = SKAction.sequence([moveItem, removeItem])
        
        // 地面の画像サイズを取得
        let groundSize = SKTexture(imageNamed: "ground").size()
        
        // アイテムを生成するアクションを作成
        let createItemAnimation = SKAction.run({
            let sprite = SKSpriteNode(texture: itemTexture)
            sprite.zPosition = -50
            
            // アイテム出現Y位置を規定範囲でランダムで出力
            let random_y = CGFloat.random(in: (self.frame.height * 0.2 + groundSize.height) ... self.frame.height * 0.8)
//            print("最小　\(self.frame.height * 0.2 + groundSize.height)")
//            print("最大　\(self.frame.height * 0.8 + groundSize.height)")
//            print(random_y)
            
            // スプライトの表示する位置を指定する　壁の間にアイテム位置を指定
//            sprite.position = CGPoint(x: self.frame.size.width + wallSize.width / 2 - movingDistance / 4, y: random_y)
            sprite.position = CGPoint(x: self.frame.size.width + wallSize.width / 2, y: random_y)
            
            // 物理体を設定
            sprite.physicsBody = SKPhysicsBody(circleOfRadius: itemTexture.size().height / 2)
            // 衝突のカテゴリー設定
            sprite.physicsBody?.categoryBitMask = self.itemCategory
            // 衝突の時に動かないように設定する
            sprite.physicsBody?.isDynamic = false
            // アニメーションを設定
            sprite.run(itemMoveAnimation)
            
            // シーンにスプライトを追加する
            self.itemNode.addChild(sprite)
        })
        // 壁の間に表示するためア1秒待つ
        let wait1sAnimation = SKAction.wait(forDuration: 1)
        // 次のアイテム作成までの時間まちのアクションを作成
        let wait2sAnimation = SKAction.wait(forDuration: 2)

        // アイテムを作成->時間待ち->アイテムを作成を無限に繰り返すアクションを作成
        let repeatForeverAnimation = SKAction.repeatForever(SKAction.sequence([createItemAnimation,  wait2sAnimation]))
        
        // 二つのアニメーションを順に実行するアクションを作成
        let itemAnimation = SKAction.sequence([wait1sAnimation, repeatForeverAnimation])
        
        // アイテムを表示するノードにアイテムの作成を無限に繰り返すアクションを設定
        itemNode.run(itemAnimation)
        
    }
    
    // 画面をタップした時に呼ばれる
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if scrollNode.speed > 0 {
            // 鳥の速度をゼロにする
            bird.physicsBody?.velocity = CGVector.zero
            
            // 鳥に縦方向の力を与える
            bird.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 15))
        } else if bird.speed == 0 {
            restart()
        }
        
    }
    
    // SKPhycicsContactDelegateのメソッド。衝突したときに呼ばれる
    func didBegin(_ contact: SKPhysicsContact) {
//        print("syoutotu")
        // ゲームオーバーの時は何もしない
        if scrollNode.speed <= 0 {
            return
        }
        
        if (contact.bodyA.categoryBitMask & scoreCategory) == scoreCategory || (contact.bodyB.categoryBitMask & scoreCategory) == scoreCategory {
            // スコアカウント用の透明な壁と衝突した
            print("ScoreUp")
            score += 1
            scoreLabelNode.text = "Score:\(score)"
            
            // ベストスコア更新か確認する
            var bestScore = userDefaults.integer(forKey: "BEST")
            if score > bestScore {
                bestScore = score
                bestScoreLabelNode.text = "Best Score:\(bestScore)"
                userDefaults.set(bestScore, forKey: "BEST")
                // 使う必要ない
//                userDefaults.synchronize()
            }
        } else if (contact.bodyA.categoryBitMask & itemCategory) == itemCategory || (contact.bodyB.categoryBitMask & itemCategory) == itemCategory {
            // アイテムと衝突した
            print("Item ScoreUp")
            //効果音を鳴らす
            self.run(itemSE)
            itemScore += 1
            itemScoreLabelNode.text = "Item Score:\(itemScore)"
            // どちらがアイテムか判別
            if contact.bodyA.categoryBitMask == itemCategory {
                // 衝突したアイテムを削除
                contact.bodyA.node?.removeFromParent()
            } else {
                // 衝突したアイテムを削除
                contact.bodyB.node?.removeFromParent()
            }
//            print(contact.bodyA.categoryBitMask)
//            print(contact.bodyB.categoryBitMask)
//            print(contact.bodyB)
        } else {
            // 壁か地面と衝突した
            print("GameOver")
            //効果音を鳴らす
            self.run(gameOverSE)
            
            // BGM停止
            gameAudio.run(SKAction.stop())

            // ゲームオーバ時に画面を黒くする
            let gameOverFadeIn = SKAction.fadeAlpha(to: 0.6, duration: 2)
            gameOver.run(gameOverFadeIn)
            // リスタート用にテキスト表示
            let restartLabelFadeIn = SKAction.fadeIn(withDuration: 2)
            restartLabelNode.run(restartLabelFadeIn)
            
            // スクロールを停止させる
            scrollNode.speed = 0
            
            // 衝突後は地面と反発するのみとする（リスタートするまで壁と反発させない）
            bird.physicsBody?.collisionBitMask = groundCategory
            
            // 衝突後1秒間、鳥をくるくる回転させる
            let roll = SKAction.rotate(byAngle: CGFloat(Double.pi) * CGFloat(bird.position.y), duration: 1)
            bird.run(roll, completion:{
                self.bird.speed = 0
            })
        }
    }
    
    func restart() {
        // BGM再生
        gameAudio.run(SKAction.play())
        // ゲームオーバー時の表示を消す
        gameOver.removeAllActions()
        gameOver.alpha = 0
        restartLabelNode.removeAllActions()
        restartLabelNode.alpha = 0
        // スコアを0にする
        score = 0
        scoreLabelNode.text = "Score:\(score)"
        itemScore = 0
        itemScoreLabelNode.text = "Item Score:\(itemScore)"
        
        // 鳥を初期位置に戻し、壁と地面の両方に反発するように戻す
        bird.position = CGPoint(x: self.frame.size.width * 0.2, y: self.frame.size.height * 0.7)
        bird.physicsBody?.velocity = CGVector.zero
        bird.physicsBody?.collisionBitMask = groundCategory | wallCategory
        bird.zRotation = 0
        
        // 全ての壁を取り除く
        wallNode.removeAllChildren()
        itemNode.removeAllChildren()
        
        // 鳥の羽ばたきを戻す
        bird.speed = 1
        
        // スクロールを再開される
        scrollNode.speed = 1
    }
    
    func setupScoreLabel() {
        // スコア表示を作成
        score = 0
        scoreLabelNode = SKLabelNode()
        scoreLabelNode.fontColor = UIColor.black
        scoreLabelNode.position = CGPoint(x: 10, y: self.frame.size.height - 60)
        scoreLabelNode.zPosition = 100
        scoreLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        scoreLabelNode.text = "Score:\(score)"
        self.addChild(scoreLabelNode)
        
        // ベストスコア表示を作成
        let bestScore = userDefaults.integer(forKey: "BEST")
        bestScoreLabelNode = SKLabelNode()
        bestScoreLabelNode.fontColor = UIColor.black
        bestScoreLabelNode.position = CGPoint(x: 10, y: self.frame.size.height - 90)
        bestScoreLabelNode.zPosition = 100
        bestScoreLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        bestScoreLabelNode.text = "Best Score:\(bestScore)"
        self.addChild(bestScoreLabelNode)
        
        // アイテムスコア表示を作成
        itemScore = 0
        itemScoreLabelNode = SKLabelNode()
        itemScoreLabelNode.fontColor = UIColor.black
        itemScoreLabelNode.position = CGPoint(x: 10, y: self.frame.size.height - 120)
        itemScoreLabelNode.zPosition = 100
        itemScoreLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        itemScoreLabelNode.text = "Item Score:\(itemScore)"
        self.addChild(itemScoreLabelNode)
        
        // リスタート用テキスト表示作成
        restartLabelNode = SKLabelNode()
        restartLabelNode.fontColor = UIColor.white
        restartLabelNode.position = CGPoint(x: self.frame.size.width / 2, y: 200)
        restartLabelNode.zPosition = 300
        restartLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.center
        restartLabelNode.text = "タップで再スタート"
        restartLabelNode.alpha = 0
        self.addChild(restartLabelNode)
        
        // ゲームオーバー用画面表示作成
        gameOver = SKShapeNode(rectOf: CGSize(width: self.frame.width, height: self.frame.height))
        gameOver.position = CGPoint(x:self.frame.midX, y:self.frame.midY)
        gameOver.fillColor = .black
        gameOver.zPosition = 200
        gameOver.alpha = 0
        self.addChild(gameOver)
    }
    
}
