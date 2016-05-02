import java.util.Arrays;
import java.util.Iterator;
import java.util.Map;
import java.util.Set;
import java.util.*;

class Controller{
    HashMap<String, Discipline> disciplineList = new HashMap<String, Discipline>();
    HashMap<String, Department> departmentList = new HashMap<String, Department>();
    HashMap<String, Sponsor> sponsorList = new HashMap<String, Sponsor>();
    HashMap<Integer, ArrayList<Donation>> donationsByYear = new HashMap<Integer, ArrayList<Donation>>();
    
    // Bubble Chart Variables
    BubbleChart bubbleChart = new BubbleChart();
    int totalSponsorDonations = 0;
    int rowCount = 0;
    
    // Squarified Tree Map Variables
    SqTreeMap sTreeMap = new SqTreeMap();
    
    // Bar Chart Variables
    BarChart barChart = new BarChart();
    
    Controller(){
      
    }
    
    void parseData() {
        data = loadTable(file, "header");
        headers = data.getColumnTitles();
        
        rowCount = data.getRowCount();

        Discipline tmpDiscipline;
        Department tmpDept;
        Sponsor tmpSponsor;
        for (TableRow row: data.rows()){
            // Add discipline, department, then sponsors
            tmpDiscipline = createDiscipline(row);
            tmpDept = createDepartment(row, tmpDiscipline);
            tmpSponsor = createSponsor(row, tmpDiscipline, tmpDept);
            createDonation(row, tmpDiscipline, tmpDept, tmpSponsor);
        }
        
        //printRowsGivenDiscipline("Biochemistry");
    }
    
    // Creates discipline
    Discipline createDiscipline(TableRow row){
        String dName = row.getString(headers[0]);
        Discipline d = (Discipline)disciplineList.get(dName);
        if( d == null) {
            d = new Discipline(dName);
            disciplineList.put(dName, d);
        }
        d.addFunding(row.getInt(headers[4]));
        
        return d;
    }
    
    // Creates department and links it to discipline
    Department createDepartment(TableRow row, Discipline discipline){
        String deptName = row.getString(headers[1]);
        Department myDept = (Department)departmentList.get(deptName);
        if(myDept == null){
            // create department
            myDept = new Department(deptName, discipline);
            departmentList.put(deptName, myDept);
        }
        // add myDept to discipline (discipline will only add it if it wasn't already added)
        discipline.addDepartment(myDept);
        myDept.addFunding(row.getInt(headers[4]));
        return myDept;
    }
    
    Donation createDonation(TableRow row, Discipline discipline, Department department, Sponsor sponsor){
        int year = row.getInt(headers[3]);
        int funding = row.getInt(headers[4]);
        totalSponsorDonations += funding;   // to keep track of how much was donated
        Donation myDonation = new Donation(sponsor, department, discipline, year, funding);
           
        // Add this donation to the sponsor's hashmap
        sponsor.addDonation(myDonation);
       
        // Add this donation to the donationsByYear hashmap
        ArrayList<Donation> tmpDonations = donationsByYear.get(year);
        if(tmpDonations == null){
            tmpDonations = new ArrayList<Donation>();
        }
        tmpDonations.add(myDonation);
        donationsByYear.put(year, tmpDonations);
        
        return myDonation;
    }
    
    Sponsor createSponsor(TableRow row, Discipline discipline, Department dept){
        String sponsorName = row.getString(headers[2]);
        Sponsor mySponsor = (Sponsor)sponsorList.get(sponsorName);
        if(mySponsor == null){
            mySponsor = new Sponsor(sponsorName);
            sponsorList.put(sponsorName, mySponsor);
        }
        // add sponsor to department list, discipline lists & update its total donations
        mySponsor.totalDonations += row.getInt(headers[4]);
        discipline.addSponsor(mySponsor);
        dept.addSponsor(mySponsor);
        
        return mySponsor;
    }
    
