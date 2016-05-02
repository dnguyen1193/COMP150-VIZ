class Rectangle {
  float xPos;
  float yPos;
  float rWidth;
  float rHeight;
  String rText;
  String rID;
  String parentID;
  int colorVar;

  Rectangle(float x, float y, float rwidth, float rheight, String text, String ID, String pID, int nrec) {
    xPos = x;
    yPos = y;
    rWidth = rwidth;
    rHeight = rheight;
    rText = text;
    rID = ID;
    parentID = pID;
    colorVar = nrec;
  } 

  float getX() { return xPos; }
  float getY() { return yPos; }
  float getWidth() { return rWidth; }
  float getHeight() { return rHeight; }
  String getID() { return rID; }
  
  void makeRect() {
    stroke(1);
    if(colorVar == 0){
        fill(49,163,84);  // dark green
    }else if(colorVar == 1){
        fill(173,221,142);   //light green
    }else if(colorVar == 2){
        // should be leaf nodes but it doesn't get here
        fill(247,252,185); //beige
    }else{
        println("Rectangle: " + rID + " has colorVar: " + colorVar + ". It should be between 0-2");  
    }
    rect(xPos, yPos, rWidth, rHeight);
    fill(0, 0, 0);
    if (textWidth(rText) > rWidth || rHeight < 8)
        // don't print the text if it doesn't fit
        return;
    textSize(8);
    textAlign(LEFT, TOP);
    text(rText, xPos + 2, yPos + 2);
  }
  
  void drawPartialRect(float ratio) {
      stroke(1);
      fill(204,232,251,75);
      rect(xPos, yPos, rWidth, rHeight * ratio);
  }
  
  Boolean checkHover(){
    if (mouseX > xPos && mouseX < xPos + rWidth &&
        mouseY > yPos && mouseY < yPos + rHeight){
          fill(204,232,251);
          rect(xPos, yPos, rWidth, rHeight);
          if (textWidth(rText) <= rWidth && rHeight >= 8) {
              fill(0, 0, 0);
              textSize(8);
              textAlign(LEFT, TOP);
              text(rText, xPos + 2, yPos + 2);
          }
          selectedNode = this.rID;
          sourceView = SMAP_VIEW;
          return true;
        }
    else{
      return false;
    }
  }
  
  Boolean checkClick(){
    if (mouseX > xPos && mouseX < xPos + rWidth &&
        mouseY > yPos && mouseY < yPos + rHeight){
         return true;
    }
    else
      return false;
  }
}