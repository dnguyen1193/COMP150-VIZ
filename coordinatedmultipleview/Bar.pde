class Bar{
    public float xPos, yPos, barWidth, barHeight, space;
    public color barColor, origColor;
    public int year;
    public String hoverText;
    public color highLightColor = color(204,232,251);
    boolean isHovered = false;
  
    Bar(int year, float x, float y, float w, float h, int bColor, String _hoverText){
        this.year = year;
        xPos = x;
        yPos = y;
        barWidth = w;
        barHeight = h;
        origColor = bColor;
        barColor = bColor;
        space = barWidth * 0.15;
        this.hoverText = _hoverText;
    }

    void drawRect() {
        fill(barColor);
        rect(xPos + space, yPos, barWidth - (2 * space), barHeight); 
    }
    
    void drawPartialRect(float ratio) {
        fill(204, 232,251);
        rect(xPos + space, yPos + (barHeight *(1 - ratio)), barWidth - (2 * space), barHeight * ratio);
    }

  void changeColor(color newColor){
        barColor = newColor;
  }
  
  void highLight() {
      changeColor(highLightColor);
      drawRect();
      stroke(50,50,50);
      fill(0);
      addToolTip();
  }
  
  void drawLabel() {
      String label = Integer.toString(year);
      fill(255);
      textAlign(BASELINE);
      textSize(12);
      text(label, xPos + barWidth/2 - space, yPos + barHeight + 17);
  };
  
  void addToolTip(){
        textSize(10);
        float toolTipLen = textWidth(hoverText);
        fill(255, 255, 255);
        noStroke();
        if(mouseX + toolTipLen > width){
            rect(mouseX - 15 - toolTipLen, mouseY + 5, toolTipLen + 10, 18);
            fill(0);
            textAlign(RIGHT, TOP);
            text(hoverText, mouseX - 8.5, mouseY + 7.5);
            stroke(1);
        } else {
            rect(mouseX + 13, mouseY + 5, toolTipLen + 10, 18);
            fill(0);
            textAlign(LEFT, TOP);
            text(hoverText, mouseX + 18.5, mouseY + 7.5);
            stroke(1);
        }
        
    }
  
    void useOriginalColor() {
        barColor = origColor;
    }
}