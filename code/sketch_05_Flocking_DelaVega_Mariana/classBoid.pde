
/* REFERENCES: 
Align, separation and cohesion methods based on:
  Video Series Chapter 6: Autonomous Agents - The Nature of Code --> https://www.youtube.com/watch?v=JIz2L4tn5kM&list=PLRqwX-V7Uu6YHt0dtyf4uiw8tKOxQLvlW
  Video Series Flocking AI from Nathan Biefeld --> https://www.youtube.com/watch?v=RI2mViPlJzc
  Article "Steering Behaviors For Autonomous Characters" by Craig W. Reynolds  --> http://www.red3d.com/cwr/steer/gdc99/
*/
  

class Boid {

  PVector pos;
  PVector vel;
  PVector acc;
  int l = 5;            // length of triangle's side
  ArrayList<Boid> neighbors = new ArrayList<Boid>();
  ArrayList<Enemy> enemyNeighbors = new ArrayList<Enemy>();
  PVector a = new PVector();
  PVector c = new PVector();
  PVector s = new PVector();
  PVector se = new PVector();
  PVector leader = new PVector();
  int[] coloresClaros = new int[3];
  float weightEnemies = 5;
  int separationDistanceEnemies = 130;
  boolean isLeader = false;
  boolean night;

  Boid() {
    this.pos = new PVector(random(width), random(height));
    this.vel = PVector.random2D();      // to have an initial value
    this.vel.setMag(random(2, 4));      // set initial velocity
    this.acc = new PVector();          // set to 0
    for (int i=0; i<2; i++) coloresClaros[i] = (int)random(10, 245);
  }

  Boid(float x, float y) {                  // when a boid is added manually
    this.pos = new PVector(x, y);
    this.vel = PVector.random2D();      // to have an initial value
    this.vel.setMag(random(2, 4));      // set initial velocity
    this.acc = new PVector();          // set to 0
    for (int i=0; i<2; i++) coloresClaros[i] = (int)random(10, 245);
  }

  void sense (ArrayList<Boid> all, ArrayList<Enemy> enemies) {      // receives the entire flock  -->  sense its neighbors

    float d;
    neighbors.clear();
    enemyNeighbors.clear();

    for (Boid next : all) {
      d = dist(this.pos.x, this.pos.y, next.pos.x, next.pos.y);
      if (next!=this && d<perceptionRadius.getValueF()) {      // if it's not the actual boid and it's within the radius

        neighbors.add(next);
      }
    }

    for (Enemy next : enemies) {
      d = dist(this.pos.x, this.pos.y, next.pos.x, next.pos.y);
      if (d<perceptionRadius.getValueF()) {      // if it's within the radius

        enemyNeighbors.add(next);
      }
    }
  }

  void decide (ArrayList<Enemy> enemies, ArrayList<Boid> all, boolean leaderOn) {    // does the three methods --> cohesion, separation and alignment

    a = this.align();
    c = this.cohesion();
    s = this.separation();
    se = this.separationEnemies();
    if (leaderOn && !isLeader) leader = this.followLeader(all);
  }

  void act(boolean leaderOn) {      // uses three vectors and multiplies by weight

    a.mult(alignWeight.getValueF());                // assign weight to vectors
    c.mult(alignWeight.getValueF());
    s.mult(alignWeight.getValueF());
    weightEnemies = max(alignWeight.getValueF(), alignWeight.getValueF(), alignWeight.getValueF());
    if (weightEnemies > 0) se.mult(weightEnemies+3);
    else se.mult(3);
    if (leaderOn && !isLeader) leader.mult(weightEnemies);

    this.acc.add(a);                                // add to the acceleration --> acceleration = sum of forces
    this.acc.add(c);
    this.acc.add(s);
    this.acc.add(se);
    if (leaderOn && !isLeader) this.acc.add(leader);
  }

  void resetVector () {                      // updates position

    this.pos.add(this.vel);                    // sets position to the actual velocity
    this.vel.add(this.acc);                    // updates velocity with the acceleration that has the sum of forces
    this.vel.limit(maxS.getValueF());        // limits the final vector to maxSpeed, not only the individual vectors in the other methods
    this.acc.mult(0);                     // every update, it will set acc to 0
  }

