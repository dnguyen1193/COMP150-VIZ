class Pie {
  float total = 0;
  ArrayList arcs = new ArrayList();
  float[] cartesianArcsX = null;
  float[] cartesianArcsY = null;

  void init() {
    for (int i = 0; i < values.length; i++) {
      total = total + values[i];
    }
    cartesianArcsX = new float[values.length];
    cartesianArcsY = new float[values.length];
  }

  void makePie() {
    float tmpStart = 0;
    Arc temp;
    for (int i = 0; i < values.length; i++) {
      temp = new Arc(labels[i], values[i], tmpStart, (float)total, i);
      cartesianArcsX[i] = (width/4)*cos(tmpStart) + (width/2);
      cartesianArcsY[i] = (width/4)*sin(tmpStart) + (height/2);        
      tmpStart = temp.get_arcStop();
      arcs.add(temp);
    }
  }

  void drawPie() {
    Arc temp;
    Boolean hovering = false;
    for (int i = 0; i < arcs.size(); i++) {
      temp = (Arc)arcs.get(i);
      temp.draw_arc();
    }
    for (int i = 0; i < arcs.size(); i++) {
      temp = (Arc)arcs.get(i);
      hovering = temp.checkHover();
      if (hovering)
        temp.showHoverText();
    }
  }
}


class Arc {
  String name;
  float value;
  int xpos;
  int ypos;
  int arcWidth;
  int arcHeight;
  float arcStop;
  float arc_length;
  float degrees;
  float radians;
  float arcStart;
  color arcColor;

  public Arc(String nname, float nvalue, float narcStart, float total, int index) {
    value = nvalue;
    name = nname;
    arcStart = narcStart;
    arc_length = value/(total);
    degrees = 360*arc_length;
    radians = radians(degrees);
    xpos = width/2;
    ypos = height/2;
    arcWidth = (width)/2;
    arcHeight = (width)/2;
    arcStop = radians + arcStart;
    arcColor = colors[index];
  }

  float get_arcStop() {
    return arcStop;
  }

  void draw_arc() {
    fill(arcColor);
    arc(xpos, ypos, arcWidth, arcHeight, arcStart, arcStop, PIE);   
  }

  Boolean checkHover() {
    Boolean inCircle = false;
    float distance = sqrt(abs(sq((mouseX - xpos)) + sq((mouseY - ypos))));
    if (distance <= arcWidth/2) {
      inCircle = true;
    }
    float angle = 0;
    float dy = ((float)mouseY-(float)ypos);
    float dx = ((float)mouseX - (float)xpos);
    angle = atan2(dy, dx);
    if (angle < 0) {
      angle = 2*PI + angle;
    }

    if (inCircle && angle >= arcStart && angle <= arcStop) {
      return true;
    }
    return false;
  }

  void showHoverText() {
    fill(50, 50, 175);  
    arc(xpos, ypos, arcWidth, arcHeight, arcStart, arcStop, PIE);
    textSize(12);
    textAlign(LEFT, TOP);
    String toolTipString = name + ": " + value;
    float toolTipLen = textWidth(toolTipString);
    fill(255, 255, 255);
    noStroke();
    rect(mouseX + 5, mouseY + 5, toolTipLen + 10, 20);
    fill(0);
    text(toolTipString, mouseX + 8.5, mouseY + 7.5);
    stroke(1);
  }
}