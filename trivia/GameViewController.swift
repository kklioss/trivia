//
//  GameViewController.swift
//  trivia
//
//  Copyright (c) 2021 Karl Li. All rights reserved.
//

import UIKit
import Foundation
import AVFoundation

class GameViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    // UI controls
    @IBOutlet weak var scoreLabel:UILabel?
    @IBOutlet weak var timeLabel:UILabel?
    @IBOutlet weak var questionLabel:UILabel?
    @IBOutlet weak var multiChoicePicker:UIPickerView?
    @IBOutlet weak var button:UIButton?

    // Background music player
    var audioPlayer: AVAudioPlayer?
    
    // Question list
    let questions = [
        "Who is Karl Li?",
        "How old is SHS?",
        "How many teeth does a man have?",
        "How many bones does a shark have?",
        "Where's Mardi Gras held in US?",
        "Where's Area 51?",
        "What is 'cynophobia'?",
        "Where was ice cream invented?",
        "How many hearts in an octopus?",
        "What was Walt Disney afraid of?"
    ]
    // Multichoices for each question
    let choices = [
        ["Violinist", "Historian", "Computer Nerd", "Hiker"],
        ["75", "100", "104", "158"],
        ["32", "20", "36", "34"],
        ["202", "88", "0", "270"],
        ["New Orleans", "Houston", "New York", "Boston"],
        ["Arizona", "Nevada", "California", "Texas"],
        ["Fear of tigers", "Cat lover", "Dog lover", "Fear of dogs"],
        ["France", "China", "England", "United States"],
        ["1", "2", "3", "8"],
        ["Dogs", "Cats", "Ducks", "Mice"]
    ]
    // Index of correct answers
    // -1 indicates that all choices are correct
    let answers = [-1, 2, 0, 2, 0, 1, 3, 1, 2, 3]
    
    // Text font and color for multiChoicePicker
    let textFont = UIFont(name: "HVD Comic Serif Pro", size: 24)
    let textColor = UIColor(red:135/255, green:79/255, blue:33/255, alpha:1)
    
    // Game states
    var gameOn = false
    // The index of current question
    var currentQuestion = 0
    var score = 0
    // The number of seconds for a game
    var seconds = 60
    // Count down timer
    var timer:Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // word wrapping
        questionLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        questionLabel?.numberOfLines = 0
        
        updateScoreLabel()
        updateTimeLabel()
        
        // The controller will provide data to picker
        multiChoicePicker?.delegate = self
        multiChoicePicker?.dataSource = self
        
        startBackgroundMusic()
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func updateScoreLabel() {
        scoreLabel?.text = String(score)
    }
    
    func updateQuestion() {
        questionLabel?.text = questions[currentQuestion]
        // refresh the multichoice picker
        multiChoicePicker?.reloadAllComponents()
    }
    
    func updateTimeLabel() {
        let min = (seconds / 60) % 60
        let sec = seconds % 60

        timeLabel?.text = String(format: "%02d", min) + ":" + String(format: "%02d", sec)
    }
    
    @IBAction func buttonTapped() {
        if gameOn {
            checkAnswer()
        } else {
            startGame()
        }
    }
    
    func startGame() {
        gameOn = true
        score = 0
        seconds = 60
        currentQuestion = 0

        updateScoreLabel()
        updateTimeLabel()
        updateQuestion()

        button?.setTitle("Submit", for: .normal)
        multiChoicePicker?.isHidden = false

        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if self.seconds > 0 {
                self.seconds -= 1
                self.updateTimeLabel()
            } else {
                self.finishGame(timeUp: true)
            }
        }
    }
    
    func finishGame(timeUp: Bool) {
        gameOn = false

        multiChoicePicker?.isHidden = true
        timer?.invalidate()
        timer = nil
        
        let title = timeUp ? "Time's Up!" : "Game Over!"
        var message = "You scored \(score) points and took \(60 - seconds) seconds."
        message += score > 500 ? " Awesome!" : " Try again!"
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "New Game", style: .default, handler: { action in
            self.startGame()
        }))

        self.present(alert, animated: true, completion: nil)
    }
    
    func checkAnswer() {
        let answer = answers[currentQuestion]
        if answer == -1 || answer == multiChoicePicker?.selectedRow(inComponent:0) {
            score += 100
        }
        
        // last question
        if currentQuestion == questions.count - 1 {
            // bonus points
            if score >= 700 {
                score += seconds * 10
            }
            updateScoreLabel()
            finishGame(timeUp: false)
        } else {
            currentQuestion += 1
            updateScoreLabel()
            updateQuestion()
        }
    }
    
    // Returns the number of columns in UIPickerView
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // Returns the number of rows in UIPickerView
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return choices[currentQuestion].count
    }
    
    // Returns the data for the row and component (column) in UIPickerView
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return choices[currentQuestion][row]
    }

    // Set cool font and size in UIPickerView
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var pickerLabel: UILabel? = (view as? UILabel)
        if pickerLabel == nil {
            pickerLabel = UILabel()
            pickerLabel?.font = textFont
            pickerLabel?.textColor = textColor
            pickerLabel?.textAlignment = .center
        }
        pickerLabel?.text = choices[currentQuestion][row]

        return pickerLabel!
    }
    
    func startBackgroundMusic() {
        if let bundle = Bundle.main.path(forResource: "Pokémon Gym", ofType: "mp3") {
            let backgroundMusic = NSURL(fileURLWithPath: bundle)
            do {
                audioPlayer = try AVAudioPlayer(contentsOf:backgroundMusic as URL)
                guard let audioPlayer = audioPlayer else { return }
                // infinite repeat
                audioPlayer.numberOfLoops = -1
                audioPlayer.prepareToPlay()
                audioPlayer.play()
            } catch {
                print(error)
            }
        }
    }
    
    func stopBackgroundMusic() {
        guard let audioPlayer = audioPlayer else { return }
        audioPlayer.stop()
    }
    
    // animate button with bouncing effect
    @IBAction func animateButton(sender: UIButton) {
        sender.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)

        UIView.animate(withDuration: 2.0,
                       delay: 0,
                       usingSpringWithDamping: CGFloat(0.20),
                       initialSpringVelocity: CGFloat(6.0),
                       options: UIView.AnimationOptions.allowUserInteraction,
                       animations: { sender.transform = CGAffineTransform.identity },
                       completion: { Void in()  }
        )
    }
}
