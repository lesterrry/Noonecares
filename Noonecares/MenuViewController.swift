//
//  MenuViewController.swift
//  Noonecares
//
//  Created by Lesterrry on 17.07.2021.
//

import Cocoa

class MenuViewController: NSViewController {
    
    //*********************************************************************
    // OUTLETS & ACTIONS
    //*********************************************************************
    @IBOutlet weak var connectionStatusImageView: NSImageView!
    @IBOutlet weak var connectionStatusLabel: NSTextField!
    @IBOutlet weak var applianceStatusLabel: NSTextField!
    
    @IBOutlet weak var textModeButton: NSButton!
    @IBAction func textModeButtonPressed(_ sender: Any) {
        setApplianceLabel(isApplied: false)
        switchMode(to: .text)
    }
    @IBOutlet weak var textModeTextField: NSTextField!
    @IBAction func textModeTextFieldValueChanged(_ sender: Any) {
        setApplianceLabel(isApplied: false)
    }
    @IBOutlet weak var textModeColorModePopUpButton: NSPopUpButton!
    @IBAction func textModeColorModePopUpButtonValueChanged(_ sender: Any) {
        setApplianceLabel(isApplied: false)
    }
    @IBOutlet weak var textModeColorWell: NSColorWell!
    @IBAction func textModeColorWellValueChanged(_ sender: Any) {
        setApplianceLabel(isApplied: false)
    }
    @IBOutlet weak var textModeAnimationSegmentedControl: NSSegmentedControl!
    @IBAction func textModeAnimationSegmentedControlValueChanged(_ sender: Any) {
        suitTextCellAnimationDelaySliderEnabledState()
        setApplianceLabel(isApplied: false)
    }
    @IBOutlet weak var textModeAnimationFadeButton: NSButton!
    @IBAction func textModeAnimationFadeButtonPressed(_ sender: Any) {
        setApplianceLabel(isApplied: false)
    }
    @IBOutlet weak var textModeAnimationDelaySlider: NSSlider!
    @IBAction func textModeAnimationDelaySliderValueChanged(_ sender: Any) {
        setApplianceLabel(isApplied: false)
        textModeAnimationDelayLabel.stringValue = textModeAnimationDelaySlider.stringValue
        setApplianceLabel(isApplied: false)
    }
    @IBOutlet weak var textModeAnimationDelayLabel: NSTextField!
    @IBOutlet weak var textModeCycleSwitch: NSSwitch!
    @IBAction func textModeCycleSwitchSwitched(_ sender: Any) {
        suitTextCellCycleElementsEnabledState()
    }
    @IBOutlet weak var textModeCycleStepsLabel: NSTextField!
    @IBOutlet weak var textModeCycleStepsStepper: NSStepper!
    @IBAction func textModeCycleStepsStepperValueChanged(_ sender: Any) {
        setApplianceLabel(isApplied: false)
    }
    @IBOutlet weak var textModeCycleStepAddButton: NSButton!
    @IBAction func textModeCycleStepAddButtonPressed(_ sender: Any) {
        setApplianceLabel(isApplied: false)
    }
    @IBOutlet weak var textModeCycleStepRemoveButton: NSButton!
    @IBAction func textModeCycleStepRemoveButtonPressed(_ sender: Any) {
        setApplianceLabel(isApplied: false)
    }
    @IBOutlet weak var textModeCycleStepClearButton: NSButton!
    @IBAction func textModeCycleStepsClearButtonPressed(_ sender: Any) {
        setApplianceLabel(isApplied: false)
    }
    @IBOutlet weak var textModeCycleDelayTextField: NSTextField!
    @IBAction func textModeCycleDelayTextFieldValueChanged(_ sender: NSTextField) {
        setApplianceLabel(isApplied: false)
        textModeCycleDelayStepper.stringValue = textModeCycleDelayTextField.stringValue
    }
    @IBOutlet weak var textModeCycleDelayStepper: NSStepper!
    @IBAction func textModeCycleDelayStepperValueChanged(_ sender: Any) {
        setApplianceLabel(isApplied: false)
        textModeCycleDelayTextField.stringValue = textModeCycleDelayStepper.stringValue
    }
    
