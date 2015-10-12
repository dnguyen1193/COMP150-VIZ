import java.util.*;

String path = "hierarchy3.shf";

Set<Integer> childIDsSet = new LinkedHashSet<Integer>();
Set<Integer> parentIDsSet = new LinkedHashSet<Integer>();
Set<Integer> AllIDsSet = new LinkedHashSet<Integer>();
int numNodes;
Node nodes[];
int rootID; 
int currentRootID;
ArrayList rectangles = new ArrayList();

void setup() {
  size(800, 600);
  frame.setResizable(true);
  frameRate(12);
  parse();
  findRoot();
  computeValues();
  sortNodes();
  //printNodes();
}

void draw(){
  // clear background and rectangle list
  background(255,255,255);
  rectangles.clear();
  
  float CONSTPAD = .015 * (width > height ? width : height);
  Rectangle temp;
  //add root to rectangles list
  temp = new Rectangle(0 + CONSTPAD, 0 + CONSTPAD, width - 2*CONSTPAD, height - 2*CONSTPAD, 
                        "" + currentRootID, currentRootID, currentRootID, 0);
  rectangles.add(temp);  
  //add root's children to rectangle list
  squarify(currentRootID, 0, getValue(currentRootID), width - 4*CONSTPAD, height - 4*CONSTPAD,
           0.0 + 2*CONSTPAD, 0.0 + 2*CONSTPAD, 1);
  //add children of children, etc. to rectangle list
  for (int i = 0; i < rectangles.size(); i++) {
    temp = (Rectangle)rectangles.get(i);
    squarify(temp.getID(), 0, getValue(temp.getID()), temp.getWidth() - 2*CONSTPAD, temp.getHeight() - 2*CONSTPAD, 
             temp.getX() + CONSTPAD, temp.getY() + CONSTPAD, i);
  }
  drawRectangles();
  
  // zoom in and out
  if (mousePressed && mouseButton == RIGHT){
    currentRootID = getParentID(currentRootID);
  }
  else if (mousePressed && mouseButton == LEFT){
    for (int i = rectangles.size() - 1; i >= 0; i--) {
      temp = (Rectangle)rectangles.get(i);
      if (temp.checkClick()){
         currentRootID = temp.getID(); 
         break;
      }
    }
  }
}

// parse data from .shf file, store in data structures
void parse() {
  String[] lines = loadStrings(path);
  //create variables to be used later
  int numLeaves = (int)parseFloat(lines[0]);
  int numRelationships = (int)parseFloat(lines[numLeaves + 1]);
  int leafID;
  int leafValue;
  int parentID;
  int childID;
  numNodes = numRelationships + 1;
  nodes = new Node[numNodes];
  int pos = 0; // counter to figure out where to create node in arr
  
  // Storing all LeafIDs and LeafValues as nodes 
  for (int i = 1; i < numLeaves + 1; i++) {
    String row[] = split(lines[i], " ");
    leafID = (int)parseFloat(row[0]);
    leafValue = (int)parseFloat(row[1]);
    AllIDsSet.add(leafID);
    nodes[pos] = new Node(leafID, leafValue);
    pos++;
  }

  // Storing non-leaves (parents) as nodes
  for (int i = numLeaves + 2; i < numLeaves + 2 + numRelationships; i++) {
    // parse and store information from each line
    String row[] = split(lines[i], " ");
    parentID = (int)parseFloat(row[0]);
    childID = (int)parseFloat(row[1]);
    childIDsSet.add(childID);
    AllIDsSet.add(childID);
    AllIDsSet.add(parentID);
    
    //check if a node for this parent exists already - if not, make it
    if (!parentNodeExists(parentID)) {
      parentIDsSet.add(parentID);
      nodes[pos] = new Node(parentID); 
      nodes[pos].addChild(childID);
      pos++;
    }
    //get parent node
    //add child to list of children
    else {
      for (int j = numLeaves; j < pos; j++) {
        if (nodes[j].id == parentID) {
          nodes[j].addChild(childID);
          break;
        }
      }
    }
  }
  // add parentIDs to child nodes
  for (int i = numLeaves + 2; i < numLeaves + 2 + numRelationships; i++) {
    String row[] = split(lines[i], " ");
    parentID = (int)parseFloat(row[0]);
    childID = (int)parseFloat(row[1]);
    int childIndex = getNodeIndex(childID);
    nodes[childIndex].parentID = parentID;
  }
}

// helper function for adding children
boolean parentNodeExists(int nid) {
  return parentIDsSet.contains(nid);
}

// find root node (the one with no parent)
void findRoot() {
  for (Integer id : AllIDsSet) {
    if (!childIDsSet.contains(id)) {
      rootID = id;
    }
  }
  currentRootID = rootID;
}

// debugging function to print all nodes
void printNodes() {
  for (int i = 0; i < nodes.length; i++) {
    nodes[i].printNode();
  }
}

// calls function in node class to recursively compute values of all nodes
void computeValues(){
  int index = getNodeIndex(rootID);
  nodes[index].computeValue();
}


// sort children of all nodes by value - necessary for squarifying
void sortNodes(){
  int index = getNodeIndex(rootID);
  nodes[index].sortChildren();
}

