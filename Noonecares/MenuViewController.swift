//
//  MenuViewController.swift
//  Noonecares
//
//  Created by Lesterrry on 17.07.2021.
//

import Cocoa

class MenuViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    //*********************************************************************
    // OUTLETS & ACTIONS
    //*********************************************************************
    
    @IBOutlet weak var connectionStatusImageView: NSImageView!
    @IBOutlet weak var connectionStatusLabel: NSTextField!
    @IBOutlet weak var applianceStatusLabel: NSTextField!
    @IBOutlet weak var textModeButton: NSButton!
    @IBAction func textModeButtonPressed(_ sender: Any) {  }
    @IBOutlet weak var textModeTextField: NSTextField!
    @IBOutlet weak var textModeColorModePopUpButton: NSPopUpButton!
    @IBOutlet weak var textModeColorWell: NSColorWell!
    @IBOutlet weak var textModeAnimationSegmentedControl: NSSegmentedControl!
    @IBOutlet weak var textModeAnimationFadeButton: NSButton!
    @IBOutlet weak var textModeAnimationDelaySlider: NSSlider!
    @IBAction func textModeAnimationDelaySliderValueChanged(_ sender: Any) {  }
    @IBOutlet weak var textModeAnimationDelayLabel: NSTextField!
    @IBOutlet weak var textModeCycleSwitch: NSSwitch!
    @IBOutlet weak var textModeCycleStepsLabel: NSTextField!
    @IBOutlet weak var textModeCycleStepsStepper: NSStepper!
    @IBAction func textModeCycleStepsStepperValueChanged(_ sender: Any) {  }
    @IBAction func textModeCycleStepAddButtonPressed(_ sender: Any) {  }
    @IBAction func textModeCycleStepRemoveButtonPressed(_ sender: Any) {  }
    @IBAction func textModeCycleStepsClearButtonPressed(_ sender: Any) {  }
    @IBOutlet weak var textModeCycleDelayTextField: NSTextField!
    @IBAction func textModeCycleDelayTextFieldValueChanged(_ sender: NSTextField) {  }
    @IBOutlet weak var textModeCycleDelayStepper: NSStepper!
    @IBAction func textModeCycleDelayStepperValueChanged(_ sender: Any) {  }
    @IBOutlet weak var keyTraceModeButton: NSButton!
    @IBAction func keyTraceModeButtonPressed(_ sender: Any) {  }
    @IBOutlet weak var keyTraceModeColorModePopUpButton: NSPopUpButton!
    @IBOutlet weak var keyTraceModeColorWell: NSColorWell!
    @IBOutlet weak var CCPSModeButton: NSButton!
    @IBAction func CCPSModeButtonPressed(_ sender: Any) {  }
    @IBOutlet weak var CCPSModeSavedFileComboBox: NSComboBox!
    @IBAction func CCPSModeSavedFileComboBoxValueChanged(_ sender: Any) {  }
    @IBAction func CCPSModeControlPanelButtonPressed(_ sender: Any) {
        let myWindowController = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "MatrixWindowController") as! NSWindowController
        myWindowController.showWindow(self)
    }
    @IBOutlet weak var timerModeButton: NSButton!
    @IBAction func timerModeButtonPressed(_ sender: Any) {  }
    @IBOutlet weak var timerModeTextField: NSTextField!
    @IBAction func timerModeTextFieldValueChanged(_ sender: NSTextField) {  }
    @IBOutlet weak var timerModeStepper: NSStepper!
    @IBAction func timerModeStepperValueChanged(_ sender: Any) {  }
    @IBOutlet weak var timerModeSlider: NSSlider!
    @IBAction func timerModeSliderValueChanged(_ sender: Any) {  }
    @IBOutlet weak var timerModeProgressIndicator: NSProgressIndicator!
    @IBOutlet weak var pomodoroModeButton: NSButton!
    @IBAction func pomodoroModeButtonPressed(_ sender: Any) {  }
    @IBOutlet weak var pomodoroModeWorkTextField: NSTextField!
    @IBAction func pomodoroModeWorkTextFieldValueChanged(_ sender: Any) {  }
    @IBOutlet weak var pomodoroModeWorkStepper: NSStepper!
    @IBAction func pomodoroModeWorkStepperValueChanged(_ sender: Any) {  }
    @IBOutlet weak var pomodoroModeWorkProgressIndicator: NSProgressIndicator!
    @IBOutlet weak var pomodoroModeRestTextField: NSTextField!
    @IBAction func pomodoroModeRestTextFieldValueChanged(_ sender: Any) {  }
    @IBOutlet weak var pomodoroModeRestStepper: NSStepper!
    @IBAction func pomodoroModeRestStepperValueChanged(_ sender: Any) {  }
    @IBOutlet weak var pomodoroModeRestProgressIndicator: NSProgressIndicator!
    @IBOutlet weak var clockModeButton: NSButton!
    @IBAction func clockModeButtonPressed(_ sender: Any) {  }
    @IBOutlet weak var nowPlayingModeButton: NSButton!
    @IBAction func nowPlayingModeButtonPressed(_ sender: Any) {  }
    @IBOutlet weak var offModeButton: NSButton!
    @IBAction func offModeButtonPressed(_ sender: Any) {  }
    @IBAction func quitButtonPressed(_ sender: Any) { exit(0) }
    @IBOutlet weak var customCommandButton: NSButton!
    @IBAction func customCommandButtonPressed(_ sender: Any) {  }
    @IBOutlet weak var applyButton: NSButton!  // TODO: Disable button by default
    @IBAction func applyButtonPressed(_ sender: Any) {  }
}

extension MenuViewController {
  static func freshController() -> MenuViewController {
    let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
    let identifier = NSStoryboard.SceneIdentifier("MenuViewController")
    guard let viewController = storyboard.instantiateController(withIdentifier: identifier) as? MenuViewController else {
      fatalError("No controller found")
    }
    return viewController
  }
}
