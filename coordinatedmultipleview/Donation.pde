class Donation {
    Sponsor from;
    Department to;
    Discipline discipline;
    int year;
    int donation;
    
    Donation(Sponsor from, Department to, Discipline discipline, int year, int donation){
        this.from = from;
        this.discipline = discipline;
        this.to = to;
        this.year = year;
        this.donation = donation;
    }
  
}