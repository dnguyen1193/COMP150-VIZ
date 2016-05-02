class Barchart {
  int bwidth;
  int bheight;
  String[] names;
  float[] values;
  float maxval;
  Bar[] bars;
  int quadrantsize;
  float bCurrLen;
  float bCurrWidth;
  Boolean shrinkingHeight;
  Boolean shrinkingWidth;
  Boolean growingHeight;
  Boolean growingWidth;

  Barchart(int nwidth, int nheight, String[] nnames, float[] nvalues) {
    bwidth = nwidth;
    bheight = nheight;
    names = nnames;
    values = nvalues;
    quadrantsize = bwidth/values.length;
    bars = new Bar[values.length];
    shrinkingHeight = false;
    shrinkingWidth = false;
    growingHeight = false;
    growingWidth = false;
    bCurrLen = 0.9;
    bCurrWidth = 1;
  }

  void getmaxvalue() {
    maxval = 0;
    for (int i = 0; i < values.length; i++) {
      if (values[i] > maxval) {
        maxval = values[i];
      }
    }
  }

  void drawaxes() {
    line(20, bheight, 20, 20);  // y 
    text(axes[1], 10, bheight/2);    
    line(bwidth, bheight, 20, bheight);  // x
    text(axes[0], bwidth/2, bheight + 30);
  }

  void drawxticks() {
    for (int i = 0; i < names.length; i ++) {
      line((i+.5)*quadrantsize + 20, bheight, (i+.5)*quadrantsize + 20, bheight+5);
      textSize(7);
      text(names[i], (i+.5)*quadrantsize + 20, bheight + 15);
      textSize(12);
    }
  }

  void drawyticks() {
    for (int i = 20; i <= bheight; i+=20){
      line(15, i, 20, i);
      float txt = (((bheight-i)/(float)(bheight - 20))*maxval);
      textSize(7);
      text( nf(txt, 2, 1), 12, i);
      textSize(12);
    }
  }

  void shrinkBarHeight() {
    getmaxvalue();
    for (int i = 0; i < values.length; i++) {
      float len = ((float)values[i]/ (float) maxval) * ((float)bheight - 20);
      float a = (i+.1)*quadrantsize + 20;
      bars[i] = new Bar(names[i], (i+.1)*quadrantsize + 20, bheight + (-len*(1.0 - bCurrLen)), 
                        .8*quadrantsize, (-len) + (len*(1.0 - bCurrLen)), i);
      bars[i].drawBar(255);
    }
  }

  void growBarHeight() {
    getmaxvalue();
    for (int i = 0; i < values.length; i++) {
      float len = ((float)values[i]/ (float) maxval) * ((float)bheight - 20);
      float a = (i+.1)*quadrantsize + 20;
      bars[i] = new Bar(names[i], (i+.1)*quadrantsize + 20, bheight + (-len*bCurrLen), 
                .8*quadrantsize, (-len) + len*bCurrLen, i);
      bars[i].drawBar(255);
    }
  }

  void shrinkBarWidth(int bOpacity) {
    getmaxvalue();
    for (int i = 0; i < values.length; i++) {
      float len = ((float)values[i]/ (float) maxval) * ((float)bheight - 20);
      bars[i] = new Bar(names[i], (i+.1)*quadrantsize + 20 + bCurrWidth, bheight-len, 
                        .8*quadrantsize - (2 * bCurrWidth), 5, i);                          
      bars[i].drawBar(bOpacity);
    }
  }

  void growBarWidth(int bOpacity) {
    getmaxvalue();
    for (int i = 0; i < values.length; i++) {
      float len = ((float)values[i]/ (float) maxval) * ((float)bheight - 20);
      bars[i] = new Bar(names[i], (i+.1)*quadrantsize + 20 + (bCurrWidth), bheight-len, 
                 .8*quadrantsize - (2 * bCurrWidth), 5, i);
      bars[i].drawBar(bOpacity);
    }
  }

  void drawbars() {
    getmaxvalue();
    int hover = -1;
    float c = .8*quadrantsize;
    for (int i = 0; i < values.length; i++) {
      float len = ((float)values[i]/ (float)maxval) * ((float)bheight - 20);
      float a = (i+.1)*quadrantsize + 20;
      bars[i] = new Bar(names[i], 
                        (i+.1)*quadrantsize + 20, bheight, 
                        .8*quadrantsize, -len, i);
      bars[i].drawBar(255);
      if (mouseX > a && mouseX < a + c &&
        mouseY < bheight && mouseY > bheight - len) {
        hover = i;
      }
    }
    if (hover != -1) {
      bars[hover].drawHighlightedBar();
      
      textSize(12);
      textAlign(LEFT, TOP);
      String toolTipString = names[hover] + ": " + Float.toString(values[hover]);
      float toolTipLen = textWidth(toolTipString);
      fill(255, 255, 255);
      noStroke();
      rect(mouseX + 5, mouseY + 5, toolTipLen + 10, 20);
      fill(0);
      text(toolTipString, mouseX + 8.5, mouseY + 7.5);
      stroke(1);
    }
  }

  void drawBarchart() {
    fill(color(0, 0, 0));
    drawaxes();
    drawxticks();
    drawyticks();
    if (!shrinkingHeight && !shrinkingWidth) {
      drawbars();
    }
    if (shrinkingHeight) {
      shrinkBarHeight();
    }
  }
}


class Bar {
  float value;
  String name;
  float a;
  float b;
  float c;
  float d;
  color bColor;

  Bar(String nname, float na, float nb, float nc, float nd, int index) {
    value = nb;
    name = nname;
    a = na;
    b = nb;
    c = nc;
    d = nd;
    bColor = colors[index];
  }

  void drawBar(int bOpacity) {
    fill(bColor, bOpacity);
    rect(a, b, c, d);
  }
  
  void drawHighlightedBar() {
    fill(50, 50, 175);
    rect(a, b, c, d);
  }
}