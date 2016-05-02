class Bubble {
  String label;
  int value;
  float x;
  float y;
  float r;
  float endX;
  float endY;
  float damping = 0.009;
  float spring = 0.05;
  boolean isHovered = false;
  float endXRatio = .75;
  float endYRatio = .3;
 
  Bubble(String _label, int _value, float x_, float y_, float r_) {
    this.label = _label;
    this.value = _value;
    this.x = x_;
    this.y = y_;
    this.r = r_;
    
     
    // for gravitational pull toward the center, set endX and endY coordinates to center point
    this.endX = width * endXRatio;
    this.endY = height * endYRatio;
  }
   
  void display() {
     
    // increment end coordinates toward end point (3/4 width & .3 height)
    endX = endX + (width * endXRatio - endX) * damping;
    endY = endY + (height * endYRatio - endY) * damping;
 
     
    // increment x and y coordinates
    x = x + (endX - x) * damping;
    y = y + (endY - y) * damping;
     
    if (!isHovered) {
      fill(249, 202, 202, 190);
    } else {
      fill(204,232,251);
    }
    noStroke();
    ellipse(x, y, r*2, r*2);
    
    // draw text after circles so they appear on top
    fill(0);
    textSize(13);
    textAlign(CENTER, CENTER);
    if(textWidth(label) < r * 2) {
        text(this.label, x, y);
    }
  }
   
  void position(float x, float y) {
    endX = x;
    endY = y;
  }
   
  void collisionTest(Bubble bubble) {
    if(bubble == null){
        println("bubble is null"); 
    }
    float minDistance = bubble.r + r;
     
    // if a hit test is registered, propell bubbles in the opposite direction
    if (dist(bubble.x, bubble.y, x, y) < minDistance) {
             
      // first, get the difference between the two x, y coordinates
      float dx = bubble.x - x;
      float dy = bubble.y - y;
 
      /*
      next, calculate the angle in polar coordinates
      atan2 calculates the angle (in radians) from a specified point to the coordinate origin,
      as measured from the positive x-axis. more info here: http://processing.org/reference/atan2_.html
      */
      float angle = atan2(dy, dx);
       
      // now, calculate the target coordinates of the current bubble by using the minimum distance
      float targetX = x + cos(angle) * minDistance;
      float targetY = y + sin(angle) * minDistance;
             
      // increment the x and y coordinates for both objects
      x = x - (targetX - bubble.x) * spring;
      y = y - (targetY - bubble.y) * spring;
      bubble.x = bubble.x + (targetX - bubble.x) * spring;
      bubble.y = bubble.y + (targetY - bubble.y) * spring;
    }
  }
   
  void propell() { 
    // randomize angle relative to sketch center
    float angle = random(360);
     
    // increment endX and endY coordinates
    endX = x - cos(angle) * height * endYRatio;
    endY = y - sin(angle) * height * endYRatio;
  }
   
  void onMouseOver(float mx, float my) {
    if (dist(mx, my, x, y) < r) {
      textAlign(LEFT, TOP);
      textSize(10);
      String hoverText = new String("Sponsor: " + this.label + ", Funding: " + this.value);
      float toolTipLen = textWidth(hoverText);
      fill(255);
      if (mouseX + toolTipLen > width) {
          rect(mouseX - 15 - toolTipLen, mouseY + 5, toolTipLen + 10, 18);
          fill(0);
          textAlign(RIGHT, TOP);
          text(hoverText, mouseX - 8.5, mouseY + 7.5);
          stroke(1);
      } else {
          //isHovered = true;
          noStroke();
          rect(mouseX + 13, mouseY + 5, toolTipLen + 10, 18);
          fill(0);
          text(hoverText, mouseX + 18.5, mouseY + 7.5);
          stroke(1);
      }
      isHovered = true;
      selectedNode = this.label;
      sourceView = BUBBLE_VIEW;
    }
    else {
      isHovered = false;
    }
  }
  
  void drawPartialBubble(float ratio){
      noStroke();
      fill(204, 232,251,75);
      arc(x, y, r*2, r*2, 0, radians(ratio*360)); 
  }
   
   
}