    @IBOutlet weak var keyTraceModeButton: NSButton!
    @IBAction func keyTraceModeButtonPressed(_ sender: Any) {
        setApplianceLabel(isApplied: false)
        switchMode(to: .keyTrace)
    }
    @IBOutlet weak var keyTraceModeColorModePopUpButton: NSPopUpButton!
    @IBAction func keyTraceModeColorModePopUpButtonPressed(_ sender: Any) {
        setApplianceLabel(isApplied: false)
    }
    @IBOutlet weak var keyTraceModeColorWell: NSColorWell!
    @IBAction func keyTraceModeColorWellValueChanged(_ sender: Any) {
        setApplianceLabel(isApplied: false)
    }
    
    
    @IBOutlet weak var CCPSModeButton: NSButton!
    @IBAction func CCPSModeButtonPressed(_ sender: Any) {
        setApplianceLabel(isApplied: false)
        switchMode(to: .CCPS)
    }
    @IBOutlet weak var CCPSModeSavedFileComboBox: NSComboBox!
    @IBAction func CCPSModeSavedFileComboBoxValueChanged(_ sender: Any) {
        setApplianceLabel(isApplied: false)
    }
    @IBAction func CCPSModeControlPanelButtonPressed(_ sender: Any) {
        switchMode(to: .CCPS, forceModeButton: true)
        let controller = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "MatrixWindowController") as! NSWindowController
        controller.showWindow(self)
    }
    
    @IBOutlet weak var timerModeButton: NSButton!
    @IBAction func timerModeButtonPressed(_ sender: Any) {
        setApplianceLabel(isApplied: false)
        switchMode(to: .timer)
    }
    @IBOutlet weak var timerModeTextField: NSTextField!
    @IBAction func timerModeTextFieldValueChanged(_ sender: NSTextField) {
        setApplianceLabel(isApplied: false)
        timerModeStepper.stringValue = timerModeTextField.stringValue
        timerModeSlider.stringValue = timerModeTextField.stringValue
    }
    @IBOutlet weak var timerModeStepper: NSStepper!
    @IBAction func timerModeStepperValueChanged(_ sender: Any) {
        setApplianceLabel(isApplied: false)
        timerModeTextField.stringValue = timerModeStepper.stringValue
        timerModeSlider.stringValue = timerModeStepper.stringValue
    }
    @IBOutlet weak var timerModeSlider: NSSlider!
    @IBAction func timerModeSliderValueChanged(_ sender: Any) {
        setApplianceLabel(isApplied: false)
        timerModeTextField.stringValue = timerModeSlider.stringValue
        timerModeStepper.stringValue = timerModeSlider.stringValue
    }
    @IBOutlet weak var timerModeProgressIndicator: NSProgressIndicator!
    
    @IBOutlet weak var pomodoroModeButton: NSButton!
    @IBAction func pomodoroModeButtonPressed(_ sender: Any) {
        setApplianceLabel(isApplied: false)
        switchMode(to: .pomodoro)
    }
    @IBOutlet weak var pomodoroModeWorkTextField: NSTextField!
    @IBAction func pomodoroModeWorkTextFieldValueChanged(_ sender: Any) {
        setApplianceLabel(isApplied: false)
        pomodoroModeWorkStepper.stringValue = pomodoroModeWorkTextField.stringValue
    }
    @IBOutlet weak var pomodoroModeWorkStepper: NSStepper!
    @IBAction func pomodoroModeWorkStepperValueChanged(_ sender: Any) {
        setApplianceLabel(isApplied: false)
        pomodoroModeWorkTextField.stringValue = pomodoroModeWorkStepper.stringValue
    }
    @IBOutlet weak var pomodoroModeWorkProgressIndicator: NSProgressIndicator!
    @IBOutlet weak var pomodoroModeRestTextField: NSTextField!
    @IBAction func pomodoroModeRestTextFieldValueChanged(_ sender: Any) {
        setApplianceLabel(isApplied: false)
        pomodoroModeRestStepper.stringValue = pomodoroModeRestTextField.stringValue
    }
    @IBOutlet weak var pomodoroModeRestStepper: NSStepper!
    @IBAction func pomodoroModeRestStepperValueChanged(_ sender: Any) {
        setApplianceLabel(isApplied: false)
        pomodoroModeRestTextField.stringValue = pomodoroModeRestStepper.stringValue
    }
    @IBOutlet weak var pomodoroModeRestProgressIndicator: NSProgressIndicator!
    
    @IBOutlet weak var clockModeButton: NSButton!
    @IBAction func clockModeButtonPressed(_ sender: Any) {
        setApplianceLabel(isApplied: false)
        switchMode(to: .clock)
    }
    
    @IBOutlet weak var nowPlayingModeButton: NSButton!
    @IBAction func nowPlayingModeButtonPressed(_ sender: Any) {
        setApplianceLabel(isApplied: false)
        switchMode(to: .nowPlaying)
    }
    
    @IBOutlet weak var offModeButton: NSButton!
    @IBAction func offModeButtonPressed(_ sender: Any) {
        setApplianceLabel(isApplied: false)
        switchMode(to: .off)
    }
    
    @IBAction func quitButtonPressed(_ sender: Any) {
        exit(0)
    }
    @IBOutlet weak var customCommandButton: NSButton!
    @IBAction func customCommandButtonPressed(_ sender: Any) {
        
    }
    @IBOutlet weak var applyButton: NSButton!  // TODO: Disable button by default
    @IBAction func applyButtonPressed(_ sender: Any) {
        composeAndExecuteCommand()
    }
    
    //*********************************************************************
    // VARS & CONSTS
    //*********************************************************************
    var systemMode = SystemProperties.Mode.off
    var serialConnected = false
    var modeApplied = true
    
    //*********************************************************************
    // MAIN FUNCTIONS
    //*********************************************************************
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear() {
        NSApplication.shared.activate(ignoringOtherApps: true)
    }
    
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    /// Create and send a command to the matix
    func composeAndExecuteCommand() {
        switch systemMode {
        case .text:
            ()
        default:
            setApplianceLabel(isApplied: true)
            //setApplianceLabel("Unknown mode", NSColor.red)
        }
    }
    
    /// Switch system mode
    /// - Parameters:
    ///   - to: Mode to switch to
    ///   - forceModeButton: Whether to explicitly order the corresponding mode button to set its state to 'on'
    func switchMode(to: SystemProperties.Mode, forceModeButton: Bool = false) {
        systemMode = to
        setModeButtonsState(to: .off, except: to.rawValue, force: forceModeButton)
        setCellsEnabledState(to: false, except: to.rawValue, revert: true)
    }
    
    /// Set appliance label to default state
    /// - Parameter isApplied: Whether to set the label to Applied state
    func setApplianceLabel(isApplied: Bool) {
        applianceStatusLabel.stringValue = isApplied ? "" : "Not Applied"
        applianceStatusLabel.textColor = NSColor.white
    }
    
    /// Set appliance label to a specific string value and color
    /// - Parameters:
    ///   - to: String value to set the label to
    ///   - color: Color to paint the label in
    func setApplianceLabel(_ to: String, _ color: NSColor) {
        applianceStatusLabel.stringValue = to
        applianceStatusLabel.textColor = color
    }
    
    /// Set all mode buttons to a specific state
    /// - Parameters:
    ///   - to: State to set buttons to
    ///   - except: Index of the button to skip
    ///   - force: Explicitly set skipped button to the opposite state
    private func setModeButtonsState(to: NSControl.StateValue, except: Int? = nil, force: Bool = false) {
        let allModeButtons = [
            textModeButton,
            keyTraceModeButton,
            CCPSModeButton,
            timerModeButton,
            pomodoroModeButton,
            clockModeButton,
            nowPlayingModeButton,
            offModeButton
        ]
        for i in 0...allModeButtons.count - 1 {
            if let a = except, i == a { if force { allModeButtons[i]?.state = (to == .on ? .off : .on) }; continue }
            allModeButtons[i]?.state = to
        }
    }
    
    /// Set all mode cells to a specific enabled/disabled state
    /// - Parameters:
    ///   - to: Whether to enable the cells
    ///   - except: Index of the cell to skip
    ///   - revert: Explicitly set skipped cell to the opposite state
    private func setCellsEnabledState(to: Bool, except: Int? = nil, revert: Bool = false) {
        let allCells = [
            [
                textModeTextField,
                textModeColorModePopUpButton,
                textModeColorWell,
                textModeAnimationSegmentedControl,
                textModeAnimationFadeButton,
                textModeCycleSwitch,
                textModeAnimationDelaySlider,
                textModeCycleStepsStepper,
                textModeCycleStepAddButton,
                textModeCycleStepRemoveButton,
                textModeCycleStepClearButton,
                textModeCycleDelayTextField,
                textModeCycleDelayStepper
            ],
            [
                keyTraceModeColorModePopUpButton,
                keyTraceModeColorWell
            ],
            [
                CCPSModeSavedFileComboBox
            ],
            [
                timerModeTextField,
                timerModeStepper,
                timerModeSlider
            ],
            [
                pomodoroModeWorkTextField,
                pomodoroModeWorkStepper,
                pomodoroModeRestTextField,
                pomodoroModeRestStepper,
            ]
        ]
        for i in 0...allCells.count - 1 {
            if let a = except, i == a {
                if revert {
                    for j in 0...allCells[i].count - 1 {
                        allCells[i][j]?.isEnabled = !to
                        if j == 6 {  // Animation Delay Slider and elements of the Cycle Cell must be set in a specific way
                            suitTextCellCycleElementsEnabledState()
                            suitTextCellAnimationDelaySliderEnabledState()
                            break
                        }
                    }
                }
                continue
            }
            for j in allCells[i] {
                j?.isEnabled = to
            }
        }
    }
    
    /// Set Cycle Cell elements to a corresponding state
    private func suitTextCellCycleElementsEnabledState() {
        let allElements = [
            textModeCycleStepsStepper,
            textModeCycleStepAddButton,
            textModeCycleStepRemoveButton,
            textModeCycleStepClearButton,
            textModeCycleDelayTextField,
            textModeCycleDelayStepper
        ]
        switch textModeCycleSwitch.state {
        case .off:
            for i in allElements {
                i?.isEnabled = false
            }
        case.on:
            for i in allElements {
                i?.isEnabled = true
            }
        default: ()
        }
    }
    
    /// Set Delay Slider to a corresponding state
    private func suitTextCellAnimationDelaySliderEnabledState() {
        textModeAnimationDelaySlider.isEnabled = textModeAnimationSegmentedControl.indexOfSelectedItem != 0
    }
    
}

extension MenuViewController {
    /// Receive a functional instance of the Menu View Controller
    /// - Returns: Functional instance of the Menu View Controller
    static func freshController() -> MenuViewController {
        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        let identifier = NSStoryboard.SceneIdentifier("MenuViewController")
        guard let viewController = storyboard.instantiateController(withIdentifier: identifier) as? MenuViewController else {
            fatalError("No controller found")
    }
        return viewController
    }
}
