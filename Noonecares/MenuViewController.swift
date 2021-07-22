//
//  MenuViewController.swift
//  Noonecares
//
//  Created by Lesterrry on 17.07.2021.
//

import Cocoa
import ORSSerial

class MenuViewController: NSViewController {
    
    //*********************************************************************
    // MARK: OUTLETS & ACTIONS
    //*********************************************************************
    @IBOutlet weak var connectionStatusImageView: NSImageView!
    @IBOutlet weak var connectionStatusLabel: NSTextField!
    @IBOutlet weak var connectionStatusRefreshButton: NSButton!
    @IBAction func connectionStatusRefreshButtonClicked(_ sender: Any) {
        establishConnection()
    }
    @IBOutlet weak var applianceStatusLabel: NSTextField!
    
    @IBOutlet weak var textModeButton: NSButton!
    @IBAction func textModeButtonPressed(_ sender: Any) {
        setApplianceLabel(.notApplied)
        setMode(to: .text)
    }
    @IBOutlet weak var textModeTextField: NSTextField!
    @IBAction func textModeTextFieldValueChanged(_ sender: Any) {
        setApplianceLabel(.notApplied)
    }
    @IBOutlet weak var textModeColorModePopUpButton: NSPopUpButton!
    @IBAction func textModeColorModePopUpButtonValueChanged(_ sender: Any) {
        suitTextCellColorWellEnabledState()
        setApplianceLabel(.notApplied)
    }
    @IBOutlet weak var textModeColorWell: NSColorWell!
    @IBAction func textModeColorWellValueChanged(_ sender: Any) {
        setApplianceLabel(.notApplied)
    }
    @IBOutlet weak var textModeAnimationSegmentedControl: NSSegmentedControl!
    @IBAction func textModeAnimationSegmentedControlValueChanged(_ sender: Any) {
        suitTextCellAnimationDelaySliderEnabledState()
        setApplianceLabel(.notApplied)
    }
    @IBOutlet weak var textModeAnimationFadeButton: NSButton!
    @IBAction func textModeAnimationFadeButtonPressed(_ sender: Any) {
        setApplianceLabel(.notApplied)
    }
    @IBOutlet weak var textModeAnimationDelaySlider: NSSlider!
    @IBAction func textModeAnimationDelaySliderValueChanged(_ sender: Any) {
        setApplianceLabel(.notApplied)
        textModeAnimationDelayLabel.stringValue = textModeAnimationDelaySlider.stringValue
        setApplianceLabel(.notApplied)
    }
    @IBOutlet weak var textModeAnimationDelayLabel: NSTextField!
    @IBOutlet weak var textModeCycleSwitch: NSSwitch!
    @IBAction func textModeCycleSwitchSwitched(_ sender: Any) {
        suitTextCellCycleElementsEnabledState()
    }
    @IBOutlet weak var textModeCycleStepsLabel: NSTextField!
    @IBOutlet weak var textModeCycleStepsStepper: NSStepper!
    @IBAction func textModeCycleStepsStepperValueChanged(_ sender: Any) {
        setApplianceLabel(.notApplied)
    }
    @IBOutlet weak var textModeCycleStepAddButton: NSButton!
    @IBAction func textModeCycleStepAddButtonPressed(_ sender: Any) {
        setApplianceLabel(.notApplied)
    }
    @IBOutlet weak var textModeCycleStepRemoveButton: NSButton!
    @IBAction func textModeCycleStepRemoveButtonPressed(_ sender: Any) {
        setApplianceLabel(.notApplied)
    }
    @IBOutlet weak var textModeCycleStepClearButton: NSButton!
    @IBAction func textModeCycleStepsClearButtonPressed(_ sender: Any) {
        setApplianceLabel(.notApplied)
    }
    @IBOutlet weak var textModeCycleDelayTextField: NSTextField!
    @IBAction func textModeCycleDelayTextFieldValueChanged(_ sender: NSTextField) {
        setApplianceLabel(.notApplied)
        textModeCycleDelayStepper.stringValue = textModeCycleDelayTextField.stringValue
    }
    @IBOutlet weak var textModeCycleDelayStepper: NSStepper!
    @IBAction func textModeCycleDelayStepperValueChanged(_ sender: Any) {
        setApplianceLabel(.notApplied)
        textModeCycleDelayTextField.stringValue = textModeCycleDelayStepper.stringValue
    }
    
    @IBOutlet weak var keyTraceModeButton: NSButton!
    @IBAction func keyTraceModeButtonPressed(_ sender: Any) {
        setApplianceLabel(.notApplied)
        setMode(to: .keyTrace)
    }
    @IBOutlet weak var keyTraceModeColorModePopUpButton: NSPopUpButton!
    @IBAction func keyTraceModeColorModePopUpButtonPressed(_ sender: Any) {
        setApplianceLabel(.notApplied)
    }
    @IBOutlet weak var keyTraceModeColorWell: NSColorWell!
    @IBAction func keyTraceModeColorWellValueChanged(_ sender: Any) {
        setApplianceLabel(.notApplied)
    }
    
