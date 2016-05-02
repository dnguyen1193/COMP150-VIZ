class Sponsor {
    String name;
    int totalDonations;
    
    HashMap<String, Department> departmentsSponsored = new HashMap<String, Department>(); // Lists how many departments it sponsored
    HashMap<String, Integer> donationsToDiscipline = new HashMap<String, Integer>();  // Lists the disciplines it sponsored and how much it donated
    HashMap<String, ArrayList<Donation>> donations = new HashMap<String, ArrayList<Donation>>(); // Lists all the donations to a particular department
    HashMap<Integer, Integer> numDonationsPerYear = new HashMap<Integer, Integer>();  //# of donations in a year
    HashMap<Integer, Integer> totalDonationPerYear = new HashMap<Integer, Integer>(); // total amount donated per year
  
    Sponsor(String name){
        this.name = name;
    }
    
    // Adds this donation to the list of donations by department.  
    // Updates the total amount donated per year
    // Updates the # of donations a sponsor gave in a year
    void addDonation(Donation _donation){
        updateDonationsList(_donation);
        updateDonationsPerYear(_donation);
        updateDonationsToDiscipline(_donation);
        this.incrementDonationsInYear(_donation.year);
    }
    
    // given a department name returns how much was donated to it.
    float getDepartmentDonation(String departmentName){
        float total = 0.0;
        Donation _donation;
        ArrayList<Donation> deptDonations = (ArrayList<Donation> )donations.get(departmentName);
        
        // We only keep track of money donated to departments not disciplines.  So if we're given 
        // a discipline string it may be null since we're only keeping track of department donations
        if(deptDonations !=null){
            // add up all the donations made to a particular department
            for(int i=0; i < deptDonations.size(); i++){
                 _donation = deptDonations.get(i);
                 total += _donation.donation;
            }
        }
        return total;
    }
    
    // Updates the # of donations a sponsor gave in a year
    int incrementDonationsInYear(int year) {
        int numDonations = 0;
        if(this.numDonationsPerYear.get(year) != null) {
            numDonations = (Integer)this.numDonationsPerYear.get(year);
        }
        // increment number of donations for that year and update the hashmap
        numDonations++;
        this.numDonationsPerYear.put(year, numDonations);
        
        return numDonations;
    }
    
    // Add this donation to a list of donations by department
    void updateDonationsList(Donation _donation){
        Department dept = _donation.to;
        ArrayList<Donation> tmpDonations = (ArrayList<Donation>) this.donations.get(dept.name);
        if(tmpDonations == null){
            tmpDonations = new ArrayList<Donation>();
        }
        tmpDonations.add(_donation);
        this.donations.put(dept.name, tmpDonations);
    }
    
    void updateDonationsToDiscipline(Donation _donation){
       String disciplineName = _donation.discipline.name;
       int amount = 0;
        if(this.donationsToDiscipline.get(disciplineName) != null){
            amount = this.donationsToDiscipline.get(disciplineName);
        }
        amount += _donation.donation;
        this.donationsToDiscipline.put(disciplineName, amount); 
    }
    
    // Updates the total amount donated per year
    void updateDonationsPerYear(Donation _donation){
        int amntPerYear = 0;
        if(this.totalDonationPerYear.get(_donation.year) != null){
            amntPerYear = this.totalDonationPerYear.get(_donation.year);
        }
        amntPerYear += _donation.donation;
        this.totalDonationPerYear.put(_donation.year, amntPerYear);
    }
    
    void printAmountPerYear(){
        Set set = totalDonationPerYear.entrySet();
        Iterator iterator = set.iterator();
        println("Sponsor: " + this.name + " totalAmountGiven: " + this.totalDonations);
        while(iterator.hasNext()){
            Map.Entry entry = (Map.Entry)iterator.next();
            Integer amount = (Integer)entry.getValue();
            println("Year: " + entry.getKey() + " Amount: " + amount);
        }
    }
}