  void drawBoid () {

    if (isLeader && night) fill(255, 255, 255);
    else if (isLeader && !night) fill(0, 0, 0);
    else fill(this.coloresClaros[0], this.coloresClaros[1], this.coloresClaros[2]);

    pushMatrix();
    translate(this.pos.x, this.pos.y);                            // moves the grid instead of each element
    rotate((float)this.vel.heading() + radians(90));              // gets the angle from the vel vector and rotates the grid --> adds 90 radians to set it clockwise
    beginShape(TRIANGLES);
    vertex(0, -l*2);
    vertex(-l, l*2);
    vertex(l, l*2);
    endShape();
    popMatrix();
  }

  void update (ArrayList<Boid> all, ArrayList<Enemy> enemies, boolean n, boolean leaderOn) {

    night = n;
    this.validateScreen();
    this.sense(all, enemies);
    this.decide(enemies, all, leaderOn);
    this.act(leaderOn);
    this.resetVector();
  }

  PVector followLeader(ArrayList<Boid> all) {

    PVector res = new PVector();
    for (Boid item : neighbors) { 
      if (item.isLeader) {
        res = PVector.sub(item.pos,this.pos);
        res.normalize();
        res.mult(maxS.getValueF());
        res.sub(this.vel);
        res.limit(maxF.getValueF());
      }
    }
    return res;
  }


  PVector align () {    // uses only neighbors --> returns the final vector 

    PVector res = new PVector();     // if it doesn't change, it will return a vector of 0
    int cont = 0;

    for (Boid next : neighbors) {

      res.add(next.vel);
      cont++;
    }

    if (cont > 0) {                      // for it not to divide by 0 and cause indetermination

      res.div(cont);          // get the average
      res.normalize();          // normalizes to set length to 1
      res.mult(maxS.getValueF());        // then sets length to maxSpeed --> we only care about direction and everything can have maxSpeed
      res.sub(this.vel);                // formula of steering: desired - actualVelocity
      res.limit(maxF.getValueF());         // don't let it go beyond our limit of force
    }

    return res;
  }

  PVector separation () {            // only uses neighbors

    PVector res = new PVector();     // if it doesn't change, it will return a vector of 0
    int cont = 0;

    for (Boid next : neighbors) {     // substracts the position of the other boid with the actual boid and then calculates the average of that final position 
      float d = dist(this.pos.x, this.pos.y, next.pos.x, next.pos.y);
      if (d<separationDistance.getValueF()) {

        PVector minus = PVector.sub(this.pos, next.pos);
        minus.normalize();          // normalizes to set length to 1
        minus.div( d );             // to make it proportional to the distance the other boid is from the actual boid     
        res.add(minus);
        cont++;
      }
    }

    if (cont > 0) {

      res.div(cont);            // calculates average
      res.normalize();                // normalizes to set length to 1
      res.mult(maxS.getValueF());      // then sets length to maxSpeed --> we only care about direction and everything can have maxSpeed
      res.sub(this.vel);               // formula of steering: desired - actualVelocity
      res.limit(maxF.getValueF());
    }

    return res;
  }

  PVector separationEnemies () {            // only uses neighbors

    PVector res = new PVector();     // if it doesn't change, it will return a vector of 0
    int cont = 0;

    for (Enemy next : enemyNeighbors) {     // substracts the position of the other boid with the actual boid and then calculates the average of that final position 
      float d = dist(this.pos.x, this.pos.y, next.pos.x, next.pos.y);
      if (d<separationDistanceEnemies) {

        PVector minus = PVector.sub(this.pos, next.pos);
        minus.normalize();
        minus.div( d );            
        res.add(minus);
        cont++;
      }
    }

    if (cont > 0) {

      res.div(cont);            // calculates average
      res.normalize();
      res.mult(maxS.getValueF());
      res.sub(this.vel);
      res.limit(maxF.getValueF());
    }

    return res;
  }


  PVector cohesion () {

    PVector res = new PVector();     // if it doesn't change, it will return a vector of 0
    int cont = 0;

    for (Boid next : neighbors) {     // substracts the position of the other boid with the actual boid and then calculates the average of that final position 

      res.add(next.pos);
      cont++;
    }

    if (cont > 0) {

      res.div(cont);            // calculates average
      res.sub(this.pos);
      res.normalize();
      res.mult(maxS.getValueF());
      res.sub(this.vel);
      res.limit(maxF.getValueF());
    }

    return res;
  }


  void validateScreen() {        // moves boids if they're in the limits

    if (this.pos.x>width) this.pos.x = 0;
    else if (this.pos.x<0) this.pos.x = width;
    if (this.pos.y>height-40) this.pos.y = 0;
    else if (this.pos.y<0) this.pos.y = height-40;
  }

  void setLeader(boolean b) {
    isLeader = b;
  }

  void setLength(int n) {
    l = n;
  }
}