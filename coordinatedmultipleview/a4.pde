Table data = null;
String file = "soe-funding.csv";
String[] headers;
int w = 800;
int h = 600;

float sqMapPercentX = .5;
float sqMapPercentY = .6;

Controller controller = new Controller();
float sqTreeWidth, sqTreeHeight;
String sourceView = "";
String selectedNode = "";
final String SMAP_VIEW = "STreeMap";
final String BUBBLE_VIEW = "Bubble";
final String BAR_VIEW = "Bar";

void setup(){
    size(1200,800);
    background(255);
    surface.setResizable(true);
    sqTreeWidth = width * sqMapPercentX;
    sqTreeHeight = height * sqMapPercentY;
    
    surface.setTitle("Coordinated Multiple View");
    controller.parseData();
    controller.setSqTreeMapData();
    controller.setBubbleData();
    controller.setBarChartData();
    
    //controller.printAllDisciplineInfo();
    //controller.printNodes();
    //controller.sMap.printAllNodeInfo();
    //controller.getTotalFundingByYear(2007);
}

void draw(){
    background(125);
    sqTreeWidth = width * sqMapPercentX;
    sqTreeHeight = height * sqMapPercentY;
    if(!isStillHovering()){
        selectedNode = "";
        sourceView = "";
    }
    
    controller.drawSMap();
    controller.drawBubbleChart();
    controller.drawBarChart();
    
    if(sourceView == BAR_VIEW){
        controller.drawPartialYearBubbles();
        controller.drawPartialYearRects();
    } else if (sourceView == BUBBLE_VIEW) {
        controller.drawPartialSponsorBars();
        controller.drawPartialSponsorRects();
    } else if (sourceView == SMAP_VIEW) {
        controller.drawPartialBarsFromDept();
        controller.drawPartialBubblesFromDept();
    }
}

boolean isStillHovering(){
    boolean isHovering = false;
    String hoveredView = getHoveredView();
    if(hoveredView == SMAP_VIEW){
        Rectangle myRect;
        for(int i=0; i < controller.sTreeMap.rectangles.size(); i++){
            myRect = (Rectangle)controller.sTreeMap.rectangles.get(i);
            if(myRect.rID == selectedNode){
                isHovering = myRect.checkHover();
                break;
            }
        }
    } else if(hoveredView == BUBBLE_VIEW){
        Bubble myBubble;
        for(int i=0; i< controller.bubbleChart.bubbles.length; i++){
            myBubble = controller.bubbleChart.bubbles[i];
            if(myBubble.label == selectedNode){
                isHovering = myBubble.isHovered;
                break;
            }
        }
    } else if(hoveredView == BAR_VIEW){
        Bar bar;
        for(int i=0; i < controller.barChart.bars.length; i++){
            bar = controller.barChart.bars[i];
            if(bar.year == parseInt(selectedNode)){
                isHovering = bar.isHovered;
                break;
            }
        }
    } else{
        println("No clue what the hovered view is");
    }
    return isHovering;
}

String getHoveredView(){
    String hoverView = "";
    if(mouseX <= (width*sqMapPercentX) && mouseY <= (height * sqMapPercentY)){
        hoverView = SMAP_VIEW;
    }else if(mouseX > (width*sqMapPercentX) && mouseY <= (height * sqMapPercentY)){
        hoverView = BUBBLE_VIEW;
    }else if(mouseY > (height*sqMapPercentY)){
        hoverView = BAR_VIEW;
    }else{
        println("Where are you?!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
    }
    return hoverView;
}

//SQUARIFIED TREE MAP - zoom in & out
void mousePressed() {
  Rectangle temp;
  if (mouseButton == RIGHT) {
      controller.sTreeMap.currentRootID = controller.sTreeMap.getParentID(controller.sTreeMap.currentRootID);
  } else if (mouseButton == LEFT) {
      for (int i = controller.sTreeMap.rectangles.size() - 1; i >= 0; i--) {
          temp = (Rectangle)controller.sTreeMap.rectangles.get(i);
          if (temp.checkClick()){
             controller.sTreeMap.currentRootID = temp.getID(); 
             break;
          }
      }
  }
}

void keyPressed() {
  // when any key is pressed, propell bubbles outward to change the composition
  for (int i = 0; i < controller.bubbleChart.bubbles.length; i++) {
    controller.bubbleChart.bubbles[i].propell();
  }
}