    @IBOutlet weak var CCPSModeButton: NSButton!
    @IBAction func CCPSModeButtonPressed(_ sender: Any) {
        setApplianceLabel(.notApplied)
        setMode(to: .CCPS)
    }
    @IBOutlet weak var CCPSModeSavedFileComboBox: NSComboBox!
    @IBAction func CCPSModeSavedFileComboBoxValueChanged(_ sender: Any) {
        setApplianceLabel(.notApplied)
    }
    @IBAction func CCPSModeControlPanelButtonPressed(_ sender: Any) {
        setMode(to: .CCPS, forceModeButton: true)
        let controller = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "MatrixWindowController") as! NSWindowController
        controller.showWindow(self)
    }
    
    @IBOutlet weak var timerModeButton: NSButton!
    @IBAction func timerModeButtonPressed(_ sender: Any) {
        setApplianceLabel(.notApplied)
        setMode(to: .timer)
    }
    @IBOutlet weak var timerModeTextField: NSTextField!
    @IBAction func timerModeTextFieldValueChanged(_ sender: NSTextField) {
        setApplianceLabel(.notApplied)
        timerModeStepper.stringValue = timerModeTextField.stringValue
        timerModeSlider.stringValue = timerModeTextField.stringValue
    }
    @IBOutlet weak var timerModeStepper: NSStepper!
    @IBAction func timerModeStepperValueChanged(_ sender: Any) {
        setApplianceLabel(.notApplied)
        timerModeTextField.stringValue = timerModeStepper.stringValue
        timerModeSlider.stringValue = timerModeStepper.stringValue
    }
    @IBOutlet weak var timerModeSlider: NSSlider!
    @IBAction func timerModeSliderValueChanged(_ sender: Any) {
        setApplianceLabel(.notApplied)
        timerModeTextField.stringValue = timerModeSlider.stringValue
        timerModeStepper.stringValue = timerModeSlider.stringValue
    }
    @IBOutlet weak var timerModeProgressIndicator: NSProgressIndicator!
    
    @IBOutlet weak var pomodoroModeButton: NSButton!
    @IBAction func pomodoroModeButtonPressed(_ sender: Any) {
        setApplianceLabel(.notApplied)
        setMode(to: .pomodoro)
    }
    @IBOutlet weak var pomodoroModeWorkTextField: NSTextField!
    @IBAction func pomodoroModeWorkTextFieldValueChanged(_ sender: Any) {
        setApplianceLabel(.notApplied)
        pomodoroModeWorkStepper.stringValue = pomodoroModeWorkTextField.stringValue
    }
    @IBOutlet weak var pomodoroModeWorkStepper: NSStepper!
    @IBAction func pomodoroModeWorkStepperValueChanged(_ sender: Any) {
        setApplianceLabel(.notApplied)
        pomodoroModeWorkTextField.stringValue = pomodoroModeWorkStepper.stringValue
    }
    @IBOutlet weak var pomodoroModeWorkProgressIndicator: NSProgressIndicator!
    @IBOutlet weak var pomodoroModeRestTextField: NSTextField!
    @IBAction func pomodoroModeRestTextFieldValueChanged(_ sender: Any) {
        setApplianceLabel(.notApplied)
        pomodoroModeRestStepper.stringValue = pomodoroModeRestTextField.stringValue
    }
    @IBOutlet weak var pomodoroModeRestStepper: NSStepper!
    @IBAction func pomodoroModeRestStepperValueChanged(_ sender: Any) {
        setApplianceLabel(.notApplied)
        pomodoroModeRestTextField.stringValue = pomodoroModeRestStepper.stringValue
    }
    @IBOutlet weak var pomodoroModeRestProgressIndicator: NSProgressIndicator!
    
    @IBOutlet weak var clockModeButton: NSButton!
    @IBAction func clockModeButtonPressed(_ sender: Any) {
        setApplianceLabel(.notApplied)
        setMode(to: .clock)
    }
    
    @IBOutlet weak var nowPlayingModeButton: NSButton!
    @IBAction func nowPlayingModeButtonPressed(_ sender: Any) {
        setApplianceLabel(.notApplied)
        setMode(to: .nowPlaying)
    }
    
    @IBOutlet weak var offModeButton: NSButton!
    @IBAction func offModeButtonPressed(_ sender: Any) {
        setApplianceLabel(.notApplied)
        setMode(to: .off)
    }
    
    @IBAction func quitButtonPressed(_ sender: Any) {
        exit(0)
    }
    @IBOutlet weak var customCommandButton: NSButton!
    @IBAction func setupButtonPressed(_ sender: Any) {
        let controller = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "SetupWindowController") as! NSWindowController
        controller.showWindow(self)
    }
    @IBOutlet weak var applyButton: NSButton!
    @IBAction func applyButtonPressed(_ sender: Any) {
        composeAndExecuteCommand()
    }
    
    //*********************************************************************
    // MARK: VARS & CONSTS
    //*********************************************************************
    var systemMode = SystemProperties.Mode.off
    public static var connectionState = SystemProperties.ConnectionState.disconnected
    var modeApplied = true
    private static var serialPort: ORSSerialPort!
    
    //*********************************************************************
    // MARK: MAIN FUNCTIONS
    //*********************************************************************
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear() {
        NSApplication.shared.activate(ignoringOtherApps: true)
        establishConnection()
    }
    
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    /// Connect to the device and set the state
    func establishConnection() {
        guard let s = ORSSerialPort(path: NSUserDefaultsController.shared.defaults.string(forKey: "port") ?? "") else {
            setConnectionState(to: .disconnected)
            return
        }
        MenuViewController.serialPort = s
        MenuViewController.serialPort.baudRate = 115200
        setConnectionState(to: .connected)
        MenuViewController.serialPort.open()
    }
    
    /// Create and send a command to the matix
    func composeAndExecuteCommand() {
        let command: String!
        switch systemMode {
        case .text:
            guard textModeTextField.stringValue != "" else { setApplianceLabel(.corruptedParameters); return }
            let animationComponent: String!
            switch textModeAnimationSegmentedControl.indexOfSelectedItem {
            case 1:
                animationComponent = "<a%BLI%<e\(textModeAnimationDelaySlider.stringValue)"
            case 2:
                animationComponent = "<a%SCR%<e\(textModeAnimationDelaySlider.stringValue)"
            default:
                animationComponent = ""
            }
            let colorComponent: String!
            switch textModeColorModePopUpButton.indexOfSelectedItem {
            case 1:
                colorComponent = "%RND%"
            case 2:
                colorComponent = "%CHRND%"
            case 3:
                colorComponent = "%TLL%"
            default:
                colorComponent = colorString(from: textModeColorWell.color)
            }
            let fadeComponent = textModeAnimationFadeButton.state == .on ? "<i" : ""
            command = "RTX<t\(textModeTextField.stringValue)<c\(colorComponent + fadeComponent + animationComponent)/"
        case .off:
            command = "CLR/"
        default:
            setApplianceLabel("Unknown mode", NSColor.red)
            return
        }
        SystemMethods.log("Sending \(command!)...")
        MenuViewController.sendCommand(command)
        setApplianceLabel(.applied)
    }
    
    /// Send a command to the device via serial port
    /// - Parameter command: Command to send to the device
    public static func sendCommand(_ command: String) {
        guard let d = command.data(using: .utf8) else {
            SystemMethods.log("No data to send")
            return
        }
        MenuViewController.serialPort.send(d)
    }
    
    /// Set system mode
    /// - Parameters:
    ///   - to: Mode to switch to
    ///   - forceModeButton: Whether to explicitly order the corresponding mode button to set its state to 'on'
    func setMode(to: SystemProperties.Mode, forceModeButton: Bool = false) {
        systemMode = to
        setModeButtonsState(to: .off, except: to.rawValue, force: forceModeButton)
        setCellsEnabledState(to: false, except: to.rawValue, revert: true)
    }
    
    /// Set serial connection state
    /// - Parameter to: current connection state
    func setConnectionState(to: SystemProperties.ConnectionState) {
        MenuViewController.connectionState = to
        switch to {
        case .connected:
            connectionStatusLabel.stringValue = "Connected"
            connectionStatusLabel.textColor = NSColor.systemGreen
            connectionStatusImageView.image = NSImage(named: "NSStatusAvailable")
            applyButton.isEnabled = true
            connectionStatusRefreshButton.isHidden = true
        case .disconnected:
            connectionStatusLabel.stringValue = "Disconnected"
            connectionStatusLabel.textColor = NSColor.systemGray
            connectionStatusImageView.image = NSImage(named: "NSStatusNone")
            applyButton.isEnabled = false
            connectionStatusRefreshButton.isHidden = false
        }
    }
    
    /// Set appliance label to default state
    /// - Parameter isApplied: Whether to set the label to Applied state
    func setApplianceLabel(_ to: SystemProperties.ApplianceState) {
        switch to {
        case .applied:
            applianceStatusLabel.stringValue = ""
            applianceStatusLabel.textColor = NSColor.white
        case .notApplied:
            applianceStatusLabel.stringValue = "Not Applied"
            applianceStatusLabel.textColor = NSColor.white
        case .corruptedParameters:
            applianceStatusLabel.stringValue = "Check options"
            applianceStatusLabel.textColor = NSColor.systemRed
        }
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
                textModeColorWell,
                textModeAnimationSegmentedControl,
                textModeAnimationFadeButton,
                textModeCycleSwitch,
                textModeAnimationDelaySlider,
                textModeColorModePopUpButton,
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
                            suitTextCellColorWellEnabledState()
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
    
    /// Set Color Well to a corresponding state
    private func suitTextCellColorWellEnabledState() {
        textModeColorWell.isEnabled = textModeColorModePopUpButton.indexOfSelectedItem == 0
    }
    
    /// Get command-formatted string representing specific color
    /// - Parameter from: Color for string to represent
    /// - Returns: Command-formatted string
    private func colorString(from: NSColor) -> String {
        return "\(Int(from.redComponent * 255)),\(Int(from.greenComponent * 255)),\(Int(from.blueComponent * 255))"
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
