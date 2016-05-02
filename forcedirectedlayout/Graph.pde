class Graph {
    float minNodeRadius = 6.0;
    float massToRadiusRatio;
  
    Node[] allNodes;
    Edge[] allEdges;
    float totalEnergy;
    int maxLength;
    int minLength;
    int maxMass;
    int minMass;
    int numNodes;
    int numEdges;
    
    // constructor 
    Graph() {
        allNodes = null;
        allEdges = null;
        totalEnergy = 0.0;
        maxLength = 0;
        minLength = 0;
        maxMass = -1;
        minMass = -1;
        numNodes = 0;
        numEdges = 0;
        massToRadiusRatio = 0.0;
    }
    
    void parseData(String file) {
        String[] lines = loadStrings(file);
        numNodes = parseInt(lines[0]);
        numEdges = parseInt(lines[numNodes + 1]);
        
        allNodes = new Node[numNodes];
        allEdges = new Edge[numEdges];
         
        setNodes(lines);
        setNodeDiameters();
        setEdges(lines);
    }
    
    void drawGraph(){
        // draw edges 1ist first so they show up behind nodes
        for(int j=0; j < allEdges.length; j++){
            allEdges[j].drawEdge();
        }
        
        // draw each node and then sum up the forces exerted on node i
        // from its neighbors (e.g. Hookes law & coulombs law)
        calcTotalEnergy();
        //println("total energy: " + totalEnergy + " energyThreshold: " + energyThreshold);
        if(totalEnergy > energyThreshold || totalEnergy == 0.0){
            for(int i=0; i < allNodes.length; i++){ //<>//
                allNodes[i].calcHookesLaw();
                allNodes[i].calcCoulombsLaw(allNodes);
            }
            
            // calculate accelerations and velocities of the nodes (applying damping)
            // update the nodes' positions
            for(int i=0; i < allNodes.length; i++){
                allNodes[i].calcDamping();
                allNodes[i].calcAcceleration();
                allNodes[i].calcVelocity();           
                allNodes[i].calcPosition();  
                allNodes[i].drawNode();
            }
        }else{
            for(int i=0; i < allNodes.length; i++){
                allNodes[i].drawNode();
            }
        }  
        
        // Show font color for 'Total Energy' system data
        if(isSpaceMode){     
            textFont(boldFont);
            fill(hoverTextSpaceColor);
        }else{
            fill(0);
        }
        // Show system 'Total Energy'
        text("Total Energy: " + totalEnergy, 20, 20);
    }
    
    void calcTotalEnergy(){
        float kineticEnergy;
        float velocity;
        int mass;
        float xVel;
        float yVel;
       
        // reset total KE
        totalEnergy = 0.0;
        for(int i=0; i < allNodes.length; i++){
             mass = allNodes[i].mass;
             xVel = allNodes[i].velocity.x;
             yVel = allNodes[i].velocity.y;
             velocity = (float)Math.sqrt((xVel * xVel) + (yVel * yVel));
             kineticEnergy = 0.5*mass*velocity*velocity;
             totalEnergy += kineticEnergy;
        }
    }
    
    int checkNodeDrag(){
        for(int i=0; i < allNodes.length; i++){
            if(allNodes[i].checkHover()) {
                // reset totalEnergy so it springs will work again
                totalEnergy = 0.0;
                return i;
            }     
        }
        // return -1 if it no node is being dragged specifically
        return -1;
    }
    
    void dragNode(int nID) {
        graph.allNodes[nID].pos = new PVector(mouseX, mouseY);
    }
    
    void resetNodePositions(){
        int xPos, yPos;
        for(int i=0; i < allNodes.length; i++){
            xPos = (int)random(0, w);
            yPos = (int)random(0, h);
            allNodes[i].pos = new PVector(xPos, yPos);
        }
        // reset energy to 0.0 so it will kick off springs & coulombs law again
        totalEnergy = 0.0;
    }
    
    /* Initialize all nodes & their values */
    void setNodes(String[] lines) {
        int nID, nMass;
        for (int i = 1; i <= numNodes; i++) {
            String[] row = split(lines[i], ",");
            if(row.length == 2){
                nID = parseInt(row[0]);
                nMass = parseInt(row[1]);
                allNodes[i - 1] = new Node(nID, nMass);
                // set it to the first node mass, initially
                if (i == 1)
                    minMass = nMass;
                if (nMass < minMass)
                    minMass = nMass;
                    
            } else{
                println("line ", i, " is not formatted properly check "); 
            }
        } 
    }
    
    void setNodeDiameters() {
        float minRad = (float)Math.sqrt(minMass/PI);
        massToRadiusRatio = minNodeRadius/minRad;
        float massRadius;
        float nodeRadius;
        int nMass;
        
        for (int i = 0; i < allNodes.length; i++) {
            nMass = allNodes[i].getMass();
            massRadius = (float)Math.sqrt(nMass/PI);
            nodeRadius = massToRadiusRatio * massRadius;
            allNodes[i].setDiameter(2 * nodeRadius);
        }
    }
    
    /* Set all the edges */
    void setEdges(String[] lines) {
        int eStart, eEnd, eLength;
        Node startNode, endNode;
        Edge edge;
        
        for (int i = numNodes + 2; i < lines.length; i++) {
            String[] row = split(lines[i], ",");
            if(row.length == 3){
                eStart = parseInt(row[0]);
                eEnd = parseInt(row[1]);
                eLength = parseInt(row[2]);
                startNode = getNodeById(eStart);
                endNode = getNodeById(eEnd);
                
                // Add edge to master allEdges is as well as each nodes edge list
                edge = new Edge(startNode, endNode, eLength);
                allEdges[i - (numNodes +2)] = edge;
                startNode.edges.add(edge);
                endNode.edges.add(edge);         
            } else {
                println("line ", i, " is not formatted properly so can't set edge. " +
                    "Check file "); 
            }
        } 
    }
    
    Node getNodeById(int nodeId) {
        Node  myNode = null;
        for(int i =0; i < allNodes.length; i++){
            if(allNodes[i].id == nodeId) {
                myNode = allNodes[i];
                break; 
            }
        }
        return myNode;
    }
    
    void printEdges() {
        println(allEdges.length + " edges");
        for(int i=0; i < allEdges.length; i++){
            println("\t" + i + ", eStart: " + allEdges[i].startNode.id + ", eEnd: " 
                + allEdges[i].endNode.id + ", eLength: " + allEdges[i].edgeLength);
        }
    }
    
    void printNodeMass() {
        println(allNodes.length + " nodes " );
        for(int i= 0; i < allNodes.length; i++){
            println("\t nID: " + allNodes[i].id + ", nMass: " + allNodes[i].mass);     
        } 
    }
    
    void printNodeEdges() {
        for(int i=0; i < allNodes.length; i++){
            println("nID: ", allNodes[i].id, " has ", allNodes[i].edges.size(), " edges");
            ArrayList<Edge> nodeEdges = allNodes[i].edges;
            for(int j=0; j < nodeEdges.size(); j++){
                println("\t" + j+ ": eStart: " + nodeEdges.get(j).startNode.id + ", eEnd: " +
                    nodeEdges.get(j).endNode.id + ", eLength: " + nodeEdges.get(j).edgeLength);
            }
        }
    }
    
}