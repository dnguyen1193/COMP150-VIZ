class Dot {
  public float xPos, yPos;
  public color barColor, origColor;
  public String bText;
  public color highLightColor = color(50, 50, 175);

  Dot(float x, float y, int bColor, String text) {
    xPos = x;
    yPos = y;
    origColor = bColor;
    barColor = bColor;
    bText = text;
  }

  // GETTERS
  float getX() { 
    return xPos;
  }
  float getY() { 
    return yPos;
  }

  void drawDot(int dOpacity) {
    color dColor = color(barColor, dOpacity);
    fill(dColor);
    ellipse(xPos, yPos, 8, 8);
  }

  void changeColor(color newColor) {
    barColor = newColor;
  }

  void highlight() {
    changeColor(highLightColor);
    stroke(50, 50, 50);
    fill(150);

    textSize(12);
    textAlign(LEFT, TOP);
    String toolTipString = bText;
    float toolTipLen = textWidth(toolTipString);
    fill(255, 255, 255);
    noStroke();
    rect(mouseX + 5, mouseY + 5, toolTipLen + 10, 20);
    fill(0);
    text(toolTipString, mouseX + 8.5, mouseY + 7.5);
    stroke(1);
  }

  void useOriginalColor() {
    barColor = origColor;
  }
}

class Line {
  float startX, startY;
  float endX, endY;

  Line(float x1, float y1, float x2, float y2) {
    startX = x1;
    startY = y1;
    endX = x2;
    endY = y2;
  }

  void drawLine() {
    strokeWeight(2);
    line(startX, startY, endX, endY);
    strokeWeight(1);
  }
}

class LineChart {
  float cWidth, cHeight, quadrantSize;
  int numDots;
  String[] labels; // x-val
  float[] values; // y-val
  Dot[] dots; // data dots
  Line[] lines; // lines connecting dots
  color[] dotColors;
  Boolean fadeOut = false;
  Boolean fadeIn = false;
  Boolean growingLines = false;
  Boolean shrinkingLines = false;

  LineChart(float dWidth, float dHeight, int dDots, String[] dLabels, float[] dValues, float maxVal) {
    cWidth = dWidth;
    cHeight = dHeight;
    numDots = dDots;
    labels = dLabels;
    values = dValues;
    maxValue = maxVal;
    quadrantSize = cWidth/numDots;
  }

  void setDotColors() {
    dotColors = new color[numDots];
    for (int i= 0; i < numDots; i++) {
      dotColors[i] = colors[i];
    }
  }

  void drawChart() {
    makeXAxis();
    barchart.drawxticks();
    makeYAxis();
    barchart.drawyticks();
    makeDots();
    makeLines(1);
    int hover = -1;
    for (int i = 0; i < values.length; i++) {     
      if ((dots[i].xPos - 8 <= mouseX && dots[i].xPos + 8 >= mouseX) &&
        (dots[i].yPos - 8 <= mouseY && dots[i].yPos + 8  >= mouseY)) {
        dots[i].highlight();
      } else {
        dots[i].useOriginalColor();
      }
      dots[i].drawDot(255);
    }

    for (int i = 0; i < lines.length; i++) {
      lines[i].drawLine();
    }

    for (int i = 0; i < values.length; i++) {     
      if ((dots[i].xPos - 8 <= mouseX && dots[i].xPos + 8 >= mouseX) &&
        (dots[i].yPos - 8 <= mouseY && dots[i].yPos + 8 >= mouseY)) {
        hover = i;
      } else {
        dots[i].useOriginalColor();
      }
      dots[i].drawDot(255);
    }
    if (hover != -1)
      dots[hover].highlight();
  }

  void makeXAxis() {
    fill(0);
    stroke(0, 0, 0);
    strokeWeight(2);
    line(cWidth, cHeight, 20, cHeight);
    text(axes[0], cWidth/2, cHeight + 30);
  }

  void makeYAxis() {
    fill(0);
    stroke(0, 0, 0);
    strokeWeight(2);
    line(20, cHeight, 20, 20);
    text(axes[1], 10, cHeight/2);    
  }

  void makeDots() {
    dots = new Dot[labels.length];
    float ratio = (cHeight-20)/maxValue;
    strokeWeight(1);
    for (int i = 0; i < values.length; i++) {
      String hoverText = labels[i] +": " + values[i];
      float xPos = (quadrantSize*(i)) + (quadrantSize*.5)+20;
      float yPos = cHeight - (ratio * values[i]);
      dots[i] = new Dot(xPos, yPos, dotColors[i], hoverText); 
    }
  }

  void makeLines(float lenDiff) {
    float startX, startY, endX, endY;
    lines = new Line[dots.length - 1];
    for (int i = 1; i < dots.length; i++) {
      startX = dots[i - 1].getX();
      startY = dots[i - 1].getY();
      endX = dots[i].getX();
      endY = dots[i].getY();
      lines[i - 1] = new Line(startX, startY, 
        (1-lenDiff)*startX + lenDiff*endX, (1-lenDiff)*startY + lenDiff*endY);
    }
  }
}