class BarChart{
    String xName, yName;
    int years[];
    int totalDonations[];
    Bar bars[] = null;
    color barColors[];
    
    BarChart(){}
    
    void initializeData() {
        
        xName = headers[3];
        yName = headers[4];
        int numBars = controller.donationsByYear.size();
        years = new int[numBars];
        totalDonations = new int[numBars];
        Set set = controller.donationsByYear.entrySet();
        Iterator iterator = set.iterator();
        int pos = 0;
        
        while(iterator.hasNext()){
            Map.Entry entry = (Map.Entry)iterator.next();
            int _year = (int)entry.getKey();
            int _donationsInYear = ((ArrayList<Donation>)entry.getValue()).size();
            years[pos] = _year;
            totalDonations[pos] = _donationsInYear;
            pos++;
            setBarColors(numBars);
            
        }
    }
    
    void setBarColors(int numBars){
        barColors = new color[numBars];
        for(int i= 0; i < barColors.length; i++){
            barColors[i] = color(random(0,255), random(0,255), random(0,255));
        }
    }
    
    void drawBarChart(){
        initBars();
        Bar highlightedBar = null;
        for (int i = 0; i < bars.length; i++){ 
             if((bars[i].xPos + bars[i].space <= mouseX && bars[i].xPos + bars[i].barWidth - (2 * bars[i].space) >= mouseX) &&
                (bars[i].yPos <= mouseY && bars[i].yPos + bars[i].barHeight >= mouseY)) {
                  sourceView = BAR_VIEW;
                  selectedNode = Integer.toString(bars[i].year);
                  bars[i].isHovered = true;
                  highlightedBar = bars[i];
            } else {
                  bars[i].isHovered = false;
                  bars[i].useOriginalColor();
                  bars[i].drawRect();
                  bars[i].drawLabel();
            }
         }
         if (highlightedBar != null) {
             highlightedBar.highLight();
             highlightedBar.drawLabel();
         }
    }
    
    void createAxes(float topSpace, float sideSpace, float bottomSpace){ 
        fill(0);
        stroke(0, 0, 0);
        strokeWeight(2);
        textSize(12);
        line(sideSpace, height - bottomSpace, width - sideSpace + 10, height - bottomSpace);
        float x_xLeft = width - sideSpace/2 - textWidth(xName);
        float x_yMid = height - bottomSpace + 18;
        textAlign(TOP);
        text(xName, x_xLeft, x_yMid);
        
        
        fill(0);
        stroke(0,0,0);
        strokeWeight(2);
        line(sideSpace, topSpace, sideSpace, height - bottomSpace);
        float y_xMid = 3 * sideSpace/4.0;
        float y_yMid = height * .8;
        
        pushMatrix();
        translate(y_xMid, y_yMid);
        rotate(-HALF_PI);
        textSize(12);
        textAlign(BASELINE);
        text(yName, 0, 0);
        popMatrix();
        
    }
    
    void initBars() {
        float topSpace = height * 0.65;
        float sideSpace = width * 0.05;
        float bottomSpace = height * 0.06;
        int numBars = years.length;
        bars = new Bar[numBars];
        float barWidth = (width - (2 * sideSpace))/(numBars);
        int maxDonation = findMaxDonation();
        float ratio = (height - topSpace - bottomSpace)/maxDonation;
        
        createAxes(topSpace, sideSpace, bottomSpace);
        strokeWeight(1);
        for (int i = 0; i < numBars; i++){
            String hoverText = years[i] +": " + totalDonations[i];
            float xPos = (barWidth*i) + sideSpace;
            float yPos = (int)(height - (ratio * totalDonations[i]) - bottomSpace);
            float bHeight = ratio * totalDonations[i];
            bars[i] = new Bar(years[i], xPos, yPos, barWidth, bHeight, barColors[i], hoverText); 
        }
     }
     
    // Determines the largest donation of all sponsors
    int findMaxDonation() {
        int currMax = totalDonations[0];
        
        for (int i = 1; i < totalDonations.length; i++) {
            if (totalDonations[i] > currMax)
                currMax = totalDonations[i];
        }
        
        return currMax;
    }
};