// creates a tool tip displaying the ID and value of the node being highlighted
void addToolTip(Rectangle r){
  String toolTipString = "ID: " + r.getID() + "; Value: " + getValue(r.getID());
  float toolTipLen = textWidth(toolTipString);
  fill(255, 255, 255);
  noStroke();
  rect(mouseX + 5, mouseY + 5, toolTipLen + 10, toolTipLen/4);
  fill(0);
  text(toolTipString, mouseX + 8.5, mouseY + 7.5);
  stroke(1);
}

// squarify
// recursively places optimal number of nodes to maximize square-ness
void squarify(int currRoot, int childIndex, int totalValue, float cWidth, float cHeight, float cx, float cy, int nrec){
  int index = getNodeIndex(currRoot);
  if (childIndex >= (int)nodes[index].childIDs.size()){
    // if out of bounds, return
    return;
  }
  int largestID = (int)nodes[index].childIDs.get(childIndex);    //processing 2.x compatible?
  int largest = getValue(largestID);
  float canvas_area = cWidth * cHeight;
  int total_value = 0;
  float VA_ratio = ((float)canvas_area)/((float)totalValue);
  float short_side = (cWidth < cHeight ? cWidth : cHeight);
  String short_side_str = (cWidth < cHeight ? "width" : "height");
  float rect_area = largest * VA_ratio;
  float rect_long_side = rect_area/short_side;
  float c1_ratio = rect_long_side/short_side;
  float newRatio = c1_ratio;
  float prevRatio = 2;
  int childrenAdded = 1;
  float totalAreaAdded = rect_area;
  float prevCX = cx;
  float prevCY = cy;
  // checks how far away the aspect ratio is from 1 (being a perfect square)
  while(abs(newRatio - 1) < abs(prevRatio - 1) && (childIndex + childrenAdded) < (int)nodes[index].childIDs.size()){
     //try one more rectangle
     prevRatio = newRatio;
     int newValue = getValue((int)nodes[index].childIDs.get(childrenAdded + childIndex));
     float newArea = newValue * VA_ratio;
     float newLongSide = (totalAreaAdded + newArea)/short_side;
     float newWidth = newArea/newLongSide;
     newRatio = newLongSide/newWidth;
     // if aspect ratio of new rectangle is better than before, add it
     if (abs(newRatio - 1) < abs(prevRatio - 1)){
         totalAreaAdded += newArea;
         childrenAdded++;
     }
  }
  float rect_short_side = 0;
  int currChildID;
  int currChildValue;
  for (int i = childIndex; (i < childIndex + childrenAdded); i++){
    currChildID = (int)nodes[index].childIDs.get(i);
    rect_long_side = totalAreaAdded/short_side;
    currChildValue = getValue(currChildID);
    total_value += currChildValue;
    rect_area = currChildValue * VA_ratio;
    rect_short_side = rect_area/rect_long_side;

    Rectangle temp;
    // check which side is the short side
    // add calculated rectangle to list, to be drawn later
    if (short_side_str == "width") {
      temp = new Rectangle(cx, cy, rect_short_side, rect_long_side, 
                           "" + currChildID, currChildID, currRoot, nrec);
      rectangles.add(temp);
      cx += rect_short_side;
    } else {
      temp = new Rectangle(cx, cy, rect_long_side, rect_short_side, 
                           "" + currChildID, currChildID, currRoot, nrec);
      rectangles.add(temp);
      cy += rect_short_side;
    }
  }
  //recurse on rest of canvas
  if (short_side_str == "width") {
    squarify(currRoot, childIndex + childrenAdded, totalValue - total_value, 
             cWidth, cHeight - rect_long_side, prevCX, prevCY + rect_long_side, nrec);
  } else {
    squarify(currRoot, childIndex + childrenAdded, totalValue - total_value, 
             cWidth - rect_long_side, cHeight, prevCX + rect_long_side, prevCY, nrec);
  }
}

// draw calculated rectangles onto canvas - called every draw loop
void drawRectangles() {
  Rectangle temp;
  
  //draw children
  for (int i = 0; i < rectangles.size(); i++) {
    temp = (Rectangle)rectangles.get(i);
    temp.makeRect();
  }
 for (int i = rectangles.size() - 1; i >= 0; i--) {
    temp = (Rectangle)rectangles.get(i);
    if (temp.checkHover()){
      Rectangle temp2;
      for (int j = i + 1; j < rectangles.size(); j++) {
        temp2 = (Rectangle)rectangles.get(j);
        temp2.makeRect();
      }
      addToolTip(temp);
      return;
    }
  }
}

/* ------------------- */
/* getters and setters */
/* ------------------- */

//getValue(ID)
// given ID, get value of node
int getValue(int ID){
  int index = getNodeIndex(ID);
  if (index != -1)
    return nodes[index].value;
  else
    return -1;
}

//getNodeIndex(ID)
// given ID, get index of node in nodes[] 
int getNodeIndex(int nid) {
  for (int i = 0; i < nodes.length; i++) {
    if (nodes[i].id == nid)
      return i;
  }
  return -1;
}

//getParentID(ID)
//given ID, get ID of parent node
int getParentID(int cid) {
  if (cid == rootID){
    return rootID;
  }
  int index = getNodeIndex(cid);
  return nodes[index].parentID;    
}