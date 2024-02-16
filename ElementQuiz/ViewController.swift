//
//  ViewController.swift
//  ElementQuiz
//
//  Created by Luis Rodriguez on 1/29/24.
//

import UIKit

// Enumeration to represent the different modes of the app
enum Mode {
    case flashCard
    case quiz
}

// Enumeration to represent the different states of the app
enum State {
    case question
    case answer
    case score
}

class ViewController: UIViewController, UITextFieldDelegate {

    // Outlets for UI elements
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var answerLabel: UILabel!
    @IBOutlet weak var modeSelector: UISegmentedControl!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var showAnswerButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    
    // App's current mode
    var mode: Mode = .flashCard {
        didSet {
            // Update UI based on the selected mode
            switch mode {
            case .flashCard:
                setupFlashCards()
            case .quiz:
                setupQuiz()
            }
            updateUI()
        }
    }
    
    // App's current state
    var state: State = .question
    
    // List of fixed elements
    let fixedElementList = ["Carbon", "Gold", "Chlorine", "Sodium"]
    
    // Dynamic element list for flash card or shuffled list for quiz
    var elementList: [String] = []
    
    // Index of the current element in the list
    var currentElementIndex = 0
    
    // Quiz-specific state
    var answerIsCorrect = false
    var correctAnswerCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        mode = .flashCard
    }
    
    // Updates the app's UI in flash card mode.
    func updateFlashCardUI(elementName: String) {
        // Segmented control
        modeSelector.selectedSegmentIndex = 0
        
        // Text field and keyboard
        textField.isHidden = true
        textField.resignFirstResponder()

        // Answer label
        if state == .answer {
            answerLabel.text = elementName
        } else {
            answerLabel.text = "?"
        }

        // Buttons
        showAnswerButton.isHidden = false
        nextButton.isEnabled = true
        nextButton.setTitle("Next Element", for: .normal)
    }
    
    // Updates the app's UI in quiz mode.
    func updateQuizUI(elementName: String) {
        // Segmented control
        modeSelector.selectedSegmentIndex = 1
        
        // Text field and keyboard
        textField.isHidden = false
        switch state {
        case .question:
            textField.text = ""
            textField.becomeFirstResponder()
        case .answer:
            textField.resignFirstResponder()
        case .score:
            textField.isHidden = true
            textField.resignFirstResponder()
        }

        // Answer label
        switch state {
        case .question:
            answerLabel.text = ""
        case .answer:
            if answerIsCorrect {
                answerLabel.text = "Correct!"
            } else {
                answerLabel.text = "❌\nCorrect Answer: " + elementName
            }
        case .score:
            answerLabel.text = ""
        }
        
        // Score display
        if state == .score {
            displayScoreAlert()
        }
        
        // Buttons
        showAnswerButton.isHidden = true
        if currentElementIndex == elementList.count - 1 {
            nextButton.setTitle("Show Score", for: .normal)
        } else {
            nextButton.setTitle("Next Question", for: .normal)
        }
        switch state {
        case .question:
            nextButton.isEnabled = false
        case .answer:
            nextButton.isEnabled = true
        case .score:
            nextButton.isEnabled = false
        }

    }
    
    // Updates the app's UI based on its mode and state.
    func updateUI() {
        // Shared code: updating the image
        let elementName = elementList[currentElementIndex]
        let image = UIImage(named: elementName)
        imageView.image = image
        
        // Mode-specific UI updates are split into two methods for readability.
        switch mode {
         case .flashCard:
            updateFlashCardUI(elementName: elementName)
         case .quiz:
            updateQuizUI(elementName: elementName)
        }
    }
    
    // Handles the action when the "Show Answer" button is tapped.
    @IBAction func showAnswer(_ sender: UIButton) {
        // Update the app's state to show the answer and refresh the UI
        state = .answer
        updateUI()
    }
    
    // Handles the action when the "Next" button is tapped.
    @IBAction func next(_ sender: UIButton) {
        // Increment the index to move to the next element
        currentElementIndex += 1
        
        // Check if the index exceeds the element list count
        if currentElementIndex >= elementList.count {
            // Reset index to the beginning if in quiz mode and update state to show score
            currentElementIndex = 0
            if mode == .quiz {
                state = .score
                updateUI()
                return
            }
        }
        
        // Update the state to show the next question and refresh the UI
        state = .question
        updateUI()
    }
    
    // Handles the action when the segmented control for mode selection is changed.
    @IBAction func switchModes(_ sender: Any) {
        // Check the selected segment index and update the app's mode accordingly
        if modeSelector.selectedSegmentIndex == 0 {
            mode = .flashCard
        } else {
            mode = .quiz
        }
    }
    
    // Runs after the user hits the Return key on the keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Get the text from the text field
        let textFieldContents = textField.text!

        // Determine whether the user answered correctly and update appropriate quiz
        // state
        if textFieldContents.lowercased() == elementList[currentElementIndex].lowercased() {
            answerIsCorrect = true
            correctAnswerCount += 1
        } else {
            answerIsCorrect = false
        }

        // The app should now display the answer to the user
        state = .answer

        updateUI()

        return true
    }
    
    // Shows an iOS alert with the user's quiz score.
    func displayScoreAlert() {
        let alert = UIAlertController(title: "Quiz Score", message: "Your score is \(correctAnswerCount) out of \(elementList.count).", preferredStyle: .alert)

        let dismissAction = UIAlertAction(title: "OK", style: .default, handler: scoreAlertDismissed(_:))
        alert.addAction(dismissAction)

        present(alert, animated: true, completion: nil)
    }

    func scoreAlertDismissed(_ action: UIAlertAction) {
        mode = .flashCard
    }
    
    // Sets up a new flash card session.
    func setupFlashCards() {
        state = .question
        currentElementIndex = 0
        elementList = fixedElementList
    }

    // Sets up a new quiz.
    func setupQuiz() {
        state = .question
        currentElementIndex = 0
        answerIsCorrect = false
        correctAnswerCount = 0
        elementList = fixedElementList.shuffled()

    }
}

