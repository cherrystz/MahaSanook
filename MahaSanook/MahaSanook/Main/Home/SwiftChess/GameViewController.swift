//
//  GameViewController.swift
//  SwiftChess
//
//  Created by Steve Barnegren on 04/09/2016.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

//swiftlint:disable file_length

import UIKit
import SwiftChess
import Firebase

class GameViewController: UIViewController {
    
    @IBOutlet weak var boardView: BoardView!
    @IBOutlet weak var whiteKingSideCastleButton: UIButton!
    @IBOutlet weak var whiteQueenSideCastleButton: UIButton!
    @IBOutlet weak var blackKingSideCastleButton: UIButton!
    @IBOutlet weak var blackQueenSideCastleButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var instanceButton: UIButton!
    @IBOutlet weak var playerButton: UIButton!

    var pieceViews = [PieceView]()
    var game: Game!
    var user = String()
    
    var selectedIndex: Int? {
        didSet {
            updatePieceViewSelectedStates()
        }
    }
    
    var promotionSelectionViewController: PromotionSelectionViewController?
    
    var hasMadeInitialAppearance = false
    
    @IBAction func didTap() {
        let title = "Checkmate!"
        let message = "White wins!"
        
        showAlert(title: title, message: message)
    }
    
    @IBAction func didTapAI() {
        let title = "Checkmate!"
        let message = "Black wins!"
        
        showAlert(title: title, message: message)
    }
    
    
    // MARK: - Creation
    
    class func gameViewController(game: Game) -> GameViewController {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let className = "GameViewController"
        let gameViewController: GameViewController =
            storyboard.instantiateViewController(withIdentifier: className) as! GameViewController
        gameViewController.game = game
        return gameViewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        instanceButton.isDefaultButton()
        playerButton.isDefaultButton()
        playerButton.transform = CGAffineTransform(rotationAngle: .pi)
        playerButton.isHidden = true
        playerButton.isUserInteractionEnabled = false
        if self.title == "Player vs Player" {
            playerButton.isHidden = false
            playerButton.isUserInteractionEnabled = true
        }
        
        // Board View
        boardView.delegate = self
        
        // Game
        self.game.board.printBoardState()
        game.delegate = self
        
        // Add initial piece views
        for location in BoardLocation.all {
            
            guard let piece = game.board.getPiece(at: location) else {
                continue
            }
            
            addPieceView(at: location.x, y: location.y, piece: piece)
        }
        
        // Activity Indicator
        activityIndicator.hidesWhenStopped = true
        
        // Update castle buttons visibility
        updateCastleButtonsVisibility()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Take go if the first player is an AI player
        if !self.hasMadeInitialAppearance {
            if let player = game.currentPlayer as? AIPlayer {
                player.makeMoveAsync()
            }
        }
    }
    
    // MARK: - Manage Piece Views
    
    func addPieceView(at x: Int, y: Int, piece: Piece) {
        
        let location = BoardLocation(x: x, y: y)
        
        let pieceView = PieceView(piece: piece, location: location)
        boardView.addSubview(pieceView)
        pieceViews.append(pieceView)
    }
    
    func removePieceView(withTag tag: Int) {
        
        if let pieceView = pieceViewWithTag(tag) {
            removePieceView(pieceView: pieceView)
        }
    }
    
    func removePieceView(pieceView: PieceView) {
        
        if let index = pieceViews.firstIndex(of: pieceView) {
            pieceViews.remove(at: index)
        }
        
        if pieceView.superview != nil {
            pieceView.removeFromSuperview()
        }
    }
    
    func updatePieceViewSelectedStates() {
        
        for pieceView in pieceViews {
            pieceView.selected = (pieceView.location.index == selectedIndex)
        }
    }
    
    func pieceViewWithTag(_ tag: Int) -> PieceView? {
        return pieceViews.first { $0.piece.tag == tag }
    }
    
    // MARK: - Layout
    
    override func viewDidLayoutSubviews() {
        
        // Layout pieces
        for pieceView in pieceViews {
            
            let gridX = pieceView.location.x
            let gridY = 7 - pieceView.location.y
            
            let width = boardView.bounds.size.width / 8
            let height = boardView.bounds.size.height / 8
            
            pieceView.frame = CGRect(x: CGFloat(gridX) * width,
                                     y: CGFloat(gridY) * height,
                                     width: width,
                                     height: height)
        }
        
        // Layout promotion selection view controller
        if let promotionSelectionViewController = promotionSelectionViewController {
            
            let margin = CGFloat(40)
            promotionSelectionViewController.view.frame = CGRect(x: margin,
                                                                 y: margin,
                                                                 width: view.bounds.size.width - (margin*2),
                                                                 height: view.bounds.size.height - (margin*2))
        }
    }
    
    // MARK: - Alerts
    
