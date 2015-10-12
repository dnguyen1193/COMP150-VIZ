class Rectangle {
  float xPos;
  float yPos;
  float rWidth;
  float rHeight;
  String rText;
  int rID;
  int parentID;
  int colorVar;

  Rectangle(float x, float y, float rwidth, float rheight, String text, int ID, int pID, int nrec) {
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
  int getID() { return rID; }
  
  void makeRect() {
    fill((174+2*colorVar)%255, 225, 242);
    rect(xPos, yPos, rWidth, rHeight);
    fill(0, 0, 0);
    textSize(8);
    textAlign(LEFT, TOP);
    text(rText, xPos + 2, yPos + 2);
  }
  
  Boolean checkHover(){
    if (mouseX > xPos && mouseX < xPos + rWidth &&
        mouseY > yPos && mouseY < yPos + rHeight){
          fill(3, 165, 209);
          rect(xPos, yPos, rWidth, rHeight);
          fill(0, 0, 0);
          textSize(8);
          textAlign(LEFT, TOP);
          text(rText, xPos + 2, yPos + 2);
          return true;
        }
    else
      return false;
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