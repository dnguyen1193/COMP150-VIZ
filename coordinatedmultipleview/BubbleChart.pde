class BubbleChart {
    Bubble[] bubbles;
    float minBubbleRadius = 10.0;
    float donationToRadiusRatio;
    
    BubbleChart() {}
    
    void initializeData() {
        float minDonation = getMinSponsorDonation();
      /* Area of a circle = PI(r^2), r = sqrt(area/PI); we're setting area of the bubble = sqrt(the donation) */
        float minRad = (float)Math.sqrt(Math.sqrt(minDonation)/PI);
        donationToRadiusRatio = minBubbleRadius/minRad;
      
        int numSponsors = controller.sponsorList.size();
        bubbles = new Bubble[numSponsors];
      
        Set set = controller.sponsorList.entrySet();
        Iterator iterator = set.iterator();
        int pos = 0;
      
        while(iterator.hasNext()) {
            Map.Entry entry = (Map.Entry)iterator.next();
            Sponsor _sponsor = (Sponsor)entry.getValue();
            float sponsorDonation = _sponsor.totalDonations;
            float donationRadius = (float)Math.sqrt(Math.sqrt(sponsorDonation)/PI);
            float bubbleRadius = donationRadius * donationToRadiusRatio;
            bubbles[pos++] = new Bubble(entry.getKey().toString(), (int)sponsorDonation, 
                  random(width/2, width), random(0, height/2),  bubbleRadius);
            
        }
    }
    
    float getMinSponsorDonation() {
        float minDonation = 0;
        Set set = controller.sponsorList.entrySet();
        Iterator iterator = set.iterator();
        float sponsorDonation = 0;
        while(iterator.hasNext()){
            Map.Entry entry = (Map.Entry)iterator.next();
            Sponsor _sponsor = (Sponsor)entry.getValue();
            sponsorDonation = _sponsor.totalDonations;
            // minDonation == 0 means that we're checking the first element - set minDonation to be whatever the first element is, initially
            if (minDonation == 0) {
                minDonation = sponsorDonation;
            }
            if (sponsorDonation < minDonation) {
                minDonation = sponsorDonation;
            }
        }
        
        return minDonation;
    }
    
    // gets donation amount for the year that had the least amount of donations
    float getMinYearDonation() {
        float minDonation = 0;
        Set set = controller.donationsByYear.entrySet();
        Iterator iterator = set.iterator();
        float totalFunding = 0;
        while(iterator.hasNext()){
            Map.Entry entry = (Map.Entry)iterator.next();
            int year = (int)entry.getKey();
            totalFunding = controller.getTotalFundingByYear(year);
            // minDonation == 0 means that we're checking the first element - set minDonation to be whatever the first element is, initially
            if (minDonation == 0) {
                minDonation = totalFunding;
            }
            if (totalFunding < minDonation) {
                minDonation = totalFunding;
            }
        }
        
        return minDonation;
    }
    
    void drawBubbleChart() {
        // draw bubbles
        for (int i = 0; i < bubbles.length; i++) {
            if(bubbles[i] != null){          
                bubbles[i].display();
             
                // run a hit test on all other bubbles
                for (int n = 0; n < bubbles.length; n++) {
                    if (n != i) {
                        bubbles[i].collisionTest(bubbles[n]);
                    }
                }
            }
        }
   
        // check for mouse over
        for (int i = 0; i < bubbles.length; i++) {
            if(bubbles[i] !=null){
                bubbles[i].onMouseOver(mouseX, mouseY);
            }
        } 
    }
};