    int getTotalFundingByYear(int donationYear){
        int totalAmount = 0;
        ArrayList<Donation> donations = donationsByYear.get(donationYear);
        if(donations == null){
            println("No donations were given in ", donationYear);
        }else{
            // iterate through donations and print them
            Iterator itr = donations.iterator();
            Donation tmpD;
            while(itr.hasNext()){
                tmpD = (Donation)itr.next();
                totalAmount += tmpD.donation;            
            }
        }
        return totalAmount;
    }
    
    int getDonationsToDepartmentInYear(String name, int year){
        int amount=0;
        ArrayList<Donation> donations = donationsByYear.get(year);
        if(donations != null){
            Donation tmpDonation;
            for(int i=0; i < donations.size(); i++){
                 tmpDonation = donations.get(i);
                 if(tmpDonation.to.name == name){
                     amount += tmpDonation.donation; 
                 }
            }
        }
        return amount;
    }
    
    int getDonationsToDisciplineInYear(String name, int year){
        int amount=0;
        ArrayList<Donation> donations = donationsByYear.get(year);
        if(donations != null){
            Donation tmpDonation;
            for(int i=0; i < donations.size(); i++){
                 tmpDonation = donations.get(i);
                 if(tmpDonation.discipline.name == name){
                     amount += tmpDonation.donation; 
                 }
            }
        }
        return amount;
    }
    
    void printDonationsByYear(int donationYear){
        ArrayList<Donation> donations = donationsByYear.get(donationYear);
        if(donations == null){
            println("No donations were given in ", donationYear);
        }else{
            // iterate through donations and print them
            Iterator itr = donations.iterator();
            println("Iterating through " + donations.size() + " donations for year", donationYear);
            Donation tmpD;
            while(itr.hasNext()){
                tmpD = (Donation)itr.next();
                println("Donation from: " + tmpD.from.name + " to: " + tmpD.to.name +
                    " discipline: " + tmpD.discipline.name +" in the amount: " + tmpD.donation +
                    " year: " + tmpD.year);
                
            }
        }
    }
    
    void printAllDisciplineInfo(){
        println("********Printing all Disclipline info");
        Set set = disciplineList.entrySet();
        Iterator iterator = set.iterator();
        while(iterator.hasNext()){
            Map.Entry entry = (Map.Entry)iterator.next();
            Discipline discipline = (Discipline)entry.getValue();
            println("Discipline: " + discipline.name + " Total: " + discipline.totalFunding + 
                " Department count: " + discipline.departments.size()+ " Sponsor Count: " + discipline.sponsors.size());
            
            ArrayList<String> dNames = discipline.departmentNames;
            println("\t*****Departments for " + discipline.name + "********************");
            for(int i=0; i<dNames.size(); i++){
                println("\t\tDepartment: " + dNames.get(i) + ", "); 
            }
            
            ArrayList<String> sponsors = discipline.sponsorNames;
            println("\t*****Sponsors for " + discipline.name + "********************");
            for(int i=0; i<sponsors.size(); i++){
                println("\t\tSponsor: " + sponsors.get(i) + ", "); 
            }  
        }   
    }
    
    void printRowsGivenDiscipline(String disciplineName){
        int i = 0;
        for (TableRow row: data.findRows(disciplineName,headers[0])){
             println("Discipline: " + row.getString(headers[0]) + 
             " Department: " + row.getString(headers[1]) + 
             " Sponsor: " + row.getString(headers[2]) + 
             " Year: " + row.getString(headers[3]) +
             " Total: " + row.getString(headers[4]));
             i++;
        }
        println("There are " + i + " items with Biochemistry discipline "); 
    }
    
    /************************* SQUARIFIED TREE MAP *************************/
    void setSqTreeMapData() {
        sTreeMap.initializeSTreeMap();
        sTreeMap.sortNodes();
    }
    
