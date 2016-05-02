/* Transitions for line chart to pie chart */
void moveDotsToPie() {
  moveDots(dotMovement);
  if (dotMovement >= 1) {
    dotMovement = 1;
    movingDotsToPie = false;
    makingLinesToCenter = true;
  }
  dotMovement += 0.05;
}

void growCenterLines() {
  for (int i = 0; i < values.length; i++) {
    line(piechart.cartesianArcsX[i], piechart.cartesianArcsY[i], 
      (1 - lineLenPie) * piechart.cartesianArcsX[i] + lineLenPie * width/2, 
      (1 - lineLenPie) * piechart.cartesianArcsY[i] + lineLenPie * height/2);
    tempDots[i].drawDot(255);
  }
  if (lineLenPie >= 1) {
    lineLenPie = 1;
    makingLinesToCenter = false;
    growingArcs = true;
  }
  lineLenPie += 0.1;
}

void growArcs() {
  tempArcs = new Arc[labels.length];
  float tmpStart = 0;
  for (int i = 0; i < values.length; i++) {
    tempArcs[i] = new Arc(labels[i], values[i], tmpStart, TOTAL, i);
    tmpStart = tempArcs[i].get_arcStop();
  }
  for (int i = 0; i < tempArcs.length; i++) {
    tempDots[i].drawDot(255);
    line(piechart.cartesianArcsX[i], piechart.cartesianArcsY[i], width/2, height/2);   
    //noFill();        
    arc(tempArcs[i].xpos, tempArcs[i].ypos, tempArcs[i].arcWidth, tempArcs[i].arcHeight, 
      tempArcs[i].arcStart, (1-arcLen)*tempArcs[i].arcStart + arcLen*tempArcs[i].arcStop, PIE);
  }
  arcLen += .05;
  if (arcLen >= 1) {
    growingArcs = false; 
    arcLen = 1;
  }
}

/* Transitions for pie chart -> line chart */
void shrinkArcs() {
  tempArcs = new Arc[labels.length];
  float tmpStart = 0;
  for (int i = 0; i < values.length; i++) {
    tempArcs[i] = new Arc(labels[i], values[i], tmpStart, TOTAL, i);
    tmpStart = tempArcs[i].get_arcStop();
  }
  for (int i = 0; i < tempArcs.length; i++) {
    tempDots[i].drawDot(255);
    line(piechart.cartesianArcsX[i], piechart.cartesianArcsY[i], width/2, height/2);       
    arc(tempArcs[i].xpos, tempArcs[i].ypos, tempArcs[i].arcWidth, tempArcs[i].arcHeight, 
      tempArcs[i].arcStart, (1-arcLen)*tempArcs[i].arcStart + arcLen*tempArcs[i].arcStop, PIE);
  }
  arcLen -= .05;
  if (arcLen <= 0) {
    shrinkingArcs = false;
    shrinkingLinesFromCenter = true;
    arcLen = 0;
  }
}

void shrinkCenterLines() {
  lineLenPie -= 0.1;
  if (lineLenPie <= 0) {
    lineLenPie = 0;
    shrinkingLinesFromCenter = false;
    movingDotsToLine = true;
  }
  for (int i = 0; i < values.length; i++) {
    line(piechart.cartesianArcsX[i], piechart.cartesianArcsY[i], 
      (1 - lineLenPie) * piechart.cartesianArcsX[i] + lineLenPie * width/2, 
      (1 - lineLenPie) * piechart.cartesianArcsY[i] + lineLenPie * height/2);
    tempDots[i].drawDot(255);
  }
}

void moveDotsToLine() {
  dotMovement -= 0.05;
  moveDots(dotMovement);
  if (dotMovement <= 0) {
    dotMovement = 0;
    movingDotsToLine = false;
    lineChart.growingLines = true;
  }
}

