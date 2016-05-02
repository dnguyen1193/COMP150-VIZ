
String L1;
String L2;
String[] labels;
float[] values;
String[] axes;
color[] colors;
float maxValue = 0;
float TOTAL = 0;
Barchart barchart;
Pie piechart;
LineChart lineChart;
static final int BARCHART = 0;
static final int LINECHART = 1;
static final int PIECHART = 2;

static final int BARTOLINE = 0;
static final int LINETOBAR = 1;
static final int LINETOPIE = 2;
static final int PIETOLINE = 3;
static final int BARTOPIE  = 4;
static final int PIETOBAR  = 5;

Boolean transitioning = false;
int currTransition = -1;
int currChart = BARCHART;
Button[] buttons = new Button[3];

int bOpacity = 255;
int dOpacity = 255;
float lineLength = 1.0;
Dot[] tempDots = null;
Arc[] tempArcs = null;

// GLOBALS TO TURN LINECHART TO PIE
Boolean movingDotsToPie = false;
Boolean makingLinesToCenter = false;
Boolean growingArcs = false;

// GLOBALS TO TURN PIE TO LINE
Boolean shrinkingArcs = false;
Boolean shrinkingLinesFromCenter = false;
Boolean movingDotsToLine = false;

// shared globals for transitions between linechart/piechart
float dotMovement = 0;
float lineLenPie = 0;
float arcLen = 0;

void setup() {
  parseData();
  size(600, 600);
  frameRate(10);
  
  setColors();
  
  barchart = new Barchart(width - 20, height - 60, labels, values);

  piechart = new Pie();
  piechart.init();
  piechart.makePie();

  lineChart = new LineChart(width - 20, height - 60, labels.length, labels, values, maxValue);
  lineChart.setDotColors();
  lineChart.makeDots();

  buttons[0] = new Button(25, height - 40, "Bar");
  buttons[1] = new Button(80, height- 40, "Line");
  buttons[2] = new Button(135, height - 40, "Pie");
}

void parseData() {
  String[] lines = loadStrings("data.csv");
  axes = new String[2];
  labels = new String[lines.length - 1];
  values = new float[lines.length - 1];
  axes = split(lines[0], ",");
  
  for (int i = 1; i < lines.length; i++) {
    String[] row = split(lines[i], ",");
    labels[i - 1] = row[0];
    values[i -1] = parseFloat(row[1]);
    TOTAL += values[i-1];
    if (values[i - 1] > maxValue)
      maxValue = values[i - 1];
  }
}

void setColors(){
  colors = new color[labels.length];
  for (int i = 0; i < labels.length; i++){
    colors[i] = color(random(100,255), random(100,255), random(100,255));
  } 
}

void mouseClicked() {
  for (int i = 0; i < buttons.length; i++) {
    if (buttons[i].clicked()) {
      transitioning = true;
      if (currChart == BARCHART && i == LINECHART) {
        currTransition = BARTOLINE;
        barchart.shrinkingHeight = true;
      }
      else if (currChart == LINECHART && i == BARCHART) {
        currTransition = LINETOBAR;
        lineChart.shrinkingLines = true;
        lineChart.fadeOut = true;
      }
      else if (currChart == LINECHART && i == PIECHART) {
        currTransition = LINETOPIE;
        lineChart.shrinkingLines = true;
      }
      else if (currChart == BARCHART && i == PIECHART) {
        currTransition = BARTOPIE;
        barchart.shrinkingHeight = true;
        lineChart.shrinkingLines = true;
      }
      else if (currChart == PIECHART && i == LINECHART) {
        currTransition = PIETOLINE;
        shrinkingArcs = true;
      }
      else if (currChart == PIECHART && i == BARCHART) {
        currTransition = PIETOBAR;
        shrinkingArcs = true;
        lineChart.shrinkingLines = true;
        lineChart.fadeOut = true;
      }
      else if (currChart == i)
        transitioning = false;
      currChart = i; 
      if (currChart == 3) {
        currChart = 0;
      }
    }
  }
}


void draw() {
  //clear background
  background(255, 255, 255);

  //make buttons
  for (int i = 0; i < buttons.length; i++) {
    buttons[i].make();
  }

  if (transitioning == false) {
    switch(currChart) {
    case LINECHART:
      lineChart.drawChart();
      break;
    case BARCHART:
      barchart.drawBarchart();
      break;
    case PIECHART:
      piechart.drawPie();
      break;
    }
  } else {
    switch(currTransition) {
    case BARTOPIE:
      if (barchart.shrinkingHeight) {
        shrinkBarHeights();
      } else if (barchart.shrinkingWidth) {
        shrinkBarWidths();
      } else if (lineChart.growingLines) {
        growLines();
      } else {
        bOpacity = 0;
        lineChart.drawChart();
        currTransition = LINETOPIE;
      }
      break;
    case PIETOBAR:
      if (shrinkingArcs) {
        shrinkArcs();
      } else if (shrinkingLinesFromCenter) {
        shrinkCenterLines();
      } else if (movingDotsToLine) {
        moveDotsToLine();
      } else if (lineChart.growingLines) {
        growLines();
      } else {
        currTransition = LINETOBAR;
        lineChart.drawChart();
      }
      break;      
    case PIETOLINE:
      if (shrinkingArcs) {
        shrinkArcs();
      } else if (shrinkingLinesFromCenter) {
        shrinkCenterLines();
      } else if (movingDotsToLine) {
        moveDotsToLine();
      } else if (lineChart.growingLines) {
        growLines();
      } else {
        lineChart.drawChart();
        transitioning = false;
      }
      break;      
    case LINETOBAR: 
      if (lineChart.shrinkingLines) {
        shrinkLines();
        if (!lineChart.shrinkingLines)
          barchart.growingWidth = true;
      } else if (barchart.growingWidth) {
        growBarWidths();
      } else if (barchart.growingHeight) {
       growBarHeights();
      } else {
        barchart.drawBarchart();
        transitioning = false;
      }
      break;

    case BARTOLINE: 
      if (barchart.shrinkingHeight) {
        shrinkBarHeights();
      } else if (barchart.shrinkingWidth) {
        shrinkBarWidths();
      } else if (lineChart.growingLines) {
        growLines();
      } else {
        bOpacity = 0;
        lineChart.drawChart();
        transitioning = false;
      }
      break;

    case LINETOPIE:
      if (lineChart.shrinkingLines) {
        shrinkLines();
        if (!lineChart.shrinkingLines)
          movingDotsToPie = true;
      } else if (movingDotsToPie) {
        moveDotsToPie();
      } else if (makingLinesToCenter) {
        growCenterLines();
      } else if (growingArcs) {
        growArcs();
      } else {
        piechart.drawPie();
        transitioning = false;
      }
      break;

    default:
      break;
    }
  }
}