    void drawSMap() {
        sTreeMap.drawSMap();
    }
    
// When a user hovers over the bars in the bar chart.  It will highlight the 
    // appropriate rectangles in sq tree map
    void drawPartialSponsorRects(){
        Rectangle myRect;
        Sponsor mySponsor = sponsorList.get(selectedNode);
        
        //draw children
        float rectValue;
        String rectLabel;
        stroke(1);
        fill(204,232,251,75);
        for (int i = 0; i < sTreeMap.rectangles.size(); i++) {
            myRect = (Rectangle)sTreeMap.rectangles.get(i);
            rectLabel = myRect.rID;
            rectValue = (float)sTreeMap.getValue(rectLabel);
            float sponsorDonation = mySponsor.getDepartmentDonation(rectLabel);
            float ratio = sponsorDonation/rectValue;
            myRect.drawPartialRect(ratio);
        } 
    }
    
    // Draws recangles in sq tree map when a user hovers over the years in the bubble chart
    void drawPartialYearRects(){
        int year = parseInt(selectedNode);
        ArrayList<Donation> selectedYearDonations = donationsByYear.get(year);
        if (selectedYearDonations == null) {
            println("There were no donations for that year");
        } else {
            Rectangle myRect;
            
            float rectValue;
            String rectLabel;
            stroke(1);
            fill(204,232,251,75);
            
            for (int i = 0; i < sTreeMap.rectangles.size(); i++) {
                myRect = (Rectangle)sTreeMap.rectangles.get(i);
                rectLabel = myRect.rID;
                rectValue = (float)sTreeMap.getValue(rectLabel);
                int yearTotalDonations = findDonation(rectLabel, selectedYearDonations);
                if (yearTotalDonations != 0) {
                    float ratio = (float)yearTotalDonations/rectValue;
                    myRect.drawPartialRect(ratio);
                }
            }
        }
    }
    
    /**** HELPER FUNCTION ****/
    int findDonation(String departmentName, ArrayList<Donation> yearDonationList) {
        int total = 0;
        Donation currDonation = null;
        for(int i = 0; i < yearDonationList.size(); i++) {
            currDonation = yearDonationList.get(i);
            if (currDonation.to.name == departmentName) {
                total += currDonation.donation;
            }
        }
        return total;
    }
    
    /**************************** BAR CHART *********************************/
    void setBarChartData() {
        barChart.initializeData();  
        barChart.initBars();
    }
    
    void drawBarChart() {
        barChart.drawBarChart();
    }
    
    // Highlights the bars when a user hovers over the year
    void drawPartialSponsorBars() {
        Sponsor selectedSponsor = sponsorList.get(selectedNode);
        if (selectedSponsor != null) {
            int year;
            for(int i = 0; i < barChart.bars.length; i++) {
                year = barChart.bars[i].year;
                Object _val = selectedSponsor.totalDonationPerYear.get(year);
                if (_val != null) {
                    // only draw partial bubble if a sponsor donated in a particular year
                    float sponsorFundingThatYear = ((Integer)_val).floatValue();
                    float totalFundingThatYear = (float)getTotalFundingByYear(year);
                    float ratio = sponsorFundingThatYear/totalFundingThatYear;
                    // always start from angle 0 and move forward
                    barChart.bars[i].drawPartialRect(ratio);
                }
            }
        }
        
    }
    
