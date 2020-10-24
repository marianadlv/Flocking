class Enemy {

  PVector pos;
  int colores;
  float radius;
  
  Enemy() {
  
    radius = 20;
    colores = (int)random(100,220);
    this.pos = new PVector(random(radius*2+1,width-(radius*2)-1), random(radius*2+1,height-(radius*4)-1));
    
    //for (Enemy e: enemies) {
    //  if (this.pos == e.pos) this.pos = new PVector(random(radius*2+1,width-(radius*2)-1), random(radius*2+1,height-(radius*4)-1));
    //}

  }
  
  Enemy(float x, float y) {
  
    radius = 20;
    colores = (int)random(100,220);
    this.pos = new PVector(x,y);
    
    //for (Enemy e: enemies) {
    //  if (this.pos == e.pos) this.pos = new PVector(random(radius*2+1,width-(radius*2)-1), random(radius*2+1,height-(radius*4)-1));
    //}

  }
  
  void drawEnemy() {
  
    fill(colores,0,0);
    
    pushMatrix();
    translate(this.pos.x, this.pos.y);                            // moves the grid instead of each element
    ellipse(0,0,radius*2,radius*2);
    popMatrix();
  
  }
  
  

}