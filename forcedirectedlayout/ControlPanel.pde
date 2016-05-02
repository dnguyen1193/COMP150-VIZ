import controlP5.*;

class ControlPanel {
    float x;
    float w;
    
    float hookesSlider = .05;
    float coulombsSlider = 600;
    float wPercent = .2;  // how wide(%) of the dialog to make the control panel
    
    /* Control Panel widgets */
    Controller hSlider;
    Controller cSlider;
    Controller fSlider;
    Controller dSlider;
    Controller resetButton;
    
    PFont myFont = createFont("sans-serif",12);
    color panelColor = color(166, 206, 227);
    
    /**  HOOKE'S Constants **/
    final String HOOKES_ID = "hookesSlider";
    final String HOOKES_LABEL = "K1 Constant";
    final float HOOKES_YPERCENT = 0.1;
    final float HOOKES_RANGE_START = 0.00;
    final float HOOKES_RANGE_END = 0.1;
    final int HOOKES_TICK_MARKS = 11;
    
    /**  COULOMB's Constants **/
    final String COULOMBS_ID = "coulombsSlider";
    final String COULOMBS_LABEL = "K2 Constant";
    final float COULOMBS_YPERCENT = 0.2;
    final int COULOMBS_RANGE_START = 0;
    final int COULOMBS_RANGE_END = 2000;
    final int COULOMBS_TICK_MARKS = 11;
    
    /**  Force Threshold Constants **/
    final String FORCE_THRESHOLD_ID = "thresholdSlider";
    final String FORCE_THRESHOLD_LABEL = "Energy Threshold";
    final float FORCE_THRESHOLD_YPERCENT = 0.3;
    final float FORCE_THRESHOLD_RANGE_START = 0.00;
    final float FORCE_THRESHOLD_RANGE_END = 0.1;
    final int FORCE_THRESHOLD_TICK_MARKS = 11;
    
    /** Damping Constants **/
    final String DAMPING_ID = "dampingSlider";
    final String DAMPING_LABEL = "Damping";
    final float DAMPING_YPERCENT = 0.4;
    final float DAMPING_RANGE_START = 0.00;
    final float DAMPING_RANGE_END = 0.2;
    final int DAMPING_TICK_MARKS = 11;
    
    ControlPanel(ControlP5 cp5){
        x = width - (wPercent*width);
        w = wPercent*width;
        
        // Create Hooke's, Coulombs, max threshold & damping slider
        hSlider = createSlider(HOOKES_ID, HOOKES_LABEL, HOOKES_YPERCENT, 
              HOOKES_RANGE_START, HOOKES_RANGE_END, HOOKES_TICK_MARKS);
        cSlider = createSlider(COULOMBS_ID, COULOMBS_LABEL, COULOMBS_YPERCENT, 
              COULOMBS_RANGE_START, COULOMBS_RANGE_END, COULOMBS_TICK_MARKS);
        fSlider = createSlider(FORCE_THRESHOLD_ID, FORCE_THRESHOLD_LABEL, 
              FORCE_THRESHOLD_YPERCENT, FORCE_THRESHOLD_RANGE_START, 
              FORCE_THRESHOLD_RANGE_END, FORCE_THRESHOLD_TICK_MARKS);
        dSlider = createSlider(DAMPING_ID, DAMPING_LABEL, DAMPING_YPERCENT, 
              DAMPING_RANGE_START, DAMPING_RANGE_END, DAMPING_TICK_MARKS);
              
        // Set the initial values for the sliders
        hSlider.setValue(k1);
        cSlider.setValue(k2);
        fSlider.setValue(energyThreshold);
        dSlider.setValue(c);
        
        // "showEdgeData" must match the boolean variable's name in a3 or 
        // it won't get updated during the showEdgeData's toggle event
        createToggle("isSpaceMode", "Space Mode", .7);
        createToggle("showEdgeData", "Edge Data", .8);
        
        createResetButton();
    }
    
    Controller createSlider(String idString, String label, float yPercent, 
        float rangeStart, float rangeEnd, int tickMarks){
        cp5.addSlider(idString).
          setPosition(x + w/10, height * (yPercent)).
          setRange(rangeStart, rangeEnd).
          setNumberOfTickMarks(tickMarks);
          
        Controller slider = cp5.getController(idString);
        slider.setLabel(label);
        Label sLabel = slider.getCaptionLabel();
        sLabel.setFont(myFont);
        sLabel.align(ControlP5.LEFT-5, ControlP5.TOP_OUTSIDE);
        
        return slider;
    }
    
    void createResetButton(){
        cp5.addButton("resetButton")
            .setValue(0)
            .setPosition(x + w/10, height * .9)
            .setSize((int)(w *.8), (int)(height *.05));
            
         resetButton = cp5.getController("resetButton"); 
         resetButton.setLabel("Reset");
         resetButton.getCaptionLabel().setFont(myFont);
    }
    
    Controller createToggle(String idString, String label, float yPercent){
        // create a toggle and change the default look to a (on/off) switch look
        cp5.addToggle(idString)
           .setPosition(x + w/10, height * yPercent)
           .setSize(50,20)
           .setValue(false)
           .setMode(ControlP5.SWITCH);
        Controller toggle = cp5.getController(idString);
        toggle.setLabel(label);
        toggle.getCaptionLabel().setFont(myFont)
            .align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE);
        
        return toggle;
    }
   
    /* Draws the control panel on the right side of the screen
     * Width is a percentage (i.e. wPercent) of the width & it
     * takes up the entire height of the dialog.  These values
     * are recalculated each time in case the dialog resizes
     */
    void drawControlPanel(){
        stroke(0);
        fill(panelColor);
        x = width - (wPercent*width);
        w = wPercent * width;
        rect(x, 0 - 5, w, height + 5);
    }
    
    /*
     * Checks the slider values and only updates the system values
     * if a value has changed.  If a value has changed it will
     * set the overall total energy to 0.0, effectively allowing
     * the springs & coulombs force to recalibrate and work their magic.
     */
    void updateSystemValues(){
        float k1Value = hSlider.getValue();
        if (k1 != k1Value) {
            k1 = k1Value;
            graph.totalEnergy = 0.0;
        }
        
        float k2Value = cSlider.getValue();
        if (k2 != k2Value) {
            k2 = k2Value;
            graph.totalEnergy = 0.0;
        }
        
        float energyValue = fSlider.getValue();
        if(energyThreshold != energyValue){
            energyThreshold = energyValue;
            graph.totalEnergy = 0.0;
        }
        
        float dampingValue = dSlider.getValue();
        if(c != dampingValue){
            c = energyValue;
            graph.totalEnergy = 0.0;
        }
    }
    
    void checkResetClicked(){
        float[] position = resetButton.getPosition();
        if(mouseX >= position[0] && mouseX <= position[0]+ resetButton.getWidth() &&
            mouseY >= position[1] && mouseY <= position[1] + resetButton.getHeight()){
              // reset the position of the nodes if the reset button is clicked
              graph.resetNodePositions();
        }
    }
}