    // When a rect is highlighted in Sq Tree Map, it highlights the portions of the 
    // corresponding bars of years in which the department/discipline was donated to.    
    void drawPartialBarsFromDept() {
        Department tempDept;
        Discipline tempDisc;
        int year;
        
        if (departmentList.get(selectedNode) != null) {
            tempDept = (Department)departmentList.get(selectedNode);
            for(int i = 0; i < barChart.bars.length; i++) {
                year = barChart.bars[i].year;
                float totalDonation = getDonationsToDepartmentInYear(tempDept.name, year);
                if (totalDonation != 0) {
                    float ratio = totalDonation/getTotalFundingByYear(year);
                    barChart.bars[i].drawPartialRect(ratio);
                }
            }
        } else if (disciplineList.get(selectedNode) != null) {
            tempDisc = (Discipline)disciplineList.get(selectedNode);
            for(int i = 0; i < barChart.bars.length; i++) {
                year = barChart.bars[i].year;
                float totalDonation = getDonationsToDisciplineInYear(tempDisc.name, year);
                if (totalDonation != 0) {
                    float ratio = totalDonation/getTotalFundingByYear(year);
                    barChart.bars[i].drawPartialRect(ratio);
                }
            }
        } else if (selectedNode == "SCHOOL") {
            for(int i = 0; i < barChart.bars.length; i++) {
                barChart.bars[i].drawPartialRect(1.0);
            }
        } else {
            println("Can't find the selected node in either dept or disc hashmaps.\nSelectedNode is: " + selectedNode);
        }
    }
    
    /******************************BUBBLE CHART ****************************/
    void setBubbleData(){
        bubbleChart.initializeData();   
    }
    
    void drawBubbleChart() {
        bubbleChart.drawBubbleChart();
    }

    // Draws the partial highlighed bubbles around the year.  Called when a sponsor
    // is highlighed in the bar chart.
    void drawPartialYearBubbles(){
        int year = parseInt(selectedNode);
        println("year: " + year);
        ArrayList<Donation> selectedYearDonations = donationsByYear.get(year);
        if (selectedYearDonations != null) {
            for (int i = 0; i < bubbleChart.bubbles.length; i++) {
                String sponsorName = bubbleChart.bubbles[i].label;
                Sponsor currSponsor = sponsorList.get(sponsorName);
                Object _val = currSponsor.totalDonationPerYear.get(year);
                if (_val != null) {
                    int selectedYearDonation = (Integer)_val;
                    int totalDonations = currSponsor.totalDonations;
                    float ratio = (float)selectedYearDonation/totalDonations;
                    bubbleChart.bubbles[i].drawPartialBubble(ratio);
                }
            }
        }          
    }
    
    void drawPartialBubblesFromDept() {
        Department tempDept;
        Discipline tempDisc;
        String sponsorName;
        if (departmentList.get(selectedNode) != null){
            tempDept = (Department)departmentList.get(selectedNode);
            for(int i=0; i< bubbleChart.bubbles.length; i++){
                sponsorName = bubbleChart.bubbles[i].label;
                Sponsor currSponsor = (Sponsor)tempDept.sponsors.get(sponsorName);
                if (currSponsor != null) {
                    float donationsToDept = currSponsor.getDepartmentDonation(tempDept.name);
                    float totalDonations = currSponsor.totalDonations;
                    float ratio = donationsToDept/totalDonations;
                    bubbleChart.bubbles[i].drawPartialBubble(ratio);
                }
            }
            
        } else if (disciplineList.get(selectedNode)!=null){
            tempDisc = (Discipline)disciplineList.get(selectedNode);
            for(int i=0; i< bubbleChart.bubbles.length; i++){
                sponsorName = bubbleChart.bubbles[i].label;
                Sponsor currSponsor = (Sponsor)tempDisc.sponsors.get(sponsorName);
                if (currSponsor != null) {
                    float donationsFromSponsor = (float)currSponsor.donationsToDiscipline.get(tempDisc.name);
                    int totalDonations = currSponsor.totalDonations;
                    float ratio = donationsFromSponsor/totalDonations;
                    bubbleChart.bubbles[i].drawPartialBubble(ratio);
                }
            }
        } else if(selectedNode == "SCHOOL"){
            for (int i = 0; i < bubbleChart.bubbles.length; i++) {
                bubbleChart.bubbles[i].drawPartialBubble(1.0);
            }
        } else {
             println("Can't find the selected node in either the dept or disc hashmaps.  SelectedNode is:" + selectedNode);
        }
    }
}