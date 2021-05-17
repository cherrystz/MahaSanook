//
//  ChessViewController.swift
//  MahaSanook
//
//  Created by Napassorn V. on 4/12/2563 BE.
//

import UIKit
import SwiftChess

class ChessViewController: UIViewController {
    
    @IBOutlet weak var chessBackgrond: UIImageView!
    @IBOutlet weak var viewGame: UIView!
    @IBOutlet weak var aiButton: UIButton!
    @IBOutlet weak var playerButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "SwiftChess"
        
        chessBackgrond.layer.cornerRadius = 20
        viewGame.layer.cornerRadius = 20
        aiButton.isDefaultButton()
        playerButton.isDefaultButton()
    }
    
    // MARK: - Actions
    
    @IBAction func didTapBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func playerVsAIButtonPressed(_ sender: UIButton) {
        
        let whitePlayer = Human(color: .white)
        let blackPlayer = AIPlayer(color: .black, configuration: AIConfiguration(difficulty: .hard))
        
        let game = Game(firstPlayer: whitePlayer, secondPlayer: blackPlayer)
        startGame(game: game, title: "Player vs AI")
    }
    
    @IBAction func playerVsPlayerButtonPressed(_ sender: UIButton) {
        
        let whitePlayer = Human(color: .white)
        let blackPlayer = Human(color: .black)
        
        let game = Game(firstPlayer: whitePlayer, secondPlayer: blackPlayer)
        startGame(game: game, title: "Player vs Player")
    }
    
    func startGame(game: Game, title: String) {
        
        let gameViewController = GameViewController.gameViewController(game: game)
        gameViewController.title = title
        self.navigationController?.pushViewController(gameViewController, animated: true)
    }

}
