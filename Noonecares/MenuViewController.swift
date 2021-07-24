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
    // MARK: STRUCTURES
    //*********************************************************************
    /// Step to use in main routine cycle
    struct TextCycleStep {
        /// Text to send to the device
        let text: String
        /// Color to paint the text. Pass String to the first element if specific coloring is being used, or NSColor to the second
        let color: (String?, NSColor?)
        /// Animation value. First element is the animation keyword, second is the delay.
        let animation: (String, Int)?
        /// Whether to apply fade animation
        var fade: Bool = false
    }
    
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
        insertToTextCycleRoutine()
    }
    @IBOutlet weak var textModeTextField: NSTextField!
    @IBAction func textModeTextFieldValueChanged(_ sender: Any) {
        setApplianceLabel(.notApplied)
        insertToTextCycleRoutine()
    }
    @IBOutlet weak var textModeColorModePopUpButton: NSPopUpButton!
    @IBAction func textModeColorModePopUpButtonValueChanged(_ sender: Any) {
        suitTextCellColorWellEnabledState()
        setApplianceLabel(.notApplied)
        insertToTextCycleRoutine()
    }
    @IBOutlet weak var textModeColorWell: NSColorWell!
    @IBAction func textModeColorWellValueChanged(_ sender: Any) {
        setApplianceLabel(.notApplied)
        insertToTextCycleRoutine()
    }
    @IBOutlet weak var textModeAnimationSegmentedControl: NSSegmentedControl!
    @IBAction func textModeAnimationSegmentedControlValueChanged(_ sender: Any) {
        suitTextCellAnimationControlsEnabledState()
        setApplianceLabel(.notApplied)
        insertToTextCycleRoutine()
    }
    @IBOutlet weak var textModeAnimationFadeButton: NSButton!
    @IBAction func textModeAnimationFadeButtonPressed(_ sender: Any) {
        setApplianceLabel(.notApplied)
        insertToTextCycleRoutine()
    }
    @IBOutlet weak var textModeAnimationDelaySlider: NSSlider!
    @IBAction func textModeAnimationDelaySliderValueChanged(_ sender: Any) {
        setApplianceLabel(.notApplied)
        updateTextModeAnimationDelayLabel()
        insertToTextCycleRoutine()
    }
    @IBOutlet weak var textModeAnimationDelayLabel: NSTextField!
    @IBOutlet weak var textModeCycleSwitch: NSSwitch!
    @IBAction func textModeCycleSwitchSwitched(_ sender: Any) {
        suitTextCellCycleElementsEnabledState()
    }
    @IBOutlet weak var textModeCycleProgressIndicator: NSProgressIndicator!
    @IBOutlet weak var textModeCycleStepsLabel: NSTextField!
    @IBOutlet weak var textModeCycleStepsStepper: NSStepper!
    @IBAction func textModeCycleStepsStepperValueChanged(_ sender: Any) {
        setApplianceLabel(.notApplied)
        updateTextModeCycleStepsLabel()
        applyTextCycleRoutineElement()
    }
    @IBOutlet weak var textModeCycleStepAddButton: NSButton!
    @IBAction func textModeCycleStepAddButtonPressed(_ sender: Any) {
        setApplianceLabel(.notApplied)
        textModeCycleStepsStepper.maxValue += 1
        textModeCycleStepsStepper.integerValue += 1
        updateTextModeCycleStepsLabel()
        insertToTextCycleRoutine(inserting: true)
    }
    @IBOutlet weak var textModeCycleStepRemoveButton: NSButton!
    @IBAction func textModeCycleStepRemoveButtonPressed(_ sender: Any) {
        setApplianceLabel(.notApplied)
        currentRoutineIndex = 0
        textCycleRoutine.remove(at: textModeCycleStepsStepper.integerValue)
        textModeCycleStepsStepper.maxValue -= 1
        textModeCycleStepsStepper.integerValue -= 1
        updateTextModeCycleStepsLabel()
    }
    @IBOutlet weak var textModeCycleStepsClearButton: NSButton!
    @IBAction func textModeCycleStepsClearButtonPressed(_ sender: Any) {
        setApplianceLabel(.notApplied)
        currentRoutineIndex = 0
        textModeCycleStepsStepper.maxValue = 0
        textModeCycleStepsStepper.integerValue = 0
        updateTextModeCycleStepsLabel()
        insertToTextCycleRoutine(clearing: true)
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
        suitKeyTraceCellColorWellEnabledState()
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
    private static var serialPort: ORSSerialPort!
    public static var connectionState = SystemProperties.ConnectionState.disconnected
    public static var keylogger = Keylogger()
    public static var keyTraceColor: String?
    public static var systemCurrentMode = SystemProperties.Mode.off
    var systemTargetMode = SystemProperties.Mode.off
    var modeApplied = true
    var routineTimer: Timer?
    var textCycleRoutine: [TextCycleStep] = []
    var currentRoutineIndex = 0
    
    //*********************************************************************
    // MARK: MAIN FUNCTIONS
    //*********************************************************************
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear() {
        NSApplication.shared.activate(ignoringOtherApps: true)
        insertToTextCycleRoutine(inserting: true)
        if MenuViewController.connectionState != .connected { establishConnection() }
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
    
    /// Send key to the device
    /// - Parameter key: Key, received from keylogger
    public static func registerKeyloggerEvent(_ key: String) {
        guard let color = keyTraceColor, systemCurrentMode == .keyTrace else { return }
        MenuViewController.sendCommand("ACH<h\(key)<c\(color)/")
    }
    
    /// Do routine task
    @objc
    func performRoutine() {
        composeAndExecuteCommand(from: textCycleRoutine[currentRoutineIndex])
        if currentRoutineIndex < textCycleRoutine.count - 1 {
            currentRoutineIndex += 1
        } else {
            currentRoutineIndex = 0
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
    
    /// Creare from cycle step and send a command to the matix
    /// - Parameter from: Cycle step to use
    func composeAndExecuteCommand(from: TextCycleStep) {
        let command: String!
        let colorCompoment: String!
        if let s = from.color.0 {
            colorCompoment = s
        } else if let s = from.color.1 {
            colorCompoment = colorString(from: s)
        } else {
            fatalError("Color error")
        }
        let animationComponent: String!
        if let s = from.animation {
            animationComponent = "\(s.0)<e\(s.1)"
        } else {
            animationComponent = ""
        }
        command = "RTX<t\(from.text)<c\(colorCompoment + (from.fade ? "<i" : "") + animationComponent)/"
        MenuViewController.sendCommand(command)
        setApplianceLabel(.applied)
    }
    
    /// Create from UI and send a command to the matix
    func composeAndExecuteCommand() {
        if MenuViewController.systemCurrentMode == .keyTrace && MenuViewController.systemCurrentMode != systemTargetMode {
            MenuViewController.keylogger.stop()
            SystemMethods.log("Keylogger stopped")
        }
        textModeCycleProgressIndicator.stopAnimation(nil)
        routineTimer?.invalidate()
        let command: String!
        switch systemTargetMode {
        case .text:
            guard textModeTextField.stringValue != "" else { setApplianceLabel(.corruptedParameters); return }
            if textModeCycleSwitch.state == .on && textModeCycleSwitch.isEnabled {
                guard cycleValid() else { setApplianceLabel(.corruptedParameters); return }
                insertToTextCycleRoutine()
                routineTimer = Timer.scheduledTimer(
                    timeInterval: Double(textModeCycleDelayStepper.integerValue),
                    target: self,
                    selector: #selector(self.performRoutine), userInfo: nil, repeats: true)
                textModeCycleProgressIndicator.startAnimation(nil)
                return
            }
            let fadeComponent = (textModeAnimationFadeButton.state == .on && textModeAnimationFadeButton.isEnabled) ? "<i" : ""
            command = "RTX<t\(textModeTextField.stringValue)<c\(getColor(forMode: .text) + fadeComponent + (getTextAnimation(withDelay: true) ?? ""))/"
        case .keyTrace:
            command = "CLR/"
            MenuViewController.keyTraceColor = getColor(forMode: .keyTrace)
            MenuViewController.keylogger.start()
            SystemMethods.log("Keylogger started")
        case .off:
            command = "CLR/"
        default:
            setApplianceLabel("Unknown mode", NSColor.red)
            return
        }
        SystemMethods.log("Sending \(command!)...")
        MenuViewController.sendCommand(command)
        setApplianceLabel(.applied)
        MenuViewController.systemCurrentMode = systemTargetMode
    }
    
    /// Check cycle for validity
    /// - Returns: whether current routine is valid
    func cycleValid() -> Bool {
        for i in textCycleRoutine {
            if i.text == "" { return false }
        }
        return true
    }
    
    /// Insert current text cell parameters to routine array
    func insertToTextCycleRoutine(inserting: Bool = false, clearing: Bool = false) {
        var animationOut: (String, Int)? = nil
        if let animation = getTextAnimation(withDelay: false) {
            animationOut = (animation, textModeAnimationDelaySlider.integerValue)
        }
        let element = TextCycleStep(text: textModeTextField.stringValue, color: getColor(forMode: .text), animation: animationOut, fade: (textModeAnimationFadeButton.isEnabled && textModeAnimationFadeButton.state == .on))
        if inserting {
            textCycleRoutine.insert(element, at: textModeCycleStepsStepper.integerValue)
        } else if clearing {
            textCycleRoutine = [element]
        } else {
            textCycleRoutine[textModeCycleStepsStepper.integerValue] = element
        }
    }
    
    /// Apply current routine element's data to the UI
    func applyTextCycleRoutineElement() {
        let element = textCycleRoutine[textModeCycleStepsStepper.integerValue]
        textModeTextField.stringValue = element.text
        var itemIndex = 0
        if let s = element.color.0 {
            switch s {
            case "%RND%":
                itemIndex = 1
            case "%CHRND%":
                itemIndex = 2
            case "%TLL%":
                itemIndex = 3
            default: ()
            }
        }
        textModeColorModePopUpButton.selectItem(at: itemIndex)
        if let c = element.color.1 {
            textModeColorWell.color = c
        }
        textModeAnimationFadeButton.state = element.fade ? .on : .off
        if let a = element.animation {
            textModeAnimationDelaySlider.integerValue = a.1
            updateTextModeAnimationDelayLabel()
            var segmentIndex = 0
            switch a.0 {
            case "<a%BLI%":
                segmentIndex = 1
            case "<a%SCR%":
                segmentIndex = 2
            default: ()
            }
            textModeAnimationSegmentedControl.setSelected(true, forSegment: segmentIndex)
        } else {
            textModeAnimationSegmentedControl.setSelected(true, forSegment: 0)
        }
        suitTextCellColorWellEnabledState()
        suitTextCellAnimationControlsEnabledState()
    }
    
    /// Update text mode cell's cycle steps label according to current routine state
    func updateTextModeCycleStepsLabel() {
        textModeCycleStepsLabel.stringValue = "\(textModeCycleStepsStepper.integerValue + 1)/\(Int(textModeCycleStepsStepper.maxValue + 1))"
    }
    
    /// Update text mode cell's animation delay label according to delay slider value
    func updateTextModeAnimationDelayLabel() {
        textModeAnimationDelayLabel.stringValue = textModeAnimationDelaySlider.stringValue
    }
    
    /// Get text animation instance for the routine
    /// - Returns: Animation keyword, if exists, nil otherwise
    /// - Parameter withDelay: true if delay value should be appended to string
    func getTextAnimation(withDelay: Bool) -> String? {
        switch textModeAnimationSegmentedControl.indexOfSelectedItem {
        case 1:
            return withDelay ? "<a%BLI%<e\(textModeAnimationDelaySlider.stringValue)" : "<a%BLI%"
        case 2:
            return withDelay ? "<a%SCR%<e\(textModeAnimationDelaySlider.stringValue)" : "<a%SCR%"
        default:
            return nil
        }
    }
    
    /// Get color string for sending to the device
    /// - Returns: Color-respresenting string for the device
    /// - Parameter forMode: Cell to get data from. Only supports .text and .keyTrace
    func getColor(forMode: SystemProperties.Mode) -> String {
        let index = forMode == .text ? textModeColorModePopUpButton.indexOfSelectedItem : keyTraceModeColorModePopUpButton.indexOfSelectedItem
        switch index {
        case 1:
            return "%RND%"
        case 2:
            return "%CHRND%"
        case 3:
            return "%TLL%"
        default:
            let color = forMode == .text ? colorString(from: textModeColorWell.color) : colorString(from: keyTraceModeColorWell.color)
            return color
        }
    }
    
    /// Get color instance for the routine
    /// - Returns: String or NSColor packed in a tuple
    /// - Parameter forMode: Cell to get data from. Only supports .text and .keyTrace
    func getColor(forMode: SystemProperties.Mode) -> (String?, NSColor?) {
        let index = forMode == .text ? textModeColorModePopUpButton.indexOfSelectedItem : keyTraceModeColorModePopUpButton.indexOfSelectedItem
        switch index {
        case 1:
            return ("%RND%", nil)
        case 2:
            return ("%CHRND%", nil)
        case 3:
            return ("%TLL%", nil)
        default:
            let color = forMode == .text ? textModeColorWell.color : keyTraceModeColorWell.color
            return (nil, color)
        }
    }
    
    /// Set system mode
    /// - Parameters:
    ///   - to: Mode to switch to
    ///   - forceModeButton: Whether to explicitly order the corresponding mode button to set its state to 'on'
    func setMode(to: SystemProperties.Mode, forceModeButton: Bool = false) {
        systemTargetMode = to
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
                textModeCycleStepsClearButton,
                textModeCycleDelayTextField,
                textModeCycleDelayStepper
            ],
            [
                keyTraceModeColorModePopUpButton
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
                        if i == 0 && j == 6 {  // Animation Delay Slider and elements of the Cycle Cell must be set in a specific way
                            suitTextCellCycleElementsEnabledState()
                            suitTextCellAnimationControlsEnabledState()
                            suitTextCellColorWellEnabledState()
                            break
                        } else if i == 1 {  // So must be KeyTrace cell's Color Well
                            suitKeyTraceCellColorWellEnabledState()
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
            textModeCycleStepsClearButton,
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
    
    /// Set Delay Slider and Fade Button to a corresponding state
    private func suitTextCellAnimationControlsEnabledState() {
        let b = textModeAnimationSegmentedControl.indexOfSelectedItem != 0
        textModeAnimationDelaySlider.isEnabled = b
        textModeAnimationFadeButton.isEnabled = !b
    }
    
    /// Set Text cell's Color Well to a corresponding state
    private func suitTextCellColorWellEnabledState() {
        textModeColorWell.isEnabled = textModeColorModePopUpButton.indexOfSelectedItem == 0
    }
    
    /// Set KeyTrace cell's Color Well to a corresponding state
    private func suitKeyTraceCellColorWellEnabledState() {
        keyTraceModeColorWell.isEnabled = keyTraceModeColorModePopUpButton.indexOfSelectedItem == 0
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
