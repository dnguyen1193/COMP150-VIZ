import controlP5.*;

/* colors */
color highlightColor = color(204, 232,251); //light-blue
color nodeColor = color(31,120,180);  // blue
color hoverTextSpaceColor = color(252,141,98); //orange
color bgColor = color(237, 248, 233);  // light green

int w = 800;
int h = 750;

Graph graph = new Graph();
ControlP5 cp5 = null;
String path = "data1.csv";
boolean showEdgeData = false;
boolean isSpaceMode = false;

PImage spaceBg;
PFont boldFont;
PFont defaultFont;

int nodeToDrag = -1;

float k1 = 0.05;    // k1 hookes law spring constant
float k2 =  600;    // k2 coulombs law spring constant
float c  =  0.2;    // damping constant
float energyThreshold = 0.00;    // total energy threshold

ControlPanel controlPanel;

void setup() {
    size(1000,750);
    spaceBg = loadImage("space.jpg");
    boldFont = createFont("Arial Bold",11);
    defaultFont = createFont("Arial",11);
    
    // Create Control Panel for user to edit values
    cp5 = new ControlP5(this);
    controlPanel = new ControlPanel(cp5);
    
    graph.parseData(path); //<>//
    
    // Print Graph Info 
    //graph.printNodeMass();
    //graph.printEdges();
    //graph.printNodeEdges();
}


void draw() {
    if(isSpaceMode){
        background(spaceBg);
    }else{
        background(bgColor);
    }
    
    graph.drawGraph();
    controlPanel.drawControlPanel();
    controlPanel.updateSystemValues();
}

void mouseClicked(){
    controlPanel.checkResetClicked();
}

void mousePressed() {
    nodeToDrag = graph.checkNodeDrag();
}

void mouseDragged(){
   if (nodeToDrag != -1)
       graph.dragNode(nodeToDrag);
}

void mouseReleased() {
    nodeToDrag = -1;
}