    func showAlert(title: String, message: String) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: { _ in
            
            if title == "Checkmate!" { //self.title == "Player vs AI" || self.title == "Player vs Player" {
                
                //Date
                let date = Date()
                let calendar = Calendar.current
                let components = calendar.dateComponents([.year, .month, .day], from: date)

                let year =  components.year
                let month = components.month
                let day = components.day
                
                let hour = calendar.component(.hour, from: date)
                let minutes = calendar.component(.minute, from: date)
                let second = calendar.component(.second, from: date)
                
                let dateTime = "\(year!)x\(month!)x\(day!)x\(hour)x\(minutes)x\(second)"
                
                if self.title == "Player vs AI" {
                    
                    let ref = Database.database().reference()
                    let gameRef = GameHistory.refs.Game.child(Auth.auth().currentUser!.uid).child("single")
                    
                    
                    ref.child("game").child(Auth.auth().currentUser!.uid).child("single").observeSingleEvent(of: .value, with: {(snapshot) in
                        guard var snap = snapshot.value as? [String:String] else {
                            
                            print("noooooooo")
                            if message == "Black wins!" {
                                gameRef.setValue(["\(dateTime)": "AI Wins! (Versus AI)"])
                            }
                            else {
                                gameRef.setValue(["\(dateTime)": "Player Wins! (Versus AI)"])
                            }
                            return
                        }
                        print(snap)
                        print("yesssss")
                        if message == "Black wins!" {
                            snap.updateValue("AI Wins! (Versus AI)", forKey: dateTime)
                        }
                        else {
                            snap.updateValue("Player Wins! (Versus AI)", forKey: dateTime)
                        }
                        let update = ["/game/\(Auth.auth().currentUser!.uid)/single/" : snap]
                        print(snap)
                        ref.updateChildValues(update)
                    })
                    
                    
                    
                    
                }
                else if self.title == "Player vs Player" {
                    
                    let ref = Database.database().reference()
                    let gameRef = GameHistory.refs.Game.child(Auth.auth().currentUser!.uid).child("single")
                    
                    ref.child("game").child(Auth.auth().currentUser!.uid).child("single").observeSingleEvent(of: .value, with: {(snapshot) in
                        guard var snap = snapshot.value as? [String:String] else {
                            if message == "Black wins!" {
                                gameRef.setValue(["\(dateTime)": "Black Wins! (Versus Player)"])
                            }
                            else {
                                gameRef.setValue(["\(dateTime)": "White Wins! (Versus Player)"])
                            }
                            return
                        }
                        if message == "Black wins!" {
                            snap.updateValue("Black Wins! (Versus Player)", forKey: dateTime)
                        }
                        else {
                            snap.updateValue("White Wins! (Versus Player)", forKey: dateTime)
                        }
                        let update = ["/game/\(Auth.auth().currentUser!.uid)/single/" : snap]
                        ref.updateChildValues(update)
                    })
                }
            }
            self.navigationController?.popViewController(animated: true)
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(okAction)
        
        if title != "Checkmate!" {
            alertController.addAction(cancelAction)
        }
        
        present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - Castle buttons visibility
    
    func updateCastleButtonsVisibility() {
        
        let player = game.currentPlayer
        
        var isHuman = true
        if player is AIPlayer {
            isHuman = false
        }
        
        // White king side button
        if isHuman && player?.color == .white && game.board.canColorCastle(color: .white, side: .kingSide) {
            whiteKingSideCastleButton.isHidden = false
        } else {
            whiteKingSideCastleButton.isHidden = true
        }
        
        // White queen side button
        if isHuman && player?.color == .white && game.board.canColorCastle(color: .white, side: .queenSide) {
            whiteQueenSideCastleButton.isHidden = false
        } else {
            whiteQueenSideCastleButton.isHidden = true
        }
        
        // Black king side button
        if isHuman && player?.color == .black && game.board.canColorCastle(color: .black, side: .kingSide) {
            blackKingSideCastleButton.isHidden = false
        } else {
            blackKingSideCastleButton.isHidden = true
        }
        
        // Black queen side button
        if isHuman && player?.color == .black && game.board.canColorCastle(color: .black, side: .queenSide) {
            blackQueenSideCastleButton.isHidden = false
        } else {
            blackQueenSideCastleButton.isHidden = true
        }
    }
    
    // MARK: - Actions
    
    @IBAction func whiteKingSideCastleButtonPressed(sender: UIButton) {
        
        if let player = game.currentPlayer as? Human {
            player.performCastleMove(side: .kingSide)
        }
    }
    
    @IBAction func whiteQueenSideCastleButtonPressed(sender: UIButton) {
        
        if let player = game.currentPlayer as? Human {
            player.performCastleMove(side: .queenSide)
        }
    }
    
    @IBAction func blackKingSideCastleButtonPressed(sender: UIButton) {
        
        if let player = game.currentPlayer as? Human {
            player.performCastleMove(side: .kingSide)
        }
    }
    
    @IBAction func blackQueenSideCastleButtonPressed(sender: UIButton) {
        
        if let player = game.currentPlayer as? Human {
            player.performCastleMove(side: .queenSide)
        }
    }
    
    @IBAction func didTapStopGame(_ sender: UIButton) {
        let alert = UIAlertController.init(title: "Stop game?", message: "Do you want to stop this game?" , preferredStyle: .alert)
        alert.addAction(.init(title: "Stop", style: .destructive, handler: { _ in
            self.navigationController?.popViewController(animated: true)
        }))
        alert.addAction(.init(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
}

// MARK: - Board view delegate

extension GameViewController: BoardViewDelegate {
    
    func touchedSquareAtIndex(_ boardView: BoardView, index: Int) {
                
        // Get the player (must be human)
        guard let player = game.currentPlayer as? Human else {
            return
        }
        
        let location = BoardLocation(index: index)
        
        // If has tapped the same piece again, deselect it
        if let selectedIndex = selectedIndex {
            if location == BoardLocation(index: selectedIndex) {
                self.selectedIndex = nil
                return
            }
        }
        
        // Select new piece if possible
        if player.occupiesSquare(at: location) {
            selectedIndex = index
        }
        
        // If there is a selected piece, see if it can move to the new location
        if let selectedIndex = selectedIndex {
            
            do {
                try player.movePiece(from: BoardLocation(index: selectedIndex),
                                     to: location)
                
            } catch Player.MoveError.pieceUnableToMoveToLocation {
                print("Piece is unable to move to this location")
                
            } catch Player.MoveError.cannotMoveInToCheck {
                print("Player cannot move in to check")
                showAlert(title: "😜", message: "Player cannot move in to check")
                
            } catch Player.MoveError.playerMustMoveOutOfCheck {
                print("Player must move out of check")
                showAlert(title: "🙃", message: "Player must move out of check")
                
            } catch {
                print("Something went wrong!")
                return
            }
            
        }
        
    }
    
}

// MARK: - GameDelegate

extension GameViewController: GameDelegate {
    
    public func gameWillBeginUpdates(game: Game) {
        // Do nothing
    }
    
    func gameDidAddPiece(game: Game) {
        // Do nothing
    }

    func gameDidMovePiece(game: Game, piece: Piece, toLocation: BoardLocation) {
        
        guard let pieceView = pieceViewWithTag(piece.tag) else {
            return
        }
        
        pieceView.location = toLocation
        
        // Animate
        view.setNeedsLayout()
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
        
    }
    
    func gameDidRemovePiece(game: Game, piece: Piece, location: BoardLocation) {
        
        guard let pieceView = pieceViewWithTag(piece.tag) else {
            return
        }
        
        // Fade out and remove
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            pieceView.alpha = 0
        }, completion: { (finished: Bool) in
            self.removePieceView(withTag: piece.tag)
        })
        
    }
    
    func gameDidTransformPiece(game: Game, piece: Piece, location: BoardLocation) {
        
        guard let pieceView = pieceViewWithTag(piece.tag) else {
            return
        }
        
        pieceView.piece = piece
    }
    
    func gameDidEndUpdates(game: Game) {
        activityIndicator.stopAnimating()
    }
    
    func gameWonByPlayer(game: Game, player: Player) {
        
        let colorName = player.color.string
        
        let title = "Checkmate!"
        let message = "\(colorName.capitalized) wins!"
        
        showAlert(title: title, message: message)
    }
    
    func gameEndedInStaleMate(game: Game) {
        showAlert(title: "Stalemate", message: "Player cannot move")
    }
    
    func gameDidChangeCurrentPlayer(game: Game) {
        
        // Deselect selected piece
        self.selectedIndex = nil
        
        // Tell AI to take go
        if game.currentPlayer is AIPlayer {
            perform(#selector(tellAIToTakeGo), with: nil, afterDelay: 1)
        }
        
        // Update castle buttons visibility
        updateCastleButtonsVisibility()
    }
    
    @objc func tellAIToTakeGo() {
        
        if let player =  game.currentPlayer as? AIPlayer {
            activityIndicator.startAnimating()
            player.makeMoveAsync()
        }
    }
    
    func promotedTypeForPawn(location: BoardLocation,
                             player: Human,
                             possiblePromotions: [Piece.PieceType],
                             callback: @escaping (Piece.PieceType) -> Void) {
        
        boardView.isUserInteractionEnabled = false
        
        let viewController =
            PromotionSelectionViewController.promotionSelectionViewController(pawnLocation: location,
                                                                              possibleTypes: possiblePromotions) {
            
            self.promotionSelectionViewController?.view.removeFromSuperview()
            self.promotionSelectionViewController?.removeFromParent()
            self.boardView.isUserInteractionEnabled = true
            callback($0)
        }
        
        view.addSubview(viewController.view)
        addChild(viewController)
        promotionSelectionViewController = viewController
    }

}
