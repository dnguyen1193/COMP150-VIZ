class SqTreeMap{
    Set<String> childIDsSet = new LinkedHashSet<String>();
    Set<String> parentIDsSet = new LinkedHashSet<String>();
    Set<String> AllIDsSet = new LinkedHashSet<String>();
    int numNodes;
    Node nodes[];
    Node rootNode;
    String rootID; 
    String currentRootID;
    ArrayList rectangles = new ArrayList();
    int pos = 0;
    
    SqTreeMap() { }
    
    void initializeSTreeMap() {
        rootNode = new Node("SCHOOL", 0);
        rootID = rootNode.id;
        AllIDsSet.add(rootID);
        parentIDsSet.add(rootID);
        
        int numRelationships = getNumRelationships();
        // add one for the root node
        numNodes = numRelationships + 1;
        nodes = new Node[numNodes];
        nodes[pos++] = rootNode;
        rootID = rootNode.id;
        currentRootID = rootNode.id;
        
        populateLeafNodes();
        populateParentNodes();
    }
    
    int getNumRelationships() {
        return controller.departmentList.size() + controller.disciplineList.size();
    }
    
    void populateLeafNodes() {
        String leafID;
        int leafValue;
        Set set = controller.departmentList.entrySet();
        Iterator iterator = set.iterator();
        while(iterator.hasNext()){
            Map.Entry entry = (Map.Entry)iterator.next();
            Department department = (Department)entry.getValue();
            leafID = department.name;
            leafValue = department.totalFunding;
            AllIDsSet.add(leafID);
            nodes[pos] = new Node(leafID, leafValue);
            nodes[pos].depth = 2;    // set depth of 2 since its a leaf  node
            nodes[pos].parentID = department.parentDiscipline.name;
            pos++;
        }
    }
    
    void populateParentNodes() {
        String parentID;
        int parentValue;
        String childID;
        Set set = controller.disciplineList.entrySet();
        Iterator iterator = set.iterator();
        while(iterator.hasNext()){
            Map.Entry entry = (Map.Entry)iterator.next();
            Discipline discipline = (Discipline)entry.getValue();
            parentID = discipline.name;
            parentValue = discipline.totalFunding;
            nodes[pos] = new Node(parentID, parentValue);
            nodes[pos].depth = 1;  // set internal nodes (i.e. dept nodes) to depth of 1
            nodes[pos].parentID = rootNode.id;
            ArrayList<String> parentsChildren = discipline.departmentNames;
            for (int i = 0; i < parentsChildren.size(); i++) {
                childID = parentsChildren.get(i);
                childIDsSet.add(childID);
                AllIDsSet.add(childID);
                nodes[pos].childIDs.add(childID);
            }
            pos++;
            AllIDsSet.add(parentID);
            childIDsSet.add(parentID);
            
            rootNode.childIDs.add(parentID);
            rootNode.value += discipline.totalFunding;
        }
    }
    
    int getValue(String ID){
        int index = getNodeIndex(ID);
        if (index != -1)
            return nodes[index].value;
        else
            return -1;
    }
    
    int getNodeIndex(String nid) {
        for (int i = 0; i < nodes.length; i++) {
            if (nodes[i].id == nid)
                return i;
        }
        return -1;
    }
    
    //getParentID(ID)
    //given ID, get ID of parent node
    String getParentID(String cid) {
        if (cid == rootID){
          return rootID;
        }
        int index = getNodeIndex(cid);
        return nodes[index].parentID;    
    }
    
    // sort children of all nodes by value - necessary for squarifying
    void sortNodes(){
      int index = getNodeIndex(rootID);
      nodes[index].sortChildren();
    }
    
    // debugging function to print all nodes
    void printNodes() {
         for (int i = 0; i < nodes.length; i++) {
            nodes[i].printNode();
          }
    }
  
    // squarify
    // recursively places optimal number of nodes to maximize square-ness
    void squarify(String currRoot, int childIndex, int totalValue, float cWidth, float cHeight, float cx, float cy, int nrec){
      //println(currRoot);
     int index = getNodeIndex(currRoot);
      
      if (childIndex >= (int)nodes[index].childIDs.size()){
        // if out of bounds, return
        return;
      }
      String largestID = (String)nodes[index].childIDs.get(childIndex);
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
         int newValue = getValue((String)nodes[index].childIDs.get(childrenAdded + childIndex));
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
      String currChildID;
      int currChildValue;
      for (int i = childIndex; (i < childIndex + childrenAdded); i++){
        currChildID = (String)nodes[index].childIDs.get(i);
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
                                "" + currChildID, currChildID, currRoot, nodes[index].depth + 1);
                               //"" + currChildID, currChildID, currRoot, nrec);
          rectangles.add(temp);
          cx += rect_short_side;
        } else {
          temp = new Rectangle(cx, cy, rect_long_side, rect_short_side,
                               "" + currChildID, currChildID, currRoot, nodes[index].depth + 1);
                               //"" + currChildID, currChildID, currRoot, nrec);
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
      
      void drawSMap() {
          rectangles.clear();
          
          float CONSTPAD = .01 * (sqTreeWidth > sqTreeHeight ? sqTreeWidth : sqTreeHeight);
          Rectangle temp;
          //add root to rectangles list
          temp = new Rectangle(0 + CONSTPAD, 0 + CONSTPAD, sqTreeWidth - 2*CONSTPAD, sqTreeHeight - 2*CONSTPAD, 
                              "" + currentRootID, currentRootID, currentRootID, 0);
          rectangles.add(temp);  
          squarify(currentRootID, 0, getValue(currentRootID), sqTreeWidth - 4*CONSTPAD, sqTreeHeight - 4*CONSTPAD,
               0.0 + 2*CONSTPAD, 0.0 + 2*CONSTPAD, 1);
          for (int i = 0; i < rectangles.size(); i++) {
            temp = (Rectangle)rectangles.get(i);
            squarify(temp.getID(), 0, getValue(temp.getID()), temp.getWidth() - 2*CONSTPAD, temp.getHeight() - 2*CONSTPAD, 
                     temp.getX() + CONSTPAD, temp.getY() + CONSTPAD, i);
          }
          drawRectangles();
    }
    
    void addToolTip(Rectangle r){
        textSize(10);
        String toolTipString = "ID: " + r.getID() + "; Value: " + getValue(r.getID());
        float toolTipLen = textWidth(toolTipString);
        fill(255);
        noStroke();
        if(mouseX + toolTipLen > width*sqMapPercentX){
            rect(mouseX - 15 - toolTipLen, mouseY + 5, toolTipLen + 10, 18);
            fill(0);
            textAlign(RIGHT, TOP);
            text(toolTipString, mouseX - 8.5, mouseY + 7.5);
            stroke(1);
        } else {
            rect(mouseX + 5, mouseY + 5, toolTipLen + 10, 18);
            fill(0);
            textAlign(LEFT, TOP);
            text(toolTipString, mouseX + 8.5, mouseY + 7.5);
            stroke(1);
        }
        
    }
}