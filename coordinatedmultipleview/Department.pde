class Department {
    String name;
    Discipline parentDiscipline;
    int totalFunding;
    
    HashMap<String, Sponsor> sponsors = new HashMap<String, Sponsor>();
    ArrayList<String> sponsorNames = new ArrayList<String>();
  
    Department(String name, Discipline discipline) {
        this.name = name;
        this.parentDiscipline = discipline;
    }
    
    int addFunding(int funding) {
        return this.totalFunding += funding;
    }
    
    // Only adds the sponsor if it hasn't already been added
    // Adds it to the sponsors hashMap & sponsorNames list
    void addSponsor(Sponsor sponsor) {
        // Only add sponsor if it doesn't already exist
        Sponsor mySponsor = this.sponsors.get(sponsor.name);
        if(mySponsor == null){
            this.sponsors.put(sponsor.name, sponsor);
            this.sponsorNames.add(sponsor.name);
        }
    }
  
}