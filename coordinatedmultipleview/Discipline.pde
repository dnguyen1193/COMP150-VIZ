class Discipline {
    String name;
    int totalFunding;
    
    HashMap<String, Department> departments = new HashMap<String, Department>();
    ArrayList<String> departmentNames = new ArrayList<String>();
    
    HashMap<String, Sponsor> sponsors = new HashMap<String, Sponsor>();
    ArrayList<String> sponsorNames = new ArrayList<String>();
     
    Discipline(String discipline){
        this.name = discipline;
    }
    
    // Adds a child department to this discipline
    // Only adds it if it hasn't been added before
    void addDepartment(Department dept){
        Department myDepartment = this.departments.get(dept.name);
        if(myDepartment == null){
            this.departments.put(dept.name, dept);
            this.departmentNames.add(dept.name);   
        }
    }
    
    int addFunding(int funding){
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