/* Transitions for bar chart -> line chart */
void shrinkBarHeights() {
  barchart.shrinkBarHeight();
  barchart.bCurrLen *= 0.9;
  if (barchart.bCurrLen <= .01) {
    barchart.bCurrLen = 0.9;
    barchart.shrinkingHeight = false;
    barchart.shrinkingWidth = true;
    lineChart.fadeIn = true;
  }
}

void shrinkBarWidths() {
  if (lineChart.fadeIn) {
    dOpacity += 20;
    if (dOpacity >= 255) {
      dOpacity = 255;
      lineChart.fadeIn = false;
      stroke(1);
    }
    for (int i = 0; i < lineChart.numDots; i++) {
      noStroke();
      lineChart.dots[i].drawDot(dOpacity);
    }
  }
  noStroke();
  barchart.shrinkBarWidth(bOpacity);
  stroke(1);
  barchart.bCurrWidth += 1;
  bOpacity -= 10;
  if (barchart.bCurrWidth >= (0.4 * barchart.quadrantsize)) {
    barchart.shrinkingWidth = false;
    barchart.bCurrWidth = .4*barchart.quadrantsize;
    lineChart.growingLines = true;
    lineLength = 0;
  }
  for (int i = 0; i < lineChart.numDots; i++) {
      lineChart.dots[i].drawDot(dOpacity);
    }
}


/* Transitions from line chart to bar chart */
void growBarWidths() {
  if (lineChart.fadeOut) {
    dOpacity -= 20;
    if (dOpacity <= 5) {
      dOpacity = 0; // reset to 0 in case it's negative
      lineChart.fadeOut = false;
      stroke(1);
    }
    for (int i = 0; i < lineChart.numDots; i++) {
      noStroke();
      lineChart.dots[i].drawDot(dOpacity);
    }
  }
  stroke(1);
  bOpacity += 10;
  barchart.growBarWidth(bOpacity);
  barchart.bCurrWidth -= 1;
  if (barchart.bCurrWidth <= 0) {
    barchart.growingWidth = false;
    barchart.growingHeight = true;
    barchart.bCurrWidth = 0;
  }
}

void growBarHeights() {
  barchart.growBarHeight();
  barchart.bCurrLen *= 0.9;
  if (barchart.bCurrLen <= .01) {
    barchart.bCurrLen = 0.9;
    barchart.growingHeight = false;
  }
}



/* Shared transition functions from bar chart/line chart and pie chart/line chart */
void growLines() {
  lineLength += 0.1;
  if (lineLength >= 1) {
    lineLength = 1;
    lineChart.growingLines = false;
  }
  lineChart.makeLines(lineLength);
  for (int i = 0; i < lineChart.lines.length; i++) {
    lineChart.lines[i].drawLine();
  }
  for (int i = 0; i < lineChart.numDots; i++)
    lineChart.dots[i].drawDot(dOpacity);
}

void shrinkLines() {
  lineLength -= 0.1;
  if (lineLength <= 0) {
    lineLength = 0;
    lineChart.shrinkingLines = false;
  } 
  lineChart.makeLines(lineLength);
  for (int i = 0; i < lineChart.lines.length; i++) {
    lineChart.lines[i].drawLine();
  }
  for (int i = 0; i < lineChart.numDots; i++)
    lineChart.dots[i].drawDot(dOpacity);
}

/* Auxiliary functions */
void moveDots(float lenMove) {
  tempDots = new Dot[labels.length];
  strokeWeight(1);
  for (int i = 0; i < values.length; i++) {
    float xPos = (1-lenMove)*lineChart.dots[i].xPos + lenMove* piechart.cartesianArcsX[i];
    float yPos = (1-lenMove)*lineChart.dots[i].yPos + lenMove* piechart.cartesianArcsY[i];
    tempDots[i] = new Dot(xPos, yPos, lineChart.dotColors[i], "");
  }
  for (int i = 0; i < tempDots.length; i++)
    tempDots[i].drawDot(255);
}